Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6546C6B0038
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 03:12:56 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id q10so6454886pdj.25
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 00:12:56 -0800 (PST)
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com. [122.248.162.8])
        by mx.google.com with ESMTPS id cz3si11109898pbc.3.2013.12.17.00.12.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 00:12:54 -0800 (PST)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 17 Dec 2013 13:42:46 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 9CC561258051
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 13:43:58 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBH8Cfuo5046394
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 13:42:42 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBH8Chpl011485
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 13:42:44 +0530
Date: Tue, 17 Dec 2013 16:12:42 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: mm: kernel BUG at mm/mlock.c:82!
Message-ID: <52b00786.a3b2440a.1f13.ffff8597SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <52AFA331.9070108@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52AFA331.9070108@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Bob Liu <bob.liu@oracle.com>, npiggin@suse.de, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Sasha,
On Mon, Dec 16, 2013 at 08:04:49PM -0500, Sasha Levin wrote:
>Hi all,
>
>While fuzzing with trinity inside a KVM tools guest running latest -next kernel, I've
>stumbled on the following spew.
>
>Codewise, it's pretty straightforward. In try_to_unmap_cluster():
>
>                page = vm_normal_page(vma, address, *pte);
>                BUG_ON(!page || PageAnon(page));
>
>                if (locked_vma) {
>                        mlock_vma_page(page);   /* no-op if already mlocked */
>                        if (page == check_page)
>                                ret = SWAP_MLOCK;
>                        continue;       /* don't unmap */
>                }
>
>And the BUG triggers once we see that 'page' isn't locked.
>

Could you test this patch?
http://marc.info/?l=linux-mm&m=138726757627739&w=2

Regards,
Wanpeng Li 

>I couldn't find anything that recently changed in those codepaths, so I'm a bit lost.
>
>[  253.869145] kernel BUG at mm/mlock.c:82!
>[  253.869549] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>[  253.870098] Dumping ftrace buffer:
>[  253.870098]    (ftrace buffer empty)
>[  253.870098] Modules linked in:
>[  253.870098] CPU: 10 PID: 9162 Comm: trinity-child75 Tainted: G        W    3.13.0-rc
>4-next-20131216-sasha-00011-g5f105ec-dirty #4137
>[  253.873310] task: ffff8800c98cb000 ti: ffff8804d34e8000 task.ti: ffff8804d34e8000
>[  253.873310] RIP: 0010:[<ffffffff81281f28>]  [<ffffffff81281f28>] mlock_vma_page+0x18
>/0xc0
>[  253.873310] RSP: 0000:ffff8804d34e99e8  EFLAGS: 00010246
>[  253.873310] RAX: 006fffff8038002c RBX: ffffea00474944c0 RCX: ffff880807636000
>[  253.873310] RDX: ffffea0000000000 RSI: 00007f17a9bca000 RDI: ffffea00474944c0
>[  253.873310] RBP: ffff8804d34e99f8 R08: ffff880807020000 R09: 0000000000000000
>[  253.873310] R10: 0000000000000001 R11: 0000000000002000 R12: 00007f17a9bca000
>[  253.873310] R13: ffffea00474944c0 R14: 00007f17a9be0000 R15: ffff880807020000
>[  253.873310] FS:  00007f17aa31a700(0000) GS:ffff8801c9c00000(0000) knlGS:000000000000
>0000
>[  253.873310] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>[  253.873310] CR2: 00007f17a94fa000 CR3: 00000004d3b02000 CR4: 00000000000006e0
>[  253.873310] DR0: 00007f17a74ca000 DR1: 0000000000000000 DR2: 0000000000000000
>[  253.873310] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
>[  253.873310] Stack:
>[  253.873310]  0000000b3de28067 ffff880b3de28e50 ffff8804d34e9aa8 ffffffff8128bc31
>[  253.873310]  0000000000000301 ffffea0011850220 ffff8809a4039000 ffffea0011850238
>[  253.873310]  ffff8804d34e9aa8 ffff880807636060 0000000000000001 ffff880807636348
>[  253.873310] Call Trace:
>[  253.873310]  [<ffffffff8128bc31>] try_to_unmap_cluster+0x1c1/0x340
>[  253.873310]  [<ffffffff8128c60a>] try_to_unmap_file+0x20a/0x2e0
>[  253.873310]  [<ffffffff8128c7b3>] try_to_unmap+0x73/0x90
>[  253.873310]  [<ffffffff812b526d>] __unmap_and_move+0x18d/0x250
>[  253.873310]  [<ffffffff812b53e9>] unmap_and_move+0xb9/0x180
>[  253.873310]  [<ffffffff812b559b>] migrate_pages+0xeb/0x2f0
>[  253.873310]  [<ffffffff812a0660>] ? queue_pages_pte_range+0x1a0/0x1a0
>[  253.873310]  [<ffffffff812a193c>] migrate_to_node+0x9c/0xc0
>[  253.873310]  [<ffffffff812a30b8>] do_migrate_pages+0x1b8/0x240
>[  253.873310]  [<ffffffff812a3456>] SYSC_migrate_pages+0x316/0x380
>[  253.873310]  [<ffffffff812a31ec>] ? SYSC_migrate_pages+0xac/0x380
>[  253.873310]  [<ffffffff811763c6>] ? vtime_account_user+0x96/0xb0
>[  253.873310]  [<ffffffff812a34ce>] SyS_migrate_pages+0xe/0x10
>[  253.873310]  [<ffffffff843c4990>] tracesys+0xdd/0xe2
>[  253.873310] Code: 0f 1f 00 65 48 ff 04 25 10 25 1d 00 48 83 c4 08
>5b c9 c3 55 48 89 e5 53 48 83 ec 08 66 66 66 66 90 48 8b 07 48 89 fb
>a8 01 75 10 <0f> 0b 66 0f 1f 44 00 00 eb fe 66 0f 1f 44 00 00 f0 0f
>ba 2f 15
>[  253.873310] RIP  [<ffffffff81281f28>] mlock_vma_page+0x18/0xc0
>[  253.873310]  RSP <ffff8804d34e99e8>
>[  253.904194] ---[ end trace be59c4a7f8edab3f ]---
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
