Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 579FF8E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 20:05:03 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 68so38276997pfr.6
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 17:05:03 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q24si14005799pgi.334.2019.01.04.17.05.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 17:05:01 -0800 (PST)
Date: Fri, 4 Jan 2019 17:04:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 202149] New: NULL Pointer Dereference in __split_huge_pmd
 on PPC64LE
Message-Id: <20190104170459.c8c7fa57ba9bc8a69dee5666@linux-foundation.org>
In-Reply-To: <bug-202149-27@https.bugzilla.kernel.org/>
References: <bug-202149-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org
Cc: bugzilla-daemon@bugzilla.kernel.org, kernel@bluematt.me

(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 04 Jan 2019 22:49:52 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=202149
> 
>             Bug ID: 202149
>            Summary: NULL Pointer Dereference in __split_huge_pmd on
>                     PPC64LE

I think that trace is pointing at the ppc-specific
pgtable_trans_huge_withdraw()?

>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.19.13
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: akpm@linux-foundation.org
>           Reporter: kernel@bluematt.me
>         Regression: No
> 
> Kernel is actually 4.19.13 + this commit to fix mpt3sas, though I also saw this
> fault with a different version of mpt3sas patched into an earlier 4.19 kernel
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=23c3828aa2f84edec7020c7397a22931e7a879e1
> . Config is roughly Debian's default config + 4K pages instead of the default
> 64K.
> 
> [ 9531.579895] Unable to handle kernel paging request for data at address
> 0x00000000
> [ 9531.579918] Faulting instruction address: 0xc000000000076c64
> [ 9531.579930] Oops: Kernel access of bad area, sig: 11 [#1]
> [ 9531.579948] LE SMP NR_CPUS=2048 NUMA PowerNV
> [ 9531.579960] Modules linked in: binfmt_misc veth xt_nat tap
> nft_chain_nat_ipv4 nft_chain_route_ipv4 tun btrfs zstd_compress zstd_decompress
> xxhash ipip tunnel4 ip_tunnel ipt_MASQUERADE nf_nat_ipv4 nf_nat nf_conntrack
> nf_defrag_ipv6 nf_defrag_ipv4 xt_DSCP xt_dscp nft_counter xt_tcpudp nft_compat
> nf_tables nfnetlink amdgpu chash gpu_sched ast snd_hda_codec_hdmi ttm
> drm_kms_helper snd_hda_intel snd_hda_codec drm sg snd_hda_core snd_hwdep
> snd_pcm uas drm_panel_orientation_quirks syscopyarea sysfillrect snd_timer
> sysimgblt fb_sys_fops tg3 mpt3sas snd i2c_algo_bit ofpart ipmi_powernv opal_prd
> ipmi_devintf soundcore ipmi_msghandler powernv_flash libphy mtd raid_class
> scsi_transport_sas at24 ip_tables x_tables autofs4 ext4 crc16 mbcache jbd2
> fscrypto sd_mod raid10 raid456 crc32c_generic libcrc32c async_raid6_recov
> [ 9531.580142]  async_memcpy async_pq evdev hid_generic usbhid hid raid6_pq
> async_xor xor async_tx raid1 raid0 multipath linear md_mod usb_storage dm_crypt
> dm_mod algif_skcipher af_alg ecb xts xhci_pci vmx_crypto xhci_hcd usbcore nvme
> nvme_core usb_common
> [ 9531.580219] CPU: 9 PID: 4762 Comm: rustc Not tainted 4.19.0-2-powerpc64le #1
> Debian 4.19.13-1
> [ 9531.580250] NIP:  c000000000076c64 LR: c00000000037ec38 CTR:
> c0000000000471e0
> [ 9531.580280] REGS: c0000001a4f6f840 TRAP: 0300   Not tainted 
> (4.19.0-2-powerpc64le Debian 4.19.13-1)
> [ 9531.580311] MSR:  9000000000009033 <SF,HV,EE,ME,IR,DR,RI,LE>  CR: 24202848 
> XER: 00000000
> [ 9531.580337] CFAR: c00000000037ec34 DAR: 0000000000000000 DSISR: 40000000
> IRQMASK: 0 
>                GPR00: c00000000037ec38 c0000001a4f6fac0 c0000000010a5800
> c0000008b1a2ec00 
>                GPR04: c0000001a0ccaf80 0000000000000800 c000000001202e60
> c000000001202de0 
>                GPR08: 0000000000000009 c00a000006833280 c00a000000000000
> c0000000010b9fd8 
>                GPR12: 0000000000002000 c000000fffff9600 00003fff40000000
> 0001000000000000 
>                GPR16: e61fffffffffffff fffffffffffffe7f 0000000000000001
> c00a0000065f48a8 
>                GPR20: c0000001a0ccaf80 0002000000000000 c0000008b1a2ec00
> c000000001202de0 
>                GPR24: c00a000019a20000 c0000008b1a2ec00 c0000001a0ccaf80
> c0000006f001c5b0 
>                GPR28: c00a000006833280 c000000001202e68 00003fff3e000000
> 0000000000000000 
> [ 9531.580483] NIP [c000000000076c64]
> radix__pgtable_trans_huge_withdraw+0x94/0x160
> [ 9531.580506] LR [c00000000037ec38] __split_huge_pmd+0x588/0xcc0
> [ 9531.580524] Call Trace:
> [ 9531.580541] [c0000001a4f6fac0] [c0000001a4f6fb10] 0xc0000001a4f6fb10
> (unreliable)
> [ 9531.580572] [c0000001a4f6faf0] [c00000000037ebbc]
> __split_huge_pmd+0x50c/0xcc0
> [ 9531.580605] [c0000001a4f6fbb0] [c00000000032aeb8]
> move_page_tables+0x438/0xd30
> [ 9531.580637] [c0000001a4f6fcc0] [c00000000032b8fc] move_vma+0x14c/0x370
> [ 9531.580669] [c0000001a4f6fd60] [c00000000032c0a8] sys_mremap+0x588/0x670
> [ 9531.580702] [c0000001a4f6fe30] [c00000000000b9e4] system_call+0x5c/0x70
> [ 9531.580732] Instruction dump:
> [ 9531.580760] 0b0a0000 e9060000 e9470000 7d294030 7d2907b4 79291f24 7d2900d0
> 7d292038 
> [ 9531.580797] 7929a402 79293664 7d2a4a14 ebe90010 <e95f0000> 7fbf5040 419e0064
> 7c0802a6 
> [ 9531.580837] ---[ end trace 21ba871647464d8b ]---
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.
