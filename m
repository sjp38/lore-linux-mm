From: Sasha Levin <levinsasha928@gmail.com>
Subject: mtd: kernel BUG at arch/x86/mm/pat.c:279!
Date: Fri, 29 Jun 2012 10:48:59 +0200
Message-ID: <1340959739.2936.28.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, dwmw2@infradead.org
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mtd@lists.infradead.org, linux-mm <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>
List-Id: linux-mm.kvack.org

Hi all,

I've stumbled on the following while fuzzing with trinity in a KVM tools guest using latest linux-next:

[ 3299.675163] ------------[ cut here ]------------
[ 3299.676027] kernel BUG at arch/x86/mm/pat.c:279!
[ 3299.676027] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 3299.678596] CPU 2 
[ 3299.678596] Pid: 21541, comm: trinity-child6 Tainted: G        W    3.5.0-rc4-next-20120628-sasha-00005-g9f23eb7 #479  
[ 3299.678596] RIP: 0010:[<ffffffff810a8b62>]  [<ffffffff810a8b62>] reserve_memtype+0x22/0x3d0
[ 3299.678596] RSP: 0018:ffff88000ad61bc8  EFLAGS: 00010286
[ 3299.678596] RAX: 0000000000000000 RBX: fffffffffffff000 RCX: ffff88000ad61c50
[ 3299.678596] RDX: 0000000000000010 RSI: 0000000000000000 RDI: fffffffffffff000
[ 3299.696632] RBP: ffff88000ad61c08 R08: 0000000000000010 R09: ffff88002617d5a8
[ 3299.696632] R10: ffff88003111edc8 R11: 0000000000000001 R12: ffff88000ad61c50
[ 3299.696632] R13: fffffffffffff000 R14: 0000000000000000 R15: ffff88000ad61d18
[ 3299.696632] FS:  00007f3ffc3aa700(0000) GS:ffff880029800000(0000) knlGS:0000000000000000
[ 3299.696632] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 3299.696632] CR2: 0000000000f73ffc CR3: 000000000ad6e000 CR4: 00000000000406e0
[ 3299.696632] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3299.696632] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3299.696632] Process trinity-child6 (pid: 21541, threadinfo ffff88000ad60000, task ffff88000a390000)
[ 3299.696632] Stack:
[ 3299.696632]  ffff88000ad61c18 ffffffff81161bc6 ffff88000ad61c18 fffffffffffff000
[ 3299.696632]  0000000000000010 0000000000000000 0000000000001000 ffff88000ad61d18
[ 3299.696632]  ffff88000ad61c88 ffffffff810a8fe2 ffff88000ad61c38 0000000000000086
[ 3299.696632] Call Trace:
[ 3299.696632]  [<ffffffff81161bc6>] ? mark_held_locks+0xf6/0x120
[ 3299.696632]  [<ffffffff810a8fe2>] reserve_pfn_range+0xd2/0x1e0
[ 3299.696632]  [<ffffffff810a912d>] track_pfn_vma_new+0x3d/0x80
[ 3299.696632]  [<ffffffff8120c4bc>] remap_pfn_range+0xac/0x380
[ 3299.696632]  [<ffffffff8220e016>] mtdchar_mmap+0xe6/0x100
[ 3299.696632]  [<ffffffff812145ae>] mmap_region+0x35e/0x5f0
[ 3299.696632]  [<ffffffff81214af9>] do_mmap_pgoff+0x2b9/0x350
[ 3299.696632]  [<ffffffff811ff46c>] ? vm_mmap_pgoff+0x6c/0xb0
[ 3299.696632]  [<ffffffff811ff484>] vm_mmap_pgoff+0x84/0xb0
[ 3299.696632]  [<ffffffff8124fd80>] ? fget_raw+0x260/0x260
[ 3299.696632]  [<ffffffff81211fde>] sys_mmap_pgoff+0x15e/0x190
[ 3299.696632]  [<ffffffff81985ede>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 3299.696632]  [<ffffffff8106d4dd>] sys_mmap+0x1d/0x20
[ 3299.696632]  [<ffffffff8372a539>] system_call_fastpath+0x16/0x1b
[ 3299.696632] Code: 28 5b c9 c3 0f 1f 44 00 00 55 49 89 d0 48 89 e5 41 57 41 56 49 89 f6 41 55 49 89 fd 41 54 49 89 cc 53 48 83 ec 18 48 39 f7 72 0e <0f> 0b 0f 1f 40 00 eb fe 66 0f 1f 44 00 00 8b 3d 1a 5b e3 03 85 
[ 3299.696632] RIP  [<ffffffff810a8b62>] reserve_memtype+0x22/0x3d0
[ 3299.696632]  RSP <ffff88000ad61bc8>
