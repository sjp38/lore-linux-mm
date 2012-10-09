Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 1F38E6B002B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 19:02:08 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id t2so5167585qcq.14
        for <linux-mm@kvack.org>; Tue, 09 Oct 2012 16:02:07 -0700 (PDT)
Message-ID: <5074ACDA.2060705@gmail.com>
Date: Tue, 09 Oct 2012 19:01:46 -0400
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 06/10] mm: kill vma flag VM_CAN_NONLINEAR
References: <20120731103724.20515.60334.stgit@zurg> <20120731104221.20515.90791.stgit@zurg>
In-Reply-To: <20120731104221.20515.90791.stgit@zurg>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Nick Piggin <npiggin@kernel.dk>, Dave Jones <davej@redhat.com>

On 07/31/2012 06:42 AM, Konstantin Khlebnikov wrote:
> This patch moves actual ptes filling for non-linear file mappings
> into special vma operation: ->remap_pages().
> 
> File system must implement this method to get non-linear mappings support,
> if it uses filemap_fault() then generic_file_remap_pages() can be used.
> 
> Now device drivers can implement this method and obtain nonlinear vma support.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Nick Piggin <npiggin@kernel.dk>
> Cc: Ingo Molnar <mingo@redhat.com>

I was fuzzing with trinity inside a KVM tools guest, and hit the following NULL deref:

[ 1202.209854] BUG: unable to handle kernel NULL pointer dereference at 0000000000000040
[ 1202.215344] IP: [<ffffffff812290cf>] sys_remap_file_pages+0xcf/0x380
[ 1202.215904] PGD 24ccc067 PUD 2f693067 PMD 0
[ 1202.215904] Oops: 0000 [#2] PREEMPT SMP DEBUG_PAGEALLOC
[ 1202.215904] CPU 3
[ 1202.224995] Pid: 17953, comm: trinity-child3 Tainted: G      D W    3.6.0-next-20121009-sasha-00001-ge404bae #43
[ 1202.224995] RIP: 0010:[<ffffffff812290cf>]  [<ffffffff812290cf>] sys_remap_file_pages+0xcf/0x380
[ 1202.224995] RSP: 0018:ffff880025819f18  EFLAGS: 00010246
[ 1202.224995] RAX: 00000000050444f9 RBX: 0000000080100000 RCX: 0000000000000001
[ 1202.224995] RDX: 0000000000000000 RSI: 0000000080100000 RDI: ffff8800255f1000
[ 1202.279533] RBP: ffff880025819f78 R08: ffff88000c9ea580 R09: 0000000000000000
[ 1202.279533] R10: 0000000000000001 R11: 0000000000000000 R12: ffff8800255f10a8
[ 1202.279533] R13: 0000000000000000 R14: ffff8800255f1000 R15: 0000000080700000
[ 1202.279533] FS:  00007fa063d0e700(0000) GS:ffff880067600000(0000) knlGS:0000000000000000
[ 1202.279533] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1202.279533] CR2: 0000000000000040 CR3: 000000002cc81000 CR4: 00000000000406e0
[ 1202.279533] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1202.279533] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1202.279533] Process trinity-child3 (pid: 17953, threadinfo ffff880025818000, task ffff88003061b000)
[ 1202.279533] Stack:
[ 1202.279533]  ffff880025819f48 ffffffff8107dc10 0000000080100000 0000000000000000
[ 1202.279533]  0000000000600000 000000000aefbf86 00000000000000d8 0000000080100000
[ 1202.279533]  0000000000000003 00000000000000d8 0000000000600000 00000000000000d8
[ 1202.279533] Call Trace:
[ 1202.279533]  [<ffffffff8107dc10>] ? syscall_trace_enter+0x20/0x2e0
[ 1202.279533]  [<ffffffff83a64738>] tracesys+0xe1/0xe6
[ 1202.279533] Code: 02 00 00 48 8b 40 30 a8 08 0f 84 6d 02 00 00 49 83 b8 a0 00 00 00 00 74 0b a9 00 00 80 00 0f 84 58 02 00 00
49 8b 90 88 00 00 00 <48> 83 7a 40 00 0f 84 46 02 00 00 49 8b 50 08 48 39 d3 0f 82 39
[ 1202.279533] RIP  [<ffffffff812290cf>] sys_remap_file_pages+0xcf/0x380
[ 1202.279533]  RSP <ffff880025819f18>
[ 1202.279533] CR2: 0000000000000040
[ 1202.401144] ---[ end trace fe8a5604834bab83 ]---

It would seem that this patch adds the following check into sys_remap_file_pages():

        if (!vma->vm_ops->remap_pages)
                goto out;

But vma->vm_ops itself is NULL.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
