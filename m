From: Sasha Levin <levinsasha928@gmail.com>
Subject: Early boot panic on machine with lots of memory
Date: Wed, 13 Jun 2012 23:38:55 +0200
Message-ID: <1339623535.3321.4.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, hpa@linux.intel.com
Cc: linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Hi all,

I'm seeing the following when booting a KVM guest with 65gb of RAM, on latest linux-next.

Note that it happens with numa=off.

[    0.000000] BUG: unable to handle kernel paging request at ffff88102febd948
[    0.000000] IP: [<ffffffff836a6f37>] __next_free_mem_range+0x9b/0x155
[    0.000000] PGD 4826063 PUD cf67a067 PMD cf7fa067 PTE 800000102febd160
[    0.000000] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[    0.000000] CPU 0 
[    0.000000] Pid: 0, comm: swapper Not tainted 3.5.0-rc2-next-20120612-sasha-00015-g996227e #395  
[    0.000000] RIP: 0010:[<ffffffff836a6f37>]  [<ffffffff836a6f37>] __next_free_mem_range+0x9b/0x155
[    0.000000] RSP: 0000:ffffffff84801db8  EFLAGS: 00010006
[    0.000000] RAX: 0000000000000109 RBX: 000000000000011a RCX: 0000000000000000
[    0.000000] RDX: 0000000000000109 RSI: 0000000000000400 RDI: ffffffff84801e60
[    0.000000] RBP: ffffffff84801e18 R08: ffff88102febd958 R09: 0000000100000000
[    0.000000] R10: 0000001030000000 R11: 0000000000000119 R12: ffff88102febc080
[    0.000000] R13: ffffffff84e1beb0 R14: 0000000000000000 R15: 0000000000000002
[    0.000000] FS:  0000000000000000(0000) GS:ffff880fcfa00000(0000) knlGS:0000000000000000
[    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    0.000000] CR2: ffff88102febd948 CR3: 0000000004825000 CR4: 00000000000006b0
[    0.000000] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    0.000000] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[    0.000000] Process swapper (pid: 0, threadinfo ffffffff84800000, task ffffffff8482d400)
[    0.000000] Stack:
[    0.000000]  0000000000000000 ffffffff84801e68 ffffffff84801e70 ffffffff84801e60
[    0.000000]  ffffffff84e1be80 0000000000000003 0000010900000002 0000000000f9122f
[    0.000000]  ffffffff84801e60 ffffffff84801e70 ffffffff84801e68 ffffea0000000000
[    0.000000] Call Trace:
[    0.000000]  [<ffffffff850e8a98>] free_low_memory_core_early+0x1e4/0x206
[    0.000000]  [<ffffffff850dab50>] numa_free_all_bootmem+0x82/0x8e
[    0.000000]  [<ffffffff836b4352>] ? bad_to_user+0x149c/0x149c
[    0.000000]  [<ffffffff850d8ff9>] mem_init+0x1e/0xec
[    0.000000]  [<ffffffff850c0eb9>] start_kernel+0x209/0x3e9
[    0.000000]  [<ffffffff850c0ade>] ? kernel_init+0x28a/0x28a
[    0.000000]  [<ffffffff850c0324>] x86_64_start_reservations+0xff/0x104
[    0.000000]  [<ffffffff850c047e>] x86_64_start_kernel+0x155/0x164
[    0.000000] Code: 55 08 81 fe 00 04 00 00 0f 84 9a 00 00 00 41 3b 75 10 0f 85 9c 00 00 00 e9 8b 00 00 00 4c 6b c0 18 31 c9 4f 8d 04 04 85 d2 74 08 <49> 8b 48 f0 49 03 48 e8 48 83 cf ff 4c 39 d8 73 03 49 8b 38 4c 
[    0.000000] RIP  [<ffffffff836a6f37>] __next_free_mem_range+0x9b/0x155
[    0.000000]  RSP <ffffffff84801db8>
[    0.000000] CR2: ffff88102febd948
[    0.000000] ---[ end trace a7919e7f17c0a725 ]---
