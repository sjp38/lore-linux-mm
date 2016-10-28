Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 22E886B028B
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 19:12:41 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id f78so150894989oih.7
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 16:12:41 -0700 (PDT)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id 184si11112521oih.257.2016.10.28.16.12.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Oct 2016 16:12:40 -0700 (PDT)
Received: by mail-oi0-x242.google.com with SMTP id e12so2484648oib.3
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 16:12:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CADzA9onJOyKGWkzzr7HP742-xXpiJciNddhv946Yg_tPSszTDQ@mail.gmail.com>
References: <bug-180101-27@https.bugzilla.kernel.org/> <20161028145215.87fd39d8f8822a2cd11b621c@linux-foundation.org>
 <CADzA9onJOyKGWkzzr7HP742-xXpiJciNddhv946Yg_tPSszTDQ@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 28 Oct 2016 16:12:39 -0700
Message-ID: <CA+55aFyJmxLvFfM=KnoBqm01YYvBs136p7gJSmatJzj0cXarRQ@mail.gmail.com>
Subject: Re: [Bug 180101] New: BUG: unable to handle kernel paging request at
 x with "mm: remove gup_flags FOLL_WRITE games from __get_user_pages()"
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joseph Yasi <joe.yasi@gmail.com>, Chris Mason <clm@fb.com>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm <linux-mm@kvack.org>

[ Chris, Kent, ignore the subject line, that was a mis-attribution of
the cause ]

On Fri, Oct 28, 2016 at 3:25 PM, Joseph Yasi <joe.yasi@gmail.com> wrote:
>
> I've been able to reproduce the issue with 19be0eaffa3ac7d8eb ("mm: remove
> gup_flags FOLL_WRITE games from __get_user_pages()") reverted.

Yeah, this doesn't look to have anything to do with that commit.

>   This smells like a race condition
> somewhere. It's possible I just happened to never encounter that race
> before.

It looks like some seriously odd corruption. It's doing spin_lock()
inside lockref_get_not_dead(), which is just a spinlock in the dentry.
There's no way it should cause problems.

The code disassembles to

   0: 45 31 c9             xor    %r9d,%r9d
   3: 85 c0                 test   %eax,%eax
   5: 74 44                 je     0x4b
   7: 48 89 c2             mov    %rax,%rdx
   a: c1 e8 12             shr    $0x12,%eax
   d: 48 c1 ea 0c           shr    $0xc,%rdx
  11: 83 e8 01             sub    $0x1,%eax
  14: 83 e2 30             and    $0x30,%edx
  17: 48 98                 cltq
  19: 48 81 c2 c0 6e 01 00 add    $0x16ec0,%rdx
  20: 48 03 14 c5 a0 21 a7 add    -0x5e58de60(,%rax,8),%rdx
  27: a1
  28:* 48 89 0a             mov    %rcx,(%rdx) <-- trapping instruction
  2b: 8b 41 08             mov    0x8(%rcx),%eax
  2e: 85 c0                 test   %eax,%eax
  30: 75 09                 jne    0x3b
  32: f3 90                 pause
  34: 8b 41 08             mov    0x8(%rcx),%eax
  37: 85 c0                 test   %eax,%eax
  39: 74 f7                 je     0x32

where the beginning of that sequence is the "decode_tail() code, and I
think the trapping instruction is the

                WRITE_ONCE(prev->next, node);

so it's from kernel/locking/qspinlock.c:536:

                prev = decode_tail(old);
                /*
                 * The above xchg_tail() is also a load of @lock which
generates,
                 * through decode_tail(), a pointer.
                 *
                 * The address dependency matches the RELEASE of xchg_tail()
                 * such that the access to @prev must happen after.
                 */
                smp_read_barrier_depends();

                WRITE_ONCE(prev->next, node);

                pv_wait_node(node, prev);

and yes, %rdx (which should contain that pointer to 'prev') has that
bogus pointer value 00007facb85592b6.

So that's a core spinlock in the dentry being corrupted.

Quite frankly, I'm somewhat suspicious of this:

  Modules linked in: pci_stub vboxpci(O) vboxnetadp(O) vboxnetflt(O)
     vboxdrv(O) rfcomm bnep binfmt_misc vfat fat snd_hda_codec_hdmi

ie those out-of-tree vbox modules..

But for others, here's a cleaned-up copy of the oops in case somebody
else sees something.

  BUG: unable to handle kernel paging request at 00007facb85592b6
  IP: queued_spin_lock_slowpath+0xe1/0x170
  PGD 7cee19067 PUD 0
  Oops: 0002 [#1] PREEMPT SMP
  Modules linked in: pci_stub vboxpci(O) vboxnetadp(O) vboxnetflt(O)
     vboxdrv(O) rfcomm bnep binfmt_misc vfat fat snd_hda_codec_hdmi
     snd_hda_codec_realtek snd_hda_codec_generic uvcvideo
     videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 videobuf2_core
     snd_usb_audio videodev snd_usbmidi_lib media snd_hda_intel
     snd_hda_codec snd_hwdep snd_hda_core snd_pcm_oss snd_mixer_oss
     snd_pcm input_leds intel_rapl x86_pkg_temp_thermal btusb
     intel_powerclamp crct10dif_pclmul btrtl btbcm efi_pstore
     crc32_pclmul btintel crc32c_intel bluetooth ghash_clmulni_intel
     aesni_intel aes_x86_64 snd_seq_oss lrw glue_helper ablk_helper
     cryptd intel_cstate snd_seq_midi snd_rawmidi intel_rapl_perf
     snd_seq_midi_event snd_seq efivars snd_seq_device snd_timer snd
     soundcore wl(PO) cfg80211 rfkill sg battery intel_lpss_acpi
     intel_lpss mfd_core acpi_pad tpm_tis acpi_als tpm_tis_core
     kfifo_buf tpm industrialio nfsd auth_rpcgss coretemp oid_registry
     nfs_acl lockd loop grace sunrpc efivarfs ipv6 crc_ccitt hid_generic
     usbhid uas usb_storage igb e1000e dca ptp mxm_wmi bcache psmouse
     i915 intel_gtt pps_core drm_kms_helper xhci_pci hwmon syscopyarea
     xhci_hcd sysfillrect sysimgblt i2c_algo_bit fb_sys_fops usbcore
     sr_mod drm cdrom i2c_core usb_common fan thermal
     pinctrl_sunrisepoint wmi video pinctrl_intel button
  CPU: 3 PID: 1139 Comm: lsof Tainted: P           O    4.8.3-customskl #1
  Hardware name: System manufacturer System Product Name/Z170-DELUXE,
BIOS 2202 09/19/2016
  task: ffff9e4a40062640 task.stack: ffff9e468ef80000
  RIP: 0010:[<ffffffffa1082731>]  [<ffffffffa1082731>]
queued_spin_lock_slowpath+0xe1/0x170
  RSP: 0018:ffff9e468ef83d00  EFLAGS: 00010202
  RAX: 0000000000001fff RBX: ffff9e494f7f2718 RCX: ffff9e4b2ecd6ec0
  RDX: 00007facb85592b6 RSI: 0000000080000000 RDI: ffff9e494f7f2718
  RBP: 0000000000000000 R08: 0000000000100000 R09: 0000000000000000
  R10: 0000000020ab886e R11: ffff9e494f7f26f8 R12: 0000000000000000
  R13: ffff9e494f7f26c0 R14: ffff9e468ef83d90 R15: 0000000000000000
  FS:  00007f3344595800(0000) GS:ffff9e4b2ecc0000(0000) knlGS:0000000000000000
  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  CR2: 00007facb85592b6 CR3: 00000007daf09000 CR4: 00000000003406e0
  DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
  DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
  Call Trace:
    lockref_get_not_dead+0x3a/0x80
    unlazy_walk+0xee/0x180
    complete_walk+0x2e/0x70
    path_lookupat+0x93/0x100
    filename_lookup+0x99/0x150
    pipe_read+0x27e/0x340
    getname_flags+0x6a/0x1d0
    vfs_fstatat+0x44/0x90
    SYSC_newlstat+0x1d/0x40
    vfs_read+0x112/0x130
    SyS_read+0x3d/0x90
    entry_SYSCALL_64_fastpath+0x17/0x93
  Code: c1 e0 10 45 31 c9 85 c0 74 44 48 89 c2 c1 e8 12 48 c1 ea 0c 83
e8 01 83 e2 30 48 98 48 81 c2 c0 6e 01 00 48 03 14 c5 a0 21 a7 a1 <48>
89 0a 8b 41 08 85 c0 75 09 f3 90 8b 41 08 85 c0 74 f7 4c 8b
  RIP  [<ffffffffa1082731>] queued_spin_lock_slowpath+0xe1/0x170
   RSP <ffff9e468ef83d00>
  CR2: 00007facb85592b6

> The /home partition in question is btrfs on bcache in writethrough mode. The
> cache drive is an 180 GB Intel SATA SSD, and the backing device is two WD 3
> TB SATA HDDs configured in MD RAID 10 f2 layout. / is btrfs on an NVMe SSD.
>
> I've also seen btrfs checksum errors in the kernel log when reproducing
> this. Rebooting and running btrfs scrub finds nothing though so it seems
> like in memory corruption.

I'm adding Chris Mason and Kent Overstreet to the participants,
because we did have a recent btrfs memory corruption thing. This
corruption seems to be pretty widespread through, you migth also want
to just run "memtest" on your machine.

*Most* memory corruption tends to be due to software issues, but
sometimes it really ends up being the memory itself going bad.

But also, please test if this happens without the out-of-tree modules?

                Kubys

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
