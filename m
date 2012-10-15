Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id B211A6B00B7
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 13:37:00 -0400 (EDT)
Received: by mail-vb0-f41.google.com with SMTP id v13so6574508vbk.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2012 10:36:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120920184301.GB17181@liondog.tnic>
References: <CAG3eYYRTm=ZgEJvjYLe4cN1VJr+Hia6pkSfSPgWO_UvXt1Dshg@mail.gmail.com>
	<20120920184301.GB17181@liondog.tnic>
Date: Mon, 15 Oct 2012 19:36:59 +0200
Message-ID: <CAG3eYYSSmAZLpK199UEsBRN=gzKPGa+Ydid7zaZmuA1jXx88FQ@mail.gmail.com>
Subject: Re: PROBLEM: machine hung after a struggle with oom
From: =?UTF-8?B?UMOpdGVyIEFuZHLDoXMgRmVsdsOpZ2k=?= <petschy@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

Hello,

the under scenario happened again, twice, with minor variations. Same
machine, same kernel.

1) when the machine started swapping like mad, I pressed CTRL-ALT-F1
only _once_ (X -> console), then waited for things to settle. The
machine didn't freeze, I was able to switch back to X, had all my
windows except for Chome's tabs, which were killed by the OOM handler.
The only difference now was that I didn't press CTRL-ALT-F1 a couple
of times at random moments during the disk thrashing. Is it possible
that switching to console from X back and forth at unfortunate times
can cause the machine to lock up?

2) when the machine started swapping, I did nothing. After some time
the screen was mainly black, like if I switched back to console, but I
didn't. There was some kernel output about an illegal opcode in btrfs
and the stack trace, and the graphical CPU load and clock widgets
overpainted at the top. When the swapping stopped, the front window
came back, and most of the black from the screen was erasable by
moving the mouse over. But a black rectangle stayed, despite that I
changed workspaces, and moved windows around. The size of it was of a
character on the console, and its place was on the first coloumn, at
about the place where the cursor should have been after printing the
trace dump, provided I were on the console. So I tried to switch via
CTRL-ALT-F1, and the machine froze, kind of. The mouse stopped, the
screen stayed, but NumLock was working and the machine was pingable.
Pressed CTRL-ALT-F1 a few more times, no success, then pressed
CTRL-ALT-F7, and everything worked again, in X. Now pressing
CTRL-ALT-F1 worked as expected, bringing me to the console. I'm using
the nouveau driver.

Here is the trace of the invalid opcode bug:

Oct 15 18:46:33 lobster kernel: ------------[ cut here ]------------
Oct 15 18:46:33 lobster kernel: kernel BUG at fs/btrfs/extent_io.c:743!
Oct 15 18:46:33 lobster kernel: invalid opcode: 0000 [#1] SMP
Oct 15 18:46:33 lobster kernel: CPU 6
Oct 15 18:46:33 lobster kernel: Modules linked in:
snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep
snd_pcm_oss snd_mixer_oss snd_pcm snd_page_alloc snd_seq_midi
snd_seq_midi_event snd_rawmidi snd_seq crc32c_intel
ghash_clmulni_intel aesni_intel aes_x86_64 aes_generic cryptd
snd_seq_device snd_timer snd k10temp fam15h_power edac_mce_amd
edac_core soundcore i2c_piix4 nouveau video mxm_wmi drm_kms_helper
evdev ttm wmi usbhid r8169 mii [last unloaded: scsi_wait_scan]
Oct 15 18:46:33 lobster kernel:
Oct 15 18:46:33 lobster kernel: Pid: 8774, comm: chromium Not tainted
3.5.3 #10 Gigabyte Technology Co., Ltd. GA-970A-UD3/GA-970A-UD3
Oct 15 18:46:33 lobster kernel: RIP: 0010:[<ffffffff812e0976>]
[<ffffffff812e0976>] __set_extent_bit+0x396/0x490
Oct 15 18:46:33 lobster kernel: RSP: 0000:ffff8801528c79b8  EFLAGS: 0001024=
6
Oct 15 18:46:33 lobster kernel: RAX: 0000000000000000 RBX:
000000000143ffff RCX: 0000000000000000
Oct 15 18:46:33 lobster kernel: RDX: ffff88016aef3280 RSI:
0000000000000040 RDI: 0000000000000000
Oct 15 18:46:33 lobster kernel: RBP: 000000000143f000 R08:
ffffffff8186e8b0 R09: 0000000000000040
Oct 15 18:46:33 lobster kernel: R10: 0000000000000006 R11:
0000000000020000 R12: ffff8801ad1087d0
Oct 15 18:46:33 lobster kernel: R13: 0000000000000008 R14:
0000000000000000 R15: 000000000143ffff
Oct 15 18:46:33 lobster kernel: FS:  00007fef7d1d29a0(0000)
GS:ffff88022ed80000(0000) knlGS:0000000000000000
Oct 15 18:46:33 lobster kernel: CS:  0010 DS: 0000 ES: 0000 CR0:
000000008005003b
Oct 15 18:46:33 lobster kernel: CR2: 00002afe9251ca98 CR3:
000000016af4f000 CR4: 00000000000407e0
Oct 15 18:46:33 lobster kernel: DR0: 0000000000000000 DR1:
0000000000000000 DR2: 0000000000000000
Oct 15 18:46:33 lobster kernel: DR3: 0000000000000000 DR6:
00000000ffff0ff0 DR7: 0000000000000400
Oct 15 18:46:33 lobster kernel: Process chromium (pid: 8774,
threadinfo ffff8801528c6000, task ffff88016aef3280)
Oct 15 18:46:33 lobster kernel: Stack:
Oct 15 18:46:33 lobster kernel: 0000000002fe1358 ffff8801ad1087d0
ffff8801528c7fd8 ffff8801528c7fd8
Oct 15 18:46:33 lobster kernel: ffff8801528c7a50 0000100800000008
0000000002fe1358 ffff8801528c7a58
Oct 15 18:46:33 lobster kernel: ffff8801528c7ad0 000000000143ffff
000000000143f000 ffff8801ad1087d0
Oct 15 18:46:33 lobster kernel: Call Trace:
Oct 15 18:46:33 lobster kernel: [<ffffffff812e147f>] ?
lock_extent_bits+0x6f/0xa0
Oct 15 18:46:33 lobster kernel: [<ffffffff812e2fac>] ?
__extent_read_full_page+0xbc/0x680
Oct 15 18:46:33 lobster kernel: [<ffffffff810e0a34>] ? release_pages+0x1d4/=
0x210
Oct 15 18:46:33 lobster kernel: [<ffffffff812c4230>] ?
btrfs_real_readdir+0x570/0x570
Oct 15 18:46:33 lobster kernel: [<ffffffff810e05f0>] ?
lru_deactivate_fn+0x1e0/0x1e0
Oct 15 18:46:33 lobster kernel: [<ffffffff812e434b>] ?
extent_readpages+0xbb/0x100
Oct 15 18:46:33 lobster kernel: [<ffffffff812c4230>] ?
btrfs_real_readdir+0x570/0x570
Oct 15 18:46:33 lobster kernel: [<ffffffff810df8a3>] ?
__do_page_cache_readahead+0x183/0x220
Oct 15 18:46:33 lobster kernel: [<ffffffff810dfc5c>] ? ra_submit+0x1c/0x30
Oct 15 18:46:33 lobster kernel: [<ffffffff810d7995>] ? filemap_fault+0x3f5/=
0x460
Oct 15 18:46:33 lobster kernel: [<ffffffff810f1b6e>] ? __do_fault+0x6e/0x50=
0
Oct 15 18:46:33 lobster kernel: [<ffffffff810f46c8>] ?
handle_pte_fault+0x98/0xa30
Oct 15 18:46:33 lobster kernel: [<ffffffff8109d4eb>] ? futex_wake+0xfb/0x12=
0
Oct 15 18:46:33 lobster kernel: [<ffffffff810f5652>] ?
handle_mm_fault+0x52/0x380
Oct 15 18:46:33 lobster kernel: [<ffffffff810569a0>] ? do_page_fault+0x130/=
0x460
Oct 15 18:46:33 lobster kernel: [<ffffffff8108cdf0>] ?
__dequeue_entity+0x40/0x50
Oct 15 18:46:33 lobster kernel: [<ffffffff8108e202>] ?
pick_next_task_fair+0x62/0x180
Oct 15 18:46:33 lobster kernel: [<ffffffff8160d239>] ? __schedule+0x289/0x6=
20
Oct 15 18:46:33 lobster kernel: [<ffffffff8160e92f>] ? page_fault+0x1f/0x30
Oct 15 18:46:33 lobster kernel: Code: 0f 1f 44 00 00 f6 84 24 88 00 00
00 10 0f 84 d0 fc ff ff 8b bc 24 88 00 00 00 e8 f6 ed ff ff 48 85 c0
48 89 c1 0f 85 b8 fc ff ff <0f> 0b 4c 89 ed 31 c9 eb 99 90 48 83 7b 28
00 0f 85 1b fd ff ff
Oct 15 18:46:33 lobster kernel: RIP  [<ffffffff812e0976>]
__set_extent_bit+0x396/0x490
Oct 15 18:46:33 lobster kernel: RSP <ffff8801528c79b8>
Oct 15 18:46:33 lobster kernel: ---[ end trace 24bd767af2444190 ]---

Hope this helps!

Regards, Peter


On 20 September 2012 20:43, Borislav Petkov <bp@alien8.de> wrote:
> Adding linux-mm.
>
> Btw, this is how you do bug reports! Good job.
>
> On Thu, Sep 20, 2012 at 07:06:04PM +0200, P=C3=A9ter Andr=C3=A1s Felv=C3=
=A9gi wrote:
>> Hello,
>>
>> my machine hung today after some serious disk trashing caused by out
>> of memory contition(s).
>>
>> I didn't do anything unusual. There was an xtem window with a few
>> tabs, iceweasel/firefox, chromium and codelite running. I already
>> worked for some hours, started a build, then in the middle of it, the
>> disk (sdb, where the 2G swap partition is) started working real
>> intesively. This was unlikely, because the system and my home dir is
>> on ssd / btrfs (sda) for a few months now, so normally things go
>> quietly.
>>
>> The system started struggling, the mouse moved really slow, pressing
>> the num-lock and seeing the results on the led had quite some lag
>> (3-14 secs). Tried to switch back to console via ctrl-alt-f1, after
>> quite a few seconds it did switch, where I saw an oops regarding some
>> btrfs extent function.
>>
>> Switched back to X, took a few minutes to get back the title/border of
>> the topmost window. Meanwhile, 3 small windows appeared slowly (the
>> disk was still trashing like hell) notifying about an oops, and
>> waiting for action. The mouse moved pixel-by-pixel, was useless. Then,
>> after about 15 minutes, the disk stopped working, and silence set in.
>> Num-lock and the kb in general wasn't responding, nor the mouse. Tried
>> to unplug the kb and plug in an usb one, but no luck. Tried to ping
>> the machine, it was unreachable. After a few minutes I pulled the
>> plug. At reboot, I was informed about some orphaned inodes, but that
>> was all, the system is up and running since then.
>>
>> I don't know what triggered the swapping. From the logs it seems that
>> the chromium processes were the first victims, but I wasn't using the
>> browser, I was compiling my project. I haven't experienced any similar
>> behaviour recently. I had plenty of free space on the btrfs partition
>> (22G used out of 200G). I attached the relevant part from the kern.log
>> (starting from the first oom and ending at the reboot), also I'm
>> providing the info required for bug reports, hope that helps.
>>
>> Kind regards, Peter
>>
>>
>> $ sh scripts/ver_linux
>> If some fields are empty or look unusual you may have an old version.
>> Compare to the current minimal requirements in Documentation/Changes.
>>
>> Linux lobster 3.5.3 #10 SMP Thu Sep 6 12:25:33 CEST 2012 x86_64 GNU/Linu=
x
>>
>> Gnu C                  4.7
>> Gnu make               3.81
>> binutils               2.22
>> util-linux             scripts/ver_linux: 23: scripts/ver_linux:
>> fdformat: not found
>> mount                  support
>> module-init-tools      found
>> Linux C Library        2.13
>> Dynamic linker (ldd)   2.13
>> Procps                 3.3.3
>> Kbd                    1.15.3
>> Sh-utils               8.13
>> Modules Loaded         snd_hda_codec_realtek snd_hda_intel
>> snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm
>> snd_page_alloc snd_seq_midi snd_seq_midi_event snd_rawmidi snd_seq
>> crc32c_intel ghash_clmulni_intel snd_seq_device aesni_intel snd_timer
>> aes_x86_64 snd k10temp fam15h_power aes_generic cryptd edac_mce_amd
>> edac_core nouveau soundcore video i2c_piix4 mxm_wmi drm_kms_helper ttm
>> evdev wmi usbhid r8169 mii
>>
>> $ cat /proc/cpuinfo
>> processor     : 0
>> vendor_id     : AuthenticAMD
>> cpu family    : 21
>> model         : 1
>> model name    : AMD FX(tm)-8120 Eight-Core Processor
>> stepping      : 2
>> microcode     : 0x6000626
>> cpu MHz               : 3624.392
>> cache size    : 2048 KB
>> physical id   : 0
>> siblings      : 8
>> core id               : 0
>> cpu cores     : 4
>> apicid                : 0
>> initial apicid        : 0
>> fpu           : yes
>> fpu_exception : yes
>> cpuid level   : 13
>> wp            : yes
>> flags         : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca=
 cmov
>> pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt
>> pdpe1gb rdtscp lm constant_tsc rep_good nopl nonstop_tsc extd_apicid
>> aperfmperf pni pclmulqdq monitor ssse3 cx16 sse4_1 sse4_2 popcnt aes
>> xsave avx lahf_lm cmp_legacy svm extapic cr8_legacy abm sse4a
>> misalignsse 3dnowprefetch osvw ibs xop skinit wdt lwp fma4 nodeid_msr
>> topoext perfctr_core arat cpb hw_pstate npt lbrv svm_lock nrip_save
>> tsc_scale vmcb_clean flushbyasid decodeassists pausefilter pfthreshold
>> bogomips      : 7248.78
>> TLB size      : 1536 4K pages
>> clflush size  : 64
>> cache_alignment       : 64
>> address sizes : 48 bits physical, 48 bits virtual
>> power management: ts ttp tm 100mhzsteps hwpstate cpb
>>
>> [7 other cores omitted]
>>
>> $ cat /proc/modules
>> snd_hda_codec_realtek 67064 1 - Live 0xffffffffa016c000
>> snd_hda_intel 30220 4 - Live 0xffffffffa0289000
>> snd_hda_codec 90583 2 snd_hda_codec_realtek,snd_hda_intel, Live
>> 0xffffffffa0264000
>> snd_hwdep 13148 1 snd_hda_codec, Live 0xffffffffa0248000
>> snd_pcm_oss 44847 0 - Live 0xffffffffa0258000
>> snd_mixer_oss 22044 3 snd_pcm_oss, Live 0xffffffffa024d000
>> snd_pcm 75438 3 snd_hda_intel,snd_hda_codec,snd_pcm_oss, Live 0xffffffff=
a022f000
>> snd_page_alloc 17065 2 snd_hda_intel,snd_pcm, Live 0xffffffffa0212000
>> snd_seq_midi 12848 0 - Live 0xffffffffa0226000
>> snd_seq_midi_event 13316 1 snd_seq_midi, Live 0xffffffffa01fa000
>> snd_rawmidi 26914 1 snd_seq_midi, Live 0xffffffffa021e000
>> snd_seq 52897 2 snd_seq_midi,snd_seq_midi_event, Live 0xffffffffa0204000
>> crc32c_intel 12747 0 - Live 0xffffffffa0219000
>> ghash_clmulni_intel 12981 0 - Live 0xffffffffa01ff000
>> snd_seq_device 13132 3 snd_seq_midi,snd_rawmidi,snd_seq, Live 0xffffffff=
a01e7000
>> aesni_intel 50435 0 - Live 0xffffffffa01ec000
>> snd_timer 26606 2 snd_pcm,snd_seq, Live 0xffffffffa01df000
>> aes_x86_64 16796 1 aesni_intel, Live 0xffffffffa01d9000
>> snd 60845 15 snd_hda_codec_realtek,snd_hda_intel,snd_hda_codec,snd_hwdep=
,snd_pcm_oss,snd_mixer_oss,snd_pcm,snd_rawmidi,snd_seq,snd_seq_device,snd_t=
imer,
>> Live 0xffffffffa01c9000
>> k10temp 12618 0 - Live 0xffffffffa01c4000
>> fam15h_power 12597 0 - Live 0xffffffffa01bf000
>> aes_generic 33026 2 aesni_intel,aes_x86_64, Live 0xffffffffa01ac000
>> cryptd 14560 2 ghash_clmulni_intel,aesni_intel, Live 0xffffffffa0067000
>> edac_mce_amd 21093 0 - Live 0xffffffffa0165000
>> edac_core 43036 0 - Live 0xffffffffa0159000
>> nouveau 843331 2 - Live 0xffffffffa006c000
>> soundcore 13026 3 snd, Live 0xffffffffa0154000
>> video 17631 1 nouveau, Live 0xffffffffa0061000
>> i2c_piix4 12536 0 - Live 0xffffffffa0017000
>> mxm_wmi 12473 1 nouveau, Live 0xffffffffa004d000
>> drm_kms_helper 35294 1 nouveau, Live 0xffffffffa0057000
>> ttm 61344 1 nouveau, Live 0xffffffffa003d000
>> evdev 17406 15 - Live 0xffffffffa0029000
>> wmi 17339 2 nouveau,mxm_wmi, Live 0xffffffffa0033000
>> usbhid 44463 0 - Live 0xffffffffa001d000
>> r8169 58988 0 - Live 0xffffffffa0007000
>> mii 12675 1 r8169, Live 0xffffffffa0000000
>>
>> $ cat /proc/ioports
>> 0000-0cf7 : PCI Bus 0000:00
>>   0000-001f : dma1
>>   0020-0021 : pic1
>>   0040-0043 : timer0
>>   0050-0053 : timer1
>>   0060-0060 : keyboard
>>   0064-0064 : keyboard
>>   0070-0073 : rtc0
>>   0080-008f : dma page reg
>>   00a0-00a1 : pic2
>>   00c0-00df : dma2
>>   00f0-00ff : fpu
>>   0220-0225 : pnp 00:01
>>   0228-022f : pnp 00:02
>>   0290-0294 : pnp 00:01
>>   03c0-03df : vga+
>>   03f8-03ff : serial
>>   040b-040b : pnp 00:02
>>   04d0-04d1 : pnp 00:01
>>   04d6-04d6 : pnp 00:02
>>   0800-08fe : pnp 00:02
>>     0800-0803 : ACPI PM1a_EVT_BLK
>>     0804-0805 : ACPI PM1a_CNT_BLK
>>     0808-080b : ACPI PM_TMR
>>     0810-0815 : ACPI CPU throttle
>>     0820-0827 : ACPI GPE0_BLK
>>     0850-0850 : ACPI PM2_CNT_BLK
>>   0900-091f : pnp 00:02
>>   0a10-0a17 : pnp 00:02
>>   0b00-0b0f : pnp 00:02
>>   0b10-0b1f : pnp 00:02
>>   0b20-0b3f : pnp 00:02
>>   0c00-0c01 : pnp 00:02
>>   0c14-0c14 : pnp 00:02
>>   0c50-0c52 : pnp 00:02
>>   0c6c-0c6d : pnp 00:02
>>   0c6f-0c6f : pnp 00:02
>>   0cd0-0cd1 : pnp 00:02
>>   0cd2-0cd3 : pnp 00:02
>>   0cd4-0cdf : pnp 00:02
>> 0cf8-0cff : PCI conf1
>> 0d00-ffff : PCI Bus 0000:00
>>   9000-9fff : PCI Bus 0000:06
>>   a000-afff : PCI Bus 0000:05
>>     af00-af7f : 0000:05:0e.0
>>   b000-bfff : PCI Bus 0000:01
>>   c000-cfff : PCI Bus 0000:04
>>   d000-dfff : PCI Bus 0000:03
>>     de00-deff : 0000:03:00.0
>>       de00-deff : r8169
>>   e000-efff : PCI Bus 0000:02
>>   fb00-fb0f : 0000:00:11.0
>>     fb00-fb0f : ahci
>>   fc00-fc03 : 0000:00:11.0
>>     fc00-fc03 : ahci
>>   fd00-fd07 : 0000:00:11.0
>>     fd00-fd07 : ahci
>>   fe00-fe03 : 0000:00:11.0
>>     fe00-fe03 : ahci
>>   ff00-ff07 : 0000:00:11.0
>>     ff00-ff07 : ahci
>>
>> $ cat /proc/iomem
>> 00000000-0000ffff : reserved
>> 00010000-00091fff : System RAM
>> 00092000-0009f7ff : RAM buffer
>> 0009f800-0009ffff : reserved
>> 000a0000-000bffff : PCI Bus 0000:00
>> 000c0000-000dffff : PCI Bus 0000:00
>>   000c0000-000c7fff : Video ROM
>> 000f0000-000fffff : reserved
>>   000f0000-000fffff : System ROM
>> 00100000-cfd9ffff : System RAM
>>   01000000-01613166 : Kernel code
>>   01613167-01872b7f : Kernel data
>>   01902000-0198efff : Kernel bss
>>   c4000000-c7ffffff : GART
>> cfda0000-cfdd0fff : ACPI Non-volatile Storage
>> cfdd1000-cfdfffff : ACPI Tables
>> cfe00000-cfefffff : reserved
>>   cfe00000-cfefffff : pnp 00:0b
>> cff00000-cfffffff : RAM buffer
>> d0000000-febfffff : PCI Bus 0000:00
>>   d0000000-dfffffff : PCI Bus 0000:01
>>     d0000000-dfffffff : 0000:01:00.0
>>   e0000000-efffffff : PCI MMCONFIG 0000 [bus 00-ff]
>>     e0000000-efffffff : reserved
>>       e0000000-efffffff : pnp 00:0a
>>   fa000000-fcffffff : PCI Bus 0000:01
>>     fa000000-faffffff : 0000:01:00.0
>>     fb000000-fbffffff : 0000:01:00.0
>>     fc000000-fc01ffff : 0000:01:00.0
>>   fd500000-fd5fffff : PCI Bus 0000:03
>>   fd600000-fd6fffff : PCI Bus 0000:02
>>   fd700000-fd7fffff : PCI Bus 0000:06
>>   fd800000-fd8fffff : PCI Bus 0000:06
>>   fd900000-fd9fffff : PCI Bus 0000:02
>>     fd9f8000-fd9fffff : 0000:02:00.0
>>       fd9f8000-fd9fffff : xhci_hcd
>>   fda00000-fdafffff : PCI Bus 0000:05
>>   fdb00000-fdbfffff : PCI Bus 0000:05
>>     fdbff000-fdbff7ff : 0000:05:0e.0
>>   fdc00000-fdcfffff : PCI Bus 0000:04
>>   fdd00000-fddfffff : PCI Bus 0000:04
>>     fddf8000-fddfffff : 0000:04:00.0
>>       fddf8000-fddfffff : xhci_hcd
>>   fde00000-fdefffff : PCI Bus 0000:03
>>     fdef8000-fdefbfff : 0000:03:00.0
>>       fdef8000-fdefbfff : r8169
>>     fdeff000-fdefffff : 0000:03:00.0
>>       fdeff000-fdefffff : r8169
>>   fdff4000-fdff7fff : 0000:00:14.2
>>     fdff4000-fdff7fff : ICH HD audio
>>   fdff8000-fdff80ff : 0000:00:16.2
>>     fdff8000-fdff80ff : ehci_hcd
>>   fdff9000-fdff9fff : 0000:00:16.0
>>     fdff9000-fdff9fff : ohci_hcd
>>   fdffa000-fdffafff : 0000:00:14.5
>>     fdffa000-fdffafff : ohci_hcd
>>   fdffb000-fdffb0ff : 0000:00:13.2
>>     fdffb000-fdffb0ff : ehci_hcd
>>   fdffc000-fdffcfff : 0000:00:13.0
>>     fdffc000-fdffcfff : ohci_hcd
>>   fdffd000-fdffd0ff : 0000:00:12.2
>>     fdffd000-fdffd0ff : ehci_hcd
>>   fdffe000-fdffefff : 0000:00:12.0
>>     fdffe000-fdffefff : ohci_hcd
>>   fdfff000-fdfff3ff : 0000:00:11.0
>>     fdfff000-fdfff3ff : ahci
>> fec00000-ffffffff : reserved
>>   fec00000-fec003ff : IOAPIC 0
>>   fec30000-fec33fff : amd_iommu
>>   fed00000-fed003ff : HPET 0
>>   fed40000-fed44fff : PCI Bus 0000:00
>>   fee00000-fee00fff : Local APIC
>>     fee00400-fee00fff : pnp 00:02
>>   fff80000-fffeffff : pnp 00:0b
>>   ffff0000-ffffffff : pnp 00:0b
>> 100000000-22effffff : System RAM
>> 22f000000-22fffffff : RAM buffer
>>
>> # lspci -vvv
>> 00:00.0 Host bridge: Advanced Micro Devices [AMD] nee ATI RD890 PCI to
>> PCI bridge (external gfx0 port B) (rev 02)
>>       Subsystem: Advanced Micro Devices [AMD] nee ATI RD890 PCI to PCI
>> bridge (external gfx0 port B)
>>       Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
>> <TAbort- <MAbort+ >SERR- <PERR- INTx-
>>       Region 3: Memory at <ignored> (64-bit, non-prefetchable)
>>       Capabilities: [f0] HyperTransport: MSI Mapping Enable+ Fixed+
>>       Capabilities: [c4] HyperTransport: Slave or Primary Interface
>>               Command: BaseUnitID=3D0 UnitCnt=3D20 MastHost- DefDir- DUL=
-
>>               Link Control 0: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- <=
CRCErr=3D0
>> IsocEn- LSEn- ExtCTL- 64b-
>>               Link Config 0: MLWI=3D16bit DwFcIn- MLWO=3D16bit DwFcOut- =
LWI=3D8bit
>> DwFcInEn- LWO=3D8bit DwFcOutEn-
>>               Link Control 1: CFlE- CST- CFE- <LkFail+ Init- EOC+ TXO+ <=
CRCErr=3D0
>> IsocEn- LSEn- ExtCTL- 64b-
>>               Link Config 1: MLWI=3D8bit DwFcIn- MLWO=3D8bit DwFcOut- LW=
I=3D8bit
>> DwFcInEn- LWO=3D8bit DwFcOutEn-
>>               Revision ID: 3.00
>>               Link Frequency 0: [d]
>>               Link Error 0: <Prot- <Ovfl- <EOC- CTLTm-
>>               Link Frequency Capability 0: 200MHz+ 300MHz- 400MHz+ 500MH=
z- 600MHz+
>> 800MHz+ 1.0GHz+ 1.2GHz+ 1.4GHz- 1.6GHz- Vend-
>>               Feature Capability: IsocFC+ LDTSTOP+ CRCTM- ECTLT- 64bA+ U=
IDRD-
>>               Link Frequency 1: 200MHz
>>               Link Error 1: <Prot- <Ovfl- <EOC- CTLTm-
>>               Link Frequency Capability 1: 200MHz- 300MHz- 400MHz- 500MH=
z- 600MHz-
>> 800MHz- 1.0GHz- 1.2GHz- 1.4GHz- 1.6GHz- Vend-
>>               Error Handling: PFlE- OFlE- PFE- OFE- EOCFE- RFE- CRCFE- S=
ERRFE- CF-
>> RE- PNFE- ONFE- EOCNFE- RNFE- CRCNFE- SERRNFE-
>>               Prefetchable memory behind bridge Upper: 00-00
>>               Bus Number: 00
>>       Capabilities: [40] HyperTransport: Retry Mode
>>       Capabilities: [54] HyperTransport: UnitID Clumping
>>       Capabilities: [9c] HyperTransport: #1a
>>       Capabilities: [70] MSI: Enable- Count=3D1/4 Maskable- 64bit-
>>               Address: 00000000  Data: 0000
>>
>> 00:00.2 IOMMU: Advanced Micro Devices [AMD] nee ATI RD990 I/O Memory
>> Management Unit (IOMMU)
>>       Subsystem: Advanced Micro Devices [AMD] nee ATI RD990 I/O Memory
>> Management Unit (IOMMU)
>>       Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx+
>>       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx+
>>       Interrupt: pin A routed to IRQ 40
>>       Capabilities: [40] Secure device <?>
>>       Capabilities: [54] MSI: Enable+ Count=3D1/1 Maskable- 64bit+
>>               Address: 00000000feeff00c  Data: 4151
>>       Capabilities: [64] HyperTransport: MSI Mapping Enable+ Fixed+
>>
>> 00:02.0 PCI bridge: Advanced Micro Devices [AMD] nee ATI RD890 PCI to
>> PCI bridge (PCI express gpp port B) (prog-if 00 [Normal decode])
>>       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
>> <TAbort+ <MAbort- >SERR- <PERR- INTx-
>>       Latency: 0, Cache Line Size: 64 bytes
>>       Bus: primary=3D00, secondary=3D01, subordinate=3D01, sec-latency=
=3D0
>>       I/O behind bridge: 0000b000-0000bfff
>>       Memory behind bridge: fa000000-fcffffff
>>       Prefetchable memory behind bridge: 00000000d0000000-00000000dfffff=
ff
>>       Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort+
>> <TAbort- <MAbort- <SERR- <PERR-
>>       BridgeCtl: Parity- SERR- NoISA- VGA+ MAbort- >Reset- FastB2B-
>>               PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>>       Capabilities: [50] Power Management version 3
>>               Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0+,D1-,D=
2-,D3hot+,D3cold+)
>>               Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
>>       Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
>>               DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64=
ns, L1 <1us
>>                       ExtTag+ RBE+ FLReset-
>>               DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsu=
pported-
>>                       RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
>>                       MaxPayload 128 bytes, MaxReadReq 128 bytes
>>               DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- T=
ransPend-
>>               LnkCap: Port #0, Speed 5GT/s, Width x16, ASPM L0s L1, Late=
ncy L0 <1us, L1 <8us
>>                       ClockPM- Surprise- LLActRep+ BwNot+
>>               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- Com=
mClk-
>>                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>>               LnkSta: Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk+ D=
LActive+
>> BWMgmt- ABWMgmt-
>>               SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- S=
urprise-
>>                       Slot #2, PowerLimit 75.000W; Interlock- NoCompl+
>>               SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HP=
Irq- LinkChg-
>>                       Control: AttnInd Unknown, PwrInd Unknown, Power- I=
nterlock-
>>               SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ =
Interlock-
>>                       Changed: MRL- PresDet+ LinkState+
>>               RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna=
- CRSVisible-
>>               RootCap: CRSVisible-
>>               RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>>               DevCap2: Completion Timeout: Range ABCD, TimeoutDis+ ARIFw=
d+
>>               DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis- AR=
IFwd-
>>               LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedD=
is-,
>> Selectable De-emphasis: -3.5dB
>>                        Transmit Margin: Normal Operating Range, EnterMod=
ifiedCompliance-
>> ComplianceSOS-
>>                        Compliance De-emphasis: -6dB
>>               LnkSta2: Current De-emphasis Level: -3.5dB, EqualizationCo=
mplete-,
>> EqualizationPhase1-
>>                        EqualizationPhase2-, EqualizationPhase3-, LinkEqu=
alizationRequest-
>>       Capabilities: [a0] MSI: Enable- Count=3D1/1 Maskable- 64bit-
>>               Address: 00000000  Data: 0000
>>       Capabilities: [b0] Subsystem: Advanced Micro Devices [AMD] nee ATI=
 Device 5a14
>>       Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
>>       Capabilities: [100 v1] Vendor Specific Information: ID=3D0001 Rev=
=3D1 Len=3D010 <?>
>>       Capabilities: [190 v1] Access Control Services
>>               ACSCap: SrcValid+ TransBlk+ ReqRedir+ CmpltRedir+ Upstream=
Fwd+
>> EgressCtrl- DirectTrans+
>>               ACSCtl: SrcValid+ TransBlk- ReqRedir+ CmpltRedir+ Upstream=
Fwd+
>> EgressCtrl- DirectTrans-
>>       Kernel driver in use: pcieport
>>
>> 00:04.0 PCI bridge: Advanced Micro Devices [AMD] nee ATI RD890 PCI to
>> PCI bridge (PCI express gpp port D) (prog-if 00 [Normal decode])
>>       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Latency: 0, Cache Line Size: 64 bytes
>>       Bus: primary=3D00, secondary=3D02, subordinate=3D02, sec-latency=
=3D0
>>       I/O behind bridge: 0000e000-0000efff
>>       Memory behind bridge: fd900000-fd9fffff
>>       Prefetchable memory behind bridge: 00000000fd600000-00000000fd6fff=
ff
>>       Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
>> <TAbort- <MAbort- <SERR- <PERR-
>>       BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>>               PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>>       Capabilities: [50] Power Management version 3
>>               Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0+,D1-,D=
2-,D3hot+,D3cold+)
>>               Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
>>       Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
>>               DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64=
ns, L1 <1us
>>                       ExtTag+ RBE+ FLReset-
>>               DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsu=
pported-
>>                       RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
>>                       MaxPayload 128 bytes, MaxReadReq 128 bytes
>>               DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- T=
ransPend-
>>               LnkCap: Port #0, Speed 5GT/s, Width x2, ASPM L0s L1, Laten=
cy L0 <1us, L1 <8us
>>                       ClockPM- Surprise- LLActRep+ BwNot+
>>               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- Com=
mClk+
>>                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>>               LnkSta: Speed 5GT/s, Width x1, TrErr- Train- SlotClk+ DLAc=
tive+
>> BWMgmt+ ABWMgmt+
>>               SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- S=
urprise-
>>                       Slot #4, PowerLimit 75.000W; Interlock- NoCompl+
>>               SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HP=
Irq- LinkChg-
>>                       Control: AttnInd Unknown, PwrInd Unknown, Power- I=
nterlock-
>>               SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ =
Interlock-
>>                       Changed: MRL- PresDet+ LinkState+
>>               RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna=
- CRSVisible-
>>               RootCap: CRSVisible-
>>               RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>>               DevCap2: Completion Timeout: Range ABCD, TimeoutDis+ ARIFw=
d+
>>               DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis- AR=
IFwd-
>>               LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedD=
is-,
>> Selectable De-emphasis: -3.5dB
>>                        Transmit Margin: Normal Operating Range, EnterMod=
ifiedCompliance-
>> ComplianceSOS-
>>                        Compliance De-emphasis: -6dB
>>               LnkSta2: Current De-emphasis Level: -3.5dB, EqualizationCo=
mplete-,
>> EqualizationPhase1-
>>                        EqualizationPhase2-, EqualizationPhase3-, LinkEqu=
alizationRequest-
>>       Capabilities: [a0] MSI: Enable- Count=3D1/1 Maskable- 64bit-
>>               Address: 00000000  Data: 0000
>>       Capabilities: [b0] Subsystem: Advanced Micro Devices [AMD] nee ATI=
 Device 5a14
>>       Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
>>       Capabilities: [100 v1] Vendor Specific Information: ID=3D0001 Rev=
=3D1 Len=3D010 <?>
>>       Capabilities: [190 v1] Access Control Services
>>               ACSCap: SrcValid+ TransBlk+ ReqRedir+ CmpltRedir+ Upstream=
Fwd+
>> EgressCtrl- DirectTrans+
>>               ACSCtl: SrcValid+ TransBlk- ReqRedir+ CmpltRedir+ Upstream=
Fwd+
>> EgressCtrl- DirectTrans-
>>       Kernel driver in use: pcieport
>>
>> 00:09.0 PCI bridge: Advanced Micro Devices [AMD] nee ATI RD890 PCI to
>> PCI bridge (PCI express gpp port H) (prog-if 00 [Normal decode])
>>       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Latency: 0, Cache Line Size: 64 bytes
>>       Bus: primary=3D00, secondary=3D03, subordinate=3D03, sec-latency=
=3D0
>>       I/O behind bridge: 0000d000-0000dfff
>>       Memory behind bridge: fd500000-fd5fffff
>>       Prefetchable memory behind bridge: 00000000fde00000-00000000fdefff=
ff
>>       Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
>> <TAbort- <MAbort- <SERR- <PERR-
>>       BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>>               PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>>       Capabilities: [50] Power Management version 3
>>               Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0+,D1-,D=
2-,D3hot+,D3cold+)
>>               Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
>>       Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
>>               DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64=
ns, L1 <1us
>>                       ExtTag+ RBE+ FLReset-
>>               DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsu=
pported-
>>                       RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
>>                       MaxPayload 128 bytes, MaxReadReq 128 bytes
>>               DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- T=
ransPend-
>>               LnkCap: Port #4, Speed 5GT/s, Width x1, ASPM L0s L1, Laten=
cy L0 <1us, L1 <8us
>>                       ClockPM- Surprise- LLActRep+ BwNot+
>>               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- Com=
mClk+
>>                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>>               LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DL=
Active+
>> BWMgmt+ ABWMgmt-
>>               SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- S=
urprise-
>>                       Slot #9, PowerLimit 75.000W; Interlock- NoCompl+
>>               SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HP=
Irq- LinkChg-
>>                       Control: AttnInd Unknown, PwrInd Unknown, Power- I=
nterlock-
>>               SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ =
Interlock-
>>                       Changed: MRL- PresDet+ LinkState+
>>               RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna=
- CRSVisible-
>>               RootCap: CRSVisible-
>>               RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>>               DevCap2: Completion Timeout: Range ABCD, TimeoutDis+ ARIFw=
d+
>>               DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis- AR=
IFwd-
>>               LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedD=
is-,
>> Selectable De-emphasis: -3.5dB
>>                        Transmit Margin: Normal Operating Range, EnterMod=
ifiedCompliance-
>> ComplianceSOS-
>>                        Compliance De-emphasis: -6dB
>>               LnkSta2: Current De-emphasis Level: -3.5dB, EqualizationCo=
mplete-,
>> EqualizationPhase1-
>>                        EqualizationPhase2-, EqualizationPhase3-, LinkEqu=
alizationRequest-
>>       Capabilities: [a0] MSI: Enable- Count=3D1/1 Maskable- 64bit-
>>               Address: 00000000  Data: 0000
>>       Capabilities: [b0] Subsystem: Advanced Micro Devices [AMD] nee ATI=
 Device 5a14
>>       Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
>>       Capabilities: [100 v1] Vendor Specific Information: ID=3D0001 Rev=
=3D1 Len=3D010 <?>
>>       Capabilities: [190 v1] Access Control Services
>>               ACSCap: SrcValid+ TransBlk+ ReqRedir+ CmpltRedir+ Upstream=
Fwd+
>> EgressCtrl- DirectTrans+
>>               ACSCtl: SrcValid+ TransBlk- ReqRedir+ CmpltRedir+ Upstream=
Fwd+
>> EgressCtrl- DirectTrans-
>>       Kernel driver in use: pcieport
>>
>> 00:0a.0 PCI bridge: Advanced Micro Devices [AMD] nee ATI RD890 PCI to
>> PCI bridge (external gfx1 port A) (prog-if 00 [Normal decode])
>>       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Latency: 0, Cache Line Size: 64 bytes
>>       Bus: primary=3D00, secondary=3D04, subordinate=3D04, sec-latency=
=3D0
>>       I/O behind bridge: 0000c000-0000cfff
>>       Memory behind bridge: fdd00000-fddfffff
>>       Prefetchable memory behind bridge: 00000000fdc00000-00000000fdcfff=
ff
>>       Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
>> <TAbort- <MAbort- <SERR- <PERR-
>>       BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>>               PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>>       Capabilities: [50] Power Management version 3
>>               Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0+,D1-,D=
2-,D3hot+,D3cold+)
>>               Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
>>       Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
>>               DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64=
ns, L1 <1us
>>                       ExtTag+ RBE+ FLReset-
>>               DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsu=
pported-
>>                       RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
>>                       MaxPayload 128 bytes, MaxReadReq 128 bytes
>>               DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- T=
ransPend-
>>               LnkCap: Port #5, Speed 5GT/s, Width x1, ASPM L0s L1, Laten=
cy L0 <1us, L1 <8us
>>                       ClockPM- Surprise- LLActRep+ BwNot+
>>               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- Com=
mClk+
>>                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>>               LnkSta: Speed 5GT/s, Width x1, TrErr- Train- SlotClk+ DLAc=
tive+
>> BWMgmt+ ABWMgmt+
>>               SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- S=
urprise-
>>                       Slot #10, PowerLimit 75.000W; Interlock- NoCompl+
>>               SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HP=
Irq- LinkChg-
>>                       Control: AttnInd Unknown, PwrInd Unknown, Power- I=
nterlock-
>>               SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ =
Interlock-
>>                       Changed: MRL- PresDet+ LinkState+
>>               RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna=
- CRSVisible-
>>               RootCap: CRSVisible-
>>               RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>>               DevCap2: Completion Timeout: Range ABCD, TimeoutDis+ ARIFw=
d+
>>               DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis- AR=
IFwd-
>>               LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedD=
is-,
>> Selectable De-emphasis: -3.5dB
>>                        Transmit Margin: Normal Operating Range, EnterMod=
ifiedCompliance-
>> ComplianceSOS-
>>                        Compliance De-emphasis: -6dB
>>               LnkSta2: Current De-emphasis Level: -3.5dB, EqualizationCo=
mplete-,
>> EqualizationPhase1-
>>                        EqualizationPhase2-, EqualizationPhase3-, LinkEqu=
alizationRequest-
>>       Capabilities: [a0] MSI: Enable- Count=3D1/1 Maskable- 64bit-
>>               Address: 00000000  Data: 0000
>>       Capabilities: [b0] Subsystem: Advanced Micro Devices [AMD] nee ATI=
 Device 5a14
>>       Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
>>       Capabilities: [100 v1] Vendor Specific Information: ID=3D0001 Rev=
=3D1 Len=3D010 <?>
>>       Capabilities: [190 v1] Access Control Services
>>               ACSCap: SrcValid+ TransBlk+ ReqRedir+ CmpltRedir+ Upstream=
Fwd+
>> EgressCtrl- DirectTrans+
>>               ACSCtl: SrcValid+ TransBlk- ReqRedir+ CmpltRedir+ Upstream=
Fwd+
>> EgressCtrl- DirectTrans-
>>       Kernel driver in use: pcieport
>>
>> 00:11.0 SATA controller: Advanced Micro Devices [AMD] nee ATI
>> SB7x0/SB8x0/SB9x0 SATA Controller [AHCI mode] (rev 40) (prog-if 01
>> [AHCI 1.0])
>>       Subsystem: Giga-byte Technology Device b002
>>       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Latency: 32, Cache Line Size: 64 bytes
>>       Interrupt: pin A routed to IRQ 19
>>       Region 0: I/O ports at ff00 [size=3D8]
>>       Region 1: I/O ports at fe00 [size=3D4]
>>       Region 2: I/O ports at fd00 [size=3D8]
>>       Region 3: I/O ports at fc00 [size=3D4]
>>       Region 4: I/O ports at fb00 [size=3D16]
>>       Region 5: Memory at fdfff000 (32-bit, non-prefetchable) [size=3D1K=
]
>>       Capabilities: [70] SATA HBA v1.0 InCfgSpace
>>       Capabilities: [a4] PCI Advanced Features
>>               AFCap: TP+ FLR+
>>               AFCtrl: FLR-
>>               AFStatus: TP-
>>       Kernel driver in use: ahci
>>
>> 00:12.0 USB controller: Advanced Micro Devices [AMD] nee ATI
>> SB7x0/SB8x0/SB9x0 USB OHCI0 Controller (prog-if 10 [OHCI])
>>       Subsystem: Giga-byte Technology Device 5004
>>       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Latency: 32, Cache Line Size: 64 bytes
>>       Interrupt: pin A routed to IRQ 18
>>       Region 0: Memory at fdffe000 (32-bit, non-prefetchable) [size=3D4K=
]
>>       Kernel driver in use: ohci_hcd
>>
>> 00:12.2 USB controller: Advanced Micro Devices [AMD] nee ATI
>> SB7x0/SB8x0/SB9x0 USB EHCI Controller (prog-if 20 [EHCI])
>>       Subsystem: Giga-byte Technology Device 5004
>>       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Latency: 32, Cache Line Size: 64 bytes
>>       Interrupt: pin B routed to IRQ 17
>>       Region 0: Memory at fdffd000 (32-bit, non-prefetchable) [size=3D25=
6]
>>       Capabilities: [c0] Power Management version 2
>>               Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1+,D=
2+,D3hot+,D3cold-)
>>               Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
>>               Bridge: PM- B3+
>>       Capabilities: [e4] Debug port: BAR=3D1 offset=3D00e0
>>       Kernel driver in use: ehci_hcd
>>
>> 00:13.0 USB controller: Advanced Micro Devices [AMD] nee ATI
>> SB7x0/SB8x0/SB9x0 USB OHCI0 Controller (prog-if 10 [OHCI])
>>       Subsystem: Giga-byte Technology Device 5004
>>       Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Latency: 32, Cache Line Size: 64 bytes
>>       Interrupt: pin A routed to IRQ 18
>>       Region 0: Memory at fdffc000 (32-bit, non-prefetchable) [size=3D4K=
]
>>       Kernel driver in use: ohci_hcd
>>
>> 00:13.2 USB controller: Advanced Micro Devices [AMD] nee ATI
>> SB7x0/SB8x0/SB9x0 USB EHCI Controller (prog-if 20 [EHCI])
>>       Subsystem: Giga-byte Technology Device 5004
>>       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Latency: 32, Cache Line Size: 64 bytes
>>       Interrupt: pin B routed to IRQ 17
>>       Region 0: Memory at fdffb000 (32-bit, non-prefetchable) [size=3D25=
6]
>>       Capabilities: [c0] Power Management version 2
>>               Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1+,D=
2+,D3hot+,D3cold-)
>>               Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
>>               Bridge: PM- B3+
>>       Capabilities: [e4] Debug port: BAR=3D1 offset=3D00e0
>>       Kernel driver in use: ehci_hcd
>>
>> 00:14.0 SMBus: Advanced Micro Devices [AMD] nee ATI SBx00 SMBus
>> Controller (rev 42)
>>       Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx+
>>       Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>
>> 00:14.2 Audio device: Advanced Micro Devices [AMD] nee ATI SBx00
>> Azalia (Intel HDA) (rev 40)
>>       Subsystem: Giga-byte Technology Device a002
>>       Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dslow >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Latency: 32, Cache Line Size: 64 bytes
>>       Interrupt: pin A routed to IRQ 16
>>       Region 0: Memory at fdff4000 (64-bit, non-prefetchable) [size=3D16=
K]
>>       Capabilities: [50] Power Management version 2
>>               Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D55mA PME(D0+,D1-,=
D2-,D3hot+,D3cold+)
>>               Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
>>       Kernel driver in use: snd_hda_intel
>>
>> 00:14.3 ISA bridge: Advanced Micro Devices [AMD] nee ATI
>> SB7x0/SB8x0/SB9x0 LPC host controller (rev 40)
>>       Subsystem: Advanced Micro Devices [AMD] nee ATI SB7x0/SB8x0/SB9x0 =
LPC
>> host controller
>>       Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Latency: 0
>>
>> 00:14.4 PCI bridge: Advanced Micro Devices [AMD] nee ATI SBx00 PCI to
>> PCI Bridge (rev 40) (prog-if 01 [Subtractive decode])
>>       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop+ ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Latency: 64
>>       Bus: primary=3D00, secondary=3D05, subordinate=3D05, sec-latency=
=3D64
>>       I/O behind bridge: 0000a000-0000afff
>>       Memory behind bridge: fdb00000-fdbfffff
>>       Prefetchable memory behind bridge: fda00000-fdafffff
>>       Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
>> <TAbort- <MAbort+ <SERR- <PERR-
>>       BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>>               PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>>
>> 00:14.5 USB controller: Advanced Micro Devices [AMD] nee ATI
>> SB7x0/SB8x0/SB9x0 USB OHCI2 Controller (prog-if 10 [OHCI])
>>       Subsystem: Giga-byte Technology Device 5004
>>       Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Latency: 32, Cache Line Size: 64 bytes
>>       Interrupt: pin C routed to IRQ 18
>>       Region 0: Memory at fdffa000 (32-bit, non-prefetchable) [size=3D4K=
]
>>       Kernel driver in use: ohci_hcd
>>
>> 00:15.0 PCI bridge: Advanced Micro Devices [AMD] nee ATI
>> SB700/SB800/SB900 PCI to PCI bridge (PCIE port 0) (prog-if 00 [Normal
>> decode])
>>       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Latency: 0, Cache Line Size: 64 bytes
>>       Bus: primary=3D00, secondary=3D06, subordinate=3D06, sec-latency=
=3D0
>>       I/O behind bridge: 00009000-00009fff
>>       Memory behind bridge: fd800000-fd8fffff
>>       Prefetchable memory behind bridge: 00000000fd700000-00000000fd7fff=
ff
>>       Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
>> <TAbort- <MAbort- <SERR- <PERR-
>>       BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>>               PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>>       Capabilities: [50] Power Management version 3
>>               Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0-,D1-,D=
2-,D3hot-,D3cold-)
>>               Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
>>       Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
>>               DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64=
ns, L1 <1us
>>                       ExtTag+ RBE+ FLReset-
>>               DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsu=
pported-
>>                       RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
>>                       MaxPayload 128 bytes, MaxReadReq 128 bytes
>>               DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- T=
ransPend-
>>               LnkCap: Port #247, Speed 2.5GT/s, Width x4, ASPM L0s L1, L=
atency L0
>> <64ns, L1 <1us
>>                       ClockPM- Surprise- LLActRep+ BwNot+
>>               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- Com=
mClk-
>>                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>>               LnkSta: Speed unknown, Width x16, TrErr- Train- SlotClk+ D=
LActive-
>> BWMgmt- ABWMgmt-
>>               SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ S=
urprise-
>>                       Slot #0, PowerLimit 0.000W; Interlock- NoCompl+
>>               SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HP=
Irq- LinkChg-
>>                       Control: AttnInd Unknown, PwrInd Unknown, Power- I=
nterlock-
>>               SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- =
Interlock-
>>                       Changed: MRL- PresDet- LinkState-
>>               RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna=
- CRSVisible-
>>               RootCap: CRSVisible-
>>               RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>>               DevCap2: Completion Timeout: Range ABCD, TimeoutDis+ ARIFw=
d-
>>               DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis- AR=
IFwd-
>>               LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- Spee=
dDis-,
>> Selectable De-emphasis: -6dB
>>                        Transmit Margin: Normal Operating Range, EnterMod=
ifiedCompliance-
>> ComplianceSOS-
>>                        Compliance De-emphasis: -6dB
>>               LnkSta2: Current De-emphasis Level: -6dB, EqualizationComp=
lete-,
>> EqualizationPhase1-
>>                        EqualizationPhase2-, EqualizationPhase3-, LinkEqu=
alizationRequest-
>>       Capabilities: [a0] MSI: Enable- Count=3D1/1 Maskable- 64bit+
>>               Address: 0000000000000000  Data: 0000
>>       Capabilities: [b0] Subsystem: Advanced Micro Devices [AMD] nee ATI=
 Device 0000
>>       Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
>>       Capabilities: [100 v1] Vendor Specific Information: ID=3D0001 Rev=
=3D1 Len=3D010 <?>
>>       Kernel driver in use: pcieport
>>
>> 00:16.0 USB controller: Advanced Micro Devices [AMD] nee ATI
>> SB7x0/SB8x0/SB9x0 USB OHCI0 Controller (prog-if 10 [OHCI])
>>       Subsystem: Giga-byte Technology Device 5004
>>       Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Latency: 32, Cache Line Size: 64 bytes
>>       Interrupt: pin A routed to IRQ 18
>>       Region 0: Memory at fdff9000 (32-bit, non-prefetchable) [size=3D4K=
]
>>       Kernel driver in use: ohci_hcd
>>
>> 00:16.2 USB controller: Advanced Micro Devices [AMD] nee ATI
>> SB7x0/SB8x0/SB9x0 USB EHCI Controller (prog-if 20 [EHCI])
>>       Subsystem: Giga-byte Technology Device 5004
>>       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Latency: 32, Cache Line Size: 64 bytes
>>       Interrupt: pin B routed to IRQ 17
>>       Region 0: Memory at fdff8000 (32-bit, non-prefetchable) [size=3D25=
6]
>>       Capabilities: [c0] Power Management version 2
>>               Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1+,D=
2+,D3hot+,D3cold-)
>>               Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
>>               Bridge: PM- B3+
>>       Capabilities: [e4] Debug port: BAR=3D1 offset=3D00e0
>>       Kernel driver in use: ehci_hcd
>>
>> 00:18.0 Host bridge: Advanced Micro Devices [AMD] Family 15h Processor
>> Function 0
>>       Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Capabilities: [80] HyperTransport: Host or Secondary Interface
>>               Command: WarmRst+ DblEnd- DevNum=3D0 ChainSide- HostHide+ =
Slave- <EOCErr- DUL-
>>               Link Control: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- <CR=
CErr=3D0
>> IsocEn- LSEn+ ExtCTL- 64b+
>>               Link Config: MLWI=3D16bit DwFcIn- MLWO=3D16bit DwFcOut- LW=
I=3D8bit
>> DwFcInEn- LWO=3D8bit DwFcOutEn-
>>               Revision ID: 3.00
>>               Link Frequency: [d]
>>               Link Error: <Prot- <Ovfl- <EOC- CTLTm-
>>               Link Frequency Capability: 200MHz+ 300MHz- 400MHz+ 500MHz-=
 600MHz+
>> 800MHz+ 1.0GHz+ 1.2GHz+ 1.4GHz- 1.6GHz- Vend-
>>               Feature Capability: IsocFC+ LDTSTOP+ CRCTM- ECTLT- 64bA+ U=
IDRD- ExtRS- UCnfE-
>>
>> 00:18.1 Host bridge: Advanced Micro Devices [AMD] Family 15h Processor
>> Function 1
>>       Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>
>> 00:18.2 Host bridge: Advanced Micro Devices [AMD] Family 15h Processor
>> Function 2
>>       Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>
>> 00:18.3 Host bridge: Advanced Micro Devices [AMD] Family 15h Processor
>> Function 3
>>       Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Capabilities: [f0] Secure device <?>
>>       Kernel driver in use: k10temp
>>
>> 00:18.4 Host bridge: Advanced Micro Devices [AMD] Family 15h Processor
>> Function 4
>>       Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Kernel driver in use: fam15h_power
>>
>> 00:18.5 Host bridge: Advanced Micro Devices [AMD] Family 15h Processor
>> Function 5
>>       Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>
>> 01:00.0 VGA compatible controller: NVIDIA Corporation NV44 [GeForce
>> 6200 TurboCache(TM)] (rev a1) (prog-if 00 [VGA controller])
>>       Subsystem: ASUSTeK Computer Inc. Device 81ae
>>       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
>> <TAbort+ <MAbort- >SERR- <PERR- INTx-
>>       Latency: 0, Cache Line Size: 64 bytes
>>       Interrupt: pin A routed to IRQ 18
>>       Region 0: Memory at fa000000 (32-bit, non-prefetchable) [size=3D16=
M]
>>       Region 1: Memory at d0000000 (64-bit, prefetchable) [size=3D256M]
>>       Region 3: Memory at fb000000 (64-bit, non-prefetchable) [size=3D16=
M]
>>       [virtual] Expansion ROM at fc000000 [disabled] [size=3D128K]
>>       Capabilities: [60] Power Management version 2
>>               Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D=
2-,D3hot-,D3cold-)
>>               Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
>>       Capabilities: [68] MSI: Enable- Count=3D1/1 Maskable- 64bit+
>>               Address: 0000000000000000  Data: 0000
>>       Capabilities: [78] Express (v1) Endpoint, MSI 00
>>               DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <51=
2ns, L1 <4us
>>                       ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
>>               DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsu=
pported-
>>                       RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
>>                       MaxPayload 128 bytes, MaxReadReq 512 bytes
>>               DevSta: CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr- T=
ransPend-
>>               LnkCap: Port #0, Speed 2.5GT/s, Width x16, ASPM L0s L1, La=
tency L0
>> <1us, L1 <4us
>>                       ClockPM- Surprise- LLActRep- BwNot-
>>               LnkCtl: ASPM Disabled; RCB 128 bytes Disabled- Retrain- Co=
mmClk-
>>                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>>               LnkSta: Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk- D=
LActive-
>> BWMgmt- ABWMgmt-
>>       Capabilities: [100 v1] Virtual Channel
>>               Caps:   LPEVC=3D0 RefClk=3D100ns PATEntryBits=3D1
>>               Arb:    Fixed- WRR32- WRR64- WRR128-
>>               Ctrl:   ArbSelect=3DFixed
>>               Status: InProgress-
>>               VC0:    Caps:   PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTr=
ans-
>>                       Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR2=
56-
>>                       Ctrl:   Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3Df=
f
>>                       Status: NegoPending- InProgress-
>>       Capabilities: [128 v1] Power Budgeting <?>
>>       Kernel driver in use: nouveau
>>
>> 02:00.0 USB controller: Etron Technology, Inc. EJ168 USB 3.0 Host
>> Controller (rev 01) (prog-if 30 [XHCI])
>>       Subsystem: Giga-byte Technology Device 5007
>>       Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx+
>>       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Latency: 0, Cache Line Size: 64 bytes
>>       Interrupt: pin A routed to IRQ 41
>>       Region 0: Memory at fd9f8000 (64-bit, non-prefetchable) [size=3D32=
K]
>>       Capabilities: [50] Power Management version 3
>>               Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1+,D=
2+,D3hot+,D3cold+)
>>               Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
>>       Capabilities: [70] MSI: Enable+ Count=3D1/4 Maskable+ 64bit+
>>               Address: 00000000feeff00c  Data: 4161
>>               Masking: 0000000e  Pending: 00000000
>>       Capabilities: [a0] Express (v2) Endpoint, MSI 00
>>               DevCap: MaxPayload 1024 bytes, PhantFunc 0, Latency L0s <6=
4ns, L1 <1us
>>                       ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset+
>>               DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsu=
pported-
>>                       RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+ FLRes=
et-
>>                       MaxPayload 128 bytes, MaxReadReq 512 bytes
>>               DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ T=
ransPend-
>>               LnkCap: Port #0, Speed 5GT/s, Width x1, ASPM L0s L1, Laten=
cy L0 <1us, L1 <64us
>>                       ClockPM+ Surprise- LLActRep- BwNot-
>>               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- Com=
mClk+
>>                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>>               LnkSta: Speed 5GT/s, Width x1, TrErr- Train- SlotClk+ DLAc=
tive-
>> BWMgmt- ABWMgmt-
>>               DevCap2: Completion Timeout: Not Supported, TimeoutDis-
>>               DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
>>               LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedD=
is-,
>> Selectable De-emphasis: -6dB
>>                        Transmit Margin: Normal Operating Range, EnterMod=
ifiedCompliance-
>> ComplianceSOS-
>>                        Compliance De-emphasis: -6dB
>>               LnkSta2: Current De-emphasis Level: -6dB, EqualizationComp=
lete-,
>> EqualizationPhase1-
>>                        EqualizationPhase2-, EqualizationPhase3-, LinkEqu=
alizationRequest-
>>       Capabilities: [100 v1] Advanced Error Reporting
>>               UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt-=
 RxOF-
>> MalfTLP- ECRC- UnsupReq- ACSViol-
>>               UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt-=
 RxOF-
>> MalfTLP- ECRC- UnsupReq- ACSViol-
>>               UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt-=
 RxOF+
>> MalfTLP+ ECRC- UnsupReq- ACSViol-
>>               CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFata=
lErr+
>>               CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFata=
lErr+
>>               AERCap: First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ C=
hkEn-
>>       Capabilities: [190 v1] Device Serial Number 01-01-01-01-01-01-01-0=
1
>>       Kernel driver in use: xhci_hcd
>>
>> 03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
>> RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 06)
>>       Subsystem: Giga-byte Technology GA-EP45-DS5/GA-EG45M-DS2H Motherbo=
ard
>>       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx+
>>       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Latency: 0, Cache Line Size: 64 bytes
>>       Interrupt: pin A routed to IRQ 43
>>       Region 0: I/O ports at de00 [size=3D256]
>>       Region 2: Memory at fdeff000 (64-bit, prefetchable) [size=3D4K]
>>       Region 4: Memory at fdef8000 (64-bit, prefetchable) [size=3D16K]
>>       Capabilities: [40] Power Management version 3
>>               Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D375mA PME(D0+,D1+=
,D2+,D3hot+,D3cold+)
>>               Status: D0 NoSoftRst+ PME-Enable- DSel=3D0 DScale=3D0 PME-
>>       Capabilities: [50] MSI: Enable+ Count=3D1/1 Maskable- 64bit+
>>               Address: 00000000feeff00c  Data: 4171
>>       Capabilities: [70] Express (v2) Endpoint, MSI 01
>>               DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <51=
2ns, L1 <64us
>>                       ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
>>               DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsu=
pported-
>>                       RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
>>                       MaxPayload 128 bytes, MaxReadReq 4096 bytes
>>               DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ T=
ransPend-
>>               LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Lat=
ency L0
>> unlimited, L1 <64us
>>                       ClockPM+ Surprise- LLActRep- BwNot-
>>               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- Com=
mClk+
>>                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>>               LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DL=
Active-
>> BWMgmt- ABWMgmt-
>>               DevCap2: Completion Timeout: Range ABCD, TimeoutDis+
>>               DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
>>               LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- Spee=
dDis-,
>> Selectable De-emphasis: -6dB
>>                        Transmit Margin: Normal Operating Range, EnterMod=
ifiedCompliance-
>> ComplianceSOS-
>>                        Compliance De-emphasis: -6dB
>>               LnkSta2: Current De-emphasis Level: -6dB, EqualizationComp=
lete-,
>> EqualizationPhase1-
>>                        EqualizationPhase2-, EqualizationPhase3-, LinkEqu=
alizationRequest-
>>       Capabilities: [b0] MSI-X: Enable- Count=3D4 Masked-
>>               Vector table: BAR=3D4 offset=3D00000000
>>               PBA: BAR=3D4 offset=3D00000800
>>       Capabilities: [d0] Vital Product Data
>>               Unknown small resource type 00, will not decode more.
>>       Capabilities: [100 v1] Advanced Error Reporting
>>               UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt-=
 RxOF-
>> MalfTLP- ECRC- UnsupReq- ACSViol-
>>               UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt-=
 RxOF-
>> MalfTLP- ECRC- UnsupReq- ACSViol-
>>               UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt-=
 RxOF+
>> MalfTLP+ ECRC- UnsupReq- ACSViol-
>>               CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFata=
lErr+
>>               CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFata=
lErr+
>>               AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ C=
hkEn-
>>       Capabilities: [140 v1] Virtual Channel
>>               Caps:   LPEVC=3D0 RefClk=3D100ns PATEntryBits=3D1
>>               Arb:    Fixed- WRR32- WRR64- WRR128-
>>               Ctrl:   ArbSelect=3DFixed
>>               Status: InProgress-
>>               VC0:    Caps:   PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTr=
ans-
>>                       Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR2=
56-
>>                       Ctrl:   Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3Df=
f
>>                       Status: NegoPending- InProgress-
>>       Capabilities: [160 v1] Device Serial Number 12-34-56-78-12-34-56-7=
8
>>       Kernel driver in use: r8169
>>
>> 04:00.0 USB controller: Etron Technology, Inc. EJ168 USB 3.0 Host
>> Controller (rev 01) (prog-if 30 [XHCI])
>>       Subsystem: Giga-byte Technology Device 5007
>>       Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx+
>>       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Latency: 0, Cache Line Size: 64 bytes
>>       Interrupt: pin A routed to IRQ 42
>>       Region 0: Memory at fddf8000 (64-bit, non-prefetchable) [size=3D32=
K]
>>       Capabilities: [50] Power Management version 3
>>               Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1+,D=
2+,D3hot+,D3cold+)
>>               Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
>>       Capabilities: [70] MSI: Enable+ Count=3D1/4 Maskable+ 64bit+
>>               Address: 00000000feeff00c  Data: 4169
>>               Masking: 0000000e  Pending: 00000000
>>       Capabilities: [a0] Express (v2) Endpoint, MSI 00
>>               DevCap: MaxPayload 1024 bytes, PhantFunc 0, Latency L0s <6=
4ns, L1 <1us
>>                       ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset+
>>               DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsu=
pported-
>>                       RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+ FLRes=
et-
>>                       MaxPayload 128 bytes, MaxReadReq 512 bytes
>>               DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ T=
ransPend-
>>               LnkCap: Port #0, Speed 5GT/s, Width x1, ASPM L0s L1, Laten=
cy L0 <1us, L1 <64us
>>                       ClockPM+ Surprise- LLActRep- BwNot-
>>               LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- Com=
mClk+
>>                       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>>               LnkSta: Speed 5GT/s, Width x1, TrErr- Train- SlotClk+ DLAc=
tive-
>> BWMgmt- ABWMgmt-
>>               DevCap2: Completion Timeout: Not Supported, TimeoutDis-
>>               DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
>>               LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedD=
is-,
>> Selectable De-emphasis: -6dB
>>                        Transmit Margin: Normal Operating Range, EnterMod=
ifiedCompliance-
>> ComplianceSOS-
>>                        Compliance De-emphasis: -6dB
>>               LnkSta2: Current De-emphasis Level: -6dB, EqualizationComp=
lete-,
>> EqualizationPhase1-
>>                        EqualizationPhase2-, EqualizationPhase3-, LinkEqu=
alizationRequest-
>>       Capabilities: [100 v1] Advanced Error Reporting
>>               UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt-=
 RxOF-
>> MalfTLP- ECRC- UnsupReq- ACSViol-
>>               UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt-=
 RxOF-
>> MalfTLP- ECRC- UnsupReq- ACSViol-
>>               UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt-=
 RxOF+
>> MalfTLP+ ECRC- UnsupReq- ACSViol-
>>               CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFata=
lErr+
>>               CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFata=
lErr+
>>               AERCap: First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ C=
hkEn-
>>       Capabilities: [190 v1] Device Serial Number 01-01-01-01-01-01-01-0=
1
>>       Kernel driver in use: xhci_hcd
>>
>> 05:0e.0 FireWire (IEEE 1394): VIA Technologies, Inc. VT6306/7/8 [Fire
>> II(M)] IEEE 1394 OHCI Controller (rev c0) (prog-if 10 [OHCI])
>>       Subsystem: Giga-byte Technology GA-7VT600-1394 Motherboard
>>       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr=
-
>> Stepping- SERR- FastB2B- DisINTx-
>>       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>       Latency: 32 (8000ns max), Cache Line Size: 64 bytes
>>       Interrupt: pin A routed to IRQ 3
>>       Region 0: Memory at fdbff000 (32-bit, non-prefetchable) [size=3D2K=
]
>>       Region 1: I/O ports at af00 [size=3D128]
>>       Capabilities: [50] Power Management version 2
>>               Flags: PMEClk- DSI- D1- D2+ AuxCurrent=3D0mA PME(D0-,D1-,D=
2+,D3hot+,D3cold+)
>>               Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
>
>
>
> --
> Regards/Gruss,
>     Boris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
