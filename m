Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D29946B028A
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 17:52:17 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e6so21976230pfk.2
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 14:52:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k73si15229873pgc.189.2016.10.28.14.52.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Oct 2016 14:52:16 -0700 (PDT)
Date: Fri, 28 Oct 2016 14:52:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 180101] New: BUG: unable to handle kernel paging request
 at x with "mm: remove gup_flags FOLL_WRITE games from __get_user_pages()"
Message-Id: <20161028145215.87fd39d8f8822a2cd11b621c@linux-foundation.org>
In-Reply-To: <bug-180101-27@https.bugzilla.kernel.org/>
References: <bug-180101-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: joe.yasi@gmail.com
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 24 Oct 2016 01:27:15 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=180101
> 
>             Bug ID: 180101
>            Summary: BUG: unable to handle kernel paging request at x with
>                     "mm: remove gup_flags FOLL_WRITE games from
>                     __get_user_pages()"
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.8.4
>           Hardware: x86-64
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>           Assignee: akpm@linux-foundation.org
>           Reporter: joe.yasi@gmail.com
>         Regression: No
> 
> After updating to 4.8.3 and 4.8.4, I am having stability issues. I can also
> reproduce them with 4.7.10. This issue does not occur with 4.8.2. I can also
> not reproduce after reverting the security fix
> 89eeba1594ac641a30b91942961e80fae978f839 "mm: remove gup_flags FOLL_WRITE games
> from __get_user_pages()" with 4.8.4.

That's 19be0eaffa3ac7d8eb ("mm: remove gup_flags FOLL_WRITE games from
__get_user_pages()") in the upstream tree.

I seem to recall a fix for that patch went flying past earlier this
week.  Perhaps Linus recalls?

19be0eaffa3ac7d8eb has gone into a billion -stable trees so we'll need
to be attentive...


> This seems to happen when I'm doing an operation that mmaps a bunch of small
> files like building the kernel or cross-compiling an image for my router. I've
> been able to reliably reproduce it by running "sudo lsof +D /home" a few times
> while building a kernel located in my /home partition. The /home partition is
> btrfs on bcache. The bcache cache device is an Intel SATA SSD, and the backing
> device is an MD RAID 1 array of two 3 TB hard drives.
> 
> I tried to fix it by using the can_follow_write_pte function from the 3.2.83
> version of the patch (243f858d7045b710a31c377112578387ead4dde1) which checks
> PageAnon and !PageKsm instead of pte_dirty, and can't reproduce the issue. If I
> switch back to the mainline 4.8.4 version, I can reproduce it reliably.
> 
> Any idea why pte_dirty is having an issue for me? Something in the
> btrfs/bcache/md layer?
> 
> This bug is triggered:
> Oct 23 14:07:52 hostname kernel: [ 4880.464356] BUG: unable to handle kernel
> paging request at 00007facb85592b6
> Oct 23 14:07:52 hostname kernel: [ 4880.464413] IP: [<ffffffffa1082731>]
> queued_spin_lock_slowpath+0xe1/0x170
> Oct 23 14:07:52 hostname kernel: [ 4880.464463] PGD 7cee19067 PUD 0 
> Oct 23 14:07:52 hostname kernel: [ 4880.464497] Oops: 0002 [#1] PREEMPT SMP
> Oct 23 14:07:52 hostname kernel: [ 4880.464526] Modules linked in: pci_stub
> vboxpci(O) vboxnetadp(O) vboxnetflt(O) vboxdrv(O) rfcomm bnep binfmt_misc vfat
> fat snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic uvcvideo
> videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 videobuf2_core snd_usb_audio
> videodev snd_usbmidi_lib media snd_hda_intel snd_hda_codec snd_hwdep
> snd_hda_core snd_pcm_oss snd_mixer_oss snd_pcm input_leds intel_rapl
> x86_pkg_temp_thermal btusb intel_powerclamp crct10dif_pclmul btrtl btbcm
> efi_pstore crc32_pclmul btintel crc32c_intel bluetooth ghash_clmulni_intel
> aesni_intel aes_x86_64 snd_seq_oss lrw glue_helper ablk_helper cryptd
> intel_cstate snd_seq_midi snd_rawmidi intel_rapl_perf snd_seq_midi_event
> snd_seq efivars snd_seq_device snd_timer snd soundcore wl(PO) cfg80211 rfkill
> sg battery intel_lpss_acpi intel_lpss mfd_core acpi_pad tpm_tis acpi_als
> tpm_tis_core kfifo_buf tpm industrialio nfsd auth_rpcgss coretemp oid_registry
> nfs_acl lockd loop grace sunrpc efivarfs ipv6 crc_ccitt hid_generic usbhid uas
> usb_storage igb e1000e dca ptp mxm_wmi bcache psmouse i915 intel_gtt pps_core
> drm_kms_helper xhci_pci hwmon syscopyarea xhci_hcd sysfillrect sysimgblt
> i2c_algo_bit fb_sys_fops usbcore sr_mod drm cdrom i2c_core usb_common fan
> thermal pinctrl_sunrisepoint wmi video pinctrl_intel button
> Oct 23 14:07:52 hostname kernel: [ 4880.465490] CPU: 3 PID: 1139 Comm: lsof
> Tainted: P           O    4.8.3-customskl #1
> Oct 23 14:07:52 hostname kernel: [ 4880.465540] Hardware name: System
> manufacturer System Product Name/Z170-DELUXE, BIOS 2202 09/19/2016
> Oct 23 14:07:52 hostname kernel: [ 4880.465599] task: ffff9e4a40062640
> task.stack: ffff9e468ef80000
> Oct 23 14:07:52 hostname kernel: [ 4880.465643] RIP: 0010:[<ffffffffa1082731>] 
> [<ffffffffa1082731>] queued_spin_lock_slowpath+0xe1/0x170
> Oct 23 14:07:52 hostname kernel: [ 4880.465705] RSP: 0018:ffff9e468ef83d00 
> EFLAGS: 00010202
> Oct 23 14:07:52 hostname kernel: [ 4880.465742] RAX: 0000000000001fff RBX:
> ffff9e494f7f2718 RCX: ffff9e4b2ecd6ec0
> Oct 23 14:07:52 hostname kernel: [ 4880.465789] RDX: 00007facb85592b6 RSI:
> 0000000080000000 RDI: ffff9e494f7f2718
> Oct 23 14:07:52 hostname kernel: [ 4880.465836] RBP: 0000000000000000 R08:
> 0000000000100000 R09: 0000000000000000
> Oct 23 14:07:52 hostname kernel: [ 4880.465887] R10: 0000000020ab886e R11:
> ffff9e494f7f26f8 R12: 0000000000000000
> Oct 23 14:07:52 hostname kernel: [ 4880.465934] R13: ffff9e494f7f26c0 R14:
> ffff9e468ef83d90 R15: 0000000000000000
> Oct 23 14:07:52 hostname kernel: [ 4880.465981] FS:  00007f3344595800(0000)
> GS:ffff9e4b2ecc0000(0000) knlGS:0000000000000000
> Oct 23 14:07:52 hostname kernel: [ 4880.466033] CS:  0010 DS: 0000 ES: 0000
> CR0: 0000000080050033
> Oct 23 14:07:52 hostname kernel: [ 4880.468745] CR2: 00007facb85592b6 CR3:
> 00000007daf09000 CR4: 00000000003406e0
> Oct 23 14:07:52 hostname kernel: [ 4880.471484] DR0: 0000000000000000 DR1:
> 0000000000000000 DR2: 0000000000000000
> Oct 23 14:07:52 hostname kernel: [ 4880.474221] DR3: 0000000000000000 DR6:
> 00000000fffe0ff0 DR7: 0000000000000400
> Oct 23 14:07:52 hostname kernel: [ 4880.476930] Stack:
> Oct 23 14:07:52 hostname kernel: [ 4880.479644]  ffffffffa13680aa
> 0000000000000000 ffff9e494f7f26c0 ffffffffa1162f3e
> Oct 23 14:07:52 hostname kernel: [ 4880.482419]  ffff9e468ef83d90
> ffff9e494f7f26c0 ffff9e468ef83ea0 0000000000000000
> Oct 23 14:07:52 hostname kernel: [ 4880.485205]  ffff9e468ef83ea0
> ffffffffa11632de ffff9e468ef83d90 ffff9e468ef83d80
> Oct 23 14:07:52 hostname kernel: [ 4880.487984] Call Trace:
> Oct 23 14:07:52 hostname kernel: [ 4880.490774]  [<ffffffffa13680aa>] ?
> lockref_get_not_dead+0x3a/0x80
> Oct 23 14:07:52 hostname kernel: [ 4880.493558]  [<ffffffffa1162f3e>] ?
> unlazy_walk+0xee/0x180
> Oct 23 14:07:52 hostname kernel: [ 4880.496362]  [<ffffffffa11632de>] ?
> complete_walk+0x2e/0x70
> Oct 23 14:07:52 hostname kernel: [ 4880.499166]  [<ffffffffa1165453>] ?
> path_lookupat+0x93/0x100
> Oct 23 14:07:52 hostname kernel: [ 4880.501977]  [<ffffffffa1167859>] ?
> filename_lookup+0x99/0x150
> Oct 23 14:07:52 hostname kernel: [ 4880.504767]  [<ffffffffa1160d0e>] ?
> pipe_read+0x27e/0x340
> Oct 23 14:07:52 hostname kernel: [ 4880.507550]  [<ffffffffa11674fa>] ?
> getname_flags+0x6a/0x1d0
> Oct 23 14:07:52 hostname kernel: [ 4880.510278]  [<ffffffffa115d4c4>] ?
> vfs_fstatat+0x44/0x90
> Oct 23 14:07:52 hostname kernel: [ 4880.513049]  [<ffffffffa115d96d>] ?
> SYSC_newlstat+0x1d/0x40
> Oct 23 14:07:52 hostname kernel: [ 4880.515844]  [<ffffffffa1158b12>] ?
> vfs_read+0x112/0x130
> Oct 23 14:07:52 hostname kernel: [ 4880.518654]  [<ffffffffa1159d7d>] ?
> SyS_read+0x3d/0x90
> Oct 23 14:07:52 hostname kernel: [ 4880.521437]  [<ffffffffa15ff41f>] ?
> entry_SYSCALL_64_fastpath+0x17/0x93
> Oct 23 14:07:52 hostname kernel: [ 4880.524245] Code: c1 e0 10 45 31 c9 85 c0
> 74 44 48 89 c2 c1 e8 12 48 c1 ea 0c 83 e8 01 83 e2 30 48 98 48 81 c2 c0 6e 01
> 00 48 03 14 c5 a0 21 a7 a1 <48> 89 0a 8b 41 08 85 c0 75 09 f3 90 8b 41 08 85 c0
> 74 f7 4c 8b 
> Oct 23 14:07:52 hostname kernel: [ 4880.527307] RIP  [<ffffffffa1082731>]
> queued_spin_lock_slowpath+0xe1/0x170
> Oct 23 14:07:52 hostname kernel: [ 4880.530277]  RSP <ffff9e468ef83d00>
> Oct 23 14:07:52 hostname kernel: [ 4880.533247] CR2: 00007facb85592b6
> Oct 23 14:07:52 hostname kernel: [ 4880.536159] ---[ end trace 78d7ef040dfa41d9
> ]---
> Oct 23 14:07:52 hostname kernel: [ 4880.638571] note: lsof[1139] exited with
> preempt_count 1
> Oct 23 14:08:52 hostname kernel: [ 4940.464837] INFO: rcu_preempt detected
> stalls on CPUs/tasks:
> Oct 23 14:08:52 hostname kernel: [ 4940.468014]     Tasks blocked on level-0
> rcu_node (CPUs 0-7): P1139
> Oct 23 14:08:52 hostname kernel: [ 4940.471228]     (detected by 2, t=60002
> jiffies, g=469992, c=469991, q=109361)
> Oct 23 14:08:52 hostname kernel: [ 4940.474458] lsof            x
> 0000000000030001     0  1139      0 0x00000002
> Oct 23 14:08:52 hostname kernel: [ 4940.477714]  ffff9e4a40062640
> ffff9e4796162e00 ffff9e4a40062640 ffff9e468ef84000
> Oct 23 14:08:52 hostname kernel: [ 4940.480966]  ffff9e468ef83f10
> ffff9e468ef83b18 ffff9e4a40062a00 00007facb85592b6
> Oct 23 14:08:52 hostname kernel: [ 4940.484228]  0000000000030001
> ffffffffa15fb513 ffff9e4a40062640 ffffffffa104e5c8
> Oct 23 14:08:52 hostname kernel: [ 4940.487471] Call Trace:
> Oct 23 14:08:52 hostname kernel: [ 4940.490683]  [<ffffffffa15fb513>] ?
> schedule+0x33/0x90
> Oct 23 14:08:52 hostname kernel: [ 4940.493919]  [<ffffffffa104e5c8>] ?
> do_exit+0x708/0xac0
> Oct 23 14:08:52 hostname kernel: [ 4940.497169]  [<ffffffffa1600d47>] ?
> rewind_stack_do_exit+0x17/0x20
> Oct 23 14:08:52 hostname kernel: [ 4940.500409] lsof            x
> 0000000000030001     0  1139      0 0x00000002
> Oct 23 14:08:52 hostname kernel: [ 4940.503676]  ffff9e4a40062640
> ffff9e4796162e00 ffff9e4a40062640 ffff9e468ef84000
> Oct 23 14:08:52 hostname kernel: [ 4940.506964]  ffff9e468ef83f10
> ffff9e468ef83b18 ffff9e4a40062a00 00007facb85592b6
> Oct 23 14:08:52 hostname kernel: [ 4940.510230]  0000000000030001
> ffffffffa15fb513 ffff9e4a40062640 ffffffffa104e5c8
> Oct 23 14:08:52 hostname kernel: [ 4940.513532] Call Trace:
> Oct 23 14:08:52 hostname kernel: [ 4940.516807]  [<ffffffffa15fb513>] ?
> schedule+0x33/0x90
> Oct 23 14:08:52 hostname kernel: [ 4940.520129]  [<ffffffffa104e5c8>] ?
> do_exit+0x708/0xac0
> Oct 23 14:08:52 hostname kernel: [ 4940.523457]  [<ffffffffa1600d47>] ?
> rewind_stack_do_exit+0x17/0x20
> Oct 23 14:10:10 hostname kernel: [ 5018.824396] INFO: rcu_sched self-detected
> stall on CPU
> Oct 23 14:10:10 hostname kernel: [ 5018.826669]     2-...: (59999 ticks this
> GP) idle=609/140000000000001/0 softirq=954063/954063 fqs=15000 
> Oct 23 14:10:10 hostname kernel: [ 5018.828924]      (t=60000 jiffies g=333
> c=332 q=1)
> Oct 23 14:10:10 hostname kernel: [ 5018.831185] Task dump for CPU 2:
> Oct 23 14:10:10 hostname kernel: [ 5018.833406] lsof            R  running task
>        0  1213      1 0x0000000c
> Oct 23 14:10:10 hostname kernel: [ 5018.835688]  ffffffffa1a29f80
> ffffffffa10ed903 ffff9e4b2ec97240 ffffffffa1a29f80
> Oct 23 14:10:10 hostname kernel: [ 5018.837940]  0000000000000000
> ffff9e4a13a9cc80 ffffffffa109c05a ffffffffa10a45f9
> Oct 23 14:10:10 hostname kernel: [ 5018.840205]  003b9aca00000000
> ffff9e4b2ec83ee0 0000000000000086 ffffffffa10a5c5c
> Oct 23 14:10:10 hostname kernel: [ 5018.842491] Call Trace:
> Oct 23 14:10:10 hostname kernel: [ 5018.844706]  <IRQ>  [<ffffffffa10ed903>] ?
> rcu_dump_cpu_stacks+0x88/0xaa
> Oct 23 14:10:10 hostname kernel: [ 5018.846997]  [<ffffffffa109c05a>] ?
> rcu_check_callbacks+0x69a/0x8d0
> Oct 23 14:10:10 hostname kernel: [ 5018.849251]  [<ffffffffa10a45f9>] ?
> timekeeping_update+0xe9/0x140
> Oct 23 14:10:10 hostname kernel: [ 5018.851535]  [<ffffffffa10a5c5c>] ?
> update_wall_time+0x45c/0x770
> Oct 23 14:10:10 hostname kernel: [ 5018.853790]  [<ffffffffa10accb0>] ?
> tick_sched_handle.isra.14+0x30/0x30
> Oct 23 14:10:10 hostname kernel: [ 5018.856086]  [<ffffffffa109ef73>] ?
> update_process_times+0x23/0x50
> Oct 23 14:10:10 hostname kernel: [ 5018.858336]  [<ffffffffa10acce3>] ?
> tick_sched_timer+0x33/0x60
> Oct 23 14:10:10 hostname kernel: [ 5018.860593]  [<ffffffffa109f9a9>] ?
> __hrtimer_run_queues+0xb9/0x150
> Oct 23 14:10:10 hostname kernel: [ 5018.862810]  [<ffffffffa109fc35>] ?
> hrtimer_interrupt+0x95/0x190
> Oct 23 14:10:10 hostname kernel: [ 5018.865048]  [<ffffffffa10327de>] ?
> smp_trace_apic_timer_interrupt+0x5e/0x90
> Oct 23 14:10:10 hostname kernel: [ 5018.867302]  [<ffffffffa160000f>] ?
> apic_timer_interrupt+0x7f/0x90
> Oct 23 14:10:10 hostname kernel: [ 5018.869557]  <EOI>  [<ffffffffa108273d>] ?
> queued_spin_lock_slowpath+0xed/0x170
> Oct 23 14:10:10 hostname kernel: [ 5018.871826]  [<ffffffffa13680aa>] ?
> lockref_get_not_dead+0x3a/0x80
> Oct 23 14:10:10 hostname kernel: [ 5018.874097]  [<ffffffffa1162f3e>] ?
> unlazy_walk+0xee/0x180
> Oct 23 14:10:10 hostname kernel: [ 5018.876372]  [<ffffffffa11632de>] ?
> complete_walk+0x2e/0x70
> Oct 23 14:10:10 hostname kernel: [ 5018.878684]  [<ffffffffa1165453>] ?
> path_lookupat+0x93/0x100
> Oct 23 14:10:10 hostname kernel: [ 5018.880953]  [<ffffffffa1167859>] ?
> filename_lookup+0x99/0x150
> Oct 23 14:10:10 hostname kernel: [ 5018.883225]  [<ffffffffa1160d0e>] ?
> pipe_read+0x27e/0x340
> Oct 23 14:10:10 hostname kernel: [ 5018.885532]  [<ffffffffa11674fa>] ?
> getname_flags+0x6a/0x1d0
> Oct 23 14:10:10 hostname kernel: [ 5018.887824]  [<ffffffffa115d4c4>] ?
> vfs_fstatat+0x44/0x90
> Oct 23 14:10:10 hostname kernel: [ 5018.890126]  [<ffffffffa115d96d>] ?
> SYSC_newlstat+0x1d/0x40
> Oct 23 14:10:10 hostname kernel: [ 5018.892443]  [<ffffffffa1158b12>] ?
> vfs_read+0x112/0x130
> Oct 23 14:10:10 hostname kernel: [ 5018.894717]  [<ffffffffa1159d7d>] ?
> SyS_read+0x3d/0x90
> Oct 23 14:10:10 hostname kernel: [ 5018.896912]  [<ffffffffa15ff41f>] ?
> entry_SYSCALL_64_fastpath+0x17/0x93
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
