From: Sasha Levin <sasha.levin@oracle.com>
Subject: mm/fs: gpf when shrinking slab
Date: Fri, 13 Jun 2014 08:53:52 -0400
Message-ID: <539AF460.4000400@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Christoph Lameter <cl@gentwo.org>, Pekka Enberg <penberg@kernel.org>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>
List-Id: linux-mm.kvack.org

[ 7193.961785] general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 7193.961785] Dumping ftrace buffer:
[ 7193.961785]    (ftrace buffer empty)
[ 7193.961785] Modules linked in:
[ 7193.961785] CPU: 2 PID: 4011 Comm: kswapd2 Not tainted 3.15.0-next-20140612-sasha-00022-g5e4db85-dirty #645
[ 7193.961785] task: ffff880035563000 ti: ffff88003557c000 task.ti: ffff88003557c000
[ 7193.961785] RIP: __lock_acquire (./arch/x86/include/asm/atomic.h:92 kernel/locking/lockdep.c:3082)
[ 7193.961785] RSP: 0000:ffff88003557f848  EFLAGS: 00010002
[ 7193.961785] RAX: 0000000000000000 RBX: 6b6b6b6b6b6b6b6b RCX: 0000000000000000
[ 7193.961785] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff8800761fbae0
[ 7193.961785] RBP: ffff88003557f938 R08: 0000000000000001 R09: 0000000000000000
[ 7193.961785] R10: ffff8800761fbae0 R11: 0000000000000000 R12: ffff880035563000
[ 7193.961785] R13: 0000000000000000 R14: 0000000000000001 R15: 0000000000000000
[ 7193.961785] FS:  0000000000000000(0000) GS:ffff8800a6e00000(0000) knlGS:0000000000000000
[ 7193.961785] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 7193.961785] CR2: 0000000005aabfc8 CR3: 00000006d5276000 CR4: 00000000000006a0
[ 7193.961785] DR0: 00000000006df000 DR1: 0000000000000000 DR2: 0000000000000000
[ 7193.961785] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[ 7193.961785] Stack:
[ 7193.961785]  ffff88003557f948 ffffffff891cbe79 ffffffff908c1c38 ffffffff908c1c30
[ 7193.961785]  ffff880000000001 ffffffff8919ff21 0000000000000000 ffff8800a6fd8340
[ 7193.961785]  0000000000000000 ffff8800a6fd8340 ffff8800a6fd8350 0000000000000282
[ 7193.961785] Call Trace:
[ 7193.961785] lock_acquire (./arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
[ 7193.961785] ? shrink_dentry_list (fs/dcache.c:550 fs/dcache.c:781)
[ 7193.961785] _raw_spin_lock (include/linux/spinlock_api_smp.h:143 kernel/locking/spinlock.c:151)
[ 7193.961785] ? shrink_dentry_list (fs/dcache.c:550 fs/dcache.c:781)
[ 7193.961785] ? rcu_read_lock (include/linux/rcupdate.h:870 (discriminator 2))
[ 7193.961785] shrink_dentry_list (fs/dcache.c:550 fs/dcache.c:781)
[ 7193.961785] prune_dcache_sb (fs/dcache.c:934)
[ 7193.961785] super_cache_scan (fs/super.c:94)
[ 7193.961785] shrink_slab_node (mm/vmscan.c:312)
[ 7193.961785] ? mem_cgroup_iter (mm/memcontrol.c:1258)
[ 7193.961785] ? mem_cgroup_iter (include/linux/rcupdate.h:867 mm/memcontrol.c:1222)
[ 7193.961785] shrink_slab (mm/vmscan.c:387)
[ 7193.961785] kswapd_shrink_zone (mm/vmscan.c:3028)
[ 7193.961785] balance_pgdat (mm/vmscan.c:3209)
[ 7193.961785] kswapd (mm/vmscan.c:3415)
[ 7193.961785] ? bit_waitqueue (kernel/sched/wait.c:291)
[ 7193.961785] ? balance_pgdat (mm/vmscan.c:3332)
[ 7193.961785] kthread (kernel/kthread.c:210)
[ 7193.961785] ? kthread_create_on_node (kernel/kthread.c:176)
[ 7193.961785] ret_from_fork (arch/x86/kernel/entry_64.S:349)
[ 7193.961785] ? kthread_create_on_node (kernel/kthread.c:176)
[ 7193.961785] Code: 48 c7 c2 a7 0f 6f 8d 31 c0 be 3b 03 00 00 48 c7 c7 33 67 6f 8d e8 e1 51 f9 ff e9 94 04 00 00 48 85 db 0f 84 8b 04 00 00 0f 1f 00 <f0> ff 83 98 01 00 00 8b 05 2b 51 49 07 45 8b bc 24 f0 0c 00 00
All code
========
   0:	48 c7 c2 a7 0f 6f 8d 	mov    $0xffffffff8d6f0fa7,%rdx
   7:	31 c0                	xor    %eax,%eax
   9:	be 3b 03 00 00       	mov    $0x33b,%esi
   e:	48 c7 c7 33 67 6f 8d 	mov    $0xffffffff8d6f6733,%rdi
  15:	e8 e1 51 f9 ff       	callq  0xfffffffffff951fb
  1a:	e9 94 04 00 00       	jmpq   0x4b3
  1f:	48 85 db             	test   %rbx,%rbx
  22:	0f 84 8b 04 00 00    	je     0x4b3
  28:	0f 1f 00             	nopl   (%rax)
  2b:*	f0 ff 83 98 01 00 00 	lock incl 0x198(%rbx)		<-- trapping instruction
  32:	8b 05 2b 51 49 07    	mov    0x749512b(%rip),%eax        # 0x7495163
  38:	45 8b bc 24 f0 0c 00 	mov    0xcf0(%r12),%r15d
  3f:	00
	...

Code starting with the faulting instruction
===========================================
   0:	f0 ff 83 98 01 00 00 	lock incl 0x198(%rbx)
   7:	8b 05 2b 51 49 07    	mov    0x749512b(%rip),%eax        # 0x7495138
   d:	45 8b bc 24 f0 0c 00 	mov    0xcf0(%r12),%r15d
  14:	00
	...
[ 7193.961785] RIP __lock_acquire (./arch/x86/include/asm/atomic.h:92 kernel/locking/lockdep.c:3082)
[ 7193.961785]  RSP <ffff88003557f848>
