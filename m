Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 176178D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 08:11:29 -0400 (EDT)
Date: Mon, 25 Apr 2011 14:11:14 +0200
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110425141114.73539b2c@neptune.home>
In-Reply-To: <BANLkTikpt7E5eE9vv9NFbNAwT_O6sHnQvA@mail.gmail.com>
References: <20110424202158.45578f31@neptune.home>
	<20110424235928.71af51e0@neptune.home>
	<20110425114429.266A.A69D9226@jp.fujitsu.com>
	<BANLkTinVQtLbmBknBZeY=7w7AOyQk61Pew@mail.gmail.com>
	<20110425111705.786ef0c5@neptune.home>
	<BANLkTi=2DK+iq-5NEFKexe0QhpW8G0RL8Q@mail.gmail.com>
	<20110425123444.639aad34@neptune.home>
	<20110425134145.048f7cc1@neptune.home>
	<BANLkTikpt7E5eE9vv9NFbNAwT_O6sHnQvA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Nick Piggin <nickpiggin@yahoo.com.au>

On Mon, 25 April 2011 Pekka Enberg wrote:
> On Mon, Apr 25, 2011 at 2:41 PM, Bruno Pr=C3=A9mont wrote:
> >> Hm, seems not to be willing to let me run kmemleak... each time I put
> >> on my load scenario I get "BUG: unable to handle kernel " on console
> >> as a last breath from the system. (the rest of the trace never shows u=
p)
> >>
> >> Going to try harder to get at least a complete trace...
> >
> > After many attempts I got something from kmemleak (running on VESAfb
> > instead of vgacon or nouveau KMS), netconsole disabled.
> > For the crashes my screen is just too small to display the interesting
> > part of it (maybe I can get it via serial console at a later attempt)
> >

...

> Btw, did you manage to grab any kmemleak related crashes? It
> would be good to get them fixed as well.

(after plugging in serial cable and hooking it to minicom)
With serial console I got the crash (unless more are waiting behind):

[  290.477295] cc1 used greatest stack depth: 4972 bytes left
[  304.476261] cc1plus used greatest stack depth: 4916 bytes left
[  314.573703] BUG: unable to handle kernel NULL pointer dereference at 000=
00001
[  314.580013] IP: [<c10b0aea>] kmem_cache_alloc+0x4a/0x120
[  314.580013] *pde =3D 00000000=20
[  314.580013] Oops: 0000 [#1]=20
[  314.580013] last sysfs file: /sys/devices/platform/w83627hf.656/temp3_in=
put
[  314.580013] Modules linked in: squashfs zlib_inflate nfs lockd nfs_acl s=
unrpc snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm snd_timer snd pcspkr snd=
_page_alloc
[  314.580013]=20
[  314.580013] Pid: 2119, comm: configure Tainted: G        W   2.6.39-rc4-=
jupiter-00187-g686c4cb #3 NVIDIA Corporation. nFORCE-MCP/MS-6373
[  314.580013] EIP: 0060:[<c10b0aea>] EFLAGS: 00210246 CPU: 0
[  314.580013] EIP is at kmem_cache_alloc+0x4a/0x120
[  314.580013] EAX: ddc25718 EBX: dd406100 ECX: c10b75f9 EDX: 00000000
[  314.580013] ESI: 00000001 EDI: 000112d0 EBP: db1ebe34 ESP: db1ebe08
[  314.580013]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[  314.580013] Process configure (pid: 2119, ti=3Ddb1ea000 task=3Ddb144d00 =
task.ti=3Ddb1ea000)
[  314.580013] Stack:
[  314.580013]  dc688510 c6df1690 c6df16a4 c10b75f9 db1ebe4c 00200286 00000=
000 001aa464
[  314.580013]  000000d0 00000001 db31a738 db1ebe68 c10b75f9 00000000 00000=
0d0 dc688510
[  314.580013]  00000010 db1ebe5c c138aae7 000000d0 dd406280 000000d0 db31a=
738 000000d0
[  314.580013] Call Trace:
[  314.580013]  [<c10b75f9>] ? create_object+0x29/0x210
[  314.580013]  [<c10b75f9>] create_object+0x29/0x210
[  314.580013]  [<c138aae7>] ? kmemleak_alloc+0x27/0x50
[  314.580013]  [<c138aae7>] kmemleak_alloc+0x27/0x50
[  314.580013]  [<c10b0b28>] kmem_cache_alloc+0x88/0x120
[  314.580013]  [<c10a60a0>] ? anon_vma_fork+0x50/0xe0
[  314.580013]  [<c10a6022>] ? anon_vma_clone+0x82/0xb0
[  314.580013]  [<c10a60a0>] anon_vma_fork+0x50/0xe0
[  314.580013]  [<c102c411>] dup_mm+0x1d1/0x440
[  314.580013]  [<c102d11d>] copy_process+0x98d/0xcc0
[  314.580013]  [<c102d4a7>] do_fork+0x57/0x2e0
[  314.580013]  [<c11c4cc4>] ? copy_to_user+0x34/0x130
[  314.580013]  [<c11c4cc4>] ? copy_to_user+0x34/0x130
[  314.580013]  [<c1008b6f>] sys_clone+0x2f/0x40
[  314.580013]  [<c139469d>] ptregs_clone+0x15/0x38
[  314.580013]  [<c13945d0>] ? sysenter_do_call+0x12/0x26
[  314.580013] Code: 0f 85 8b 00 00 00 8b 03 8b 50 04 89 55 f0 8b 30 85 f6 =
0f 84 97 00 00 00 8b 03 8b 10 39 d6 75 e8 8b 50 04 39 55 f0 75 e0 8b 53 14 =
<8b> 14 16 89 10 8b 55 f0 8b 03 42 89 50 04 85 f6 89 f8 0f 95 c2=20
[  314.580013] EIP: [<c10b0aea>] kmem_cache_alloc+0x4a/0x120 SS:ESP 0068:db=
1ebe08
[  314.580013] CR2: 0000000000000001
[  315.060947] BUG: unable to handle kernel NULL pointer dereference at 000=
00001
[  315.070927] IP: [<c10b0aea>] kmem_cache_alloc+0x4a/0x120
[  315.070927] *pde =3D 00000000=20
[  315.070927] Oops: 0000 [#2]=20
[  315.070927] last sysfs file: /sys/devices/platform/w83627hf.656/temp3_in=
put
[  315.070927] Modules linked in: squashfs zlib_inflate nfs lockd nfs_acl s=
unrpc snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm snd_timer snd pcspkr snd=
_page_alloc
[  315.070927]=20
[  315.070927] Pid: 2119, comm: configure Tainted: G      D W   2.6.39-rc4-=
jupiter-00187-g686c4cb #3 NVIDIA Corporation. nFORCE-MCP/MS-6373
[  315.070927] EIP: 0060:[<c10b0aea>] EFLAGS: 00210046 CPU: 0
[  315.070927] EIP is at kmem_cache_alloc+0x4a/0x120
[  315.070927] EAX: ddc25718 EBX: dd406100 ECX: c10b75f9 EDX: 00000000
[  315.070927] ESI: 00000001 EDI: 00011220 EBP: db1ebad0 ESP: db1ebaa4
[  315.070927]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[  315.070927] Process configure (pid: 2119, ti=3Ddb1ea000 task=3Ddb144d00 =
task.ti=3Ddb1ea000)
[  315.070927] Stack:
[  315.070927]  1d424de4 00000048 0060a459 00000000 49e0f2ff 00000007 00000=
00e 001aa464
[  315.070927]  00000020 00000001 dc5d8630 db1ebb04 c10b75f9 00a8b6a4 00000=
000 69e595ce
[  315.070927]  00000090 db144d00 db4248a0 db1ebb14 c1025d9f 00000020 dc5d8=
630 00000020
[  315.070927] Call Trace:
[  315.070927]  [<c10b75f9>] create_object+0x29/0x210
[  315.070927]  [<c1025d9f>] ? check_preempt_wakeup+0xcf/0x160
[  315.070927]  [<c138aae7>] kmemleak_alloc+0x27/0x50
[  315.070927]  [<c10b0b28>] kmem_cache_alloc+0x88/0x120
[  315.070927]  [<c103c755>] __sigqueue_alloc+0x45/0xc0
[  315.070927]  [<c103d4cd>] T.792+0x9d/0x290
[  315.070927]  [<c103e234>] do_send_sig_info+0x44/0x60
[  315.070927]  [<c103e53a>] group_send_sig_info+0x3a/0x50
[  315.070927]  [<c103e60f>] kill_pid_info+0x2f/0x50
[  315.070927]  [<c1031843>] it_real_fn+0x33/0x80
[  315.070927]  [<c1031810>] ? alarm_setitimer+0x60/0x60
[  315.070927]  [<c104b1c4>] __run_hrtimer+0x64/0x1a0
[  315.070927]  [<c10503c5>] ? ktime_get+0x55/0xf0
[  315.070927]  [<c104b555>] hrtimer_interrupt+0x115/0x250
[  315.070927]  [<c104d415>] ? sched_clock_cpu+0x95/0x110
[  315.070927]  [<c10187a1>] smp_apic_timer_interrupt+0x41/0x80
[  315.070927]  [<c139417e>] apic_timer_interrupt+0x2a/0x30
[  315.070927]  [<c100519a>] ? oops_end+0x4a/0xb0
[  315.070927]  [<c101eb6e>] no_context+0xbe/0x150
[  315.070927]  [<c101ec8f>] __bad_area_nosemaphore+0x8f/0x130
[  315.070927]  [<c108b81d>] ? __alloc_pages_nodemask+0xdd/0x730
[  315.070927]  [<c105b222>] ? search_module_extables+0x62/0x80
[  315.070927]  [<c101ed42>] bad_area_nosemaphore+0x12/0x20
[  315.070927]  [<c101f2d1>] do_page_fault+0x2f1/0x3d0
[  315.070927]  [<c105a57b>] ? __module_text_address+0xb/0x50
[  315.070927]  [<c105a5c8>] ? is_module_text_address+0x8/0x10
[  315.070927]  [<c1045207>] ? __kernel_text_address+0x47/0x70
[  315.070927]  [<c1005441>] ? print_context_stack+0x41/0xb0
[  315.070927]  [<c101efe0>] ? vmalloc_sync_all+0x100/0x100
[  315.070927]  [<c139436c>] error_code+0x58/0x60
[  315.070927]  [<c10b75f9>] ? create_object+0x29/0x210
[  315.070927]  [<c101efe0>] ? vmalloc_sync_all+0x100/0x100
[  315.070927]  [<c10b0aea>] ? kmem_cache_alloc+0x4a/0x120
[  315.070927]  [<c10b75f9>] ? create_object+0x29/0x210
[  315.070927]  [<c10b75f9>] create_object+0x29/0x210
[  315.070927]  [<c138aae7>] ? kmemleak_alloc+0x27/0x50
[  315.070927]  [<c138aae7>] kmemleak_alloc+0x27/0x50
[  315.070927]  [<c10b0b28>] kmem_cache_alloc+0x88/0x120
[  315.070927]  [<c10a60a0>] ? anon_vma_fork+0x50/0xe0
[  315.070927]  [<c10a6022>] ? anon_vma_clone+0x82/0xb0
[  315.070927]  [<c10a60a0>] anon_vma_fork+0x50/0xe0
[  315.070927]  [<c102c411>] dup_mm+0x1d1/0x440
[  315.070927]  [<c102d11d>] copy_process+0x98d/0xcc0
[  315.070927]  [<c102d4a7>] do_fork+0x57/0x2e0
[  315.070927]  [<c11c4cc4>] ? copy_to_user+0x34/0x130
[  315.070927]  [<c11c4cc4>] ? copy_to_user+0x34/0x130
[  315.070927]  [<c1008b6f>] sys_clone+0x2f/0x40
[  315.070927]  [<c139469d>] ptregs_clone+0x15/0x38
[  315.070927]  [<c13945d0>] ? sysenter_do_call+0x12/0x26
[  315.070927] Code: 0f 85 8b 00 00 00 8b 03 8b 50 04 89 55 f0 8b 30 85 f6 =
0f 84 97 00 00 00 8b 03 8b 10 39 d6 75 e8 8b 50 04 39 55 f0 75 e0 8b 53 14 =
<8b> 14 16 89 10 8b 55 f0 8b 03 42 89 50 04 85 f6 89 f8 0f 95 c2=20
[  315.070927] EIP: [<c10b0aea>] kmem_cache_alloc+0x4a/0x120 SS:ESP 0068:db=
1ebaa4
[  315.070927] CR2: 0000000000000001
[  315.070927] ---[ end trace 009f60096033f2b2 ]---
[  315.070927] Kernel panic - not syncing: Fatal exception in interrupt
[  315.070927] Pid: 2119, comm: configure Tainted: G      D W   2.6.39-rc4-=
jupiter-00187-g686c4cb #3
[  315.070927] Call Trace:
[  315.070927]  [<c139244c>] panic+0x57/0x14c
[  315.070927]  [<c10051fb>] oops_end+0xab/0xb0
[  315.070927]  [<c101eb6e>] no_context+0xbe/0x150
[  315.070927]  [<c101ec8f>] __bad_area_nosemaphore+0x8f/0x130
[  315.070927]  [<c101ed42>] bad_area_nosemaphore+0x12/0x20
[  315.070927]  [<c101f234>] do_page_fault+0x254/0x3d0
[  315.070927]  [<c11e7a52>] ? bit_putcs+0x2a2/0x430
[  315.070927]  [<c101efe0>] ? vmalloc_sync_all+0x100/0x100
[  315.070927]  [<c139436c>] error_code+0x58/0x60
[  315.070927]  [<c10b75f9>] ? create_object+0x29/0x210
[  315.070927]  [<c101efe0>] ? vmalloc_sync_all+0x100/0x100
[  315.070927]  [<c10b0aea>] ? kmem_cache_alloc+0x4a/0x120
[  315.070927]  [<c10b75f9>] create_object+0x29/0x210
[  315.070927]  [<c1025d9f>] ? check_preempt_wakeup+0xcf/0x160
[  315.070927]  [<c138aae7>] kmemleak_alloc+0x27/0x50
[  315.070927]  [<c10b0b28>] kmem_cache_alloc+0x88/0x120
[  315.070927]  [<c103c755>] __sigqueue_alloc+0x45/0xc0
[  315.070927]  [<c103d4cd>] T.792+0x9d/0x290
[  315.070927]  [<c103e234>] do_send_sig_info+0x44/0x60
[  315.070927]  [<c103e53a>] group_send_sig_info+0x3a/0x50
[  315.070927]  [<c103e60f>] kill_pid_info+0x2f/0x50
[  315.070927]  [<c1031843>] it_real_fn+0x33/0x80
[  315.070927]  [<c1031810>] ? alarm_setitimer+0x60/0x60
[  315.070927]  [<c104b1c4>] __run_hrtimer+0x64/0x1a0
[  315.070927]  [<c10503c5>] ? ktime_get+0x55/0xf0
[  315.070927]  [<c104b555>] hrtimer_interrupt+0x115/0x250
[  315.070927]  [<c104d415>] ? sched_clock_cpu+0x95/0x110
[  315.070927]  [<c10187a1>] smp_apic_timer_interrupt+0x41/0x80
[  315.070927]  [<c139417e>] apic_timer_interrupt+0x2a/0x30
[  315.070927]  [<c100519a>] ? oops_end+0x4a/0xb0
[  315.070927]  [<c101eb6e>] no_context+0xbe/0x150
[  315.070927]  [<c101ec8f>] __bad_area_nosemaphore+0x8f/0x130
[  315.070927]  [<c108b81d>] ? __alloc_pages_nodemask+0xdd/0x730
[  315.070927]  [<c105b222>] ? search_module_extables+0x62/0x80
[  315.070927]  [<c101ed42>] bad_area_nosemaphore+0x12/0x20
[  315.070927]  [<c101f2d1>] do_page_fault+0x2f1/0x3d0
[  315.070927]  [<c105a57b>] ? __module_text_address+0xb/0x50
[  315.070927]  [<c105a5c8>] ? is_module_text_address+0x8/0x10
[  315.070927]  [<c1045207>] ? __kernel_text_address+0x47/0x70
[  315.070927]  [<c1005441>] ? print_context_stack+0x41/0xb0
[  315.070927]  [<c101efe0>] ? vmalloc_sync_all+0x100/0x100
[  315.070927]  [<c139436c>] error_code+0x58/0x60
[  315.070927]  [<c10b75f9>] ? create_object+0x29/0x210
[  315.070927]  [<c101efe0>] ? vmalloc_sync_all+0x100/0x100
[  315.070927]  [<c10b0aea>] ? kmem_cache_alloc+0x4a/0x120
[  315.070927]  [<c10b75f9>] ? create_object+0x29/0x210
[  315.070927]  [<c10b75f9>] create_object+0x29/0x210
[  315.070927]  [<c138aae7>] ? kmemleak_alloc+0x27/0x50
[  315.070927]  [<c138aae7>] kmemleak_alloc+0x27/0x50
[  315.070927]  [<c10b0b28>] kmem_cache_alloc+0x88/0x120
[  315.070927]  [<c10a60a0>] ? anon_vma_fork+0x50/0xe0
[  315.070927]  [<c10a6022>] ? anon_vma_clone+0x82/0xb0
[  315.070927]  [<c10a60a0>] anon_vma_fork+0x50/0xe0
[  315.070927]  [<c102c411>] dup_mm+0x1d1/0x440
[  315.070927]  [<c102d11d>] copy_process+0x98d/0xcc0
[  315.070927]  [<c102d4a7>] do_fork+0x57/0x2e0
[  315.070927]  [<c11c4cc4>] ? copy_to_user+0x34/0x130
[  315.070927]  [<c11c4cc4>] ? copy_to_user+0x34/0x130
[  315.070927]  [<c1008b6f>] sys_clone+0x2f/0x40
[  315.070927]  [<c139469d>] ptregs_clone+0x15/0x38
[  315.070927]  [<c13945d0>] ? sysenter_do_call+0x12/0x26

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
