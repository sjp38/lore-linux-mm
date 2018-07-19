Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0F8C36B0003
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 03:15:19 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p5-v6so2888913edh.16
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 00:15:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g34-v6si194054edd.226.2018.07.19.00.15.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 00:15:17 -0700 (PDT)
Date: Thu, 19 Jul 2018 09:15:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm: fix race on soft-offlining free huge pages
Message-ID: <20180719071516.GK7193@dhcp22.suse.cz>
References: <1531805552-19547-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1531805552-19547-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180717142743.GJ7193@dhcp22.suse.cz>
 <20180718005528.GA12184@hori1.linux.bs1.fc.nec.co.jp>
 <20180718085032.GS7193@dhcp22.suse.cz>
 <20180719061945.GB22154@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719061945.GB22154@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, "zy.zhengyi@alibaba-inc.com" <zy.zhengyi@alibaba-inc.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu 19-07-18 06:19:45, Naoya Horiguchi wrote:
> On Wed, Jul 18, 2018 at 10:50:32AM +0200, Michal Hocko wrote:
> > On Wed 18-07-18 00:55:29, Naoya Horiguchi wrote:
> > > On Tue, Jul 17, 2018 at 04:27:43PM +0200, Michal Hocko wrote:
> > > > On Tue 17-07-18 14:32:31, Naoya Horiguchi wrote:
> > > > > There's a race condition between soft offline and hugetlb_fault which
> > > > > causes unexpected process killing and/or hugetlb allocation failure.
> > > > >
> > > > > The process killing is caused by the following flow:
> > > > >
> > > > >   CPU 0               CPU 1              CPU 2
> > > > >
> > > > >   soft offline
> > > > >     get_any_page
> > > > >     // find the hugetlb is free
> > > > >                       mmap a hugetlb file
> > > > >                       page fault
> > > > >                         ...
> > > > >                           hugetlb_fault
> > > > >                             hugetlb_no_page
> > > > >                               alloc_huge_page
> > > > >                               // succeed
> > > > >       soft_offline_free_page
> > > > >       // set hwpoison flag
> > > > >                                          mmap the hugetlb file
> > > > >                                          page fault
> > > > >                                            ...
> > > > >                                              hugetlb_fault
> > > > >                                                hugetlb_no_page
> > > > >                                                  find_lock_page
> > > > >                                                    return VM_FAULT_HWPOISON
> > > > >                                            mm_fault_error
> > > > >                                              do_sigbus
> > > > >                                              // kill the process
> > > > >
> > > > >
> > > > > The hugetlb allocation failure comes from the following flow:
> > > > >
> > > > >   CPU 0                          CPU 1
> > > > >
> > > > >                                  mmap a hugetlb file
> > > > >                                  // reserve all free page but don't fault-in
> > > > >   soft offline
> > > > >     get_any_page
> > > > >     // find the hugetlb is free
> > > > >       soft_offline_free_page
> > > > >       // set hwpoison flag
> > > > >         dissolve_free_huge_page
> > > > >         // fail because all free hugepages are reserved
> > > > >                                  page fault
> > > > >                                    ...
> > > > >                                      hugetlb_fault
> > > > >                                        hugetlb_no_page
> > > > >                                          alloc_huge_page
> > > > >                                            ...
> > > > >                                              dequeue_huge_page_node_exact
> > > > >                                              // ignore hwpoisoned hugepage
> > > > >                                              // and finally fail due to no-mem
> > > > >
> > > > > The root cause of this is that current soft-offline code is written
> > > > > based on an assumption that PageHWPoison flag should beset at first to
> > > > > avoid accessing the corrupted data.  This makes sense for memory_failure()
> > > > > or hard offline, but does not for soft offline because soft offline is
> > > > > about corrected (not uncorrected) error and is safe from data lost.
> > > > > This patch changes soft offline semantics where it sets PageHWPoison flag
> > > > > only after containment of the error page completes successfully.
> > > >
> > > > Could you please expand on the worklow here please? The code is really
> > > > hard to grasp. I must be missing something because the thing shouldn't
> > > > be really complicated. Either the page is in the free pool and you just
> > > > remove it from the allocator (with hugetlb asking for a new hugeltb page
> > > > to guaratee reserves) or it is used and you just migrate the content to
> > > > a new page (again with the hugetlb reserves consideration). Why should
> > > > PageHWPoison flag ordering make any relevance?
> > >
> > > (Considering soft offlining free hugepage,)
> > > PageHWPoison is set at first before this patch, which is racy with
> > > hugetlb fault code because it's not protected by hugetlb_lock.
> > >
> > > Originally this was written in the similar manner as hard-offline, where
> > > the race is accepted and a PageHWPoison flag is set as soon as possible.
> > > But actually that's found not necessary/correct because soft offline is
> > > supposed to be less aggressive and failure is OK.
> >
> > OK
> >
> > > So this patch is suggesting to make soft-offline less aggressive by
> > > moving SetPageHWPoison into the lock.
> >
> > I guess I still do not understand why we should even care about the
> > ordering of the HWPoison flag setting. Why cannot we simply have the
> > following code flow? Or maybe we are doing that already I just do not
> > follow the code
> >
> > 	soft_offline
> > 	  check page_count
> > 	    - free - normal page - remove from the allocator
> > 	           - hugetlb - allocate a new hugetlb page && remove from the pool
> > 	    - used - migrate to a new page && never release the old one
> >
> > Why do we even need HWPoison flag here? Everything can be completely
> > transparent to the application. It shouldn't fail from what I
> > understood.
> 
> PageHWPoison flag is used to the 'remove from the allocator' part
> which is like below:
> 
>   static inline
>   struct page *rmqueue(
>           ...
>           do {
>                   page = NULL;
>                   if (alloc_flags & ALLOC_HARDER) {
>                           page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
>                           if (page)
>                                   trace_mm_page_alloc_zone_locked(page, order, migratetype);
>                   }
>                   if (!page)
>                           page = __rmqueue(zone, order, migratetype);
>           } while (page && check_new_pages(page, order));
> 
> check_new_pages() returns true if the page taken from free list has
> a hwpoison page so that the allocator iterates another round to get
> another page.
> 
> There's no function that can be called from outside allocator to remove
> a page in allocator.  So actual page removal is done at allocation time,
> not at error handling time. That's the reason why we need PageHWPoison.

hwpoison is an internal mm functionality so why cannot we simply add a
function that would do that? I find the PageHWPoison usage here doing
more complications than real good. Or am I missing something?
-- 
Michal Hocko
SUSE Labs
