Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 957106B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 08:16:18 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so6880205vbk.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 05:16:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5016DC5F.7030604@redhat.com>
References: <20120720134937.GG9222@suse.de>
	<20120720141108.GH9222@suse.de>
	<20120720143635.GE12434@tiehlicka.suse.cz>
	<20120720145121.GJ9222@suse.de>
	<alpine.LSU.2.00.1207222033030.6810@eggly.anvils>
	<50118E7F.8000609@redhat.com>
	<50120FA8.20409@redhat.com>
	<20120727102356.GD612@suse.de>
	<5016DC5F.7030604@redhat.com>
Date: Tue, 31 Jul 2012 20:16:17 +0800
Message-ID: <CAJd=RBDBXWGKJRFuZA5Jr_u_QO+MnWe=vbp0L5ngorgDjhKtvw@mail.gmail.com>
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown of
 hugetlbfs shared page tables V2 (resend)
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lwoodman@redhat.com
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 31, 2012 at 3:11 AM, Larry Woodman <lwoodman@redhat.com> wrote:
> [ 1106.156569] ------------[ cut here ]------------
> [ 1106.161731] kernel BUG at mm/filemap.c:135!
> [ 1106.166395] invalid opcode: 0000 [#1] SMP
> [ 1106.170975] CPU 22
> [ 1106.173115] Modules linked in: bridge stp llc sunrpc binfmt_misc dcdbas
> microcode pcspkr acpi_pad acpi]
> [ 1106.201770]
> [ 1106.203426] Pid: 18001, comm: mpitest Tainted: G        W    3.3.0+ #4
> Dell Inc. PowerEdge R620/07NDJ2
> [ 1106.213822] RIP: 0010:[<ffffffff8112cfed>]  [<ffffffff8112cfed>]
> __delete_from_page_cache+0x15d/0x170
> [ 1106.224117] RSP: 0018:ffff880428973b88  EFLAGS: 00010002
> [ 1106.230032] RAX: 0000000000000001 RBX: ffffea0006b80000 RCX:
> 00000000ffffffb0
> [ 1106.237979] RDX: 0000000000016df1 RSI: 0000000000000009 RDI:
> ffff88043ffd9e00
> [ 1106.245927] RBP: ffff880428973b98 R08: 0000000000000050 R09:
> 0000000000000003
> [ 1106.253876] R10: 000000000000000d R11: 0000000000000000 R12:
> ffff880428708150
> [ 1106.261826] R13: ffff880428708150 R14: 0000000000000000 R15:
> ffffea0006b80000
> [ 1106.269780] FS:  0000000000000000(0000) GS:ffff88042fd60000(0000)
> knlGS:0000000000000000
> [ 1106.278794] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 1106.285193] CR2: 0000003a1d38c4a8 CR3: 000000000187d000 CR4:
> 00000000000406e0
> [ 1106.293149] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [ 1106.301097] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> [ 1106.309046] Process mpitest (pid: 18001, threadinfo ffff880428972000,
> task ffff880428b5cc20)
> [ 1106.318447] Stack:
> [ 1106.320690]  ffffea0006b80000 0000000000000000 ffff880428973bc8
> ffffffff8112d040
> [ 1106.328958]  ffff880428973bc8 00000000000002ab 00000000000002a0
> ffff880428973c18
> [ 1106.337234]  ffff880428973cc8 ffffffff8125b405 ffff880400000001
> 0000000000000000
> [ 1106.345513] Call Trace:
> [ 1106.348235]  [<ffffffff8112d040>] delete_from_page_cache+0x40/0x80
> [ 1106.355128]  [<ffffffff8125b405>] truncate_hugepages+0x115/0x1f0
> [ 1106.361826]  [<ffffffff8125b4f8>] hugetlbfs_evict_inode+0x18/0x30
> [ 1106.368615]  [<ffffffff811ab1af>] evict+0x9f/0x1b0
> [ 1106.373951]  [<ffffffff811ab3a3>] iput_final+0xe3/0x1e0
> [ 1106.379773]  [<ffffffff811ab4de>] iput+0x3e/0x50
> [ 1106.384922]  [<ffffffff811a8e18>] d_kill+0xf8/0x110
> [ 1106.390356]  [<ffffffff811a8f12>] dput+0xe2/0x1b0
> [ 1106.395595]  [<ffffffff81193612>] __fput+0x162/0x240
> [ 1106.401124]  [<ffffffff81193715>] fput+0x25/0x30
> [ 1106.406265]  [<ffffffff8118f6c3>] filp_close+0x63/0x90
> [ 1106.411997]  [<ffffffff8106058f>] put_files_struct+0x7f/0xf0
> [ 1106.418302]  [<ffffffff8106064c>] exit_files+0x4c/0x60
> [ 1106.424025]  [<ffffffff810629d7>] do_exit+0x1a7/0x470
> [ 1106.429652]  [<ffffffff81062cf5>] do_group_exit+0x55/0xd0
> [ 1106.435665]  [<ffffffff81062d87>] sys_exit_group+0x17/0x20
> [ 1106.441777]  [<ffffffff815d0229>] system_call_fastpath+0x16/0x1b


Perhaps we have to remove rmap when evicting inode.

--- a/fs/hugetlbfs/inode.c	Tue Jul 31 19:59:32 2012
+++ b/fs/hugetlbfs/inode.c	Tue Jul 31 20:04:14 2012
@@ -390,9 +390,11 @@ static void truncate_hugepages(struct in
 	hugetlb_unreserve_pages(inode, start, freed);
 }

+static int hugetlb_vmtruncate(struct inode *, loff_t);
+
 static void hugetlbfs_evict_inode(struct inode *inode)
 {
-	truncate_hugepages(inode, 0);
+	hugetlb_vmtruncate(inode, 0);
 	clear_inode(inode);
 }

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
