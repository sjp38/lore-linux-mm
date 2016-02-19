Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0936B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 13:02:15 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ho8so55351173pac.2
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 10:02:15 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id h4si17735041pat.211.2016.02.19.10.02.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Feb 2016 10:02:14 -0800 (PST)
Subject: Re: [PATCH 4/5] mm: Use radix_tree_iter_retry()
References: <1453929472-25566-1-git-send-email-matthew.r.wilcox@intel.com>
 <1453929472-25566-5-git-send-email-matthew.r.wilcox@intel.com>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <56C758A0.4060600@oracle.com>
Date: Fri, 19 Feb 2016 13:02:08 -0500
MIME-Version: 1.0
In-Reply-To: <1453929472-25566-5-git-send-email-matthew.r.wilcox@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 01/27/2016 04:17 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <willy@linux.intel.com>
> 
> Instead of a 'goto restart', we can now use radix_tree_iter_retry()
> to restart from our current position.  This will make a difference
> when there are more ways to happen across an indirect pointer.  And it
> eliminates some confusing gotos.

Hey Matthew,

I'm seeing the following NULL ptr deref while fuzzing:

[ 3380.120501] general protection fault: 0000 [#1] SMP KASAN
[ 3380.120529] Modules linked in:
[ 3380.120555] CPU: 2 PID: 23271 Comm: syz-executor Not tainted 4.5.0-rc4-next-20160219-sasha-00026-g7978205-dirty #2978
[ 3380.120569] task: ffff8800a5181000 ti: ffff8801a63b8000 task.ti: ffff8801a63b8000
[ 3380.120681] RIP: shmem_add_seals (include/linux/compiler.h:222 include/linux/radix-tree.h:206 mm/shmem.c:2001 mm/shmem.c:2100)
[ 3380.120692] RSP: 0018:ffff8801a63bfd58  EFLAGS: 00010202
[ 3380.120703] RAX: dffffc0000000000 RBX: 0000000000000001 RCX: 0000000000940000
[ 3380.120714] RDX: 0000000000000001 RSI: 0000000000000004 RDI: ffff8800a5181b3c
[ 3380.120725] RBP: ffff8801a63bfe58 R08: ffff8800a5181b40 R09: 0000000000000001
[ 3380.120736] R10: fffff44e6f425fff R11: ffffffffbdb0a420 R12: 0000000000000008
[ 3380.120745] R13: 0000000000000001 R14: 0000000000000001 R15: ffffea0002ad1660
[ 3380.120759] FS:  00007fbc71e9c700(0000) GS:ffff8801d3c00000(0000) knlGS:0000000000000000
[ 3380.120769] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 3380.120780] CR2: 0000000020010ff7 CR3: 00000001a0728000 CR4: 00000000000406e0
[ 3380.120794] Stack:
[ 3380.120815]  ffffffffa2738239 00000008a63bfdc8 ffff8800a499e740 1ffff10034c77fba
[ 3380.120834]  ffff8801ac446da0 ffff8800a499e8f0 0000000000000000 1ffff10034c77001
[ 3380.120852]  ffff8801a63b8000 ffff8801a63b8008 ffff8801ac446f90 ffff8801ac446f98
[ 3380.120856] Call Trace:
[ 3380.120929] shmem_fcntl (mm/shmem.c:2135)
[ 3380.120963] SyS_fcntl (fs/fcntl.c:336 fs/fcntl.c:372 fs/fcntl.c:357)
[ 3380.121112] entry_SYSCALL_64_fastpath (arch/x86/entry/entry_64.S:200)
[ 3380.122294] Code: c7 45 a0 00 00 00 00 e9 86 02 00 00 e8 cf a8 ee ff 4d 85 e4 0f 84 b2 07 00 00 48 b8 00 00 00 00 00 fc ff df 4c 89 e2 48 c1 ea 03 <80> 3c 02 00 0f 85 d4 08 00 00 49 8b 1c 24 e8 12 34 de ff 85 c0
All code
========
   0:   c7 45 a0 00 00 00 00    movl   $0x0,-0x60(%rbp)
   7:   e9 86 02 00 00          jmpq   0x292
   c:   e8 cf a8 ee ff          callq  0xffffffffffeea8e0
  11:   4d 85 e4                test   %r12,%r12
  14:   0f 84 b2 07 00 00       je     0x7cc
  1a:   48 b8 00 00 00 00 00    movabs $0xdffffc0000000000,%rax
  21:   fc ff df
  24:   4c 89 e2                mov    %r12,%rdx
  27:   48 c1 ea 03             shr    $0x3,%rdx
  2b:*  80 3c 02 00             cmpb   $0x0,(%rdx,%rax,1)               <-- trapping instruction
  2f:   0f 85 d4 08 00 00       jne    0x909
  35:   49 8b 1c 24             mov    (%r12),%rbx
  39:   e8 12 34 de ff          callq  0xffffffffffde3450
  3e:   85 c0                   test   %eax,%eax
        ...

Code starting with the faulting instruction
===========================================
   0:   80 3c 02 00             cmpb   $0x0,(%rdx,%rax,1)
   4:   0f 85 d4 08 00 00       jne    0x8de
   a:   49 8b 1c 24             mov    (%r12),%rbx
   e:   e8 12 34 de ff          callq  0xffffffffffde3425
  13:   85 c0                   test   %eax,%eax
        ...
[ 3380.122312] RIP shmem_add_seals (include/linux/compiler.h:222 include/linux/radix-tree.h:206 mm/shmem.c:2001 mm/shmem.c:2100)
[ 3380.122317]  RSP <ffff8801a63bfd58>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
