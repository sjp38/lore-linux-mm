Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 30EF36B4DBA
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 17:11:11 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id e3-v6so5545940qkj.17
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 14:11:11 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t74-v6si2666693qki.111.2018.08.29.14.11.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Aug 2018 14:11:10 -0700 (PDT)
Date: Wed, 29 Aug 2018 17:11:07 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v6 1/2] mm: migration: fix migration of huge PMD shared
 pages
Message-ID: <20180829211106.GC3784@redhat.com>
References: <20180823205917.16297-1-mike.kravetz@oracle.com>
 <20180823205917.16297-2-mike.kravetz@oracle.com>
 <20180824084157.GD29735@dhcp22.suse.cz>
 <6063f215-a5c8-2f0c-465a-2c515ddc952d@oracle.com>
 <20180827074645.GB21556@dhcp22.suse.cz>
 <20180827134633.GB3930@redhat.com>
 <9209043d-3240-105b-72a3-b4cd30f1b1f1@oracle.com>
 <20180829181424.GB3784@redhat.com>
 <20180829183906.GF10223@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180829183906.GF10223@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, linux-rdma@vger.kernel.org, Matan Barak <matanb@mellanox.com>, Leon Romanovsky <leonro@mellanox.com>, Dimitri Sivanich <sivanich@sgi.com>

On Wed, Aug 29, 2018 at 08:39:06PM +0200, Michal Hocko wrote:
> On Wed 29-08-18 14:14:25, Jerome Glisse wrote:
> > On Wed, Aug 29, 2018 at 10:24:44AM -0700, Mike Kravetz wrote:
> [...]
> > > What would be the best mmu notifier interface to use where there are no
> > > start/end calls?
> > > Or, is the best solution to add the start/end calls as is done in later
> > > versions of the code?  If that is the suggestion, has there been any change
> > > in invalidate start/end semantics that we should take into account?
> > 
> > start/end would be the one to add, 4.4 seems broken in respect to THP
> > and mmu notification. Another solution is to fix user of mmu notifier,
> > they were only a handful back then. For instance properly adjust the
> > address to match first address covered by pmd or pud and passing down
> > correct page size to mmu_notifier_invalidate_page() would allow to fix
> > this easily.
> > 
> > This is ok because user of try_to_unmap_one() replace the pte/pmd/pud
> > with an invalid one (either poison, migration or swap) inside the
> > function. So anyone racing would synchronize on those special entry
> > hence why it is fine to delay mmu_notifier_invalidate_page() to after
> > dropping the page table lock.
> > 
> > Adding start/end might the solution with less code churn as you would
> > only need to change try_to_unmap_one().
> 
> What about dependencies? 369ea8242c0fb sounds like it needs work for all
> notifiers need to be updated as well.

This commit remove mmu_notifier_invalidate_page() hence why everything
need to be updated. But in 4.4 you can get away with just adding start/
end and keep around mmu_notifier_invalidate_page() to minimize disruption.

So the new semantic in 369ea8242c0fb is that all page table changes are
bracketed with mmu notifier start/end calls and invalidate_range right
after tlb flush. This simplify thing and make it more reliable for mmu
notifier users like IOMMU or ODP or GPUs drivers.


> Anyway, I am wondering why we haven't see any bugs coming from
> incomplete range invalidation. How would those exhibit?

Reading back the 4.4 code try_to_unmap() can only be call against a
huge tlb page and only when migrating one ie through migrate_pages()
So this highly limit the cases where issues would happen. I believe
no one use hugetlb fs has backing for guest memory so xen and kvm
would never face such case.

So what is left is ODP, i915, radeon, amd gpu, SGI and IOMMU drivers.

The IOMMU drivers are never use that way AFAICT in 4.4 their was no
drivers upstream for a PCIE device that would support ATS/PASID and
thus the notifier path would never be use. Back then the only device
was AMD APU AFAIK which were never really use with that features
due to lack of mature userspace to use this.

For i915,radeon and amd GPU we would never see this either as the
mmu notifier is only use for uptr GEM object which are only use
to upload texture with either anonymous vma or file back vma. I
never heard of an xorg server or ddx or mesa drivers which would
use hugetlb fs.

So the only ones that might have issues AFAICT are ODP and SGI.
I am unsure on how likely either can be use in conjunction with a
hugetlb fs. CCing maintainers for those so they could comment.


The symptoms would either be memory corruption ie RDMA or SGI would
write to the old huge page and not the new one. Or even harder to
spot use of stall/invalid data ie RDMA or SGI are reading from
the old huge page and instead of the new one.

Corruption to hugetlbfs page can likely go unoticed.

Cheers,
Jerome
