Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id D290A6B028B
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 21:00:03 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id v138so117981288qka.2
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 18:00:03 -0700 (PDT)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id f31si9695872qki.213.2016.10.28.18.00.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Oct 2016 18:00:02 -0700 (PDT)
Received: by mail-qt0-x243.google.com with SMTP id 23so2549641qtp.2
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 18:00:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFyJmxLvFfM=KnoBqm01YYvBs136p7gJSmatJzj0cXarRQ@mail.gmail.com>
References: <bug-180101-27@https.bugzilla.kernel.org/> <20161028145215.87fd39d8f8822a2cd11b621c@linux-foundation.org>
 <CADzA9onJOyKGWkzzr7HP742-xXpiJciNddhv946Yg_tPSszTDQ@mail.gmail.com> <CA+55aFyJmxLvFfM=KnoBqm01YYvBs136p7gJSmatJzj0cXarRQ@mail.gmail.com>
From: Joseph Yasi <joe.yasi@gmail.com>
Date: Fri, 28 Oct 2016 21:00:01 -0400
Message-ID: <CADzA9onmVegryn6aQW22+FzMqpuCBfEAG5zDN5vUbb3UgBs5_w@mail.gmail.com>
Subject: Re: [Bug 180101] New: BUG: unable to handle kernel paging request at
 x with "mm: remove gup_flags FOLL_WRITE games from __get_user_pages()"
Content-Type: multipart/alternative; boundary=001a114524909eb066053ff67ecc
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, Chris Mason <clm@fb.com>, Kent Overstreet <kent.overstreet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

--001a114524909eb066053ff67ecc
Content-Type: text/plain; charset=UTF-8

On Oct 28, 2016 7:12 PM, "Linus Torvalds" <torvalds@linux-foundation.org>
wrote:
>
> [ Chris, Kent, ignore the subject line, that was a mis-attribution of
> the cause ]
>
> On Fri, Oct 28, 2016 at 3:25 PM, Joseph Yasi <joe.yasi@gmail.com> wrote:
> >
> > I've been able to reproduce the issue with 19be0eaffa3ac7d8eb ("mm:
remove
> > gup_flags FOLL_WRITE games from __get_user_pages()") reverted.
>
> Yeah, this doesn't look to have anything to do with that commit.
>
> >   This smells like a race condition
> > somewhere. It's possible I just happened to never encounter that race
> > before.
>
> It looks like some seriously odd corruption. It's doing spin_lock()
> inside lockref_get_not_dead(), which is just a spinlock in the dentry.
> There's no way it should cause problems.
>
> The code disassembles to
>
>    0: 45 31 c9             xor    %r9d,%r9d
>    3: 85 c0                 test   %eax,%eax
>    5: 74 44                 je     0x4b
>    7: 48 89 c2             mov    %rax,%rdx
>    a: c1 e8 12             shr    $0x12,%eax
>    d: 48 c1 ea 0c           shr    $0xc,%rdx
>   11: 83 e8 01             sub    $0x1,%eax
>   14: 83 e2 30             and    $0x30,%edx
>   17: 48 98                 cltq
>   19: 48 81 c2 c0 6e 01 00 add    $0x16ec0,%rdx
>   20: 48 03 14 c5 a0 21 a7 add    -0x5e58de60(,%rax,8),%rdx
>   27: a1
>   28:* 48 89 0a             mov    %rcx,(%rdx) <-- trapping instruction
>   2b: 8b 41 08             mov    0x8(%rcx),%eax
>   2e: 85 c0                 test   %eax,%eax
>   30: 75 09                 jne    0x3b
>   32: f3 90                 pause
>   34: 8b 41 08             mov    0x8(%rcx),%eax
>   37: 85 c0                 test   %eax,%eax
>   39: 74 f7                 je     0x32
>
> where the beginning of that sequence is the "decode_tail() code, and I
> think the trapping instruction is the
>
>                 WRITE_ONCE(prev->next, node);
>
> so it's from kernel/locking/qspinlock.c:536:
>
>                 prev = decode_tail(old);
>                 /*
>                  * The above xchg_tail() is also a load of @lock which
> generates,
>                  * through decode_tail(), a pointer.
>                  *
>                  * The address dependency matches the RELEASE of
xchg_tail()
>                  * such that the access to @prev must happen after.
>                  */
>                 smp_read_barrier_depends();
>
>                 WRITE_ONCE(prev->next, node);
>
>                 pv_wait_node(node, prev);
>
> and yes, %rdx (which should contain that pointer to 'prev') has that
> bogus pointer value 00007facb85592b6.
>
> So that's a core spinlock in the dentry being corrupted.
>
> Quite frankly, I'm somewhat suspicious of this:
>
>   Modules linked in: pci_stub vboxpci(O) vboxnetadp(O) vboxnetflt(O)
>      vboxdrv(O) rfcomm bnep binfmt_misc vfat fat snd_hda_codec_hdmi
>
> ie those out-of-tree vbox modules..
>
> But for others, here's a cleaned-up copy of the oops in case somebody
> else sees something.
>
>   BUG: unable to handle kernel paging request at 00007facb85592b6
>   IP: queued_spin_lock_slowpath+0xe1/0x170
>   PGD 7cee19067 PUD 0
>   Oops: 0002 [#1] PREEMPT SMP
>   Modules linked in: pci_stub vboxpci(O) vboxnetadp(O) vboxnetflt(O)
>      vboxdrv(O) rfcomm bnep binfmt_misc vfat fat snd_hda_codec_hdmi
>      snd_hda_codec_realtek snd_hda_codec_generic uvcvideo
>      videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 videobuf2_core
>      snd_usb_audio videodev snd_usbmidi_lib media snd_hda_intel
>      snd_hda_codec snd_hwdep snd_hda_core snd_pcm_oss snd_mixer_oss
>      snd_pcm input_leds intel_rapl x86_pkg_temp_thermal btusb
>      intel_powerclamp crct10dif_pclmul btrtl btbcm efi_pstore
>      crc32_pclmul btintel crc32c_intel bluetooth ghash_clmulni_intel
>      aesni_intel aes_x86_64 snd_seq_oss lrw glue_helper ablk_helper
>      cryptd intel_cstate snd_seq_midi snd_rawmidi intel_rapl_perf
>      snd_seq_midi_event snd_seq efivars snd_seq_device snd_timer snd
>      soundcore wl(PO) cfg80211 rfkill sg battery intel_lpss_acpi
>      intel_lpss mfd_core acpi_pad tpm_tis acpi_als tpm_tis_core
>      kfifo_buf tpm industrialio nfsd auth_rpcgss coretemp oid_registry
>      nfs_acl lockd loop grace sunrpc efivarfs ipv6 crc_ccitt hid_generic
>      usbhid uas usb_storage igb e1000e dca ptp mxm_wmi bcache psmouse
>      i915 intel_gtt pps_core drm_kms_helper xhci_pci hwmon syscopyarea
>      xhci_hcd sysfillrect sysimgblt i2c_algo_bit fb_sys_fops usbcore
>      sr_mod drm cdrom i2c_core usb_common fan thermal
>      pinctrl_sunrisepoint wmi video pinctrl_intel button
>   CPU: 3 PID: 1139 Comm: lsof Tainted: P           O    4.8.3-customskl #1
>   Hardware name: System manufacturer System Product Name/Z170-DELUXE,
> BIOS 2202 09/19/2016
>   task: ffff9e4a40062640 task.stack: ffff9e468ef80000
>   RIP: 0010:[<ffffffffa1082731>]  [<ffffffffa1082731>]
> queued_spin_lock_slowpath+0xe1/0x170
>   RSP: 0018:ffff9e468ef83d00  EFLAGS: 00010202
>   RAX: 0000000000001fff RBX: ffff9e494f7f2718 RCX: ffff9e4b2ecd6ec0
>   RDX: 00007facb85592b6 RSI: 0000000080000000 RDI: ffff9e494f7f2718
>   RBP: 0000000000000000 R08: 0000000000100000 R09: 0000000000000000
>   R10: 0000000020ab886e R11: ffff9e494f7f26f8 R12: 0000000000000000
>   R13: ffff9e494f7f26c0 R14: ffff9e468ef83d90 R15: 0000000000000000
>   FS:  00007f3344595800(0000) GS:ffff9e4b2ecc0000(0000)
knlGS:0000000000000000
>   CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>   CR2: 00007facb85592b6 CR3: 00000007daf09000 CR4: 00000000003406e0
>   DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>   DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
>   Call Trace:
>     lockref_get_not_dead+0x3a/0x80
>     unlazy_walk+0xee/0x180
>     complete_walk+0x2e/0x70
>     path_lookupat+0x93/0x100
>     filename_lookup+0x99/0x150
>     pipe_read+0x27e/0x340
>     getname_flags+0x6a/0x1d0
>     vfs_fstatat+0x44/0x90
>     SYSC_newlstat+0x1d/0x40
>     vfs_read+0x112/0x130
>     SyS_read+0x3d/0x90
>     entry_SYSCALL_64_fastpath+0x17/0x93
>   Code: c1 e0 10 45 31 c9 85 c0 74 44 48 89 c2 c1 e8 12 48 c1 ea 0c 83
> e8 01 83 e2 30 48 98 48 81 c2 c0 6e 01 00 48 03 14 c5 a0 21 a7 a1 <48>
> 89 0a 8b 41 08 85 c0 75 09 f3 90 8b 41 08 85 c0 74 f7 4c 8b
>   RIP  [<ffffffffa1082731>] queued_spin_lock_slowpath+0xe1/0x170
>    RSP <ffff9e468ef83d00>
>   CR2: 00007facb85592b6
>
> > The /home partition in question is btrfs on bcache in writethrough
mode. The
> > cache drive is an 180 GB Intel SATA SSD, and the backing device is two
WD 3
> > TB SATA HDDs configured in MD RAID 10 f2 layout. / is btrfs on an NVMe
SSD.
> >
> > I've also seen btrfs checksum errors in the kernel log when reproducing
> > this. Rebooting and running btrfs scrub finds nothing though so it seems
> > like in memory corruption.
>
> I'm adding Chris Mason and Kent Overstreet to the participants,
> because we did have a recent btrfs memory corruption thing. This
> corruption seems to be pretty widespread through, you migth also want
> to just run "memtest" on your machine.
>
> *Most* memory corruption tends to be due to software issues, but
> sometimes it really ends up being the memory itself going bad.
>
> But also, please test if this happens without the out-of-tree modules?

I was testing it without VirtualBox and broadcom-wl out-of-tree modules,
and the machine locked up and won't POST anymore. The motherboard is
claiming it's the CPU, so it looks like this was hardware. Sorry for the
noise.

-Joe

>
>                 Kubys

--001a114524909eb066053ff67ecc
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"></p>
<p dir=3D"ltr">On Oct 28, 2016 7:12 PM, &quot;Linus Torvalds&quot; &lt;<a h=
ref=3D"mailto:torvalds@linux-foundation.org">torvalds@linux-foundation.org<=
/a>&gt; wrote:<br>
&gt;<br>
&gt; [ Chris, Kent, ignore the subject line, that was a mis-attribution of<=
br>
&gt; the cause ]<br>
&gt;<br>
&gt; On Fri, Oct 28, 2016 at 3:25 PM, Joseph Yasi &lt;<a href=3D"mailto:joe=
.yasi@gmail.com">joe.yasi@gmail.com</a>&gt; wrote:<br>
&gt; &gt;<br>
&gt; &gt; I&#39;ve been able to reproduce the issue with 19be0eaffa3ac7d8eb=
 (&quot;mm: remove<br>
&gt; &gt; gup_flags FOLL_WRITE games from __get_user_pages()&quot;) reverte=
d.<br>
&gt;<br>
&gt; Yeah, this doesn&#39;t look to have anything to do with that commit.<b=
r>
&gt;<br>
&gt; &gt;=C2=A0 =C2=A0This smells like a race condition<br>
&gt; &gt; somewhere. It&#39;s possible I just happened to never encounter t=
hat race<br>
&gt; &gt; before.<br>
&gt;<br>
&gt; It looks like some seriously odd corruption. It&#39;s doing spin_lock(=
)<br>
&gt; inside lockref_get_not_dead(), which is just a spinlock in the dentry.=
<br>
&gt; There&#39;s no way it should cause problems.<br>
&gt;<br>
&gt; The code disassembles to<br>
&gt;<br>
&gt; =C2=A0 =C2=A00: 45 31 c9=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0xor=C2=A0 =C2=A0 %r9d,%r9d<br>
&gt; =C2=A0 =C2=A03: 85 c0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0test=C2=A0 =C2=A0%eax,%eax<br>
&gt; =C2=A0 =C2=A05: 74 44=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0je=C2=A0 =C2=A0 =C2=A00x4b<br>
&gt; =C2=A0 =C2=A07: 48 89 c2=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0mov=C2=A0 =C2=A0 %rax,%rdx<br>
&gt; =C2=A0 =C2=A0a: c1 e8 12=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0shr=C2=A0 =C2=A0 $0x12,%eax<br>
&gt; =C2=A0 =C2=A0d: 48 c1 ea 0c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sh=
r=C2=A0 =C2=A0 $0xc,%rdx<br>
&gt; =C2=A0 11: 83 e8 01=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sub=
=C2=A0 =C2=A0 $0x1,%eax<br>
&gt; =C2=A0 14: 83 e2 30=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0and=
=C2=A0 =C2=A0 $0x30,%edx<br>
&gt; =C2=A0 17: 48 98=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0cltq<br>
&gt; =C2=A0 19: 48 81 c2 c0 6e 01 00 add=C2=A0 =C2=A0 $0x16ec0,%rdx<br>
&gt; =C2=A0 20: 48 03 14 c5 a0 21 a7 add=C2=A0 =C2=A0 -0x5e58de60(,%rax,8),=
%rdx<br>
&gt; =C2=A0 27: a1<br>
&gt; =C2=A0 28:* 48 89 0a=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mo=
v=C2=A0 =C2=A0 %rcx,(%rdx) &lt;-- trapping instruction<br>
&gt; =C2=A0 2b: 8b 41 08=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mov=
=C2=A0 =C2=A0 0x8(%rcx),%eax<br>
&gt; =C2=A0 2e: 85 c0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0test=C2=A0 =C2=A0%eax,%eax<br>
&gt; =C2=A0 30: 75 09=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0jne=C2=A0 =C2=A0 0x3b<br>
&gt; =C2=A0 32: f3 90=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0pause<br>
&gt; =C2=A0 34: 8b 41 08=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mov=
=C2=A0 =C2=A0 0x8(%rcx),%eax<br>
&gt; =C2=A0 37: 85 c0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0test=C2=A0 =C2=A0%eax,%eax<br>
&gt; =C2=A0 39: 74 f7=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0je=C2=A0 =C2=A0 =C2=A00x32<br>
&gt;<br>
&gt; where the beginning of that sequence is the &quot;decode_tail() code, =
and I<br>
&gt; think the trapping instruction is the<br>
&gt;<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 WRITE_ONCE(pre=
v-&gt;next, node);<br>
&gt;<br>
&gt; so it&#39;s from kernel/locking/qspinlock.c:536:<br>
&gt;<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 prev =3D decod=
e_tail(old);<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* The ab=
ove xchg_tail() is also a load of @lock which<br>
&gt; generates,<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* throug=
h decode_tail(), a pointer.<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* The ad=
dress dependency matches the RELEASE of xchg_tail()<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* such t=
hat the access to @prev must happen after.<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 smp_read_barri=
er_depends();<br>
&gt;<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 WRITE_ONCE(pre=
v-&gt;next, node);<br>
&gt;<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pv_wait_node(n=
ode, prev);<br>
&gt;<br>
&gt; and yes, %rdx (which should contain that pointer to &#39;prev&#39;) ha=
s that<br>
&gt; bogus pointer value 00007facb85592b6.<br>
&gt;<br>
&gt; So that&#39;s a core spinlock in the dentry being corrupted.<br>
&gt;<br>
&gt; Quite frankly, I&#39;m somewhat suspicious of this:<br>
&gt;<br>
&gt; =C2=A0 Modules linked in: pci_stub vboxpci(O) vboxnetadp(O) vboxnetflt=
(O)<br>
&gt; =C2=A0 =C2=A0 =C2=A0vboxdrv(O) rfcomm bnep binfmt_misc vfat fat snd_hd=
a_codec_hdmi<br>
&gt;<br>
&gt; ie those out-of-tree vbox modules..<br>
&gt;<br>
&gt; But for others, here&#39;s a cleaned-up copy of the oops in case someb=
ody<br>
&gt; else sees something.<br>
&gt;<br>
&gt; =C2=A0 BUG: unable to handle kernel paging request at 00007facb85592b6=
<br>
&gt; =C2=A0 IP: queued_spin_lock_slowpath+0xe1/0x170<br>
&gt; =C2=A0 PGD 7cee19067 PUD 0<br>
&gt; =C2=A0 Oops: 0002 [#1] PREEMPT SMP<br>
&gt; =C2=A0 Modules linked in: pci_stub vboxpci(O) vboxnetadp(O) vboxnetflt=
(O)<br>
&gt; =C2=A0 =C2=A0 =C2=A0vboxdrv(O) rfcomm bnep binfmt_misc vfat fat snd_hd=
a_codec_hdmi<br>
&gt; =C2=A0 =C2=A0 =C2=A0snd_hda_codec_realtek snd_hda_codec_generic uvcvid=
eo<br>
&gt; =C2=A0 =C2=A0 =C2=A0videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 =
videobuf2_core<br>
&gt; =C2=A0 =C2=A0 =C2=A0snd_usb_audio videodev snd_usbmidi_lib media snd_h=
da_intel<br>
&gt; =C2=A0 =C2=A0 =C2=A0snd_hda_codec snd_hwdep snd_hda_core snd_pcm_oss s=
nd_mixer_oss<br>
&gt; =C2=A0 =C2=A0 =C2=A0snd_pcm input_leds intel_rapl x86_pkg_temp_thermal=
 btusb<br>
&gt; =C2=A0 =C2=A0 =C2=A0intel_powerclamp crct10dif_pclmul btrtl btbcm efi_=
pstore<br>
&gt; =C2=A0 =C2=A0 =C2=A0crc32_pclmul btintel crc32c_intel bluetooth ghash_=
clmulni_intel<br>
&gt; =C2=A0 =C2=A0 =C2=A0aesni_intel aes_x86_64 snd_seq_oss lrw glue_helper=
 ablk_helper<br>
&gt; =C2=A0 =C2=A0 =C2=A0cryptd intel_cstate snd_seq_midi snd_rawmidi intel=
_rapl_perf<br>
&gt; =C2=A0 =C2=A0 =C2=A0snd_seq_midi_event snd_seq efivars snd_seq_device =
snd_timer snd<br>
&gt; =C2=A0 =C2=A0 =C2=A0soundcore wl(PO) cfg80211 rfkill sg battery intel_=
lpss_acpi<br>
&gt; =C2=A0 =C2=A0 =C2=A0intel_lpss mfd_core acpi_pad tpm_tis acpi_als tpm_=
tis_core<br>
&gt; =C2=A0 =C2=A0 =C2=A0kfifo_buf tpm industrialio nfsd auth_rpcgss corete=
mp oid_registry<br>
&gt; =C2=A0 =C2=A0 =C2=A0nfs_acl lockd loop grace sunrpc efivarfs ipv6 crc_=
ccitt hid_generic<br>
&gt; =C2=A0 =C2=A0 =C2=A0usbhid uas usb_storage igb e1000e dca ptp mxm_wmi =
bcache psmouse<br>
&gt; =C2=A0 =C2=A0 =C2=A0i915 intel_gtt pps_core drm_kms_helper xhci_pci hw=
mon syscopyarea<br>
&gt; =C2=A0 =C2=A0 =C2=A0xhci_hcd sysfillrect sysimgblt i2c_algo_bit fb_sys=
_fops usbcore<br>
&gt; =C2=A0 =C2=A0 =C2=A0sr_mod drm cdrom i2c_core usb_common fan thermal<b=
r>
&gt; =C2=A0 =C2=A0 =C2=A0pinctrl_sunrisepoint wmi video pinctrl_intel butto=
n<br>
&gt; =C2=A0 CPU: 3 PID: 1139 Comm: lsof Tainted: P=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0O=C2=A0 =C2=A0 4.8.3-customskl #1<br>
&gt; =C2=A0 Hardware name: System manufacturer System Product Name/Z170-DEL=
UXE,<br>
&gt; BIOS 2202 09/19/2016<br>
&gt; =C2=A0 task: ffff9e4a40062640 task.stack: ffff9e468ef80000<br>
&gt; =C2=A0 RIP: 0010:[&lt;ffffffffa1082731&gt;]=C2=A0 [&lt;ffffffffa108273=
1&gt;]<br>
&gt; queued_spin_lock_slowpath+0xe1/0x170<br>
&gt; =C2=A0 RSP: 0018:ffff9e468ef83d00=C2=A0 EFLAGS: 00010202<br>
&gt; =C2=A0 RAX: 0000000000001fff RBX: ffff9e494f7f2718 RCX: ffff9e4b2ecd6e=
c0<br>
&gt; =C2=A0 RDX: 00007facb85592b6 RSI: 0000000080000000 RDI: ffff9e494f7f27=
18<br>
&gt; =C2=A0 RBP: 0000000000000000 R08: 0000000000100000 R09: 00000000000000=
00<br>
&gt; =C2=A0 R10: 0000000020ab886e R11: ffff9e494f7f26f8 R12: 00000000000000=
00<br>
&gt; =C2=A0 R13: ffff9e494f7f26c0 R14: ffff9e468ef83d90 R15: 00000000000000=
00<br>
&gt; =C2=A0 FS:=C2=A0 00007f3344595800(0000) GS:ffff9e4b2ecc0000(0000) knlG=
S:0000000000000000<br>
&gt; =C2=A0 CS:=C2=A0 0010 DS: 0000 ES: 0000 CR0: 0000000080050033<br>
&gt; =C2=A0 CR2: 00007facb85592b6 CR3: 00000007daf09000 CR4: 00000000003406=
e0<br>
&gt; =C2=A0 DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000000=
00<br>
&gt; =C2=A0 DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 00000000000004=
00<br>
&gt; =C2=A0 Call Trace:<br>
&gt; =C2=A0 =C2=A0 lockref_get_not_dead+0x3a/0x80<br>
&gt; =C2=A0 =C2=A0 unlazy_walk+0xee/0x180<br>
&gt; =C2=A0 =C2=A0 complete_walk+0x2e/0x70<br>
&gt; =C2=A0 =C2=A0 path_lookupat+0x93/0x100<br>
&gt; =C2=A0 =C2=A0 filename_lookup+0x99/0x150<br>
&gt; =C2=A0 =C2=A0 pipe_read+0x27e/0x340<br>
&gt; =C2=A0 =C2=A0 getname_flags+0x6a/0x1d0<br>
&gt; =C2=A0 =C2=A0 vfs_fstatat+0x44/0x90<br>
&gt; =C2=A0 =C2=A0 SYSC_newlstat+0x1d/0x40<br>
&gt; =C2=A0 =C2=A0 vfs_read+0x112/0x130<br>
&gt; =C2=A0 =C2=A0 SyS_read+0x3d/0x90<br>
&gt; =C2=A0 =C2=A0 entry_SYSCALL_64_fastpath+0x17/0x93<br>
&gt; =C2=A0 Code: c1 e0 10 45 31 c9 85 c0 74 44 48 89 c2 c1 e8 12 48 c1 ea =
0c 83<br>
&gt; e8 01 83 e2 30 48 98 48 81 c2 c0 6e 01 00 48 03 14 c5 a0 21 a7 a1 &lt;=
48&gt;<br>
&gt; 89 0a 8b 41 08 85 c0 75 09 f3 90 8b 41 08 85 c0 74 f7 4c 8b<br>
&gt; =C2=A0 RIP=C2=A0 [&lt;ffffffffa1082731&gt;] queued_spin_lock_slowpath+=
0xe1/0x170<br>
&gt; =C2=A0 =C2=A0RSP &lt;ffff9e468ef83d00&gt;<br>
&gt; =C2=A0 CR2: 00007facb85592b6<br>
&gt;<br>
&gt; &gt; The /home partition in question is btrfs on bcache in writethroug=
h mode. The<br>
&gt; &gt; cache drive is an 180 GB Intel SATA SSD, and the backing device i=
s two WD 3<br>
&gt; &gt; TB SATA HDDs configured in MD RAID 10 f2 layout. / is btrfs on an=
 NVMe SSD.<br>
&gt; &gt;<br>
&gt; &gt; I&#39;ve also seen btrfs checksum errors in the kernel log when r=
eproducing<br>
&gt; &gt; this. Rebooting and running btrfs scrub finds nothing though so i=
t seems<br>
&gt; &gt; like in memory corruption.<br>
&gt;<br>
&gt; I&#39;m adding Chris Mason and Kent Overstreet to the participants,<br=
>
&gt; because we did have a recent btrfs memory corruption thing. This<br>
&gt; corruption seems to be pretty widespread through, you migth also want<=
br>
&gt; to just run &quot;memtest&quot; on your machine.<br>
&gt;<br>
&gt; *Most* memory corruption tends to be due to software issues, but<br>
&gt; sometimes it really ends up being the memory itself going bad.<br>
&gt;<br>
&gt; But also, please test if this happens without the out-of-tree modules?=
</p>
<p dir=3D"ltr">I was testing it without VirtualBox and broadcom-wl out-of-t=
ree modules, and the machine locked up and won&#39;t POST anymore. The moth=
erboard is claiming it&#39;s the CPU, so it looks like this was hardware. S=
orry for the noise.</p>
<p dir=3D"ltr">-Joe</p>
<p dir=3D"ltr">&gt;<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Kubys<br></p>

--001a114524909eb066053ff67ecc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
