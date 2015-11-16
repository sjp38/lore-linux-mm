Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 24E386B0253
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 03:45:26 -0500 (EST)
Received: by wmvv187 with SMTP id v187so164254974wmv.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 00:45:25 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id xa1si44594832wjc.7.2015.11.16.00.45.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 00:45:24 -0800 (PST)
Received: by wmvv187 with SMTP id v187so164253933wmv.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 00:45:24 -0800 (PST)
Date: Mon, 16 Nov 2015 10:45:22 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: kernel oops on mmotm-2015-10-15-15-20
Message-ID: <20151116084522.GA9778@node.shutemov.name>
References: <20151102125749.GB7473@node.shutemov.name>
 <20151103030258.GJ17906@bbox>
 <20151103071650.GA21553@node.shutemov.name>
 <20151103073329.GL17906@bbox>
 <20151103152019.GM17906@bbox>
 <20151104142135.GA13303@node.shutemov.name>
 <20151105001922.GD7357@bbox>
 <20151108225522.GA29600@node.shutemov.name>
 <20151112003614.GA5235@bbox>
 <20151116014521.GA7973@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151116014521.GA7973@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

On Mon, Nov 16, 2015 at 10:45:21AM +0900, Minchan Kim wrote:
> During the test with MADV_FREE on kernel I applied your patches,
> I couldn't see any problem.
> 
> However, in this round, I did another test which is same one
> I attached but a liitle bit different because it doesn't do
> (memcg things/kill/swapoff) for testing program long-live test.

Could you share updated test?

And could you try to reproduce it on clean mmotm-2015-11-10-15-53?

> With that, I encountered this problem.
> 
> page:ffffea0000f60080 count:1 mapcount:0 mapping:ffff88007f584691 index:0x600002a02
> flags: 0x400000000006a028(uptodate|lru|writeback|swapcache|reclaim|swapbacked)
> page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
> page->mem_cgroup:ffff880077cf0c00
> ------------[ cut here ]------------
> kernel BUG at mm/huge_memory.c:3340!
> invalid opcode: 0000 [#1] SMP 
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 7 PID: 1657 Comm: memhog Not tainted 4.3.0-rc5-mm1-madv-free+ #4
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff88006b0f1a40 ti: ffff88004ced4000 task.ti: ffff88004ced4000
> RIP: 0010:[<ffffffff8114bf67>]  [<ffffffff8114bf67>] split_huge_page_to_list+0x907/0x920
> RSP: 0018:ffff88004ced7a38  EFLAGS: 00010296
> RAX: 0000000000000021 RBX: ffffea0000f60080 RCX: ffffffff81830db8
> RDX: 0000000000000001 RSI: 0000000000000246 RDI: ffffffff821df4d8
> RBP: ffff88004ced7ab8 R08: 0000000000000000 R09: ffff8800000bc560
> R10: ffffffff8163d880 R11: 0000000000014f25 R12: ffffea0000f60080
> R13: ffffea0000f60088 R14: ffffea0000f60080 R15: 0000000000000000
> FS:  00007f43d3ced740(0000) GS:ffff8800782e0000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00007ff1f6fcdb98 CR3: 000000004cf56000 CR4: 00000000000006a0
> Stack:
>  cccccccccccccccd ffffea0000f60080 ffff88004ced7ad0 ffffea0000f60088
>  ffff88004ced7ad0 0000000000000000 ffff88004ced7ab8 ffffffff810ef9d0
>  ffffea0000f60000 0000000000000000 0000000000000000 ffffea0000f60080
> Call Trace:
>  [<ffffffff810ef9d0>] ? __lock_page+0xa0/0xb0
>  [<ffffffff8114c09c>] deferred_split_scan+0x11c/0x260
>  [<ffffffff81117bfc>] ? list_lru_count_one+0x1c/0x30
>  [<ffffffff81101333>] shrink_slab.part.42+0x1e3/0x350
>  [<ffffffff81105daa>] shrink_zone+0x26a/0x280
>  [<ffffffff81105eed>] do_try_to_free_pages+0x12d/0x3b0
>  [<ffffffff81106224>] try_to_free_pages+0xb4/0x140
>  [<ffffffff810f8a59>] __alloc_pages_nodemask+0x459/0x920
>  [<ffffffff8111e667>] handle_mm_fault+0xc77/0x1000
>  [<ffffffff8142718d>] ? retint_kernel+0x10/0x10
>  [<ffffffff81033629>] __do_page_fault+0x189/0x400
>  [<ffffffff810338ac>] do_page_fault+0xc/0x10
>  [<ffffffff81428142>] page_fault+0x22/0x30
> Code: ff ff 48 c7 c6 f0 b2 77 81 4c 89 f7 e8 13 c3 fc ff 0f 0b 48 83 e8 01 e9 88 f7 ff ff 48 c7 c6 70 a1 77 81 4c 89 f7 e8 f9 c2 fc ff <0f> 0b 48 c7 c6 38 af 77 81 4c 89 e7 e8 e8 c2 fc ff 0f 0b 66 0f 
> RIP  [<ffffffff8114bf67>] split_huge_page_to_list+0x907/0x920
>  RSP <ffff88004ced7a38>
> ---[ end trace c9a60522e3a296e4 ]---

I don't see how it's possible: call lock_page() just before
split_huge_page() in deferred_split_scan().

> So, I reverted all MADV_FREE patches and chaged it with MADV_DONTNEED.
> In this time, I saw below oops in this time.
> If I miss somethings, please let me know it.
> 
> ------------[ cut here ]------------
> kernel BUG at include/linux/swapops.h:129!

Looks similar to what I fixed by inserting smp_wmb() just before
clear_compound_head() in __split_huge_page_tail().

Do you have this in place? Like in last -mm tree?

> Another hit:
> 
> page:ffffea0000520080 count:2 mapcount:0 mapping:ffff880072b38a51 index:0x600002602
> flags: 0x4000000000048028(uptodate|lru|swapcache|swapbacked)
> page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
> page->mem_cgroup:ffff880077cf0c00
> ------------[ cut here ]------------
> kernel BUG at mm/huge_memory.c:3306!

The same as the first one: no idea.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
