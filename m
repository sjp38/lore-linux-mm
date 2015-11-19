Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 700086B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 01:58:31 -0500 (EST)
Received: by wmec201 with SMTP id c201so10344393wme.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 22:58:31 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id pu5si9434955wjc.50.2015.11.18.22.58.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 22:58:30 -0800 (PST)
Received: by wmdw130 with SMTP id w130so227521166wmd.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 22:58:30 -0800 (PST)
Date: Thu, 19 Nov 2015 08:58:27 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: kernel oops on mmotm-2015-10-15-15-20
Message-ID: <20151119065827.GA26601@node.shutemov.name>
References: <20151105001922.GD7357@bbox>
 <20151108225522.GA29600@node.shutemov.name>
 <20151112003614.GA5235@bbox>
 <20151116014521.GA7973@bbox>
 <20151116084522.GA9778@node.shutemov.name>
 <20151116103220.GA32578@bbox>
 <20151116105452.GA10575@node.shutemov.name>
 <20151117073539.GB32578@bbox>
 <20151117093213.GA16243@node.shutemov.name>
 <20151119021221.GA15540@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151119021221.GA15540@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Nov 19, 2015 at 11:12:21AM +0900, Minchan Kim wrote:
> On Tue, Nov 17, 2015 at 11:32:13AM +0200, Kirill A. Shutemov wrote:
> > On Tue, Nov 17, 2015 at 04:35:39PM +0900, Minchan Kim wrote:
> > > On Mon, Nov 16, 2015 at 12:54:53PM +0200, Kirill A. Shutemov wrote:
> > > > On Mon, Nov 16, 2015 at 07:32:20PM +0900, Minchan Kim wrote:
> > > > > On Mon, Nov 16, 2015 at 10:45:22AM +0200, Kirill A. Shutemov wrote:
> > > > > > On Mon, Nov 16, 2015 at 10:45:21AM +0900, Minchan Kim wrote:
> > > > > > > During the test with MADV_FREE on kernel I applied your patches,
> > > > > > > I couldn't see any problem.
> > > > > > > 
> > > > > > > However, in this round, I did another test which is same one
> > > > > > > I attached but a liitle bit different because it doesn't do
> > > > > > > (memcg things/kill/swapoff) for testing program long-live test.
> > > > > > 
> > > > > > Could you share updated test?
> > > > > 
> > > > > It's part of my testing suite so I should factor it out.
> > > > > I will send it when I go to office tomorrow.
> > > > 
> > > > Thanks.
> > > > 
> > > > > > And could you try to reproduce it on clean mmotm-2015-11-10-15-53?
> > > > > 
> > > > > Befor leaving office, I queued it up and result is below.
> > > > > It seems you fixed already but didn't apply it to mmotm yet. Right?
> > > > > Anyway, please confirm and say to me what I should add more patches
> > > > > into mmotm-2015-11-10-15-53 for follow up your recent many bug
> > > > > fix patches.
> > > > 
> > > > The two my patches which are not in the mmotm-2015-11-10-15-53 release:
> > > > 
> > > > http://lkml.kernel.org/g/1447236557-68682-1-git-send-email-kirill.shutemov@linux.intel.com
> > > > http://lkml.kernel.org/g/1447236567-68751-1-git-send-email-kirill.shutemov@linux.intel.com
> > > 
> > > 1. mm: fix __page_mapcount()
> > > 2. thp: fix leak due split_huge_page() vs. exit race
> > > 
> > > If I missed some patches, let me know it.
> > > 
> > > I applied above two patches based on mmotm-2015-11-10-15-53 and tested again.
> > > But unfortunately, the result was below.
> > > 
> > > Now, I am making test program I can send to you but it seems to be not easy
> > > because small changes for factoring it out from testing suite seems to change
> > > something(ex, timing) and makes hard to reproduce. I will try it again.
> > 
> > Your test suite seems generate quite a few bug reports. Don't mind make whole
> > suite public?
> 
> It's tough due to including company internal stuffs.
> That's why I try to factor the part I can share out but unfortunatel,
> I couldn't grab a time for retrying until now. :(
> 
> >  
> > > page:ffffea0000240080 count:2 mapcount:1 mapping:ffff88007eff3321 index:0x600000e02
> > > flags: 0x4000000000040018(uptodate|dirty|swapbacked)
> > > page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
> > > page->mem_cgroup:ffff880077cf0c00
> > > ------------[ cut here ]------------
> > > kernel BUG at mm/huge_memory.c:3272!
> > > invalid opcode: 0000 [#1] SMP 
> > > Dumping ftrace buffer:
> > >    (ftrace buffer empty)
> > > Modules linked in:
> > > CPU: 8 PID: 59 Comm: khugepaged Not tainted 4.3.0-mm1-kirill+ #8
> > > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> > > task: ffff880073441a40 ti: ffff88007344c000 task.ti: ffff88007344c000
> > > RIP: 0010:[<ffffffff8114bc9b>]  [<ffffffff8114bc9b>] split_huge_page_to_list+0x8fb/0x910
> > > RSP: 0018:ffff88007344f968  EFLAGS: 00010286
> > > RAX: 0000000000000021 RBX: ffffea0000240080 RCX: 0000000000000000
> > > RDX: 0000000000000001 RSI: 0000000000000246 RDI: ffffffff821df4d8
> > > RBP: ffff88007344f9e8 R08: 0000000000000000 R09: ffff8800000bc600
> > > R10: ffffffff8163e2c0 R11: 0000000000004b47 R12: ffffea0000240080
> > > R13: ffffea0000240088 R14: ffffea0000240080 R15: 0000000000000000
> > > FS:  0000000000000000(0000) GS:ffff880078300000(0000) knlGS:0000000000000000
> > > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > > CR2: 00007ffd59edcd68 CR3: 0000000001808000 CR4: 00000000000006a0
> > > Stack:
> > >  cccccccccccccccd ffffea0000240080 ffff88007344fa00 ffffea0000240088
> > >  ffff88007344fa00 0000000000000000 ffff88007344f9e8 ffffffff810f0200
> > >  ffffea0000240000 0000000000000000 0000000000000000 ffffea0000240080
> > > Call Trace:
> > >  [<ffffffff810f0200>] ? __lock_page+0xa0/0xb0
> > >  [<ffffffff8114bdc5>] deferred_split_scan+0x115/0x240
> > >  [<ffffffff8111851c>] ? list_lru_count_one+0x1c/0x30
> > >  [<ffffffff811018d3>] shrink_slab.part.42+0x1e3/0x350
> > >  [<ffffffff8110644a>] shrink_zone+0x26a/0x280
> > >  [<ffffffff8110658d>] do_try_to_free_pages+0x12d/0x3b0
> > >  [<ffffffff811068c4>] try_to_free_pages+0xb4/0x140
> > >  [<ffffffff810f9279>] __alloc_pages_nodemask+0x459/0x920
> > >  [<ffffffff8108d750>] ? trace_event_raw_event_tick_stop+0xd0/0xd0
> > >  [<ffffffff81147465>] khugepaged+0x155/0x1b10
> > >  [<ffffffff81073ca0>] ? prepare_to_wait_event+0xf0/0xf0
> > >  [<ffffffff81147310>] ? __split_huge_pmd_locked+0x4e0/0x4e0
> > >  [<ffffffff81057e49>] kthread+0xc9/0xe0
> > >  [<ffffffff81057d80>] ? kthread_park+0x60/0x60
> > >  [<ffffffff8142aa6f>] ret_from_fork+0x3f/0x70
> > >  [<ffffffff81057d80>] ? kthread_park+0x60/0x60
> > > Code: ff ff 48 c7 c6 00 cd 77 81 4c 89 f7 e8 df ce fc ff 0f 0b 48 83 e8 01 e9 94 f7 ff ff 48 c7 c6 80 bb 77 81 4c 89 f7 e8 c5 ce fc ff <0f> 0b 48 c7 c6 48 c9 77 81 4c 89 e7 e8 b4 ce fc ff 0f 0b 66 90 
> > > RIP  [<ffffffff8114bc9b>] split_huge_page_to_list+0x8fb/0x910
> > >  RSP <ffff88007344f968>
> > > ---[ end trace 0ee39378e850d8de ]---
> > > Kernel panic - not syncing: Fatal exception
> > > Dumping ftrace buffer:
> > >    (ftrace buffer empty)
> > > Kernel Offset: disabled
> > 
> > I looked more into it. It seems a race between split_huge_page() and
> > deferred_split_scan() as the dumped page is not huge.
> > 
> > Could you check if the patch below makes any difference to the situation?
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 91e2f4b7ca39..923c0f6eb50a 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -3186,13 +3186,6 @@ static void __split_huge_page(struct page *page, struct list_head *list)
> >  	spin_lock_irq(&zone->lru_lock);
> >  	lruvec = mem_cgroup_page_lruvec(head, zone);
> >  
> > -	spin_lock(&split_queue_lock);
> > -	if (!list_empty(page_deferred_list(head))) {
> > -		split_queue_len--;
> > -		list_del(page_deferred_list(head));
> > -	}
> > -	spin_unlock(&split_queue_lock);
> > -
> >  	/* complete memcg works before add pages to LRU */
> >  	mem_cgroup_split_huge_fixup(head);
> >  
> > @@ -3299,12 +3292,20 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
> >  	freeze_page(anon_vma, head);
> >  	VM_BUG_ON_PAGE(compound_mapcount(head), head);
> >  
> > +	/* Prevent deferred_split_scan() touching ->_count */
> > +	spin_lock(&split_queue_lock);
> >  	count = page_count(head);
> >  	mapcount = total_mapcount(head);
> >  	if (mapcount == count - 1) {
> > +		if (!list_empty(page_deferred_list(head))) {
> > +			split_queue_len--;
> > +			list_del(page_deferred_list(head));
> > +		}
> > +		spin_unlock(&split_queue_lock);
> >  		__split_huge_page(page, list);
> >  		ret = 0;
> >  	} else if (IS_ENABLED(CONFIG_DEBUG_VM) && mapcount > count - 1) {
> > +		spin_unlock(&split_queue_lock);
> >  		pr_alert("total_mapcount: %u, page_count(): %u\n",
> >  				mapcount, count);
> >  		if (PageTail(page))
> > @@ -3312,6 +3313,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
> >  		dump_page(page, "total_mapcount(head) > page_count(head) - 1");
> >  		BUG();
> >  	} else {
> > +		spin_unlock(&split_queue_lock);
> >  		unfreeze_page(anon_vma, head);
> >  		ret = -EBUSY;
> >  	}
> > -- 
> >  Kirill A. Shutemov
> > 
> 
> It seems to solve that BUG_ON. One guest which doesn't include above fix hit
> the BUG_ON within 10 hours. However, another machine with above fix works
> during 1 day above without the BUG_ON but it introduces new problem.
> 
>         BUG: Bad rss-counter state mm:ffff88007f411c00 idx:0 val:-1
>         BUG: Bad rss-counter state mm:ffff88007f411c00 idx:1 val:1

That's rather strange: looks like one file page was charged as anon or
one anon page was uncharged as file. Not sure yet how this can be caused
by my THP patchset :/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
