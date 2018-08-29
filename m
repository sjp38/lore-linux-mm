Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 649756B4D20
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 14:39:10 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x24-v6so2627196edm.13
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 11:39:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q34-v6si4295441edq.412.2018.08.29.11.39.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Aug 2018 11:39:09 -0700 (PDT)
Date: Wed, 29 Aug 2018 20:39:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 1/2] mm: migration: fix migration of huge PMD shared
 pages
Message-ID: <20180829183906.GF10223@dhcp22.suse.cz>
References: <20180823205917.16297-1-mike.kravetz@oracle.com>
 <20180823205917.16297-2-mike.kravetz@oracle.com>
 <20180824084157.GD29735@dhcp22.suse.cz>
 <6063f215-a5c8-2f0c-465a-2c515ddc952d@oracle.com>
 <20180827074645.GB21556@dhcp22.suse.cz>
 <20180827134633.GB3930@redhat.com>
 <9209043d-3240-105b-72a3-b4cd30f1b1f1@oracle.com>
 <20180829181424.GB3784@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180829181424.GB3784@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Wed 29-08-18 14:14:25, Jerome Glisse wrote:
> On Wed, Aug 29, 2018 at 10:24:44AM -0700, Mike Kravetz wrote:
[...]
> > What would be the best mmu notifier interface to use where there are no
> > start/end calls?
> > Or, is the best solution to add the start/end calls as is done in later
> > versions of the code?  If that is the suggestion, has there been any change
> > in invalidate start/end semantics that we should take into account?
> 
> start/end would be the one to add, 4.4 seems broken in respect to THP
> and mmu notification. Another solution is to fix user of mmu notifier,
> they were only a handful back then. For instance properly adjust the
> address to match first address covered by pmd or pud and passing down
> correct page size to mmu_notifier_invalidate_page() would allow to fix
> this easily.
> 
> This is ok because user of try_to_unmap_one() replace the pte/pmd/pud
> with an invalid one (either poison, migration or swap) inside the
> function. So anyone racing would synchronize on those special entry
> hence why it is fine to delay mmu_notifier_invalidate_page() to after
> dropping the page table lock.
> 
> Adding start/end might the solution with less code churn as you would
> only need to change try_to_unmap_one().

What about dependencies? 369ea8242c0fb sounds like it needs work for all
notifiers need to be updated as well.

Anyway, I am wondering why we haven't see any bugs coming from
incomplete range invalidation. How would those exhibit?
-- 
Michal Hocko
SUSE Labs
