Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8AA116B0039
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 19:55:32 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id rl12so3335400iec.18
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 16:55:32 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u6si11306497icp.41.2014.03.14.16.55.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Mar 2014 16:55:30 -0700 (PDT)
Message-ID: <532396E7.6000400@oracle.com>
Date: Fri, 14 Mar 2014 19:55:19 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: munlock: fix a bug where THP tail page is encountered
References: <52AE07B4.4020203@oracle.com> <1387188856-21027-1-git-send-email-vbabka@suse.cz> <1387188856-21027-2-git-send-email-vbabka@suse.cz> <52AFA845.3060109@oracle.com> <52B04AD2.2070406@suse.cz>
In-Reply-To: <52B04AD2.2070406@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Bob Liu <bob.liu@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, joern@logfs.org, Michel Lespinasse <walken@google.com>, stable@kernel.org

On 12/17/2013 08:00 AM, Vlastimil Babka wrote:
> From: Vlastimil Babka<vbabka@suse.cz>
> Date: Fri, 13 Dec 2013 14:25:21 +0100
> Subject: [PATCH 1/3] mm: munlock: fix a bug where THP tail page is encountered
>
> Since commit ff6a6da60 ("mm: accelerate munlock() treatment of THP pages")
> munlock skips tail pages of a munlocked THP page. However, when the head page
> already has PageMlocked unset, it will not skip the tail pages.
>
> Commit 7225522bb ("mm: munlock: batch non-THP page isolation and
> munlock+putback using pagevec") has added a PageTransHuge() check which
> contains VM_BUG_ON(PageTail(page)). Sasha Levin found this triggered using
> trinity, on the first tail page of a THP page without PageMlocked flag.
>
> This patch fixes the issue by skipping tail pages also in the case when
> PageMlocked flag is unset. There is still a possibility of race with THP page
> split between clearing PageMlocked and determining how many pages to skip.
> The race might result in former tail pages not being skipped, which is however
> no longer a bug, as during the skip the PageTail flags are cleared.
>
> However this race also affects correctness of NR_MLOCK accounting, which is to
> be fixed in a separate patch.

I've hit the same thing again, on the latest -next, this time with a different trace:

[  539.199120] page:ffffea0013249a80 count:0 mapcount:1 mapping:          (null) index:0x0
[  539.200429] page flags: 0x12fffff80008000(tail)
[  539.201167] ------------[ cut here ]------------
[  539.201889] kernel BUG at include/linux/page-flags.h:415!
[  539.202859] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  539.204588] Dumping ftrace buffer:
[  539.206415]    (ftrace buffer empty)
[  539.207022] Modules linked in:
[  539.207503] CPU: 3 PID: 18262 Comm: trinity-c228 Tainted: G        W     3.14.0-rc6-next-20140313-sasha-00010-gb8c1db1-dirty #217
[  539.209012] task: ffff880627b10000 ti: ffff8805a44c2000 task.ti: ffff8805a44c2000
[  539.209989] RIP:  munlock_vma_pages_range+0x93/0x1d0 (include/linux/page-flags.h:415 mm/mlock.c:494)
[  539.210263] RSP: 0000:ffff8805a44c3e08  EFLAGS: 00010246
[  539.210263] RAX: ffff88052ae126a0 RBX: 000000000006a000 RCX: 0000000000000099
[  539.210263] RDX: 0000000000000000 RSI: ffff880627b10cf0 RDI: 0000000004c926a0
[  539.210263] RBP: ffff8805a44c3ec8 R08: 0000000000000001 R09: 0000000000000001
[  539.210263] R10: 0000000000000001 R11: 0000000000000001 R12: ffffea0013249a80
[  539.210263] R13: ffff88039dc95a00 R14: 000000000006b000 R15: ffff8805a44c3e94
[  539.210263] FS:  00007fd6ce14a700(0000) GS:ffff88042b800000(0000) knlGS:0000000000000000
[  539.210263] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  539.210263] CR2: 00007fd6ce0ef6ac CR3: 00000006025cd000 CR4: 00000000000006a0
[  539.210263] DR0: 0000000000698000 DR1: 0000000000000000 DR2: 0000000000000000
[  539.210263] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[  539.210263] Stack:
[  539.210263]  0000000000000000 0000000000000000 00018805a44c3e38 0000000000000000
[  539.210263]  0000000000000000 ffff88039dc95a00 00000000a44c3e88 0000000000000000
[  539.210263]  00ff8805a44c3e58 ffff880528f0a0f0 ffff8805a44c3eb8 ffff88039dc95a00
[  539.210263] Call Trace:
[  539.210263]  do_munmap+0x1d2/0x360 (mm/internal.h:168 mm/mmap.c:2547)
[  539.210263]  ? down_write+0xa6/0xc0 (kernel/locking/rwsem.c:51)
[  539.210263]  ? vm_munmap+0x46/0x80 (mm/mmap.c:2571)
[  539.210263]  vm_munmap+0x54/0x80 (mm/mmap.c:2572)
[  539.210263]  SyS_munmap+0x2c/0x40 (mm/mmap.c:2577)
[  539.210263]  tracesys+0xdd/0xe2 (arch/x86/kernel/entry_64.S:749)
[  539.210263] Code: ff 49 89 c4 48 85 c0 0f 84 f3 00 00 00 48 3d 00 f0 ff ff 0f 87 e7 00 00 00 48 8b 00 66 85 c0 79 17 31 f6 4c 89 e7 e8 4d d2 fc ff <0f> 0b 0f 1f 00 eb fe 66 0f 1f 44 00 00 49 8b 04 24 f6 c4 40 74
[  539.210263] RIP  munlock_vma_pages_range+0x93/0x1d0 (include/linux/page-flags.h:415 mm/mlock.c:494)
[  539.210263]  RSP <ffff8805a44c3e08>
[  539.236666] ---[ end trace 4e90dc9141579181 ]---


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
