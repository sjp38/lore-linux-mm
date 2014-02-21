Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f176.google.com (mail-ea0-f176.google.com [209.85.215.176])
	by kanga.kvack.org (Postfix) with ESMTP id F32B66B00C8
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 11:58:33 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id b10so1687461eae.21
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 08:58:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x41si17370544eee.180.2014.02.21.08.58.30
        for <linux-mm@kvack.org>;
        Fri, 21 Feb 2014 08:58:31 -0800 (PST)
Date: Fri, 21 Feb 2014 11:58:16 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <530785b7.41570e0a.3a40.2085SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <5306F29D.8070600@gmail.com>
References: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1392068676-30627-12-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5306F29D.8070600@gmail.com>
Subject: Re: [PATCH 11/11] mempolicy: apply page table walker on
 queue_pages_range()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: levinsasha928@gmail.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mpm@selenic.com, cpw@sgi.com, kosaki.motohiro@jp.fujitsu.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, xemul@parallels.com, riel@redhat.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

Hi Sasha,

On Fri, Feb 21, 2014 at 01:30:53AM -0500, Sasha Levin wrote:
> On 02/10/2014 04:44 PM, Naoya Horiguchi wrote:
> >queue_pages_range() does page table walking in its own way now,
> >so this patch rewrites it with walk_page_range().
> >One difficulty was that queue_pages_range() needed to check vmas
> >to determine whether we queue pages from a given vma or skip it.
> >Now we have test_walk() callback in mm_walk for that purpose,
> >so we can do the replacement cleanly. queue_pages_test_walk()
> >depends on not only the current vma but also the previous one,
> >so we use queue_pages->prev to keep it.
> >
> >ChangeLog v2:
> >- rebase onto mmots
> >- add VM_PFNMAP check on queue_pages_test_walk()
> >
> >Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> >---
> 
> Hi Naoya,
> 
> I'm seeing another spew in today's -next, and it seems to be related
> to this patch. Here's the spew (with line numbers instead of kernel
> addresses):

Thanks. (line numbers translation is very helpful.)

This bug looks strange to me.
"kernel BUG at mm/hugetlb.c:3580" means we try to do isolate_huge_page()
for !PageHead page. But the caller queue_pages_hugetlb() gets the page
with "page = pte_page(huge_ptep_get(pte))", so it should be the head page!

mm/hugetlb.c:3580 is VM_BUG_ON_PAGE(!PageHead(page), page), so we expect to
have dump_page output at this point, is that in your kernel log?

Thanks,
Naoya Horiguchi

> 
> [ 1411.889835] kernel BUG at mm/hugetlb.c:3580!
> [ 1411.890108] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [ 1411.890468] Dumping ftrace buffer:
> [ 1411.890468]    (ftrace buffer empty)
> [ 1411.890468] Modules linked in:
> [ 1411.890468] CPU: 0 PID: 2653 Comm: trinity-c285 Tainted: G
> W 3.14.0-rc3-next-20140220-sasha-00008-gab7e7ac-dirty #113
> [ 1411.890468] task: ffff8801be0cb000 ti: ffff8801e471c000 task.ti: ffff8801e471c000
> [ 1411.890468] RIP: 0010:[<mm/hugetlb.c:3580>]  [<mm/hugetlb.c:3580>] isolate_huge_page+0x1c/0xb0
> [ 1411.890468] RSP: 0018:ffff8801e471dae8  EFLAGS: 00010246
> [ 1411.890468] RAX: ffff88012b900000 RBX: ffffea0000000000 RCX: 0000000000000000
> [ 1411.890468] RDX: 0000000000000000 RSI: ffff8801be0cbd00 RDI: 0000000000000000
> [ 1411.890468] RBP: ffff8801e471daf8 R08: 0000000000000000 R09: 0000000000000000
> [ 1411.890468] R10: 0000000000000001 R11: 0000000000000001 R12: ffff8801e471dcf8
> [ 1411.890468] R13: ffffffff87d39120 R14: ffff8801e471dbc8 R15: 00007f30b1800000
> [ 1411.890468] FS:  00007f30b50bb700(0000) GS:ffff88012bc00000(0000) knlGS:0000000000000000
> [ 1411.890468] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 1411.890468] CR2: 0000000001609a10 CR3: 00000001e4703000 CR4: 00000000000006f0
> [ 1411.890468] Stack:
> [ 1411.890468]  00007f30b1000000 00007f30b0e00000 ffff8801e471db08 ffffffff812a8d71
> [ 1411.890468]  ffff8801e471db78 ffffffff81298fb1 00007f30b0d00000 ffff880478a16c38
> [ 1411.890468]  ffff8802291c6060 ffffffffffe00000 ffffffffffe00000 ffff8804fd7fa7d0
> [ 1411.890468] Call Trace:
> [ 1411.890468]  [<mm/mempolicy.c:540>] queue_pages_hugetlb+0x81/0x90
> [ 1411.890468]  [<include/linux/spinlock.h:343 mm/pagewalk.c:203>] walk_hugetlb_range+0x111/0x180
> [ 1411.890468]  [<mm/pagewalk.c:254>] __walk_page_range+0x25/0x40
> [ 1411.890468]  [<mm/pagewalk.c:332>] walk_page_range+0xf2/0x130
> [ 1411.890468]  [<mm/mempolicy.c:637>] queue_pages_range+0x6c/0x90
> [ 1411.890468]  [<mm/mempolicy.c:492>] ? queue_pages_hugetlb+0x90/0x90
> [ 1411.890468]  [<mm/mempolicy.c:521>] ? queue_pages_range+0x90/0x90
> [ 1411.890468]  [<mm/mempolicy.c:573>] ? change_prot_numa+0x30/0x30
> [ 1411.890468]  [<mm/mempolicy.c:1004>] migrate_to_node+0x77/0xc0
> [ 1411.890468]  [<mm/mempolicy.c:1110>] do_migrate_pages+0x1a8/0x230
> [ 1411.890468]  [<mm/mempolicy.c:1461>] SYSC_migrate_pages+0x316/0x380
> [ 1411.890468]  [<include/linux/rcupdate.h:799 mm/mempolicy.c:1407>] ? SYSC_migrate_pages+0xac/0x380
> [ 1411.890468]  [<kernel/sched/cputime.c:681>] ? vtime_account_user+0x91/0xa0
> [ 1411.890468]  [<mm/mempolicy.c:1381>] SyS_migrate_pages+0x9/0x10
> [ 1411.890468]  [<arch/x86/ia32/ia32entry.S:430>] ia32_do_call+0x13/0x13
> [ 1411.890468] Code: 4c 8b 6d f8 c9 c3 66 0f 1f 84 00 00 00 00 00 55
> 48 89 e5 41 54 49 89 f4 53 48 89 fb 48 8b 07 f6 c4 40 75 13 31 f6 e8
> 84 48 fb ff <0f> 0b 66 90 eb fe 66 0f 1f 44 00 00 8b 4f 1c 48 8d 77
> 1c 85 c9
> [ 1411.890468] RIP  [<mm/hugetlb.c:3580>] isolate_huge_page+0x1c/0xb0
> [ 1411.890468]  RSP <ffff8801e471dae8>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
