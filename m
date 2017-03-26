Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D8DF46B0038
	for <linux-mm@kvack.org>; Sun, 26 Mar 2017 04:32:23 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v44so16017811wrc.9
        for <linux-mm@kvack.org>; Sun, 26 Mar 2017 01:32:23 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.15])
        by mx.google.com with ESMTPS id b188si9884958wmc.96.2017.03.26.01.32.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Mar 2017 01:32:22 -0700 (PDT)
Message-ID: <1490516743.17559.7.camel@gmx.de>
Subject: Re: Splat during resume
From: Mike Galbraith <efault@gmx.de>
Date: Sun, 26 Mar 2017 10:25:43 +0200
In-Reply-To: <20170325214615.eqgmkwbkyldt7wwl@pd.tnic>
References: <20170325185855.4itsyevunczus7sc@pd.tnic>
	 <20170325214615.eqgmkwbkyldt7wwl@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86-ml <x86@kernel.org>

On Sat, 2017-03-25 at 22:46 +0100, Borislav Petkov wrote:
> On Sat, Mar 25, 2017 at 07:58:55PM +0100, Borislav Petkov wrote:
> > Hey Rafael,
> > 
> > have you seen this already (partial splat photo attached)? Happens
> > during resume from s2d. Judging by the timestamps, this looks like the
> > resume kernel before we switch to the original, boot one but I could be
> > mistaken.
> > 
> > This is -rc3+tip/master.
> > 
> > I can't catch a full splat because this is a laptop and it doesn't have
> > serial. netconsole is helping me for shit so we'd need some guess work.
> > 
> > So I'm open to suggestions.
> > 
> > Please don't say "bisect" yet ;-)))
> 
> No need, I found it. Reverting
> 
>   ea3b5e60ce80 ("x86/mm/ident_map: Add 5-level paging support")
> 
> makes the machine suspend and resume just fine again. Lemme add people to CC.

To be filed under "_maybe_ interesting", my tip-rt tree hits the below
on boot (survives), ONLY on vaporite (kvm), silicon boots clean, works
fine, hibernate/suspend gripe free.  The revert fixed up vaporite.

[   16.566554] BUG: unable to handle kernel paging request at ffffc753f000f000
[   16.566562] IP: ident_pmd_init.isra.4+0x56/0xb0
[   16.566563] PGD 0 

[   16.566565] Oops: 0000 [#1] PREEMPT SMP
[   16.566569] Dumping ftrace buffer:
[   16.566593]    (ftrace buffer empty)
[   16.566593] Modules linked in: nf_conntrack_ipv6(E) nf_defrag_ipv6(E) ip6table_raw(E) ipt_REJECT(E) iptable_raw(E) xt_CT(E) iptable_filter(E) ip6table_mangle(E) nf_conntrack_netbios_ns(E) nf_conntrack_broadcast(E) nf_conntrack_ipv4(E) nf_defrag_ipv4(E) ip_tables(E) xt_conntrack(E) nf_conntrack(E) libcrc32c(E) ip6table_filter(E) ip6_tables(E) x_tables(E) joydev(E) snd_hda_codec_generic(E) snd_hda_intel(E) snd_hda_codec(E) snd_hda_core(E) snd_hwdep(E) snd_pcm(E) snd_timer(E) snd(E) soundcore(E) 8139too(E) i2c_piix4(E) virtio_balloon(E) crct10dif_pclmul(E) crc32_pclmul(E) ghash_clmulni_intel(E) pcbc(E) ppdev(E) aesni_intel(E) serio_raw(E) pcspkr(E) aes_x86_64(E) parport_pc(E) crypto_simd(E) parport(E) acpi_cpufreq(E) glue_helper(E) button(E) cryptd(E) nfsd(E) auth_rpcgss(E) nfs_acl(E) lockd(E) grace(E)
[   16.566611]  sunrpc(E) ext4(E) crc16(E) jbd2(E) mbcache(E) hid_generic(E) usbhid(E) sr_mod(E) cdrom(E) ata_generic(E) virtio_rng(E) virtio_blk(E) virtio_console(E) ata_piix(E) qxl(E) crc32c_intel(E) drm_kms_helper(E) syscopyarea(E) uhci_hcd(E) ehci_pci(E) sysfillrect(E) sysimgblt(E) ehci_hcd(E) fb_sys_fops(E) ahci(E) virtio_pci(E) libahci(E) ttm(E) virtio_ring(E) 8139cp(E) virtio(E) usbcore(E) drm(E) libata(E) mii(E) floppy(E) sg(E) scsi_mod(E) autofs4(E)
[   16.566625] CPU: 6 PID: 1295 Comm: kexec Tainted: G            E   4.11.0-rt12-tip-rt #80
[   16.566626] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.1-0-g4adadbd-20161202_174313-build11a 04/01/2014
[   16.566626] task: ffff88022a3daf40 task.stack: ffffc90002520000
[   16.566628] RIP: 0010:ident_pmd_init.isra.4+0x56/0xb0
[   16.566628] RSP: 0018:ffffc90002523da0 EFLAGS: 00010286
[   16.566629] RAX: ffffc000001fffff RBX: 0000000000000000 RCX: 0000000000000000
[   16.566629] RDX: ffffc753f000f000 RSI: ffffc90002523e90 RDI: ffffc90002523e88
[   16.566629] RBP: 0000000040000000 R08: 0000000040000000 R09: 0000000035ff6fff
[   16.566630] R10: 0000000026000000 R11: 000000000009f000 R12: ffffc000001fffff
[   16.566630] R13: ffffc00000000fff R14: ffffc753f000f000 R15: ffffc90002523e88
[   16.566631] FS:  00007f7ad2486700(0000) GS:ffff88023fd80000(0000) knlGS:0000000000000000
[   16.566631] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   16.566632] CR2: ffffc753f000f000 CR3: 000000023fd68000 CR4: 00000000001406e0
[   16.566634] Call Trace:
[   16.566639]  ? ident_pud_init+0x7a/0x180
[   16.566641]  ? kernel_ident_mapping_init+0x152/0x1f0
[   16.566643]  ? machine_kexec_prepare+0xa7/0x470
[   16.566644]  ? kexec_mark_crashkres+0x70/0x70
[   16.566647]  ? SyS_kexec_file_load+0x2e4/0x6b0
[   16.566651]  ? do_sys_open+0x182/0x1e0
[   16.566655]  ? entry_SYSCALL_64_fastpath+0x1a/0xa5
[   16.566656] Code: 53 48 89 cb 48 81 e3 00 00 e0 ff 48 83 ec 08 4c 39 c3 48 89 34 24 73 54 48 89 da 4c 89 e0 48 c1 ea 12 81 e2 f8 0f 00 00 4c 01 f2 <48> 8b 0a f6 c1 80 49 0f 44 c5 48 21 c8 a9 81 01 00 00 75 21 48 
[   16.566665] RIP: ident_pmd_init.isra.4+0x56/0xb0 RSP: ffffc90002523da0
[   16.566665] CR2: ffffc753f000f000

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
