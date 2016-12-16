Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 384F96B02C8
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:06:02 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so8920614wma.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 07:06:02 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id mn20si7362802wjb.216.2016.12.16.07.06.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 07:06:00 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id g23so6002649wme.1
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 07:06:00 -0800 (PST)
Message-ID: <1481900758.31172.20.camel@gmail.com>
Subject: Re: [PATCH 0/9 v2] scope GFP_NOFS api
From: Mike Galbraith <umgwanakikbuti@gmail.com>
Date: Fri, 16 Dec 2016 16:05:58 +0100
In-Reply-To: <20161215140715.12732-1-mhocko@kernel.org>
References: <20161215140715.12732-1-mhocko@kernel.org>
Content-Type: text/plain; charset="us-ascii"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "Peter
 Zijlstra (Intel)" <peterz@infradead.org>

On Thu, 2016-12-15 at 15:07 +0100, Michal Hocko wrote:
> Hi,
> I have posted the previous version here [1]. Since then I have added a
> support to suppress reclaim lockdep warnings (__GFP_NOLOCKDEP) to allow
> removing GFP_NOFS usage motivated by the lockdep false positives. On top
> of that I've tried to convert few KM_NOFS usages to use the new flag in
> the xfs code base. This would need a review from somebody familiar with
> xfs of course.

The wild ass guess below prevents the xfs explosion below when running
ltp zram tests.

---
 fs/xfs/kmem.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/fs/xfs/kmem.h
+++ b/fs/xfs/kmem.h
@@ -45,7 +45,7 @@ kmem_flags_convert(xfs_km_flags_t flags)
 {
 	gfp_t	lflags;
 
-	BUG_ON(flags & ~(KM_SLEEP|KM_NOSLEEP|KM_NOFS|KM_MAYFAIL|KM_ZERO));
+	BUG_ON(flags & ~(KM_SLEEP|KM_NOSLEEP|KM_NOFS|KM_MAYFAIL|KM_ZERO|KM_NOLOCKDEP));
 
 	if (flags & KM_NOSLEEP) {
 		lflags = GFP_ATOMIC | __GFP_NOWARN;

[  108.775501] ------------[ cut here ]------------
[  108.775503] kernel BUG at fs/xfs/kmem.h:48!
[  108.775504] invalid opcode: 0000 [#1] SMP
[  108.775505] Dumping ftrace buffer:
[  108.775508]    (ftrace buffer empty)
[  108.775508] Modules linked in: xfs(E) libcrc32c(E) btrfs(E) xor(E) raid6_pq(E) zram(E) ebtable_filter(E) ebtables(E) fuse(E) bridge(E) stp(E) llc(E) iscsi_ibft(E) iscsi_boot_sysfs(E) ip6t_REJECT(E) xt_tcpudp(E) nf_conntrack_ipv6(E) nf_defrag_ipv6(E) ip6table_raw(E) ipt_REJECT(E) iptable_raw(E) iptable_filter(E) ip6table_mangle(E) nf_conntrack_netbios_ns(E) nf_conntrack_broadcast(E) nf_conntrack_ipv4(E) nf_defrag_ipv4(E) ip_tables(E) xt_conntrack(E) nf_conntrack(E) ip6table_filter(E) ip6_tables(E) x_tables(E) nls_iso8859_1(E) nls_cp437(E) x86_pkg_temp_thermal(E) intel_powerclamp(E) coretemp(E) kvm_intel(E) nfsd(E) kvm(E) auth_rpcgss(E) nfs_acl(E) lockd(E) snd_hda_codec_realtek(E) snd_hda_codec_hdmi(E) pl2303(E) grace(E) snd_hda_codec_generic(E) usbserial(E) irqbypass(E) snd_hda_intel(E) snd_hda_codec(E)
[  108.775523]  snd_hwdep(E) sunrpc(E) snd_hda_core(E) crct10dif_pclmul(E) mei_me(E) mei(E) serio_raw(E) snd_pcm(E) crc32_pclmul(E) snd_timer(E) crc32c_intel(E) aesni_intel(E) aes_x86_64(E) crypto_simd(E) iTCO_wdt(E) iTCO_vendor_support(E) lpc_ich(E) mfd_core(E) snd(E) soundcore(E) joydev(E) fan(E) shpchp(E) tpm_infineon(E) cryptd(E) battery(E) thermal(E) pcspkr(E) glue_helper(E) usblp(E) intel_smartconnect(E) i2c_i801(E) efivarfs(E) hid_logitech_hidpp(E) hid_logitech_dj(E) hid_generic(E) usbhid(E) nouveau(E) wmi(E) i2c_algo_bit(E) ahci(E) libahci(E) drm_kms_helper(E) syscopyarea(E) sysfillrect(E) sysimgblt(E) fb_sys_fops(E) ehci_pci(E) xhci_pci(E) ttm(E) ehci_hcd(E) xhci_hcd(E) r8169(E) libata(E) mii(E) drm(E) usbcore(E) fjes(E) video(E) button(E) af_packet(E) sd_mod(E) vfat(E) fat(E) ext4(E) crc16(E)
[  108.775540]  jbd2(E) mbcache(E) dm_mod(E) loop(E) sg(E) scsi_mod(E) autofs4(E)
[  108.775544] CPU: 5 PID: 4495 Comm: mount Tainted: G            E   4.10.0-master #4
[  108.775545] Hardware name: MEDION MS-7848/MS-7848, BIOS M7848W08.20C 09/23/2013
[  108.775546] task: ffff8803f9e54e00 task.stack: ffffc900018fc000
[  108.775565] RIP: 0010:kmem_flags_convert.part.0+0x4/0x6 [xfs]
[  108.775565] RSP: 0018:ffffc900018ffcd8 EFLAGS: 00010202
[  108.775566] RAX: ffff8803f630a800 RBX: ffff8803f6b20000 RCX: 0000000000001000
[  108.775567] RDX: 0000000000001000 RSI: 0000000000000031 RDI: 00000000000000b0
[  108.775568] RBP: ffffc900018ffcd8 R08: 0000000000019fe0 R09: ffff8803f6b20000
[  108.775568] R10: 0000000000000005 R11: 0000000000010641 R12: ffff88041e21ea00
[  108.775569] R13: ffff8803f6b20000 R14: 0000000000000000 R15: 00000000fffffff4
[  108.775570] FS:  00007f1cbee9e840(0000) GS:ffff88041ed40000(0000) knlGS:0000000000000000
[  108.775571] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  108.775571] CR2: 00007f5d4b6ed000 CR3: 00000003fbf13000 CR4: 00000000001406e0
[  108.775572] Call Trace:
[  108.775588]  kmem_alloc+0x100/0x100 [xfs]
[  108.775591]  ? kstrndup+0x49/0x60
[  108.775605]  xfs_alloc_buftarg+0x23/0xd0 [xfs]
[  108.775619]  xfs_open_devices+0x8c/0x170 [xfs]
[  108.775621]  ? sb_set_blocksize+0x1d/0x50
[  108.775633]  xfs_fs_fill_super+0x234/0x580 [xfs]
[  108.775635]  mount_bdev+0x184/0x1c0
[  108.775647]  ? xfs_test_remount_options.isra.15+0x60/0x60 [xfs]
[  108.775658]  xfs_fs_mount+0x15/0x20 [xfs]
[  108.775659]  mount_fs+0x15/0x90
[  108.775661]  vfs_kern_mount+0x67/0x130
[  108.775663]  do_mount+0x190/0xbd0
[  108.775664]  ? memdup_user+0x42/0x60
[  108.775665]  SyS_mount+0x83/0xd0
[  108.775668]  entry_SYSCALL_64_fastpath+0x1a/0xa9
[  108.775669] RIP: 0033:0x7f1cbe7bf78a
[  108.775669] RSP: 002b:00007ffc99215198 EFLAGS: 00000202 ORIG_RAX: 00000000000000a5
[  108.775670] RAX: ffffffffffffffda RBX: 00007f1cbeabb3b8 RCX: 00007f1cbe7bf78a
[  108.775671] RDX: 000055715a611690 RSI: 000055715a60d270 RDI: 000055715a60d2d0
[  108.775671] RBP: 000055715a60d120 R08: 0000000000000000 R09: 00007f1cbea7c678
[  108.775672] R10: 00000000c0ed0000 R11: 0000000000000202 R12: 00007f1cbecc8e78
[  108.775672] R13: 00000000ffffffff R14: 0000000000000000 R15: 000055715a60d060
[  108.775673] Code: ff 74 05 e8 c2 17 64 e0 48 8b 3d 6b ec 03 00 48 85 ff 74 05 e8 b1 17 64 e0 48 8b 3d 32 ec 03 00 e8 25 a6 74 e0 5d c3 55 48 89 e5 <0f> 0b 55 48 89 e5 e8 f4 53 ff ff 48 c7 c7 40 78 b7 a0 e8 18 01 
[  108.775700] RIP: kmem_flags_convert.part.0+0x4/0x6 [xfs] RSP: ffffc900018ffcd8

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
