From: Borislav Petkov <bp@alien8.de>
Subject: khugepaged+0x5a6/0x1800 - BUG: unable to handle kernel NULL pointer
 dereference at   (null)
Date: Fri, 22 Jan 2016 19:14:50 +0100
Message-ID: <20160122181450.GI9806@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

Hi guys,

I'm getting this null ptr deref below ontop of latest Linus, i.e.
top-commit is:

2b4015e9fb33 ("Merge tag 'platform-drivers-x86-v4.5-1' of git://git.infradead.org/users/dvhart/linux-platform-drivers-x86")

The good thing is, it is reproducible even in kvm, 32-bit guest.

Thoughts?

[    6.058923] BUG: unable to handle kernel NULL pointer dereference at   (null)
[    6.059496] IP: [<c119eea6>] khugepaged+0x5a6/0x1800
[    6.059496] *pde = 00000000 
[    6.059496] Oops: 0000 [#1] PREEMPT SMP 
[    6.059496] Modules linked in:
[    6.059496] CPU: 2 PID: 33 Comm: khugepaged Not tainted 4.4.0+ #2
[    6.059496] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[    6.059496] task: f5222e80 ti: f522a000 task.ti: f522a000
[    6.059496] EIP: 0060:[<c119eea6>] EFLAGS: 00010246 CPU: 2
[    6.059496] EIP is at khugepaged+0x5a6/0x1800
[    6.059496] EAX: 00000000 EBX: 00000003 ECX: 00000000 EDX: 00000000
[    6.059496] ESI: f40412c0 EDI: f451cf00 EBP: f522bf30 ESP: f522be88
[    6.059496]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[    6.059496] CR0: 80050033 CR2: 00000000 CR3: 3410f000 CR4: 000406d0
[    6.059496] Stack:
[    6.059496]  00000000 f57c1780 f511be00 f522be9c f57c1780 f522bea8 c1697c52 f57c1780
[    6.059496]  f522bee0 f451cf34 f5222e80 00000001 f61e5000 c107d930 f40412c0 f451cf54
[    6.059496]  00000000 00002000 f5222e80 f5222e80 00000000 00000000 b6400000 00002000
[    6.059496] Call Trace:
[    6.059496]  [<c1697c52>] ? _raw_spin_unlock_irq+0x32/0x50
[    6.059496]  [<c107d930>] ? finish_task_switch+0x60/0x260
[    6.059496]  [<c109b120>] ? wait_woken+0x80/0x80
[    6.059496]  [<c119e900>] ? unfreeze_page+0x430/0x430
[    6.059496]  [<c1076383>] kthread+0xb3/0xd0
[    6.059496]  [<c16984c9>] ret_from_kernel_thread+0x21/0x38
[    6.059496]  [<c10762d0>] ? kthread_create_on_node+0x180/0x180
[    6.059496] Code: 75 0b 8b 41 14 a8 01 0f 84 60 01 00 00 89 4d c4 89 4d a8 c7 45 c8 0d 00 00 00 89 f8 e8 84 8c 4f 00 c7 45 ac 00 00 00 00 8b 45 c4 <8b> 00 c1 e8 1a 8b 04 c5 c0 3f 44 c2 89 45 98 3e 8d 74 26 00 64
[    6.059496] EIP: [<c119eea6>] khugepaged+0x5a6/0x1800 SS:ESP 0068:f522be88
[    6.059496] CR2: 0000000000000000
[    6.059496] ---[ end trace 71a830f72f820be9 ]---

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
