Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 139828E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 09:26:17 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id e3-v6so14190505qkj.17
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 06:26:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e186-v6sor4832599qkb.0.2018.09.17.06.26.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Sep 2018 06:26:15 -0700 (PDT)
Date: Mon, 17 Sep 2018 09:26:07 -0400
From: Masayoshi Mizuma <msys.mizuma@gmail.com>
Subject: Re: [PATCH 2/2] mm: zero remaining unavailable struct pages
Message-ID: <20180917132605.eln6tlc6hf7vfjy2@gabell>
References: <20180823182513.8801-1-msys.mizuma@gmail.com>
 <20180823182513.8801-2-msys.mizuma@gmail.com>
 <7c773dec-ded0-7a1e-b3ad-6c6826851015@microsoft.com>
 <484388a7-1e75-0782-fdfb-20345e1bda0d@gmail.com>
 <20180831025536.GA29753@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180831025536.GA29753@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Pavel.Tatashin@microsoft.com" <Pavel.Tatashin@microsoft.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>

On Fri, Aug 31, 2018 at 02:55:36AM +0000, Naoya Horiguchi wrote:
> On Wed, Aug 29, 2018 at 11:16:30AM -0400, Masayoshi Mizuma wrote:
> > Hi Horiguchi-san and Pavel
> > 
> > Thank you for your comments!
> > The Pavel's additional patch looks good to me, so I will add it to this series.
> > 
> > However, unfortunately, the movable_node option has something wrong yet...
> > When I offline the memory which belongs to movable zone, I got the following
> > warning. I'm trying to debug it.
> > 
> > I try to describe the issue as following. 
> > If you have any comments, please let me know.
> > 
> > WARNING: CPU: 156 PID: 25611 at mm/page_alloc.c:7730 has_unmovable_pages+0x1bf/0x200
> > RIP: 0010:has_unmovable_pages+0x1bf/0x200
> > ...
> > Call Trace:
> >  is_mem_section_removable+0xd3/0x160
> >  show_mem_removable+0x8e/0xb0
> >  dev_attr_show+0x1c/0x50
> >  sysfs_kf_seq_show+0xb3/0x110
> >  seq_read+0xee/0x480
> >  __vfs_read+0x36/0x190
> >  vfs_read+0x89/0x130
> >  ksys_read+0x52/0xc0
> >  do_syscall_64+0x5b/0x180
> >  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> > RIP: 0033:0x7fe7b7823f70
> > ...
> > 
> > I added a printk to catch the unmovable page.
> > ---
> > @@ -7713,8 +7719,12 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
> >                  * is set to both of a memory hole page and a _used_ kernel
> >                  * page at boot.
> >                  */
> > -               if (found > count)
> > +               if (found > count) {
> > +                       pr_info("DEBUG: %s zone: %lx page: %lx pfn: %lx flags: %lx found: %ld count: %ld \n",
> > +                               __func__, zone, page, page_to_pfn(page), page->flags, found, count);
> >                         goto unmovable;
> > +               }
> > ---
> > 
> > Then I got the following. The page (PFN: 0x1c0ff130d) flag is 
> > 0xdfffffc0040048 (uptodate|active|swapbacked)
> > 
> > ---
> > DEBUG: has_unmovable_pages zone: 0xffff8c0ffff80380 page: 0xffffea703fc4c340 pfn: 0x1c0ff130d flags: 0xdfffffc0040048 found: 1 count: 0 
> > ---
> > 
> > And I got the owner from /sys/kernel/debug/page_owner.
> > 
> > Page allocated via order 0, mask 0x6280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
> > PFN 7532909325 type Movable Block 14712713 type Movable Flags 0xdfffffc0040048(uptodate|active|swapbacked)
> >  __alloc_pages_nodemask+0xfc/0x270
> >  alloc_pages_vma+0x7c/0x1e0
> >  handle_pte_fault+0x399/0xe50
> >  __handle_mm_fault+0x38e/0x520
> >  handle_mm_fault+0xdc/0x210
> >  __do_page_fault+0x243/0x4c0
> >  do_page_fault+0x31/0x130
> >  page_fault+0x1e/0x30
> > 
> > The page is allocated as anonymous page via page fault.
> > I'm not sure, but lru flag should be added to the page...?
> 
> There is a small window of no PageLRU flag just after page allocation
> until the page is linked to some LRU list.
> This kind of unmovability is transient, so retrying can work.
> 
> I guess that this warning seems to be visible since commit 15c30bc09085
> ("mm, memory_hotplug: make has_unmovable_pages more robust")
> which turned off the optimization based on the assumption that pages
> under ZONE_MOVABLE are always movable.
> I think that it helps developers find the issue that permanently
> unmovable pages are accidentally located in ZONE_MOVABLE zone.
> But even ZONE_MOVABLE zone could have transiently unmovable pages,
> so the reported warning seems to me a false charge and should be avoided.
> Doing lru_add_drain_all()/drain_all_pages() before has_unmovable_pages()
> might be helpful?

Thanks you for your proposal! And sorry for delayed responce.

lru_add_drain_all()/drain_all_pages() might be helpful, but it 
seems that the window is not very small because I tried to do
offline some times, and every offline failed...

I have another idea. I found that if the page is belonged to
Movable zone and it has Uptodate flag, the page will go lru
soon, so I think we can pass the page.
Does the idea make sence? As far as I tested it, it works well.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 52d9efe8c9fb..ecf87bec8ac6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7758,6 +7758,9 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
                if (__PageMovable(page))
                        continue;

+               if ((zone_idx(zone) == ZONE_MOVABLE) && PageUptodate(page))
+                       continue;
+
                if (!PageLRU(page))
                        found++;
                /*

Thanks,
Masa
