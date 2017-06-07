Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9036B02F3
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 03:21:20 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p22so2094184pgn.3
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 00:21:20 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0103.outbound.protection.outlook.com. [104.47.2.103])
        by mx.google.com with ESMTPS id h12si998466pln.483.2017.06.07.00.21.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Jun 2017 00:21:18 -0700 (PDT)
From: Tommi Rantala <tommi.t.rantala@nokia.com>
Subject: 4.9.30 NULL pointer dereference in __remove_shared_vm_struct
Message-ID: <7244cb6d-ed7a-451a-1af9-885090173311@nokia.com>
Date: Wed, 7 Jun 2017 10:21:11 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi,

I have hit this kernel bug twice with 4.9.30 while running trinity, any 
ideas? It's not easily reproducible.

Perhaps I should enable some more debug options to see if they reveal 
anything...

(note that I had different kernel builds, so the IP addresses are 
different in the logs below)


$ scripts/faddr2line vmlinux __remove_shared_vm_struct+0x16/0x40
__remove_shared_vm_struct+0x16/0x40:
atomic_inc at arch/x86/include/asm/atomic.h:91
  (inlined by) __remove_shared_vm_struct at mm/mmap.c:137


(gdb) disassemble __remove_shared_vm_struct
Dump of assembler code for function __remove_shared_vm_struct:
    0xffffffff8218e7a0 <+0>:     callq  0xffffffff825db650 <__fentry__>
    0xffffffff8218e7a5 <+5>:     mov    0x50(%rdi),%rax
    0xffffffff8218e7a9 <+9>:     push   %rbp
    0xffffffff8218e7aa <+10>:    mov    %rsp,%rbp
    0xffffffff8218e7ad <+13>:    test   $0x8,%ah
    0xffffffff8218e7b0 <+16>:    je     0xffffffff8218e7c1 
<__remove_shared_vm_struct+33>
    0xffffffff8218e7b2 <+18>:    mov    0x20(%rsi),%rax
    0xffffffff8218e7b6 <+22>:    lock incl 0x158(%rax)
    0xffffffff8218e7bd <+29>:    mov    0x50(%rdi),%rax
    0xffffffff8218e7c1 <+33>:    test   $0x8,%al
    0xffffffff8218e7c3 <+35>:    je     0xffffffff8218e7c9 
<__remove_shared_vm_struct+41>
    0xffffffff8218e7c5 <+37>:    lock decl 0x1c(%rdx)
    0xffffffff8218e7c9 <+41>:    lea    0x20(%rdx),%rsi
    0xffffffff8218e7cd <+45>:    callq  0xffffffff82183460 
<vma_interval_tree_remove>
    0xffffffff8218e7d2 <+50>:    pop    %rbp
    0xffffffff8218e7d3 <+51>:    retq




[16076.230255] BUG: unable to handle kernel NULL pointer dereference at 
0000000000000158
[16076.231566] IP: [<ffffffff8038e616>] __remove_shared_vm_struct+0x16/0x40
[16076.232533] PGD 0
[16076.233125] Oops: 0002 [#1] SMP
[16076.233631] Modules linked in: fuse tun bridge hmac 8021q garp stp 
llc2 af_key llc rds xfrm_user xfrm_algo nfnetlink dccp_ipv6 sctp 
libcrc32c dccp_ipv4 dccp iptable_filter ip_tables x_tables isofs 
ata_piix autofs4
[16076.236688] CPU: 10 PID: 10753 Comm: trinity-main Not tainted 4.9.30 #1
[16076.238917] task: ffff880285b58000 task.stack: ffffc90108d4c000
[16076.239741] RIP: 0010:[<ffffffff8038e616>]  [<ffffffff8038e616>] 
__remove_shared_vm_struct+0x16/0x40
[16076.241085] RSP: 0018:ffffc90108d4fd38  EFLAGS: 00010202
[16076.241841] RAX: 0000000000000000 RBX: ffff8801568867e8 RCX: 
0000000000000000
[16076.242807] RDX: ffff88032c7581d8 RSI: ffff88012af34a00 RDI: 
ffff8801568867e8
[16076.243773] RBP: ffffc90108d4fd38 R08: ffff880156886b80 R09: 
00007fffcf5d4000
[16076.244737] R10: 0000000000000000 R11: 0000000000000001 R12: 
ffff88012af34a00
[16076.245698] R13: ffff88032c758200 R14: ffff88032c7581d8 R15: 
ffff8801568868a0
[16076.246659] FS:  0000000000000000(0000) GS:ffff880333480000(0000) 
knlGS:0000000000000000
[16076.247864] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[16076.248667] CR2: 0000000000000158 CR3: 0000000000c07000 CR4: 
00000000000006e0
[16076.249634] DR0: 00007f54c4cae000 DR1: 00007ff1276c9000 DR2: 
0000000000000000
[16076.250599] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 
0000000000000600
[16076.251563] Stack:
[16076.251942]  ffffc90108d4fd68 ffffffff8038ef91 ffff8801568867e8 
0000000000400000
[16076.253139]  0000000000000000 ffffc90108d4fdc0 ffffc90108d4fda8 
ffffffff80387893
[16076.254335]  0000000000000000 0000000000000000 ffff8801d1126c00 
0000000000000000
[16076.255528] Call Trace:
[16076.255959]  [<ffffffff8038ef91>] unlink_file_vma+0x41/0x60
[16076.256746]  [<ffffffff80387893>] free_pgtables+0x43/0x120
[16076.257520]  [<ffffffff80390b12>] exit_mmap+0xb2/0x150
[16076.258258]  [<ffffffff8025624b>] mmput+0x3b/0x100
[16076.258953]  [<ffffffff8025ddb5>] do_exit+0x255/0xb20
[16076.259673]  [<ffffffff802024b1>] ? syscall_trace_enter+0x1c1/0x2d0
[16076.260538]  [<ffffffff8025e703>] do_group_exit+0x43/0xb0
[16076.261303]  [<ffffffff8025e784>] SyS_exit_group+0x14/0x20
[16076.262078]  [<ffffffff80202bfe>] do_syscall_64+0x7e/0x1a0
[16076.262852]  [<ffffffff807d8f84>] entry_SYSCALL64_slow_path+0x25/0x25
[16076.263736] Code: 3d 00 20 00 00 48 0f 47 c2 48 89 05 cd dc 95 00 31 
c0 c3 66 90 0f 1f 44 00 00 48 8b 47 50 55 48 89 e5 f6 c4 08 74 0f 48 8b 
46 20 <f0> ff 80 58 01 00 00 48 8b 47 50 a8 08 74 04 f0 ff 4a 1c 48 8d
[16076.267481] RIP  [<ffffffff8038e616>] __remove_shared_vm_struct+0x16/0x40
[16076.268424]  RSP <ffffc90108d4fd38>
[16076.268973] CR2: 0000000000000158
[16076.269844] ---[ end trace 98a1bbd8d9e50234 ]---
[16076.270565] Fixing recursive fault but reboot is needed!





[69086.066173] Out of memory: Kill process 2485 (trinity-c309) score 503 
or sacrifice child
[69086.067383] Killed process 2485 (trinity-c309) total-vm:73816kB, 
anon-rss:7196kB, file-rss:3940kB, shmem-rss:17248kB
[69086.071158] oom_reaper: reaped process 2485 (trinity-c309), now 
anon-rss:0kB, file-rss:0kB, shmem-rss:17248kB
[69089.763240] scsi_nl_rcv_msg: discarding partial skb
[69093.568099] scsi_nl_rcv_msg: discarding partial skb
[69095.925546] BUG: unable to handle kernel NULL pointer dereference at 
0000000000000158
[69095.926875] IP: [<ffffffff8218e7b6>] __remove_shared_vm_struct+0x16/0x40
[69095.927836] PGD 0
[69095.928411] Oops: 0002 [#1] SMP
[69095.928934] Modules linked in: fuse tun 8021q xfrm_user garp 
dccp_ipv6 dccp_ipv4 dccp sctp bridge llc2 rds stp af_key llc xfrm_algo 
libcrc32c nfnetlink isofs iptable_filter ip_tables x_tables ata_piix autofs4
[69095.931931] CPU: 5 PID: 21391 Comm: trinity-c387 Not tainted 4.9.30 #1
[69095.934129] task: ffff88006a938000 task.stack: ffffc9007c624000
[69095.934944] RIP: 0010:[<ffffffff8218e7b6>]  [<ffffffff8218e7b6>] 
__remove_shared_vm_struct+0x16/0x40
[69095.936276] RSP: 0018:ffffc9007c627b80  EFLAGS: 00010202
[69095.937027] RAX: 0000000000000000 RBX: ffff8801e0be4f18 RCX: 
0000000000000000
[69095.937982] RDX: ffff88022dc6c658 RSI: ffff88018d16c600 RDI: 
ffff8801e0be4f18
[69095.938938] RBP: ffffc9007c627b80 R08: ffff880022c48508 R09: 
00007fff63b80000
[69095.939893] R10: 0000000000000000 R11: 0000000000000001 R12: 
ffff88018d16c600
[69095.940844] R13: ffff88022dc6c680 R14: ffff88022dc6c658 R15: 
ffff8801e0be4000
[69095.941802] FS:  00007f5413555b40(0000) GS:ffff88023fd40000(0000) 
knlGS:0000000000000000
[69095.942993] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[69095.943791] CR2: 0000000000000158 CR3: 000000023f807000 CR4: 
00000000000006e0
[69095.944747] DR0: 00007f5410a26000 DR1: 00007fa168c7d000 DR2: 
00007f3d12f06000
[69095.945698] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 
0000000000000600
[69095.946653] Stack:
[69095.947030]  ffffc9007c627bb0 ffffffff8218f131 ffff8801e0be4f18 
0000000000400000
[69095.948221]  0000000000000000 ffffc9007c627c08 ffffc9007c627bf0 
ffffffff82187a33
[69095.949410]  0000000000000000 0000000000000000 ffff88013e944400 
0000000000000000
[69095.950600] Call Trace:
[69095.951029]  [<ffffffff8218f131>] unlink_file_vma+0x41/0x60
[69095.951813]  [<ffffffff82187a33>] free_pgtables+0x43/0x120
[69095.952578]  [<ffffffff82190cb2>] exit_mmap+0xb2/0x150
[69095.953311]  [<ffffffff820562eb>] mmput+0x3b/0x100
[69095.954000]  [<ffffffff8205de55>] do_exit+0x255/0xb20
[69095.954715]  [<ffffffff8205e7a3>] do_group_exit+0x43/0xb0
[69095.955466]  [<ffffffff82069f5e>] get_signal+0x29e/0x630
[69095.956216]  [<ffffffff8201a0b8>] do_signal+0x28/0x670
[69095.956942]  [<ffffffff8218a56f>] ? handle_mm_fault+0x8af/0xce0
[69095.957756]  [<ffffffff8214f0c9>] ? __perf_sw_event+0x59/0x90
[69095.958548]  [<ffffffff820fb270>] ? __audit_syscall_exit+0x230/0x2c0
[69095.959410]  [<ffffffff820022b0>] exit_to_usermode_loop+0x80/0xc0
[69095.960243]  [<ffffffff82002cc5>] do_syscall_64+0x145/0x1a0
[69095.961023]  [<ffffffff825d9fc4>] entry_SYSCALL64_slow_path+0x25/0x25
[69095.961894] Code: 3d 00 20 00 00 48 0f 47 c2 48 89 05 6d db 95 00 31 
c0 c3 66 90 0f 1f 44 00 00 48 8b 47 50 55 48 89 e5 f6 c4 08 74 0f 48 8b 
46 20 <f0> ff 80 58 01 00 00 48 8b 47 50 a8 08 74 04 f0 ff 4a 1c 48 8d
[69095.965626] RIP  [<ffffffff8218e7b6>] __remove_shared_vm_struct+0x16/0x40
[69095.966555]  RSP <ffffc9007c627b80>
[69095.977590] CR2: 0000000000000158
[69095.978460] ---[ end trace fe244491d619cdbd ]---
[69095.979178] Fixing recursive fault but reboot is needed!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
