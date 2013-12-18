Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id F1D246B0037
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 04:23:41 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id uz6so7540076obc.20
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 01:23:41 -0800 (PST)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [122.248.162.2])
        by mx.google.com with ESMTPS id iz10si13666052obb.117.2013.12.18.01.23.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 01:23:40 -0800 (PST)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 18 Dec 2013 14:53:10 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 0053FE005C
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:55:34 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBI9N2Ae40042592
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:53:03 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBI9N4JM025812
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:53:05 +0530
Date: Wed, 18 Dec 2013 17:23:03 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/mlock: fix BUG_ON unlocked page for nolinear VMAs
Message-ID: <52b1699c.aa71b60a.1a24.ffff8657SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1387267550-8689-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <52b1138b.0201430a.19a8.605dSMTPIN_ADDED_BROKEN@mx.google.com>
 <20131218032329.GA6044@hacker.(null)>
 <52B11765.8030005@oracle.com>
 <52b120a5.a3b2440a.3acf.ffffd7c3SMTPIN_ADDED_BROKEN@mx.google.com>
 <52B166CF.6080300@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52B166CF.6080300@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michel Lespinasse <walken@google.com>, Bob Liu <bob.liu@oracle.com>, npiggin@suse.de, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 18, 2013 at 10:11:43AM +0100, Vlastimil Babka wrote:
>On 12/18/2013 05:12 AM, Wanpeng Li wrote:
>>Hi Sasha,
>>On Tue, Dec 17, 2013 at 10:32:53PM -0500, Sasha Levin wrote:
>>>On 12/17/2013 10:23 PM, Wanpeng Li wrote:
>>>>-			mlock_vma_page(page);   /* no-op if already mlocked */
>>>>-			if (page == check_page)
>>>>+			if (page != check_page && trylock_page(page)) {
>>>>+				mlock_vma_page(page);   /* no-op if already mlocked */
>>>>+				unlock_page(page);
>>>>+			} else if (page == check_page) {
>>>>+				mlock_vma_page(page);  /* no-op if already mlocked */
>>>>  				ret = SWAP_MLOCK;
>>>>+			}
>>>
>>>Previously, if page != check_page and the page was locked, we'd call mlock_vma_page()
>>>anyways. With this change, we don't. In fact, we'll just skip that entire block not doing
>>>anything.
>>
>>Thanks for pointing out. ;-)
>>
>>>
>>>If that's something that's never supposed to happen, can we add a
>>>
>>>	VM_BUG_ON(page != check_page && PageLocked(page))
>>>
>>>Just to cover this new code path?
>>>
>>
>>How about this one?
>>
>>
>>0001-3.patch
>>
>>
>> From eab57d94c82fb3ab74b607a3ede0f5ce765ff2cc Mon Sep 17 00:00:00 2001
>>From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>>Date: Wed, 18 Dec 2013 12:05:59 +0800
>>Subject: [PATCH] mm/mlock: fix BUG_ON unlocked page for nolinear VMAs
>>
>>objrmap doesn't work for nonlinear VMAs because the assumption that offset-into-file
>>correlates with offset-into-virtual-addresses does not hold. Hence what
>>try_to_unmap_cluster does is a mini "virtual scan" of each nonlinear VMA which maps
>>the file to which the target page belongs. If vma locked, mlock the pages in the
>>cluster, rather than unmapping them. However, not all pages are guarantee page
>>locked instead of the check page. This patch fix the BUG by try to lock !check page
>>if them are unlocked.
>>
>>[  253.869145] kernel BUG at mm/mlock.c:82!
>>[  253.869549] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>>[  253.870098] Dumping ftrace buffer:
>>[  253.870098]    (ftrace buffer empty)
>>[  253.870098] Modules linked in:
>>[  253.870098] CPU: 10 PID: 9162 Comm: trinity-child75 Tainted: G        W    3.13.0-rc4-next-20131216-sasha-00011-g5f105ec-dirty #4137
>>[  253.873310] task: ffff8800c98cb000 ti: ffff8804d34e8000 task.ti: ffff8804d34e8000
>>[  253.873310] RIP: 0010:[<ffffffff81281f28>]  [<ffffffff81281f28>] mlock_vma_page+0x18/0xc0
>>[  253.873310] RSP: 0000:ffff8804d34e99e8  EFLAGS: 00010246
>>[  253.873310] RAX: 006fffff8038002c RBX: ffffea00474944c0 RCX: ffff880807636000
>>[  253.873310] RDX: ffffea0000000000 RSI: 00007f17a9bca000 RDI: ffffea00474944c0
>>[  253.873310] RBP: ffff8804d34e99f8 R08: ffff880807020000 R09: 0000000000000000
>>[  253.873310] R10: 0000000000000001 R11: 0000000000002000 R12: 00007f17a9bca000
>>[  253.873310] R13: ffffea00474944c0 R14: 00007f17a9be0000 R15: ffff880807020000
>>[  253.873310] FS:  00007f17aa31a700(0000) GS:ffff8801c9c00000(0000) knlGS:0000000000000000
>>[  253.873310] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>>[  253.873310] CR2: 00007f17a94fa000 CR3: 00000004d3b02000 CR4: 00000000000006e0
>>[  253.873310] DR0: 00007f17a74ca000 DR1: 0000000000000000 DR2: 0000000000000000
>>[  253.873310] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
>>[  253.873310] Stack:
>>[  253.873310]  0000000b3de28067 ffff880b3de28e50 ffff8804d34e9aa8 ffffffff8128bc31
>>[  253.873310]  0000000000000301 ffffea0011850220 ffff8809a4039000 ffffea0011850238
>>[  253.873310]  ffff8804d34e9aa8 ffff880807636060 0000000000000001 ffff880807636348
>>[  253.873310] Call Trace:
>>[  253.873310]  [<ffffffff8128bc31>] try_to_unmap_cluster+0x1c1/0x340
>>[  253.873310]  [<ffffffff8128c60a>] try_to_unmap_file+0x20a/0x2e0
>>[  253.873310]  [<ffffffff8128c7b3>] try_to_unmap+0x73/0x90
>>[  253.873310]  [<ffffffff812b526d>] __unmap_and_move+0x18d/0x250
>>[  253.873310]  [<ffffffff812b53e9>] unmap_and_move+0xb9/0x180
>>[  253.873310]  [<ffffffff812b559b>] migrate_pages+0xeb/0x2f0
>>[  253.873310]  [<ffffffff812a0660>] ? queue_pages_pte_range+0x1a0/0x1a0
>>[  253.873310]  [<ffffffff812a193c>] migrate_to_node+0x9c/0xc0
>>[  253.873310]  [<ffffffff812a30b8>] do_migrate_pages+0x1b8/0x240
>>[  253.873310]  [<ffffffff812a3456>] SYSC_migrate_pages+0x316/0x380
>>[  253.873310]  [<ffffffff812a31ec>] ? SYSC_migrate_pages+0xac/0x380
>>[  253.873310]  [<ffffffff811763c6>] ? vtime_account_user+0x96/0xb0
>>[  253.873310]  [<ffffffff812a34ce>] SyS_migrate_pages+0xe/0x10
>>[  253.873310]  [<ffffffff843c4990>] tracesys+0xdd/0xe2
>>[  253.873310] Code: 0f 1f 00 65 48 ff 04 25 10 25 1d 00 48 83 c4 08
>>5b c9 c3 55 48 89 e5 53 48 83 ec 08 66 66 66 66 90 48 8b 07 48 89 fb
>>a8 01 75 10 <0f> 0b 66 0f 1f 44 00 00 eb fe 66 0f 1f 44 00 00 f0 0f ba
>>2f 15
>>[  253.873310] RIP  [<ffffffff81281f28>] mlock_vma_page+0x18/0xc0
>>[  253.873310]  RSP <ffff8804d34e99e8>
>>[  253.904194] ---[ end trace be59c4a7f8edab3f ]---
>>
>>Reported-by: Sasha Levin <sasha.levin@oracle.com>
>>Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>>---
>>  mm/rmap.c | 11 +++++++++--
>>  1 file changed, 9 insertions(+), 2 deletions(-)
>>
>>diff --git a/mm/rmap.c b/mm/rmap.c
>>index 55c8b8d..1e24813 100644
>>--- a/mm/rmap.c
>>+++ b/mm/rmap.c
>>@@ -1347,6 +1347,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
>>  	unsigned long end;
>>  	int ret = SWAP_AGAIN;
>>  	int locked_vma = 0;
>>+	int we_locked = 0;
>>
>>  	address = (vma->vm_start + cursor) & CLUSTER_MASK;
>>  	end = address + CLUSTER_SIZE;
>>@@ -1385,9 +1386,15 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
>>  		BUG_ON(!page || PageAnon(page));
>>
>>  		if (locked_vma) {
>>-			mlock_vma_page(page);   /* no-op if already mlocked */
>>-			if (page == check_page)
>>+			if (page != check_page) {
>>+				we_locked = trylock_page(page);
>
>If it's not us who has the page already locked, but somebody else, he
>might unlock it at this point and then the BUG_ON in mlock_vma_page()
>will trigger again.

Any better idea is appreciated. ;-)

Regards,
Wanpeng Li 

>
>>+				mlock_vma_page(page);   /* no-op if already mlocked */
>>+				if (we_locked)
>>+					unlock_page(page);
>>+			} else if (page == check_page) {
>>+				mlock_vma_page(page);  /* no-op if already mlocked */
>>  				ret = SWAP_MLOCK;
>>+			}
>>  			continue;	/* don't unmap */
>>  		}
>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
