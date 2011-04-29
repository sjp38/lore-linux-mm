Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1D6900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 06:23:14 -0400 (EDT)
Received: by qyk2 with SMTP id 2so223612qyk.14
        for <linux-mm@kvack.org>; Fri, 29 Apr 2011 03:23:11 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <1303924902.2583.13.camel@mulgrave.site>
References: <1303920553.2583.7.camel@mulgrave.site>
	<1303921583-sup-4021@think>
	<1303923000.2583.8.camel@mulgrave.site>
	<1303923177-sup-2603@think>
	<1303924902.2583.13.camel@mulgrave.site>
Date: Fri, 29 Apr 2011 12:23:09 +0200
Message-ID: <BANLkTimpMJRX0CF7tZ75_x1kWmTkFx3XxA@mail.gmail.com>
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback related.
From: Sedat Dilek <sedat.dilek@googlemail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Sorry for the top-posting!

But as I see these RCU (CPU) stalls, the patch from [1] might be worth a tr=
y.
First, I have seen negative effects on my UP-system was when playing
with linux-next [2].
It was not clear what the origin was and the the side-effects were
somehow "bizarre".
The issue could be easily reproduced by tar-ing the kernel build-dir
to an external USB-hdd.
The issue kept RCU and TIP folks really busy.
Before stepping 4 weeks in the dark, give it a try and let me know in
case of success.

For the systemd/cgroups part of the discussion (yes, I followed this
thread in parallel):
The patch from [4] might be interesting (untested here).

Hope this helps you.
Have fun!

- Sedat -

[1] http://git.us.kernel.org/?p=3Dlinux/kernel/git/tip/linux-2.6-tip.git;a=
=3Dcommit;h=3Dce31332d3c77532d6ea97ddcb475a2b02dd358b4
[2] http://lkml.org/lkml/2011/3/25/97
[3] http://lkml.org/lkml/2011/4/28/444
[4] https://patchwork.kernel.org/patch/738921/

On Wed, Apr 27, 2011 at 7:21 PM, James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
> On Wed, 2011-04-27 at 12:54 -0400, Chris Mason wrote:
>> Ok, I'd try turning it on so we catch the sleeping with a spinlock held
>> case better.
>
> Will do, that's CONFIG_PREEMPT (rather than CONFIG_PREEMPT_VOLUNTARY)?
>
> This is the trace with sysrq-l and sysrq-w
>
> The repro this time doesn't have a soft lockup, just the tar is hung and
> one of my CPUs is in 99% system.
>
> James
>
> ---
>
>
> [ =C2=A0453.351255] SysRq : Show backtrace of all active CPUs
> [ =C2=A0453.352601] sending NMI to all CPUs:
> [ =C2=A0453.353849] NMI backtrace for cpu 3
> [ =C2=A0453.355545] CPU 3
> [ =C2=A0453.355560] Modules linked in: netconsole configfs cpufreq_ondema=
nd acpi_cpufreq freq_table mperf snd_hda_codec_hdmi snd_hda_codec_conexant =
arc4 snd_hda_intel snd_hda_codec iwlagn snd_hwdep snd_seq mac80211 snd_seq_=
device uvcvideo btusb cfg80211 bluetooth wmi e1000e snd_pcm videodev rfkill=
 i2c_i801 microcode iTCO_wdt iTCO_vendor_support xhci_hcd snd_timer v4l2_co=
mpat_ioctl32 joydev pcspkr snd soundcore snd_page_alloc uinput ipv6 sdhci_p=
ci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last=
 unloaded: scsi_wait_scan]
> [ =C2=A0453.363188]
> [ =C2=A0453.365162] Pid: 46, comm: kswapd0 Not tainted 2.6.39-rc4+ #1 LEN=
OVO 4170CTO/4170CTO
> [ =C2=A0453.367133] RIP: 0010:[<ffffffff8147af8c>] =C2=A0[<ffffffff8147af=
8c>] mutex_trylock+0x16/0x38
> [ =C2=A0453.369122] RSP: 0018:ffff88006dfc1d40 =C2=A0EFLAGS: 00000246
> [ =C2=A0453.371098] RAX: 0000000000000001 RBX: ffff880037de15f0 RCX: 0000=
000000000001
> [ =C2=A0453.373099] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff=
880037875820
> [ =C2=A0453.375097] RBP: ffff88006dfc1d40 R08: 0000000000000000 R09: 0000=
0000000074ad
> [ =C2=A0453.377079] R10: 0000000000000002 R11: ffffffff81a44e50 R12: 0000=
000000000000
> [ =C2=A0453.379052] R13: 0000000000000000 R14: ffff880037875800 R15: ffff=
880037875820
> [ =C2=A0453.381015] FS: =C2=A00000000000000000(0000) GS:ffff8801002c0000(=
0000) knlGS:0000000000000000
> [ =C2=A0453.382985] CS: =C2=A00010 DS: 0000 ES: 0000 CR0: 000000008005003=
b
> [ =C2=A0453.384944] CR2: 00007fbf8ea8d090 CR3: 0000000001a03000 CR4: 0000=
0000000406e0
> [ =C2=A0453.386920] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000=
000000000000
> [ =C2=A0453.388887] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000=
000000000400
> [ =C2=A0453.390789] Process kswapd0 (pid: 46, threadinfo ffff88006dfc0000=
, task ffff88006dfb8000)
> [ =C2=A0453.392649] Stack:
> [ =C2=A0453.394473] =C2=A0ffff88006dfc1d90 ffffffffa007ff52 ffff88006dfc1=
d90 ffffffff811613b5
> [ =C2=A0453.396337] =C2=A0ffff88006dfc1d60 ffff880037de15f0 0000000000000=
000 0000000000000000
> [ =C2=A0453.398174] =C2=A000000000000000d0 000000000006366c ffff88006dfc1=
de0 ffffffff810e1f89
> [ =C2=A0453.400015] Call Trace:
> [ =C2=A0453.401845] =C2=A0[<ffffffffa007ff52>] i915_gem_inactive_shrink+0=
x2f/0x194 [i915]
> [ =C2=A0453.403702] =C2=A0[<ffffffff811613b5>] ? mb_cache_shrink_fn+0x32/=
0xd0
> [ =C2=A0453.405499] =C2=A0[<ffffffff810e1f89>] shrink_slab+0x6d/0x166
> [ =C2=A0453.407234] =C2=A0[<ffffffff810e4bcc>] kswapd+0x533/0x798
> [ =C2=A0453.408952] =C2=A0[<ffffffff810e4699>] ? mem_cgroup_shrink_node_z=
one+0xe3/0xe3
> [ =C2=A0453.410690] =C2=A0[<ffffffff8106e157>] kthread+0x84/0x8c
> [ =C2=A0453.412432] =C2=A0[<ffffffff81483764>] kernel_thread_helper+0x4/0=
x10
> [ =C2=A0453.414187] =C2=A0[<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/=
0x148
> [ =C2=A0453.415945] =C2=A0[<ffffffff81483760>] ? gs_change+0x13/0x13
> [ =C2=A0453.417671] Code: 00 48 c7 47 18 00 00 00 00 f0 ff 07 7f 05 e8 ed=
 02 00 00 5d c3 55 48 89 e5 0f 1f 44 00 00 b9 01 00 00 00 31 d2 89 c8 f0 0f=
 b1 17
> [ =C2=A0453.417905] =C2=A0c1 31 c0 ff c9 75 18 65 48 8b 04 25 c8 cc 00 00=
 48 2d d8 1f
> [ =C2=A0453.421534] Call Trace:
> [ =C2=A0453.423337] =C2=A0[<ffffffffa007ff52>] i915_gem_inactive_shrink+0=
x2f/0x194 [i915]
> [ =C2=A0453.425172] =C2=A0[<ffffffff811613b5>] ? mb_cache_shrink_fn+0x32/=
0xd0
> [ =C2=A0453.426997] =C2=A0[<ffffffff810e1f89>] shrink_slab+0x6d/0x166
> [ =C2=A0453.428818] =C2=A0[<ffffffff810e4bcc>] kswapd+0x533/0x798
> [ =C2=A0453.430639] =C2=A0[<ffffffff810e4699>] ? mem_cgroup_shrink_node_z=
one+0xe3/0xe3
> [ =C2=A0453.432485] =C2=A0[<ffffffff8106e157>] kthread+0x84/0x8c
> [ =C2=A0453.434298] =C2=A0[<ffffffff81483764>] kernel_thread_helper+0x4/0=
x10
> [ =C2=A0453.436112] =C2=A0[<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/=
0x148
> [ =C2=A0453.437894] =C2=A0[<ffffffff81483760>] ? gs_change+0x13/0x13
> [ =C2=A0453.439654] NMI backtrace for cpu 2
> [ =C2=A0453.441508] CPU 2
> [ =C2=A0453.441525] Modules linked in: netconsole configfs cpufreq_ondema=
nd acpi_cpufreq freq_table mperf snd_hda_codec_hdmi snd_hda_codec_conexant =
arc4 snd_hda_intel snd_hda_codec iwlagn snd_hwdep snd_seq mac80211 snd_seq_=
device uvcvideo btusb cfg80211 bluetooth wmi e1000e snd_pcm videodev rfkill=
 i2c_i801 microcode iTCO_wdt iTCO_vendor_support xhci_hcd snd_timer v4l2_co=
mpat_ioctl32 joydev pcspkr snd soundcore snd_page_alloc uinput ipv6 sdhci_p=
ci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last=
 unloaded: scsi_wait_scan]
> [ =C2=A0453.449517]
> [ =C2=A0453.451516] Pid: 0, comm: kworker/0:1 Not tainted 2.6.39-rc4+ #1 =
LENOVO 4170CTO/4170CTO
> [ =C2=A0453.453704] RIP: 0010:[<ffffffff81275d36>] =C2=A0[<ffffffff81275d=
36>] intel_idle+0xaa/0x100
> [ =C2=A0453.455772] RSP: 0018:ffff8800715c9e68 =C2=A0EFLAGS: 00000046
> [ =C2=A0453.457827] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000=
000000000001
> [ =C2=A0453.459903] RDX: 0000000000000000 RSI: ffff8800715c9fd8 RDI: ffff=
ffff81a0e640
> [ =C2=A0453.461999] RBP: ffff8800715c9eb8 R08: 000000000000006d R09: 0000=
0000000003e5
> [ =C2=A0453.464039] R10: ffffffff00000002 R11: ffff880100293b40 R12: 0000=
000000000030
> [ =C2=A0453.466013] R13: 12187898d4512537 R14: 0000000000000004 R15: 0000=
000000000002
> [ =C2=A0453.467918] FS: =C2=A00000000000000000(0000) GS:ffff880100280000(=
0000) knlGS:0000000000000000
> [ =C2=A0453.469797] CS: =C2=A00010 DS: 0000 ES: 0000 CR0: 000000008005003=
b
> [ =C2=A0453.471644] CR2: 0000000000452630 CR3: 0000000001a03000 CR4: 0000=
0000000406e0
> [ =C2=A0453.473512] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000=
000000000000
> [ =C2=A0453.475356] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000=
000000000400
> [ =C2=A0453.477185] Process kworker/0:1 (pid: 0, threadinfo ffff8800715c8=
000, task ffff8800715a1700)
> [ =C2=A0453.479024] Stack:
> [ =C2=A0453.480855] =C2=A0ffff8800715c9e88 ffffffff810731c0 ffff880100291=
290 0000000000011290
> [ =C2=A0453.482739] =C2=A0ffff8800715c9eb8 000000028139c97a ffffe8ffffc80=
170 ffffe8ffffc80170
> [ =C2=A0453.484631] =C2=A0ffffe8ffffc80300 0000000000000000 ffff8800715c9=
ef8 ffffffff8139b868
> [ =C2=A0453.486518] Call Trace:
> [ =C2=A0453.488365] =C2=A0[<ffffffff810731c0>] ? pm_qos_request+0x3e/0x45
> [ =C2=A0453.490226] =C2=A0[<ffffffff8139b868>] cpuidle_idle_call+0xe7/0x1=
66
> [ =C2=A0453.492096] =C2=A0[<ffffffff81008321>] cpu_idle+0xa5/0xdf
> [ =C2=A0453.493947] =C2=A0[<ffffffff8146ae57>] start_secondary+0x223/0x22=
5
> [ =C2=A0453.495791] Code: 28 e0 ff ff 80 e2 08 75 22 31 d2 48 83 c0 10 48=
 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e0 0f=
 01 c9 <e8> 23 09 e0 ff 4c 29 e8 48 89 c7 e8 ab 29 de ff 4c 69 e0 40 42
> [ =C2=A0453.499958] Call Trace:
> [ =C2=A0453.501895] =C2=A0[<ffffffff810731c0>] ? pm_qos_request+0x3e/0x45
> [ =C2=A0453.503837] =C2=A0[<ffffffff8139b868>] cpuidle_idle_call+0xe7/0x1=
66
> [ =C2=A0453.505775] =C2=A0[<ffffffff81008321>] cpu_idle+0xa5/0xdf
> [ =C2=A0453.507687] =C2=A0[<ffffffff8146ae57>] start_secondary+0x223/0x22=
5
> [ =C2=A0453.509598] NMI backtrace for cpu 1
> [ =C2=A0453.511390] CPU 1
> [ =C2=A0453.511405] Modules linked in: netconsole configfs cpufreq_ondema=
nd acpi_cpufreq freq_table mperf snd_hda_codec_hdmi snd_hda_codec_conexant =
arc4 snd_hda_intel snd_hda_codec iwlagn snd_hwdep snd_seq mac80211 snd_seq_=
device uvcvideo btusb cfg80211 bluetooth wmi e1000e snd_pcm videodev rfkill=
 i2c_i801 microcode iTCO_wdt iTCO_vendor_support xhci_hcd snd_timer v4l2_co=
mpat_ioctl32 joydev pcspkr snd soundcore snd_page_alloc uinput ipv6 sdhci_p=
ci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last=
 unloaded: scsi_wait_scan]
> [ =C2=A0453.519288]
> [ =C2=A0453.521289] Pid: 0, comm: kworker/0:0 Not tainted 2.6.39-rc4+ #1 =
LENOVO 4170CTO/4170CTO
> [ =C2=A0453.523353] RIP: 0010:[<ffffffff81275d36>] =C2=A0[<ffffffff81275d=
36>] intel_idle+0xaa/0x100
> [ =C2=A0453.525377] RSP: 0018:ffff880071587e68 =C2=A0EFLAGS: 00000046
> [ =C2=A0453.527353] RAX: 0000000000000010 RBX: 0000000000000004 RCX: 0000=
000000000001
> [ =C2=A0453.529332] RDX: 0000000000000000 RSI: ffff880071587fd8 RDI: ffff=
ffff81a0e640
> [ =C2=A0453.531303] RBP: ffff880071587eb8 R08: 00000000000004af R09: 0000=
0000000003e5
> [ =C2=A0453.533276] R10: ffffffff00000001 R11: ffff880100253b40 R12: 0000=
000000000010
> [ =C2=A0453.535249] R13: 12187898d4512ee3 R14: 0000000000000002 R15: 0000=
000000000001
> [ =C2=A0453.537229] FS: =C2=A00000000000000000(0000) GS:ffff880100240000(=
0000) knlGS:0000000000000000
> [ =C2=A0453.539224] CS: =C2=A00010 DS: 0000 ES: 0000 CR0: 000000008005003=
b
> [ =C2=A0453.541210] CR2: 00000037d9071fa0 CR3: 0000000001a03000 CR4: 0000=
0000000406e0
> [ =C2=A0453.543220] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000=
000000000000
> [ =C2=A0453.545233] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000=
000000000400
> [ =C2=A0453.547239] Process kworker/0:0 (pid: 0, threadinfo ffff880071586=
000, task ffff880071589700)
> [ =C2=A0453.549274] Stack:
> [ =C2=A0453.551289] =C2=A0ffff880071587e88 ffffffff810731c0 ffff880100251=
290 0000000000011290
> [ =C2=A0453.553301] =C2=A0ffff880071587eb8 000000018139c97a ffffe8ffffc40=
170 ffffe8ffffc40170
> [ =C2=A0453.555257] =C2=A0ffffe8ffffc40240 0000000000000000 ffff880071587=
ef8 ffffffff8139b868
> [ =C2=A0453.557156] Call Trace:
> [ =C2=A0453.558980] =C2=A0[<ffffffff810731c0>] ? pm_qos_request+0x3e/0x45
> [ =C2=A0453.560817] =C2=A0[<ffffffff8139b868>] cpuidle_idle_call+0xe7/0x1=
66
> [ =C2=A0453.562635] =C2=A0[<ffffffff81008321>] cpu_idle+0xa5/0xdf
> [ =C2=A0453.564438] =C2=A0[<ffffffff8146ae57>] start_secondary+0x223/0x22=
5
> [ =C2=A0453.566227] Code: 28 e0 ff ff 80 e2 08 75 22 31 d2 48 83 c0 10 48=
 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e0 0f=
 01 c9 <e8> 23 09 e0 ff 4c 29 e8 48 89 c7 e8 ab 29 de ff 4c 69 e0 40 42
> [ =C2=A0453.570292] Call Trace:
> [ =C2=A0453.572196] =C2=A0[<ffffffff810731c0>] ? pm_qos_request+0x3e/0x45
> [ =C2=A0453.574117] =C2=A0[<ffffffff8139b868>] cpuidle_idle_call+0xe7/0x1=
66
> [ =C2=A0453.576031] =C2=A0[<ffffffff81008321>] cpu_idle+0xa5/0xdf
> [ =C2=A0453.577924] =C2=A0[<ffffffff8146ae57>] start_secondary+0x223/0x22=
5
> [ =C2=A0453.579811] NMI backtrace for cpu 0
> [ =C2=A0453.581279] CPU 0
> [ =C2=A0453.581289] Modules linked in: netconsole configfs cpufreq_ondema=
nd acpi_cpufreq freq_table mperf snd_hda_codec_hdmi snd_hda_codec_conexant =
arc4 snd_hda_intel snd_hda_codec iwlagn snd_hwdep snd_seq mac80211 snd_seq_=
device uvcvideo btusb cfg80211 bluetooth wmi e1000e snd_pcm videodev rfkill=
 i2c_i801 microcode iTCO_wdt iTCO_vendor_support xhci_hcd snd_timer v4l2_co=
mpat_ioctl32 joydev pcspkr snd soundcore snd_page_alloc uinput ipv6 sdhci_p=
ci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last=
 unloaded: scsi_wait_scan]
> [ =C2=A0453.587576]
> [ =C2=A0453.589160] Pid: 0, comm: swapper Not tainted 2.6.39-rc4+ #1 LENO=
VO 4170CTO/4170CTO
> [ =C2=A0453.590777] RIP: 0010:[<ffffffff8100f0fa>] =C2=A0[<ffffffff8100f0=
fa>] native_read_tsc+0x1/0x14
> [ =C2=A0453.592390] RSP: 0018:ffff880100203b98 =C2=A0EFLAGS: 00000883
> [ =C2=A0453.594001] RAX: 00000000f9ab6980 RBX: 0000000000002710 RCX: 0000=
000000000040
> [ =C2=A0453.595624] RDX: 000000000026066c RSI: 0000000000000100 RDI: 0000=
00000026066d
> [ =C2=A0453.597250] RBP: ffff880100203ba8 R08: 000000008b000052 R09: 0000=
000000000000
> [ =C2=A0453.598872] R10: 0000000000000000 R11: 0000000000000003 R12: 0000=
00000026066d
> [ =C2=A0453.600437] R13: 0000000000000000 R14: 0000000000000002 R15: 0000=
000000000001
> [ =C2=A0453.601924] FS: =C2=A00000000000000000(0000) GS:ffff880100200000(=
0000) knlGS:0000000000000000
> [ =C2=A0453.603434] CS: =C2=A00010 DS: 0000 ES: 0000 CR0: 000000008005003=
b
> [ =C2=A0453.604942] CR2: 0000000000440360 CR3: 0000000001a03000 CR4: 0000=
0000000406f0
> [ =C2=A0453.606460] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000=
000000000000
> [ =C2=A0453.607981] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000=
000000000400
> [ =C2=A0453.609597] Process swapper (pid: 0, threadinfo ffffffff81a00000,=
 task ffffffff81a0b020)
> [ =C2=A0453.611134] Stack:
> [ =C2=A0453.612655] =C2=A0ffff880100203ba8 ffffffff81232dfe ffff880100203=
bd8 ffffffff81232ecb
> [ =C2=A0453.614176] =C2=A00000000000002710 0000000000000008 0000000000000=
06c 0000000000000002
> [ =C2=A0453.615656] =C2=A0ffff880100203be8 ffffffff81232e49 ffff880100203=
bf8 ffffffff81232e77
> [ =C2=A0453.617101] Call Trace:
> [ =C2=A0453.618492] =C2=A0<IRQ>
> [ =C2=A0453.619874] =C2=A0[<ffffffff81232dfe>] ? paravirt_read_tsc+0xe/0x=
12
> [ =C2=A0453.621251] =C2=A0[<ffffffff81232ecb>] delay_tsc+0x27/0x74
> [ =C2=A0453.622613] =C2=A0[<ffffffff81232e49>] __delay+0xf/0x11
> [ =C2=A0453.623973] =C2=A0[<ffffffff81232e77>] __const_udelay+0x2c/0x2e
> [ =C2=A0453.625322] =C2=A0[<ffffffff8102166e>] arch_trigger_all_cpu_backt=
race+0x76/0x88
> [ =C2=A0453.626673] =C2=A0[<ffffffff812be0ad>] sysrq_handle_showallcpus+0=
xe/0x10
> [ =C2=A0453.628027] =C2=A0[<ffffffff812be310>] __handle_sysrq+0xa2/0x13c
> [ =C2=A0453.629372] =C2=A0[<ffffffff812be514>] sysrq_filter+0x112/0x16e
> [ =C2=A0453.630706] =C2=A0[<ffffffff81365764>] input_pass_event+0x94/0xcc
> [ =C2=A0453.632028] =C2=A0[<ffffffff81366bf1>] input_handle_event+0x480/0=
x48f
> [ =C2=A0453.633342] =C2=A0[<ffffffff810483af>] ? walk_tg_tree.constprop.7=
1+0x28/0x94
> [ =C2=A0453.634655] =C2=A0[<ffffffff81366cf2>] input_event+0x69/0x87
> [ =C2=A0453.635978] =C2=A0[<ffffffff8136c17b>] atkbd_interrupt+0x4c1/0x58=
e
> [ =C2=A0453.637283] =C2=A0[<ffffffff81361b2e>] serio_interrupt+0x45/0x7f
> [ =C2=A0453.638563] =C2=A0[<ffffffff81362870>] i8042_interrupt+0x299/0x2a=
b
> [ =C2=A0453.639830] =C2=A0[<ffffffff8100eb79>] ? native_sched_clock+0x34/=
0x36
> [ =C2=A0453.641092] =C2=A0[<ffffffff810a95d5>] handle_irq_event_percpu+0x=
5f/0x198
> [ =C2=A0453.642354] =C2=A0[<ffffffff810a9746>] handle_irq_event+0x38/0x56
> [ =C2=A0453.643598] =C2=A0[<ffffffff81022e0e>] ? ack_apic_edge+0x25/0x29
> [ =C2=A0453.644832] =C2=A0[<ffffffff810ab71a>] handle_edge_irq+0x9d/0xc0
> [ =C2=A0453.646069] =C2=A0[<ffffffff8100ab9d>] handle_irq+0x88/0x8e
> [ =C2=A0453.647299] =C2=A0[<ffffffff8148409d>] do_IRQ+0x4d/0xa5
> [ =C2=A0453.648527] =C2=A0[<ffffffff8147c253>] common_interrupt+0x13/0x13
> [ =C2=A0453.649695] =C2=A0<EOI>
> [ =C2=A0453.650794] =C2=A0[<ffffffff8100e6cd>] ? paravirt_read_tsc+0x9/0x=
d
> [ =C2=A0453.651911] =C2=A0[<ffffffff81275d67>] ? intel_idle+0xdb/0x100
> [ =C2=A0453.653025] =C2=A0[<ffffffff81275d46>] ? intel_idle+0xba/0x100
> [ =C2=A0453.654129] =C2=A0[<ffffffff8139b868>] cpuidle_idle_call+0xe7/0x1=
66
> [ =C2=A0453.655231] =C2=A0[<ffffffff81008321>] cpu_idle+0xa5/0xdf
> [ =C2=A0453.656329] =C2=A0[<ffffffff8145a91e>] rest_init+0x72/0x74
> [ =C2=A0453.657417] =C2=A0[<ffffffff81b59b9f>] start_kernel+0x3de/0x3e9
> [ =C2=A0453.658514] =C2=A0[<ffffffff81b592c4>] x86_64_start_reservations+=
0xaf/0xb3
> [ =C2=A0453.659576] =C2=A0[<ffffffff81b59140>] ? early_idt_handlers+0x140=
/0x140
> [ =C2=A0453.660589] =C2=A0[<ffffffff81b593ca>] x86_64_start_kernel+0x102/=
0x111
> [ =C2=A0453.661559] Code: 21 00 00 e8 74 3d 22 00 5d c3 90 90 90 55 40 88=
 f8 48 89 e5 e6 70 e4 71 5d c3 55 40 88 f0 48 89 e5 e6 70 40 88 f8 e6 71 5d=
 c3 55
> [ =C2=A0453.661721] =C2=A089 e5 0f 31 89 c1 48 89 d0 48 c1 e0 20 48 09 c8=
 5d c3 55 b2
> [ =C2=A0453.663728] Call Trace:
> [ =C2=A0453.664713] =C2=A0<IRQ> =C2=A0[<ffffffff81232dfe>] ? paravirt_rea=
d_tsc+0xe/0x12
> [ =C2=A0453.665710] =C2=A0[<ffffffff81232ecb>] delay_tsc+0x27/0x74
> [ =C2=A0453.666698] =C2=A0[<ffffffff81232e49>] __delay+0xf/0x11
> [ =C2=A0453.667686] =C2=A0[<ffffffff81232e77>] __const_udelay+0x2c/0x2e
> [ =C2=A0453.668675] =C2=A0[<ffffffff8102166e>] arch_trigger_all_cpu_backt=
race+0x76/0x88
> [ =C2=A0453.669676] =C2=A0[<ffffffff812be0ad>] sysrq_handle_showallcpus+0=
xe/0x10
> [ =C2=A0453.670681] =C2=A0[<ffffffff812be310>] __handle_sysrq+0xa2/0x13c
> [ =C2=A0453.671676] =C2=A0[<ffffffff812be514>] sysrq_filter+0x112/0x16e
> [ =C2=A0453.672662] =C2=A0[<ffffffff81365764>] input_pass_event+0x94/0xcc
> [ =C2=A0453.673646] =C2=A0[<ffffffff81366bf1>] input_handle_event+0x480/0=
x48f
> [ =C2=A0453.674627] =C2=A0[<ffffffff810483af>] ? walk_tg_tree.constprop.7=
1+0x28/0x94
> [ =C2=A0453.675614] =C2=A0[<ffffffff81366cf2>] input_event+0x69/0x87
> [ =C2=A0453.676587] =C2=A0[<ffffffff8136c17b>] atkbd_interrupt+0x4c1/0x58=
e
> [ =C2=A0453.677550] =C2=A0[<ffffffff81361b2e>] serio_interrupt+0x45/0x7f
> [ =C2=A0453.678498] =C2=A0[<ffffffff81362870>] i8042_interrupt+0x299/0x2a=
b
> [ =C2=A0453.679431] =C2=A0[<ffffffff8100eb79>] ? native_sched_clock+0x34/=
0x36
> [ =C2=A0453.680351] =C2=A0[<ffffffff810a95d5>] handle_irq_event_percpu+0x=
5f/0x198
> [ =C2=A0453.681270] =C2=A0[<ffffffff810a9746>] handle_irq_event+0x38/0x56
> [ =C2=A0453.682186] =C2=A0[<ffffffff81022e0e>] ? ack_apic_edge+0x25/0x29
> [ =C2=A0453.683100] =C2=A0[<ffffffff810ab71a>] handle_edge_irq+0x9d/0xc0
> [ =C2=A0453.684014] =C2=A0[<ffffffff8100ab9d>] handle_irq+0x88/0x8e
> [ =C2=A0453.684924] =C2=A0[<ffffffff8148409d>] do_IRQ+0x4d/0xa5
> [ =C2=A0453.685831] =C2=A0[<ffffffff8147c253>] common_interrupt+0x13/0x13
> [ =C2=A0453.686740] =C2=A0<EOI> =C2=A0[<ffffffff8100e6cd>] ? paravirt_rea=
d_tsc+0x9/0xd
> [ =C2=A0453.687655] =C2=A0[<ffffffff81275d67>] ? intel_idle+0xdb/0x100
> [ =C2=A0453.688573] =C2=A0[<ffffffff81275d46>] ? intel_idle+0xba/0x100
> [ =C2=A0453.689480] =C2=A0[<ffffffff8139b868>] cpuidle_idle_call+0xe7/0x1=
66
> [ =C2=A0453.690387] =C2=A0[<ffffffff81008321>] cpu_idle+0xa5/0xdf
> [ =C2=A0453.691293] =C2=A0[<ffffffff8145a91e>] rest_init+0x72/0x74
> [ =C2=A0453.692195] =C2=A0[<ffffffff81b59b9f>] start_kernel+0x3de/0x3e9
> [ =C2=A0453.693095] =C2=A0[<ffffffff81b592c4>] x86_64_start_reservations+=
0xaf/0xb3
> [ =C2=A0453.693996] =C2=A0[<ffffffff81b59140>] ? early_idt_handlers+0x140=
/0x140
> [ =C2=A0453.694905] =C2=A0[<ffffffff81b593ca>] x86_64_start_kernel+0x102/=
0x111
> [ =C2=A0454.680802] SysRq : Show Blocked State
> [ =C2=A0454.683427] =C2=A0 task =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0PC stack =C2=A0 pid father
> [ =C2=A0454.686058] systemd =C2=A0 =C2=A0 =C2=A0 =C2=A0 D 000000000000000=
0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 1 =C2=A0 =C2=A0 =C2=A00 0x00000000
> [ =C2=A0454.688752] =C2=A0ffff8801003bdcd8 0000000000000082 ffff8801003bd=
c88 ffffffff00000000
> [ =C2=A0454.691491] =C2=A0ffff880100370000 ffff8801003bdfd8 ffff8801003bd=
fd8 0000000000013b40
> [ =C2=A0454.694228] =C2=A0ffff8800715e1700 ffff880100370000 ffff8801003bd=
cb8 00000001811329db
> [ =C2=A0454.696969] Call Trace:
> [ =C2=A0454.699683] =C2=A0[<ffffffff8147ac4b>] schedule_timeout+0x34/0xde
> [ =C2=A0454.702447] =C2=A0[<ffffffff810ad618>] ? __call_rcu+0x123/0x12c
> [ =C2=A0454.705184] =C2=A0[<ffffffff810ad64d>] ? call_rcu_sched+0x15/0x17
> [ =C2=A0454.707906] =C2=A0[<ffffffff8147aa14>] wait_for_common+0xac/0x101
> [ =C2=A0454.710656] =C2=A0[<ffffffff8104c7af>] ? try_to_wake_up+0x226/0x2=
26
> [ =C2=A0454.713445] =C2=A0[<ffffffff8147ab1d>] wait_for_completion+0x1d/0=
x1f
> [ =C2=A0454.716199] =C2=A0[<ffffffff810ada5a>] synchronize_sched+0x5a/0x5=
c
> [ =C2=A0454.718972] =C2=A0[<ffffffff8106bdb8>] ? find_ge_pid+0x43/0x43
> [ =C2=A0454.721766] =C2=A0[<ffffffff81090d05>] cgroup_diput+0x37/0xe3
> [ =C2=A0454.724562] =C2=A0[<ffffffff81090cce>] ? parse_cgroupfs_options+0=
x353/0x353
> [ =C2=A0454.727328] =C2=A0[<ffffffff8112fc79>] dentry_kill+0xfa/0x121
> [ =C2=A0454.730103] =C2=A0[<ffffffff81130189>] dput+0xdd/0xea
> [ =C2=A0454.732866] =C2=A0[<ffffffff8112aa68>] do_rmdir+0xc6/0xfe
> [ =C2=A0454.735481] =C2=A0[<ffffffff8111dc78>] ? filp_close+0x6e/0x7a
> [ =C2=A0454.737990] =C2=A0[<ffffffff8112b32f>] sys_rmdir+0x16/0x18
> [ =C2=A0454.740469] =C2=A0[<ffffffff81482642>] system_call_fastpath+0x16/=
0x1b
> [ =C2=A0454.742935] flush-253:2 =C2=A0 =C2=A0 D 0000000000000000 =C2=A0 =
=C2=A0 0 =C2=A0 793 =C2=A0 =C2=A0 =C2=A02 0x00000000
> [ =C2=A0454.745425] =C2=A0ffff88006355b710 0000000000000046 ffff88006355b=
6b0 ffffffff00000000
> [ =C2=A0454.747955] =C2=A0ffff880037ee9700 ffff88006355bfd8 ffff88006355b=
fd8 0000000000013b40
> [ =C2=A0454.750506] =C2=A0ffffffff81a0b020 ffff880037ee9700 ffff88006355b=
710 000000018106e7c3
> [ =C2=A0454.753048] Call Trace:
> [ =C2=A0454.755537] =C2=A0[<ffffffff811c82b8>] do_get_write_access+0x1c6/=
0x38d
> [ =C2=A0454.758071] =C2=A0[<ffffffff8106e88b>] ? autoremove_wake_function=
+0x3d/0x3d
> [ =C2=A0454.760644] =C2=A0[<ffffffff811c8588>] jbd2_journal_get_write_acc=
ess+0x2b/0x42
> [ =C2=A0454.763206] =C2=A0[<ffffffff8118ea4f>] ? ext4_read_block_bitmap+0=
x54/0x2d0
> [ =C2=A0454.765770] =C2=A0[<ffffffff811b5888>] __ext4_journal_get_write_a=
ccess+0x58/0x66
> [ =C2=A0454.768353] =C2=A0[<ffffffff811b8dbe>] ext4_mb_mark_diskspace_use=
d+0x70/0x2ae
> [ =C2=A0454.770942] =C2=A0[<ffffffff811bb10e>] ext4_mb_new_blocks+0x1c8/0=
x3c2
> [ =C2=A0454.773501] =C2=A0[<ffffffff811b4628>] ext4_ext_map_blocks+0x1961=
/0x1c04
> [ =C2=A0454.776082] =C2=A0[<ffffffff8122ed78>] ? radix_tree_gang_lookup_t=
ag_slot+0x81/0xa2
> [ =C2=A0454.778711] =C2=A0[<ffffffff810d55f9>] ? find_get_pages_tag+0x3b/=
0xd6
> [ =C2=A0454.781323] =C2=A0[<ffffffff811967fa>] ext4_map_blocks+0x112/0x1e=
7
> [ =C2=A0454.783894] =C2=A0[<ffffffff811984e8>] mpage_da_map_and_submit+0x=
93/0x2cd
> [ =C2=A0454.786491] =C2=A0[<ffffffff81198de5>] ext4_da_writepages+0x2c1/0=
x44d
> [ =C2=A0454.789090] =C2=A0[<ffffffff810ddeb4>] do_writepages+0x21/0x2a
> [ =C2=A0454.791703] =C2=A0[<ffffffff8113cbb7>] writeback_single_inode+0xb=
2/0x1bc
> [ =C2=A0454.794334] =C2=A0[<ffffffff8113cf03>] writeback_sb_inodes+0xcd/0=
x161
> [ =C2=A0454.796962] =C2=A0[<ffffffff8113d407>] writeback_inodes_wb+0x119/=
0x12b
> [ =C2=A0454.799582] =C2=A0[<ffffffff8113d607>] wb_writeback+0x1ee/0x335
> [ =C2=A0454.802204] =C2=A0[<ffffffff81080be3>] ? arch_local_irq_save+0x15=
/0x1b
> [ =C2=A0454.804803] =C2=A0[<ffffffff8147be3a>] ? _raw_spin_lock_irqsave+0=
x12/0x2f
> [ =C2=A0454.807427] =C2=A0[<ffffffff8113d891>] wb_do_writeback+0x143/0x19=
d
> [ =C2=A0454.810077] =C2=A0[<ffffffff8147acc7>] ? schedule_timeout+0xb0/0x=
de
> [ =C2=A0454.812776] =C2=A0[<ffffffff8113d973>] bdi_writeback_thread+0x88/=
0x1e5
> [ =C2=A0454.815464] =C2=A0[<ffffffff8113d8eb>] ? wb_do_writeback+0x19d/0x=
19d
> [ =C2=A0454.818129] =C2=A0[<ffffffff8106e157>] kthread+0x84/0x8c
> [ =C2=A0454.820808] =C2=A0[<ffffffff81483764>] kernel_thread_helper+0x4/0=
x10
> [ =C2=A0454.823452] =C2=A0[<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/=
0x148
> [ =C2=A0454.826103] =C2=A0[<ffffffff81483760>] ? gs_change+0x13/0x13
> [ =C2=A0454.828711] jbd2/dm-2-8 =C2=A0 =C2=A0 D 0000000000000000 =C2=A0 =
=C2=A0 0 =C2=A0 799 =C2=A0 =C2=A0 =C2=A02 0x00000000
> [ =C2=A0454.831390] =C2=A0ffff88006d59db10 0000000000000046 ffff88006d59d=
aa0 ffffffff00000000
> [ =C2=A0454.834094] =C2=A0ffff88006deb4500 ffff88006d59dfd8 ffff88006d59d=
fd8 0000000000013b40
> [ =C2=A0454.836788] =C2=A0ffffffff81a0b020 ffff88006deb4500 ffff88006d59d=
ad0 000000016d59dad0
> [ =C2=A0454.839453] Call Trace:
> [ =C2=A0454.842098] =C2=A0[<ffffffff810d5904>] ? lock_page+0x3e/0x3e
> [ =C2=A0454.844738] =C2=A0[<ffffffff810d5904>] ? lock_page+0x3e/0x3e
> [ =C2=A0454.847303] =C2=A0[<ffffffff8147a7c9>] io_schedule+0x63/0x7e
> [ =C2=A0454.849877] =C2=A0[<ffffffff810d5912>] sleep_on_page+0xe/0x12
> [ =C2=A0454.852469] =C2=A0[<ffffffff8147aea9>] __wait_on_bit+0x48/0x7b
> [ =C2=A0454.855021] =C2=A0[<ffffffff810d5a8c>] wait_on_page_bit+0x72/0x74
> [ =C2=A0454.857583] =C2=A0[<ffffffff8106e88b>] ? autoremove_wake_function=
+0x3d/0x3d
> [ =C2=A0454.860171] =C2=A0[<ffffffff810d5b6b>] filemap_fdatawait_range+0x=
84/0x163
> [ =C2=A0454.862744] =C2=A0[<ffffffff810d5c6e>] filemap_fdatawait+0x24/0x2=
6
> [ =C2=A0454.865299] =C2=A0[<ffffffff811c94a2>] jbd2_journal_commit_transa=
ction+0x922/0x1194
> [ =C2=A0454.867892] =C2=A0[<ffffffff81008714>] ? __switch_to+0xc6/0x220
> [ =C2=A0454.870496] =C2=A0[<ffffffff811cd3b6>] kjournald2+0xc9/0x20a
> [ =C2=A0454.873103] =C2=A0[<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0=
x3a
> [ =C2=A0454.875690] =C2=A0[<ffffffff811cd2ed>] ? commit_timeout+0x10/0x10
> [ =C2=A0454.878327] =C2=A0[<ffffffff8106e157>] kthread+0x84/0x8c
> [ =C2=A0454.880961] =C2=A0[<ffffffff81483764>] kernel_thread_helper+0x4/0=
x10
> [ =C2=A0454.883604] =C2=A0[<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/=
0x148
> [ =C2=A0454.886262] =C2=A0[<ffffffff81483760>] ? gs_change+0x13/0x13
> [ =C2=A0454.888875] tar =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 D ffff8=
8006e573af8 =C2=A0 =C2=A0 0 =C2=A0 991 =C2=A0 =C2=A0838 0x00000000
> [ =C2=A0454.891546] =C2=A0ffff880037f5b8a8 0000000000000086 ffff8801002a1=
d40 0000000000000282
> [ =C2=A0454.894213] =C2=A0ffff88006d644500 ffff880037f5bfd8 ffff880037f5b=
fd8 0000000000013b40
> [ =C2=A0454.896889] =C2=A0ffff8801002b4500 ffff88006d644500 ffff880037f5b=
8a8 ffffffff8106e7c3
> [ =C2=A0454.899530] Call Trace:
> [ =C2=A0454.902118] =C2=A0[<ffffffff8106e7c3>] ? prepare_to_wait+0x6c/0x7=
8
> [ =C2=A0454.904724] =C2=A0[<ffffffff811c82b8>] do_get_write_access+0x1c6/=
0x38d
> [ =C2=A0454.907344] =C2=A0[<ffffffff8106e88b>] ? autoremove_wake_function=
+0x3d/0x3d
> [ =C2=A0454.909967] =C2=A0[<ffffffff811991cc>] ? ext4_dirty_inode+0x33/0x=
4c
> [ =C2=A0454.912574] =C2=A0[<ffffffff811c8588>] jbd2_journal_get_write_acc=
ess+0x2b/0x42
> [ =C2=A0454.915192] =C2=A0[<ffffffff811b5888>] __ext4_journal_get_write_a=
ccess+0x58/0x66
> [ =C2=A0454.917819] =C2=A0[<ffffffff81195526>] ext4_reserve_inode_write+0=
x41/0x83
> [ =C2=A0454.920459] =C2=A0[<ffffffff811955e4>] ext4_mark_inode_dirty+0x7c=
/0x1f0
> [ =C2=A0454.923070] =C2=A0[<ffffffff811991cc>] ext4_dirty_inode+0x33/0x4c
> [ =C2=A0454.925660] =C2=A0[<ffffffff8113c3d6>] __mark_inode_dirty+0x2f/0x=
175
> [ =C2=A0454.928247] =C2=A0[<ffffffff81143a0d>] generic_write_end+0x6c/0x7=
e
> [ =C2=A0454.930865] =C2=A0[<ffffffff811983f6>] ext4_da_write_end+0x1a5/0x=
204
> [ =C2=A0454.933454] =C2=A0[<ffffffff810d5e9d>] generic_file_buffered_writ=
e+0x17e/0x23a
> [ =C2=A0454.936062] =C2=A0[<ffffffff810d6c9d>] __generic_file_aio_write+0=
x242/0x272
> [ =C2=A0454.938648] =C2=A0[<ffffffff810d6d2e>] generic_file_aio_write+0x6=
1/0xba
> [ =C2=A0454.941288] =C2=A0[<ffffffff8118fe00>] ext4_file_write+0x1dc/0x23=
4
> [ =C2=A0454.943909] =C2=A0[<ffffffff8111edab>] do_sync_write+0xbf/0xff
> [ =C2=A0454.946501] =C2=A0[<ffffffff8114b9fc>] ? fsnotify+0x1eb/0x217
> [ =C2=A0454.949114] =C2=A0[<ffffffff811f1866>] ? selinux_file_permission+=
0x58/0xb4
> [ =C2=A0454.951736] =C2=A0[<ffffffff811e9cfe>] ? security_file_permission=
+0x2e/0x33
> [ =C2=A0454.954349] =C2=A0[<ffffffff8111f196>] ? rw_verify_area+0xb0/0xcd
> [ =C2=A0454.956943] =C2=A0[<ffffffff8111f421>] vfs_write+0xac/0xf3
> [ =C2=A0454.959530] =C2=A0[<ffffffff8111f610>] sys_write+0x4a/0x6e
> [ =C2=A0454.962129] =C2=A0[<ffffffff81482642>] system_call_fastpath+0x16/=
0x1b
> [ =C2=A0454.964732] dhclient-script D 0000000000000000 =C2=A0 =C2=A0 0 =
=C2=A02856 =C2=A0 2855 0x00000000
> [ =C2=A0454.967360] =C2=A0ffff88006e1f5b18 0000000000000082 ffff8800378da=
880 0000000000000000
> [ =C2=A0454.970056] =C2=A0ffff88006deb1700 ffff88006e1f5fd8 ffff88006e1f5=
fd8 0000000000013b40
> [ =C2=A0454.972706] =C2=A0ffff880071589700 ffff88006deb1700 ffff88006e1f5=
ad8 000000016e1f5ad8
> [ =C2=A0454.975323] Call Trace:
> [ =C2=A0454.977882] =C2=A0[<ffffffff810d5916>] ? sleep_on_page+0x12/0x12
> [ =C2=A0454.980477] =C2=A0[<ffffffff8147a7c9>] io_schedule+0x63/0x7e
> [ =C2=A0454.983063] =C2=A0[<ffffffff810d5924>] sleep_on_page_killable+0xe=
/0x3b
> [ =C2=A0454.985622] =C2=A0[<ffffffff8147ad9b>] __wait_on_bit_lock+0x46/0x=
8f
> [ =C2=A0454.988182] =C2=A0[<ffffffff810d5819>] __lock_page_killable+0x66/=
0x68
> [ =C2=A0454.990785] =C2=A0[<ffffffff8106e88b>] ? autoremove_wake_function=
+0x3d/0x3d
> [ =C2=A0454.993436] =C2=A0[<ffffffff810d5859>] lock_page_killable+0x3e/0x=
43
> [ =C2=A0454.996099] =C2=A0[<ffffffff810d71ea>] generic_file_aio_read+0x46=
3/0x640
> [ =C2=A0454.998730] =C2=A0[<ffffffff8111eeaa>] do_sync_read+0xbf/0xff
> [ =C2=A0455.001383] =C2=A0[<ffffffff811ebc34>] ? avc_has_perm+0x51/0x63
> [ =C2=A0455.004012] =C2=A0[<ffffffff811e9cfe>] ? security_file_permission=
+0x2e/0x33
> [ =C2=A0455.006644] =C2=A0[<ffffffff8111f196>] ? rw_verify_area+0xb0/0xcd
> [ =C2=A0455.009289] =C2=A0[<ffffffff8111f511>] vfs_read+0xa9/0xf0
> [ =C2=A0455.011917] =C2=A0[<ffffffff811233eb>] kernel_read+0x41/0x4f
> [ =C2=A0455.014511] =C2=A0[<ffffffff811234dd>] prepare_binprm+0xe4/0xe8
> [ =C2=A0455.017094] =C2=A0[<ffffffff81124d40>] do_execve+0x114/0x277
> [ =C2=A0455.019678] =C2=A0[<ffffffff8100ff91>] sys_execve+0x43/0x5a
> [ =C2=A0455.022281] =C2=A0[<ffffffff81482a9c>] stub_execve+0x6c/0xc0
> [ =C2=A0455.024888] Sched Debug Version: v0.10, 2.6.39-rc4+ #1
> [ =C2=A0455.027487] ktime =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 :=
 455879.226285
> [ =C2=A0455.030142] sched_clk =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 455024.886=
257
> [ =C2=A0455.032786] cpu_clk =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 455024=
.886397
> [ =C2=A0455.035352] jiffies =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 429512=
3185
> [ =C2=A0455.037904] sched_clock_stable =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 1
> [ =C2=A0455.040413]
> [ =C2=A0455.042892] sysctl_sched
> [ =C2=A0455.045306] =C2=A0 .sysctl_sched_latency =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 18.000000
> [ =C2=A0455.047775] =C2=A0 .sysctl_sched_min_granularity =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0: 2.250000
> [ =C2=A0455.050206] =C2=A0 .sysctl_sched_wakeup_granularity =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 : 3.000000
> [ =C2=A0455.052643] =C2=A0 .sysctl_sched_child_runs_first =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.055034] =C2=A0 .sysctl_sched_features =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 7279
> [ =C2=A0455.057423] =C2=A0 .sysctl_sched_tunable_scaling =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0: 1 (logaritmic)
> [ =C2=A0455.059829]
> [ =C2=A0455.059830] cpu#0, 2491.994 MHz
> [ =C2=A0455.064443] =C2=A0 .nr_running =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.066757] =C2=A0 .load =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.069054] =C2=A0 .nr_switches =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 146510
> [ =C2=A0455.071353] =C2=A0 .nr_load_updates =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 : 233084
> [ =C2=A0455.073642] =C2=A0 .nr_uninterruptible =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0: 2
> [ =C2=A0455.075894] =C2=A0 .next_balance =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 4295.122831
> [ =C2=A0455.078152] =C2=A0 .curr->pid =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.080396] =C2=A0 .clock =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 454680.481348
> [ =C2=A0455.082634] =C2=A0 .cpu_load[0] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.084867] =C2=A0 .cpu_load[1] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.087065] =C2=A0 .cpu_load[2] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.089233] =C2=A0 .cpu_load[3] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.091390] =C2=A0 .cpu_load[4] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.093499] =C2=A0 .yld_count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.095605] =C2=A0 .sched_switch =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.097667] =C2=A0 .sched_count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 149062
> [ =C2=A0455.099765] =C2=A0 .sched_goidle =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 62756
> [ =C2=A0455.101781] =C2=A0 .avg_idle =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 1000000
> [ =C2=A0455.103807] =C2=A0 .ttwu_count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 77219
> [ =C2=A0455.105958] =C2=A0 .ttwu_local =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 74144
> [ =C2=A0455.107957] =C2=A0 .bkl_count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.109914]
> [ =C2=A0455.109915] cfs_rq[0]:/
> [ =C2=A0455.113642] =C2=A0 .exec_clock =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 20017.048374
> [ =C2=A0455.115515] =C2=A0 .MIN_vruntime =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0.000001
> [ =C2=A0455.117353] =C2=A0 .min_vruntime =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 28900.800090
> [ =C2=A0455.119185] =C2=A0 .max_vruntime =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0.000001
> [ =C2=A0455.121028] =C2=A0 .spread =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0.000000
> [ =C2=A0455.122820] =C2=A0 .spread0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0.000000
> [ =C2=A0455.124581] =C2=A0 .nr_spread_over =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0: 54
> [ =C2=A0455.126318] =C2=A0 .nr_running =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.128045] =C2=A0 .load =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.129743] =C2=A0 .load_avg =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0.000000
> [ =C2=A0455.131414] =C2=A0 .load_period =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0.000000
> [ =C2=A0455.133052] =C2=A0 .load_contrib =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.134692] =C2=A0 .load_tg =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.136305]
> [ =C2=A0455.136306] runnable tasks:
> [ =C2=A0455.136307] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 task =C2=A0=
 PID =C2=A0 =C2=A0 =C2=A0 =C2=A0 tree-key =C2=A0switches =C2=A0prio =C2=A0 =
=C2=A0 exec-runtime =C2=A0 =C2=A0 =C2=A0 =C2=A0 sum-exec =C2=A0 =C2=A0 =C2=
=A0 =C2=A0sum-sleep
> [ =C2=A0455.136310] -----------------------------------------------------=
-----------------------------------------------------
> [ =C2=A0455.142856]
> [ =C2=A0455.142857] cpu#1, 2491.994 MHz
> [ =C2=A0455.146215] =C2=A0 .nr_running =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.147931] =C2=A0 .load =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.149648] =C2=A0 .nr_switches =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 62175
> [ =C2=A0455.151348] =C2=A0 .nr_load_updates =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 : 217324
> [ =C2=A0455.153045] =C2=A0 .nr_uninterruptible =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0: 2
> [ =C2=A0455.154747] =C2=A0 .next_balance =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 4295.123306
> [ =C2=A0455.156457] =C2=A0 .curr->pid =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.158149] =C2=A0 .clock =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 455157.364642
> [ =C2=A0455.159867] =C2=A0 .cpu_load[0] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.161594] =C2=A0 .cpu_load[1] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.163283] =C2=A0 .cpu_load[2] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.164954] =C2=A0 .cpu_load[3] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.166575] =C2=A0 .cpu_load[4] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.168185] =C2=A0 .yld_count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 60
> [ =C2=A0455.169791] =C2=A0 .sched_switch =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.171401] =C2=A0 .sched_count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 62899
> [ =C2=A0455.172984] =C2=A0 .sched_goidle =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 27394
> [ =C2=A0455.174580] =C2=A0 .avg_idle =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 1000000
> [ =C2=A0455.176171] =C2=A0 .ttwu_count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 30510
> [ =C2=A0455.177739] =C2=A0 .ttwu_local =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 25277
> [ =C2=A0455.179292] =C2=A0 .bkl_count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.180882]
> [ =C2=A0455.180883] cfs_rq[1]:/
> [ =C2=A0455.183954] =C2=A0 .exec_clock =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 10655.021809
> [ =C2=A0455.185550] =C2=A0 .MIN_vruntime =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0.000001
> [ =C2=A0455.187141] =C2=A0 .min_vruntime =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 19718.135550
> [ =C2=A0455.188771] =C2=A0 .max_vruntime =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0.000001
> [ =C2=A0455.190407] =C2=A0 .spread =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0.000000
> [ =C2=A0455.192016] =C2=A0 .spread0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : -9182.664540
> [ =C2=A0455.193634] =C2=A0 .nr_spread_over =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0: 80
> [ =C2=A0455.195242] =C2=A0 .nr_running =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.196848] =C2=A0 .load =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.198441] =C2=A0 .load_avg =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0.000000
> [ =C2=A0455.200059] =C2=A0 .load_period =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0.000000
> [ =C2=A0455.201654] =C2=A0 .load_contrib =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.203240] =C2=A0 .load_tg =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.204836]
> [ =C2=A0455.204837] runnable tasks:
> [ =C2=A0455.204838] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 task =C2=A0=
 PID =C2=A0 =C2=A0 =C2=A0 =C2=A0 tree-key =C2=A0switches =C2=A0prio =C2=A0 =
=C2=A0 exec-runtime =C2=A0 =C2=A0 =C2=A0 =C2=A0 sum-exec =C2=A0 =C2=A0 =C2=
=A0 =C2=A0sum-sleep
> [ =C2=A0455.204841] -----------------------------------------------------=
-----------------------------------------------------
> [ =C2=A0455.211403]
> [ =C2=A0455.211404] cpu#2, 2491.994 MHz
> [ =C2=A0455.214958] =C2=A0 .nr_running =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.216771] =C2=A0 .load =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.218564] =C2=A0 .nr_switches =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 37444
> [ =C2=A0455.220394] =C2=A0 .nr_load_updates =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 : 219042
> [ =C2=A0455.222202] =C2=A0 .nr_uninterruptible =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.224039] =C2=A0 .next_balance =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 4295.123375
> [ =C2=A0455.225897] =C2=A0 .curr->pid =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.227769] =C2=A0 .clock =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 455227.204963
> [ =C2=A0455.229681] =C2=A0 .cpu_load[0] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.231548] =C2=A0 .cpu_load[1] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.233353] =C2=A0 .cpu_load[2] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.235059] =C2=A0 .cpu_load[3] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.236676] =C2=A0 .cpu_load[4] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.238280] =C2=A0 .yld_count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.239879] =C2=A0 .sched_switch =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.241471] =C2=A0 .sched_count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 37815
> [ =C2=A0455.243075] =C2=A0 .sched_goidle =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 16831
> [ =C2=A0455.244674] =C2=A0 .avg_idle =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 1000000
> [ =C2=A0455.246270] =C2=A0 .ttwu_count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 18348
> [ =C2=A0455.247849] =C2=A0 .ttwu_local =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 16899
> [ =C2=A0455.249430] =C2=A0 .bkl_count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.250992]
> [ =C2=A0455.250993] cfs_rq[2]:/
> [ =C2=A0455.254040] =C2=A0 .exec_clock =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 6758.351942
> [ =C2=A0455.255630] =C2=A0 .MIN_vruntime =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0.000001
> [ =C2=A0455.257236] =C2=A0 .min_vruntime =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 13719.942866
> [ =C2=A0455.258861] =C2=A0 .max_vruntime =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0.000001
> [ =C2=A0455.260497] =C2=A0 .spread =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0.000000
> [ =C2=A0455.262122] =C2=A0 .spread0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : -15180.857224
> [ =C2=A0455.263753] =C2=A0 .nr_spread_over =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0: 21
> [ =C2=A0455.265389] =C2=A0 .nr_running =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.267018] =C2=A0 .load =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.268637] =C2=A0 .load_avg =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0.000000
> [ =C2=A0455.270292] =C2=A0 .load_period =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0.000000
> [ =C2=A0455.271911] =C2=A0 .load_contrib =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.273530] =C2=A0 .load_tg =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.275163]
> [ =C2=A0455.275165] runnable tasks:
> [ =C2=A0455.275166] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 task =C2=A0=
 PID =C2=A0 =C2=A0 =C2=A0 =C2=A0 tree-key =C2=A0switches =C2=A0prio =C2=A0 =
=C2=A0 exec-runtime =C2=A0 =C2=A0 =C2=A0 =C2=A0 sum-exec =C2=A0 =C2=A0 =C2=
=A0 =C2=A0sum-sleep
> [ =C2=A0455.275169] -----------------------------------------------------=
-----------------------------------------------------
> [ =C2=A0455.281810]
> [ =C2=A0455.281811] cpu#3, 2491.994 MHz
> [ =C2=A0455.285349] =C2=A0 .nr_running =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 4
> [ =C2=A0455.287149] =C2=A0 .load =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2048
> [ =C2=A0455.288952] =C2=A0 .nr_switches =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 30358
> [ =C2=A0455.290787] =C2=A0 .nr_load_updates =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 : 223302
> [ =C2=A0455.292599] =C2=A0 .nr_uninterruptible =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0: 1
> [ =C2=A0455.294419] =C2=A0 .next_balance =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 4295.123506
> [ =C2=A0455.296250] =C2=A0 .curr->pid =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 46
> [ =C2=A0455.298090] =C2=A0 .clock =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 431792.394314
> [ =C2=A0455.299953] =C2=A0 .cpu_load[0] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 2048
> [ =C2=A0455.301810] =C2=A0 .cpu_load[1] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 2048
> [ =C2=A0455.303610] =C2=A0 .cpu_load[2] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 2048
> [ =C2=A0455.305311] =C2=A0 .cpu_load[3] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 2048
> [ =C2=A0455.306926] =C2=A0 .cpu_load[4] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 2048
> [ =C2=A0455.308531] =C2=A0 .yld_count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 63
> [ =C2=A0455.310130] =C2=A0 .sched_switch =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.311723] =C2=A0 .sched_count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 30824
> [ =C2=A0455.313315] =C2=A0 .sched_goidle =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 13491
> [ =C2=A0455.314904] =C2=A0 .avg_idle =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 1000000
> [ =C2=A0455.316481] =C2=A0 .ttwu_count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 13858
> [ =C2=A0455.318057] =C2=A0 .ttwu_local =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 12507
> [ =C2=A0455.319629] =C2=A0 .bkl_count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.321187]
> [ =C2=A0455.321188] cfs_rq[3]:/
> [ =C2=A0455.324213] =C2=A0 .exec_clock =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 5334.144946
> [ =C2=A0455.325795] =C2=A0 .MIN_vruntime =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 13295.262803
> [ =C2=A0455.327401] =C2=A0 .min_vruntime =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 13302.523317
> [ =C2=A0455.329046] =C2=A0 .max_vruntime =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 13295.262803
> [ =C2=A0455.330656] =C2=A0 .spread =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0.000000
> [ =C2=A0455.332297] =C2=A0 .spread0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : -15598.276773
> [ =C2=A0455.333925] =C2=A0 .nr_spread_over =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0: 117
> [ =C2=A0455.335577] =C2=A0 .nr_running =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2
> [ =C2=A0455.337204] =C2=A0 .load =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2048
> [ =C2=A0455.338823] =C2=A0 .load_avg =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0.000000
> [ =C2=A0455.340476] =C2=A0 .load_period =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0.000000
> [ =C2=A0455.342094] =C2=A0 .load_contrib =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.343702] =C2=A0 .load_tg =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> [ =C2=A0455.345302]
> [ =C2=A0455.345303] rt_rq[3]:/
> [ =C2=A0455.348416] =C2=A0 .rt_nr_running =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 : 1
> [ =C2=A0455.350006] =C2=A0 .rt_throttled =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 0
> [ =C2=A0455.351587] =C2=A0 .rt_time =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0.000000
> [ =C2=A0455.353173] =C2=A0 .rt_runtime =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 950.000000
> [ =C2=A0455.354759]
> [ =C2=A0455.354760] runnable tasks:
> [ =C2=A0455.354761] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 task =C2=A0=
 PID =C2=A0 =C2=A0 =C2=A0 =C2=A0 tree-key =C2=A0switches =C2=A0prio =C2=A0 =
=C2=A0 exec-runtime =C2=A0 =C2=A0 =C2=A0 =C2=A0 sum-exec =C2=A0 =C2=A0 =C2=
=A0 =C2=A0sum-sleep
> [ =C2=A0455.354764] -----------------------------------------------------=
-----------------------------------------------------
> [ =C2=A0455.361357] =C2=A0 =C2=A0 =C2=A0migration/3 =C2=A0 =C2=A017 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 0.000000 =C2=A0 =C2=A0 =C2=A01084 =C2=A0 =C2=A0 0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 0.000000 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.000933 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 0.000000 /
> [ =C2=A0455.363278] =C2=A0 =C2=A0 =C2=A0 watchdog/3 =C2=A0 =C2=A020 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 0.000000 =C2=A0 =C2=A0 =C2=A0 =C2=A031 =C2=A0 =C2=
=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.000000 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.78=
0405 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.002351 /
> [ =C2=A0455.365212] R =C2=A0 =C2=A0 =C2=A0 =C2=A0kswapd0 =C2=A0 =C2=A046 =
=C2=A0 =C2=A0 13302.523317 =C2=A0 =C2=A0 =C2=A0 714 =C2=A0 120 =C2=A0 =C2=
=A0 13302.523317 =C2=A0 =C2=A0 =C2=A01148.767369 =C2=A0 =C2=A0245855.504389=
 /
> [ =C2=A0455.367220] =C2=A0 =C2=A0 =C2=A0kworker/3:1 =C2=A0 =C2=A074 =C2=
=A0 =C2=A0 13295.262803 =C2=A0 =C2=A0 10488 =C2=A0 120 =C2=A0 =C2=A0 13295.=
262803 =C2=A0 =C2=A0 =C2=A0 324.924994 =C2=A0 =C2=A0315669.659686 /
> [ =C2=A0455.369317]
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
