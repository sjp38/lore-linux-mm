Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C17D06B51D0
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 12:19:56 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g29-v6so3881077edb.1
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 09:19:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k4-v6si749245edr.290.2018.08.30.09.19.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 09:19:55 -0700 (PDT)
Date: Thu, 30 Aug 2018 18:19:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 1/2] mm: migration: fix migration of huge PMD shared
 pages
Message-ID: <20180830161800.GJ2656@dhcp22.suse.cz>
References: <20180824084157.GD29735@dhcp22.suse.cz>
 <6063f215-a5c8-2f0c-465a-2c515ddc952d@oracle.com>
 <20180827074645.GB21556@dhcp22.suse.cz>
 <20180827134633.GB3930@redhat.com>
 <9209043d-3240-105b-72a3-b4cd30f1b1f1@oracle.com>
 <20180829181424.GB3784@redhat.com>
 <20180829183906.GF10223@dhcp22.suse.cz>
 <20180829211106.GC3784@redhat.com>
 <20180830105616.GD2656@dhcp22.suse.cz>
 <20180830140825.GA3529@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180830140825.GA3529@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, linux-rdma@vger.kernel.org, Matan Barak <matanb@mellanox.com>, Leon Romanovsky <leonro@mellanox.com>, Dimitri Sivanich <sivanich@sgi.com>

On Thu 30-08-18 10:08:25, Jerome Glisse wrote:
> On Thu, Aug 30, 2018 at 12:56:16PM +0200, Michal Hocko wrote:
> > On Wed 29-08-18 17:11:07, Jerome Glisse wrote:
> > > On Wed, Aug 29, 2018 at 08:39:06PM +0200, Michal Hocko wrote:
> > > > On Wed 29-08-18 14:14:25, Jerome Glisse wrote:
> > > > > On Wed, Aug 29, 2018 at 10:24:44AM -0700, Mike Kravetz wrote:
> > > > [...]
> > > > > > What would be the best mmu notifier interface to use where there are no
> > > > > > start/end calls?
> > > > > > Or, is the best solution to add the start/end calls as is done in later
> > > > > > versions of the code?  If that is the suggestion, has there been any change
> > > > > > in invalidate start/end semantics that we should take into account?
> > > > > 
> > > > > start/end would be the one to add, 4.4 seems broken in respect to THP
> > > > > and mmu notification. Another solution is to fix user of mmu notifier,
> > > > > they were only a handful back then. For instance properly adjust the
> > > > > address to match first address covered by pmd or pud and passing down
> > > > > correct page size to mmu_notifier_invalidate_page() would allow to fix
> > > > > this easily.
> > > > > 
> > > > > This is ok because user of try_to_unmap_one() replace the pte/pmd/pud
> > > > > with an invalid one (either poison, migration or swap) inside the
> > > > > function. So anyone racing would synchronize on those special entry
> > > > > hence why it is fine to delay mmu_notifier_invalidate_page() to after
> > > > > dropping the page table lock.
> > > > > 
> > > > > Adding start/end might the solution with less code churn as you would
> > > > > only need to change try_to_unmap_one().
> > > > 
> > > > What about dependencies? 369ea8242c0fb sounds like it needs work for all
> > > > notifiers need to be updated as well.
> > > 
> > > This commit remove mmu_notifier_invalidate_page() hence why everything
> > > need to be updated. But in 4.4 you can get away with just adding start/
> > > end and keep around mmu_notifier_invalidate_page() to minimize disruption.
> > 
> > OK, this is really interesting. I was really worried to change the
> > semantic of the mmu notifiers in stable kernels because this is really
> > a hard to review change and high risk for anybody running those old
> > kernels. If we can keep the mmu_notifier_invalidate_page and wrap them
> > into the range scope API then this sounds like the best way forward.
> > 
> > So just to make sure we are at the same page. Does this sounds goo for
> > stable 4.4. backport? Mike's hugetlb pmd shared fixup can be applied on
> > top. What do you think?
> 
> You need to invalidate outside page table lock so before the call to
> page_check_address(). For instance like below patch, which also only
> do the range invalidation for huge page which would avoid too much of
> a behavior change for user of mmu notifier.

Right. I would rather not make this PageHuge special though. So the
fixed version should be.
