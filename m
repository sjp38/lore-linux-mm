Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 97F7A6B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 05:38:18 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id gq1so35598784obb.2
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 02:38:18 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d11si4828834oih.135.2015.02.23.02.38.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Feb 2015 02:38:17 -0800 (PST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] mm: shmem: check for mapping owner before dereferencing
Date: Mon, 23 Feb 2015 05:38:00 -0500
Message-Id: <1424687880-8916-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, hch@lst.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, jack@suse.cz, axboe@fb.com, Sasha Levin <sasha.levin@oracle.com>

mapping->host can be NULL and shouldn't be dereferenced before being checked.

[ 1295.741844] GPF could be caused by NULL-ptr deref or user memory accessgeneral protection fault: 0000 [#1] SMP KASAN
[ 1295.746387] Dumping ftrace buffer:
[ 1295.748217]    (ftrace buffer empty)
[ 1295.749527] Modules linked in:
[ 1295.750268] CPU: 62 PID: 23410 Comm: trinity-c70 Not tainted 3.19.0-next-20150219-sasha-00045-g9130270f #1939
[ 1295.750268] task: ffff8803a49db000 ti: ffff8803a4dc8000 task.ti: ffff8803a4dc8000
[ 1295.750268] RIP: shmem_mapping (mm/shmem.c:1458)
[ 1295.750268] RSP: 0000:ffff8803a4dcfbf8  EFLAGS: 00010206
[ 1295.750268] RAX: dffffc0000000000 RBX: 0000000000000000 RCX: 00000000000f2804
[ 1295.750268] RDX: 0000000000000005 RSI: 0400000000000794 RDI: 0000000000000028
[ 1295.750268] RBP: ffff8803a4dcfc08 R08: 0000000000000000 R09: 00000000031de000
[ 1295.750268] R10: dffffc0000000000 R11: 00000000031c1000 R12: 0400000000000794
[ 1295.750268] R13: 00000000031c2000 R14: 00000000031de000 R15: ffff880e3bdc1000
[ 1295.750268] FS:  00007f8703c7e700(0000) GS:ffff881164800000(0000) knlGS:0000000000000000
[ 1295.750268] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1295.750268] CR2: 0000000004e58000 CR3: 00000003a9f3c000 CR4: 00000000000007a0
[ 1295.750268] DR0: ffffffff81000000 DR1: 0000009494949494 DR2: 0000000000000000
[ 1295.750268] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000d0602
[ 1295.750268] Stack:
[ 1295.750268]  ffff8803a4dcfec8 ffffffffbb1dc770 ffff8803a4dcfc38 ffffffffad6f230b
[ 1295.750268]  ffffffffad6f2b0d 0000014100000000 ffff88001e17c08b ffff880d9453fe08
[ 1295.750268]  ffff8803a4dcfd18 ffffffffad6f2ce2 ffff8803a49dbcd8 ffff8803a49dbce0
[ 1295.750268] Call Trace:
[ 1295.750268] mincore_page (mm/mincore.c:61)
[ 1295.750268] ? mincore_pte_range (include/linux/spinlock.h:312 mm/mincore.c:131)
[ 1295.750268] mincore_pte_range (mm/mincore.c:151)
[ 1295.750268] ? mincore_unmapped_range (mm/mincore.c:113)
[ 1295.750268] __walk_page_range (mm/pagewalk.c:51 mm/pagewalk.c:90 mm/pagewalk.c:116 mm/pagewalk.c:204)
[ 1295.750268] walk_page_range (mm/pagewalk.c:275)
[ 1295.750268] SyS_mincore (mm/mincore.c:191 mm/mincore.c:253 mm/mincore.c:220)
[ 1295.750268] ? mincore_pte_range (mm/mincore.c:220)
[ 1295.750268] ? mincore_unmapped_range (mm/mincore.c:113)
[ 1295.750268] ? __mincore_unmapped_range (mm/mincore.c:105)
[ 1295.750268] ? ptlock_free (mm/mincore.c:24)
[ 1295.750268] ? syscall_trace_enter (arch/x86/kernel/ptrace.c:1610)
[ 1295.750268] ia32_do_call (arch/x86/ia32/ia32entry.S:446)
[ 1295.750268] Code: e5 48 c1 ea 03 53 48 89 fb 48 83 ec 08 80 3c 02 00 75 4f 48 b8 00 00 00 00 00 fc ff df 48 8b 1b 48 8d 7b 28 48 89 fa 48 c1 ea 03 <80> 3c 02 00 75 3f 48 b8 00 00 00 00 00 fc ff df 48 8b 5b 28 48

All code
========
   0:	e5 48                	in     $0x48,%eax
   2:	c1 ea 03             	shr    $0x3,%edx
   5:	53                   	push   %rbx
   6:	48 89 fb             	mov    %rdi,%rbx
   9:	48 83 ec 08          	sub    $0x8,%rsp
   d:	80 3c 02 00          	cmpb   $0x0,(%rdx,%rax,1)
  11:	75 4f                	jne    0x62
  13:	48 b8 00 00 00 00 00 	movabs $0xdffffc0000000000,%rax
  1a:	fc ff df
  1d:	48 8b 1b             	mov    (%rbx),%rbx
  20:	48 8d 7b 28          	lea    0x28(%rbx),%rdi
  24:	48 89 fa             	mov    %rdi,%rdx
  27:	48 c1 ea 03          	shr    $0x3,%rdx
  2b:*	80 3c 02 00          	cmpb   $0x0,(%rdx,%rax,1)		<-- trapping instruction
  2f:	75 3f                	jne    0x70
  31:	48 b8 00 00 00 00 00 	movabs $0xdffffc0000000000,%rax
  38:	fc ff df
  3b:	48 8b 5b 28          	mov    0x28(%rbx),%rbx
  3f:	48                   	rex.W
	...

Code starting with the faulting instruction
===========================================
   0:	80 3c 02 00          	cmpb   $0x0,(%rdx,%rax,1)
   4:	75 3f                	jne    0x45
   6:	48 b8 00 00 00 00 00 	movabs $0xdffffc0000000000,%rax
   d:	fc ff df
  10:	48 8b 5b 28          	mov    0x28(%rbx),%rbx
  14:	48                   	rex.W
	...
[ 1295.750268] RIP shmem_mapping (mm/shmem.c:1458)
[ 1295.750268]  RSP <ffff8803a4dcfbf8>

Fixes: 97b713ba3e ("fs: kill BDI_CAP_SWAP_BACKED")
Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/shmem.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index 35843667..7f6f6d9 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1455,6 +1455,9 @@ static struct inode *shmem_get_inode(struct super_block *sb, const struct inode
 
 bool shmem_mapping(struct address_space *mapping)
 {
+	if (!mapping->host)
+		return false;
+
 	return mapping->host->i_sb->s_op == &shmem_ops;
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
