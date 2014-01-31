Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 13EB06B0031
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 15:33:55 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id lj1so4828364pab.26
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 12:33:54 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id xu6si11770309pab.51.2014.01.31.12.33.53
        for <linux-mm@kvack.org>;
        Fri, 31 Jan 2014 12:33:54 -0800 (PST)
Date: Fri, 31 Jan 2014 12:33:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: remove BUG_ON() from mlock_vma_page()
Message-Id: <20140131123352.a3da2a1dee32d79ad1f6af9f@linux-foundation.org>
In-Reply-To: <1387327369-18806-1-git-send-email-bob.liu@oracle.com>
References: <1387327369-18806-1-git-send-email-bob.liu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, walken@google.com, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, sasha.levin@oracle.com, vbabka@suse.cz, stable@kernel.org, gregkh@linuxfoundation.org, Bob Liu <bob.liu@oracle.com>

On Wed, 18 Dec 2013 08:42:49 +0800 Bob Liu <lliubbo@gmail.com> wrote:

> This BUG_ON() was triggered when called from try_to_unmap_cluster() which
> didn't lock the page.
> And it's safe to mlock_vma_page() without PageLocked, so this patch fix this
> issue by removing that BUG_ON() simply.
> 

This patch doesn't appear to be going anywhere, so I will drop it. 
Please let's check to see whether the bug still exists and if so, start
another round of bugfixing.


From: Bob Liu <lliubbo@gmail.com>
Subject: mm: remove BUG_ON() from mlock_vma_page()

objrmap doesn't work for nonlinear VMAs because the assumption that
offset-into-file correlates with offset-into-virtual-addresses does not
hold.  Hence what try_to_unmap_cluster does is a mini "virtual scan" of
each nonlinear VMA which maps the file to which the target page belongs. 
If vma locked, mlock the pages in the cluster, rather than unmapping them.
However, not all pages are guarantee page locked instead of the check
page, resulting in the below BUG_ON().

It's safe to mlock_vma_page() without PageLocked, so fix this issue by
removing that BUG_ON().

[  253.869145] kernel BUG at mm/mlock.c:82!
[  253.869549] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  253.870098] Dumping ftrace buffer:
[  253.870098]    (ftrace buffer empty)
[  253.870098] Modules linked in:
[  253.870098] CPU: 10 PID: 9162 Comm: trinity-child75 Tainted: G        W 3.13.0-rc4-next-20131216-sasha-00011-g5f105ec-dirty #4137
[  253.873310] task: ffff8800c98cb000 ti: ffff8804d34e8000 task.ti: ffff8804d34e8000
[  253.873310] RIP: 0010:[<ffffffff81281f28>]  [<ffffffff81281f28>] mlock_vma_page+0x18/0xc0
[  253.873310] RSP: 0000:ffff8804d34e99e8  EFLAGS: 00010246
[  253.873310] RAX: 006fffff8038002c RBX: ffffea00474944c0 RCX: ffff880807636000
[  253.873310] RDX: ffffea0000000000 RSI: 00007f17a9bca000 RDI: ffffea00474944c0
[  253.873310] RBP: ffff8804d34e99f8 R08: ffff880807020000 R09: 0000000000000000
[  253.873310] R10: 0000000000000001 R11: 0000000000002000 R12: 00007f17a9bca000
[  253.873310] R13: ffffea00474944c0 R14: 00007f17a9be0000 R15: ffff880807020000
[  253.873310] FS:  00007f17aa31a700(0000) GS:ffff8801c9c00000(0000) knlGS:0000000000000000
[  253.873310] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  253.873310] CR2: 00007f17a94fa000 CR3: 00000004d3b02000 CR4: 00000000000006e0
[  253.873310] DR0: 00007f17a74ca000 DR1: 0000000000000000 DR2: 0000000000000000
[  253.873310] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[  253.873310] Stack:
[  253.873310]  0000000b3de28067 ffff880b3de28e50 ffff8804d34e9aa8 ffffffff8128bc31
[  253.873310]  0000000000000301 ffffea0011850220 ffff8809a4039000 ffffea0011850238
[  253.873310]  ffff8804d34e9aa8 ffff880807636060 0000000000000001 ffff880807636348
[  253.873310] Call Trace:
[  253.873310]  [<ffffffff8128bc31>] try_to_unmap_cluster+0x1c1/0x340
[  253.873310]  [<ffffffff8128c60a>] try_to_unmap_file+0x20a/0x2e0
[  253.873310]  [<ffffffff8128c7b3>] try_to_unmap+0x73/0x90
[  253.873310]  [<ffffffff812b526d>] __unmap_and_move+0x18d/0x250
[  253.873310]  [<ffffffff812b53e9>] unmap_and_move+0xb9/0x180
[  253.873310]  [<ffffffff812b559b>] migrate_pages+0xeb/0x2f0
[  253.873310]  [<ffffffff812a0660>] ? queue_pages_pte_range+0x1a0/0x1a0
[  253.873310]  [<ffffffff812a193c>] migrate_to_node+0x9c/0xc0
[  253.873310]  [<ffffffff812a30b8>] do_migrate_pages+0x1b8/0x240
[  253.873310]  [<ffffffff812a3456>] SYSC_migrate_pages+0x316/0x380
[  253.873310]  [<ffffffff812a31ec>] ? SYSC_migrate_pages+0xac/0x380
[  253.873310]  [<ffffffff811763c6>] ? vtime_account_user+0x96/0xb0
[  253.873310]  [<ffffffff812a34ce>] SyS_migrate_pages+0xe/0x10
[  253.873310]  [<ffffffff843c4990>] tracesys+0xdd/0xe2
[  253.873310] Code: 0f 1f 00 65 48 ff 04 25 10 25 1d 00 48 83 c4 08
5b c9 c3 55 48 89 e5 53 48 83 ec 08 66 66 66 66 90 48 8b 07 48 89 fb
a8 01 75 10 <0f> 0b 66 0f 1f 44 00 00 eb fe 66 0f 1f 44 00 00 f0 0f ba
2f 15
[  253.873310] RIP  [<ffffffff81281f28>] mlock_vma_page+0x18/0xc0
[  253.873310]  RSP <ffff8804d34e99e8>
[  253.904194] ---[ end trace be59c4a7f8edab3f ]---

Signed-off-by: Bob Liu <bob.liu@oracle.com>
Reported-by: Sasha Levin <sasha.levin@oracle.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/mlock.c |    2 --
 1 file changed, 2 deletions(-)

diff -puN mm/mlock.c~mm-remove-bug_on-from-mlock_vma_page mm/mlock.c
--- a/mm/mlock.c~mm-remove-bug_on-from-mlock_vma_page
+++ a/mm/mlock.c
@@ -79,8 +79,6 @@ void clear_page_mlock(struct page *page)
  */
 void mlock_vma_page(struct page *page)
 {
-	BUG_ON(!PageLocked(page));
-
 	if (!TestSetPageMlocked(page)) {
 		mod_zone_page_state(page_zone(page), NR_MLOCK,
 				    hpage_nr_pages(page));
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
