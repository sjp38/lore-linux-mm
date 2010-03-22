Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3CC2D6B01BE
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 13:31:29 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <ee036db9-1694-4f2c-99f5-a02be3001b66@default>
Date: Mon, 22 Mar 2010 10:30:29 -0700 (PDT)
From: =?UTF-8?B?IsOWemfDvHIgWcO8a3NlbCI=?= <ozgur.yuksel@oracle.com>
Subject: Re: [Bugme-new] [Bug 15610] New: fsck leads to swapper - BUG: unable
 to handle kernel NULL pointer dereference & panic
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org
List-ID: <linux-mm.kvack.org>


----- Original Message -----
From: akpm@linux-foundation.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, =
ozgur.yuksel@oracle.com
Sent: Monday, March 22, 2010 7:11:32 PM GMT +02:00 Athens, Beirut, Buchares=
t, Istanbul
Subject: Re: [Bugme-new] [Bug 15610] New: fsck leads to swapper - BUG: unab=
le to handle kernel NULL pointer dereference & panic


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

This is a post-2.6.33 regression.

On Mon, 22 Mar 2010 15:59:44 GMT bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=3D15610
>=20
>            Summary: fsck leads to swapper - BUG: unable to handle kernel
>                     NULL pointer dereference & panic
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 2.6.34-rc2-220bf991b0366cc50a94feede3d7341fa5710ee4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: ozgur.yuksel@oracle.com
>         Regression: No
>=20
>=20
> During fsck.ext3 being performed (even with regular / clean forced runs),=
 we
> get a swapper crash:
> [  159.557737] BUG: unable to handle kernel NULL pointer dereference at (=
null)
> [  159.561687] IP: [<c01304aa>] __wake_up_common+0x1a/0x70

err, what the heck?  zone->wait_table didn't get initialised?  I can't
think of anything we did which might have caused that.  Sorry to have
to ask this, but...  would it be possible for you to do a bisection of
this?  http://landley.net/writing/git-quick.html has some tips.

Thanks.

Sure. I'll give it a shot.
Cheers,
Ozgur

> [  159.561687] *pdpt =3D 0000000000853001 *pde =3D 0000000000000000
> [  159.561687] Oops: 0000 [#1] SMP
> [  159.561687] last sysfs file: /sys/kernel/uevent_seqnum
> [  159.561687] Modules linked in: snd_hda_codec_idt snd_hda_intel snd_hda=
_codec
> snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcmt
> [  159.561687]
> [  159.561687] Pid: 0, comm: swapper Not tainted 2.6.34-rc2 #10 0KU184/La=
titude
> D630
> [  159.561687] EIP: 0060:[<c01304aa>] EFLAGS: 00010086 CPU: 1
> [  159.561687] EIP is at __wake_up_common+0x1a/0x70
> [  159.561687] EAX: c4f32f00 EBX: fffffff4 ECX: 00000001 EDX: 00000000
> [  159.561687] ESI: 00000003 EDI: 00000096 EBP: f747bc84 ESP: f747bc68
> [  159.561687]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> [  159.561687] Process swapper (pid: 0, ti=3Df747a000 task=3Df743e600
> task.ti=3Df747a000)
> [  159.561687] Stack:
> [  159.561687]  f747bc70 00000001 00000003 c058d79a c4f32efc 00000003 000=
00096
> f747bca4
> [  159.561687] <0> c0136cd7 00000000 f747bcb0 00000001 c0e00000 c07b2700
> c0e00000 f747bcb8
> [  159.561687] <0> c0161689 f747bcb0 c0e00000 00000002 f747bcc8 c01616ea
> c0e00000 c539be20
> [  159.561687] Call Trace:
> [  159.561687]  [<c058d79a>] ? _raw_spin_lock_irqsave+0x2a/0x40
> [  159.561687]  [<c0136cd7>] ? __wake_up+0x37/0x50
> [  159.561687]  [<c0161689>] ? __wake_up_bit+0x29/0x30
> [  159.561687]  [<c01616ea>] ? wake_up_bit+0x5a/0x60
> [  159.561687]  [<c02199b1>] ? unlock_buffer+0x11/0x20
> [  159.561687]  [<c0219b72>] ? end_buffer_async_read+0x62/0x120
> [  159.561687]  [<c02191de>] ? end_bio_bh_io_sync+0x1e/0x40
> [  159.561687]  [<c021cd35>] ? bio_endio+0x15/0x30
> [  159.561687]  [<c030fb22>] ? req_bio_endio+0xa2/0x100
> [  159.561687]  [<c0310889>] ? blk_update_request+0xe9/0x3e0
> [  159.561687]  [<c011df46>] ? lapic_next_event+0x16/0x20
> [  159.561687]  [<c016f6c7>] ? clockevents_program_event+0x87/0x140
> [  159.561687]  [<c0310b96>] ? blk_update_bidi_request+0x16/0x60
> [  159.561687]  [<c0311ad3>] ? blk_end_bidi_request+0x23/0x70
> [  159.561687]  [<c0311b72>] ? blk_end_request+0x12/0x20
> [  159.561687]  [<c03d1afe>] ? scsi_io_completion+0x8e/0x550
> [  159.561687]  [<c03f9068>] ? ata_sff_hsm_move+0x188/0x770
> [  159.561687]  [<c03d1953>] ? scsi_device_unbusy+0x93/0xa0
> [  159.561687]  [<c03ca5a8>] ? scsi_finish_command+0x98/0x100
> [  159.561687]  [<c03ce0ad>] ? scsi_decide_disposition+0x16d/0x1a0
> [  159.561687]  [<c03d20db>] ? scsi_softirq_done+0x10b/0x130
> [  159.561687]  [<c0317122>] ? blk_done_softirq+0x62/0x70
> [  159.561687]  [<c014c4f0>] ? __do_softirq+0x90/0x1a0
> [  159.561687]  [<c0120e4a>] ? ack_apic_level+0x6a/0x200
> [  159.561687]  [<c014c63d>] ? do_softirq+0x3d/0x40
> [  159.561687]  [<c014c79d>] ? irq_exit+0x5d/0x70
> [  159.561687]  [<c01044e0>] ? do_IRQ+0x50/0xc0
> [  159.561687]  [<c0167694>] ? sched_clock_local+0xa4/0x180
> [  159.561687]  [<c01035b0>] ? common_interrupt+0x30/0x40
> [  159.561687]  [<c016007b>] ? parse_args+0x23b/0x2d0
> [  159.561687]  [<c037d4ae>] ? acpi_idle_enter_bm+0x25e/0x28f
> [  159.561687]  [<c0486b6e>] ? cpuidle_idle_call+0x6e/0xf0
> [  159.561687]  [<c0101d0c>] ? cpu_idle+0x8c/0xd0
> [  159.561687]  [<c05888eb>] ? start_secondary+0x1f5/0x1fb
> [  159.561687] Code: 90 55 89 e5 e8 68 ff ff ff 5d c3 8d b6 00 00 00 00 5=
5 89
> e5 57 56 53 83 ec 10 89 55 ec 89 4d e8 8b 50
> [  159.561687] EIP: [<c01304aa>] __wake_up_common+0x1a/0x70 SS:ESP
> 0068:f747bc68
> [  159.561687] CR2: 0000000000000000
> [  159.561687] ---[ end trace 0fd75502f6ca2e6e ]---
>=20
> and panic:
> [  159.561687] Kernel panic - not syncing: Fatal exception in interrupt
> [  159.561687] Pid: 0, comm: swapper Tainted: G      D    2.6.34-rc2 #10
> [  159.561687] Call Trace:
> [  159.561687]  [<c058b0a7>] ? printk+0x18/0x21
> [  159.561687]  [<c058b01e>] panic+0x42/0xb3
> [  159.561687]  [<c058ef87>] oops_end+0x97/0xa0
> [  159.561687]  [<c0128e8e>] no_context+0xbe/0x190
> [  159.561687]  [<c0128f97>] __bad_area_nosemaphore+0x37/0x160
> [  159.561687]  [<c013fd41>] ? enqueue_task_fair+0x41/0x90
> [  159.561687]  [<c012f649>] ? enqueue_task+0x79/0x90
> [  159.561687]  [<c01290d2>] bad_area_nosemaphore+0x12/0x20
> [  159.561687]  [<c0591106>] do_page_fault+0x2f6/0x380
> [  159.561687]  [<c013ae5c>] ? try_to_wake_up+0x2bc/0x430
> [  159.561687]  [<c0590e10>] ? do_page_fault+0x0/0x380
> [  159.561687]  [<c058e463>] error_code+0x73/0x80
> [  159.561687]  [<c013007b>] ? __sched_fork+0xcb/0x2b0
> [  159.561687]  [<c01304aa>] ? __wake_up_common+0x1a/0x70
> [  159.561687]  [<c058d79a>] ? _raw_spin_lock_irqsave+0x2a/0x40
> [  159.561687]  [<c0136cd7>] __wake_up+0x37/0x50
> [  159.561687]  [<c0161689>] __wake_up_bit+0x29/0x30
> [  159.561687]  [<c01616ea>] wake_up_bit+0x5a/0x60
> [  159.561687]  [<c02199b1>] unlock_buffer+0x11/0x20
> [  159.561687]  [<c0219b72>] end_buffer_async_read+0x62/0x120
> [  159.561687]  [<c02191de>] end_bio_bh_io_sync+0x1e/0x40
> [  159.561687]  [<c021cd35>] bio_endio+0x15/0x30
> [  159.561687]  [<c030fb22>] req_bio_endio+0xa2/0x100
> [  159.561687]  [<c0310889>] blk_update_request+0xe9/0x3e0
> [  159.561687]  [<c011df46>] ? lapic_next_event+0x16/0x20
> [  159.561687]  [<c016f6c7>] ? clockevents_program_event+0x87/0x140
> [  159.561687]  [<c0310b96>] blk_update_bidi_request+0x16/0x60
> [  159.561687]  [<c0311ad3>] blk_end_bidi_request+0x23/0x70
> [  159.561687]  [<c0311b72>] blk_end_request+0x12/0x20
> [  159.561687]  [<c03d1afe>] scsi_io_completion+0x8e/0x550
> [  159.561687]  [<c03f9068>] ? ata_sff_hsm_move+0x188/0x770
> [  159.561687]  [<c03d1953>] ? scsi_device_unbusy+0x93/0xa0
> [  159.561687]  [<c03ca5a8>] scsi_finish_command+0x98/0x100
> [  159.561687]  [<c03ce0ad>] ? scsi_decide_disposition+0x16d/0x1a0
> [  159.561687]  [<c03d20db>] scsi_softirq_done+0x10b/0x130
> [  159.561687]  [<c0317122>] blk_done_softirq+0x62/0x70
> [  159.561687]  [<c014c4f0>] __do_softirq+0x90/0x1a0
> [  159.561687]  [<c0120e4a>] ? ack_apic_level+0x6a/0x200
> [  159.561687]  [<c014c63d>] do_softirq+0x3d/0x40
> [  159.561687]  [<c014c79d>] irq_exit+0x5d/0x70
> [  159.561687]  [<c01044e0>] do_IRQ+0x50/0xc0
> [  159.561687]  [<c0167694>] ? sched_clock_local+0xa4/0x180
> [  159.561687]  [<c01035b0>] common_interrupt+0x30/0x40
> [  159.561687]  [<c016007b>] ? parse_args+0x23b/0x2d0
> [  159.561687]  [<c037d4ae>] ? acpi_idle_enter_bm+0x25e/0x28f
> [  159.561687]  [<c0486b6e>] cpuidle_idle_call+0x6e/0xf0
> [  159.561687]  [<c0101d0c>] cpu_idle+0x8c/0xd0
> [  159.561687]  [<c05888eb>] start_secondary+0x1f5/0x1fb
> [  159.561687] [drm:drm_fb_helper_panic] *ERROR* panic occurred, switchin=
g back
> to text console
> ...
> full serial console dump to be attached.
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
