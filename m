Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 82B056B004A
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 18:32:08 -0500 (EST)
Date: Mon, 27 Feb 2012 18:32:04 -0500
From: Dave Jones <davej@redhat.com>
Subject: Bad page state bugs since 3.0.
Message-ID: <20120227233204.GA20540@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Fedora Kernel Team <kernel-team@fedoraproject.org>

We've been getting noticably more 'bad page state' bugs in Fedora since 3.0.
I've looked over them, and don't see any obvious cause, though maybe
some VM gurus will see something I missed.

The only commonality seems to be that a still-in-use page somehow ends up on the
freelist, and then something falls over it when it tries to allocate.

I've pasted the traces below, along with pointers to the original bugs in case
there's more info there.

Is there anything we could add to help track down exactly what's going on here ?

	Dave



https://bugzilla.redhat.com/show_bug.cgi?id=728531
BUG: Bad page state in process systemd-readahe  pfn:37ac5
page:f62c18a0 count:0 mapcount:0 mapping: (null) index:0x0
page flags: 0x80400000(uncached)
Modules linked in: firewire_ohci firewire_core crc_itu_t i915 drm_kms_helper
drm i2c_algo_bit i2c_core video
Pid: 410, comm: systemd-readahe Tainted: G    B       3.0.0-4.1.fc16.i686.PAE #1
Call Trace:
 [<c04cc1af>] bad_page+0xcf/0xe6
 [<c04ccd88>] get_page_from_freelist+0x2e0/0x3c7
 [<c04cd10a>] __alloc_pages_nodemask+0x165/0x672
 [<c047381f>] ? lock_release+0x15a/0x17b
 [<c0473905>] ? lock_acquire+0xc5/0xe4
 [<c04ceba0>] ? file_ra_state_init+0x24/0x24
 [<c04ceca8>] __do_page_cache_readahead+0xb0/0x18b
 [<c0505f7f>] ? file_free_rcu+0x4f/0x4f
 [<c04cef3d>] force_page_cache_readahead+0x63/0x80
 [<c04ca544>] sys_fadvise64_64+0x18c/0x20a
 [<c0853d1f>] sysenter_do_call+0x12/0x38


https://bugzilla.redhat.com/show_bug.cgi?id=756814
BUG: Bad page state in process qemu-kvm  pfn:108861
page:ffffea0004221840 count:0 mapcount:0 mapping: (null) index:0x7f2d22746
page flags: 0x40000000000014(referenced|dirty)
Modules linked in: ppdev parport_pc lp parport fuse ebtable_nat ebtables lockd xt_CHECKSUM iptable_mangle tun bridge stp llc rfcomm bnep ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables xt_state ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 btusb bluetooth arc4 snd_hda_codec_conexant cdc_subset cdc_ether usbnet mii uvcvideo videodev media v4l2_compat_ioctl32 snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm i2c_i801 e1000e snd_timer snd_page_alloc microcode thinkpad_acpi iTCO_wdt snd iTCO_vendor_support soundcore iwlagn mac80211 cfg80211 rfkill joydev binfmt_misc virtio_net kvm_intel kvm uinput sunrpc xts gf128mul dm_crypt sdhci_pci sdhci mmc_core wmi i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
Pid: 4625, comm: qemu-kvm Not tainted 3.1.1-2.fc16.x86_64 #1
Call Trace:
 [<ffffffff810e3ec3>] bad_page+0xe7/0xfd
 [<ffffffff810e4d9c>] get_page_from_freelist+0x4b3/0x62a
 [<ffffffff810f47a2>] ? zone_page_state_add+0x2f/0x34
 [<ffffffff810e5003>] __alloc_pages_direct_compact+0xf0/0x15a
 [<ffffffff810e54df>] __alloc_pages_nodemask+0x472/0x71d
 [<ffffffffa019a49b>] ? vmx_decache_cr3+0x1d/0x3d [kvm_intel]
 [<ffffffff81112065>] alloc_pages_vma+0xf5/0xfa
 [<ffffffff8111fcac>] do_huge_pmd_anonymous_page+0xbf/0x25b
 [<ffffffff810f91af>] ? pmd_offset+0x19/0x3f
 [<ffffffff810fc4a8>] handle_mm_fault+0x120/0x1db
 [<ffffffff810fc8d5>] __get_user_pages+0x2db/0x419
 [<ffffffffa01349d5>] get_user_page_nowait+0x37/0x39 [kvm]
 [<ffffffffa0134a97>] hva_to_pfn+0xc0/0x2ab [kvm]
 [<ffffffffa013cb70>] ? kvm_fetch_guest_virt+0x5f/0x6c [kvm]
 [<ffffffffa0134d05>] __gfn_to_pfn+0x83/0x8c [kvm]
 [<ffffffffa0134dc6>] gfn_to_pfn_async+0x1a/0x1c [kvm]
 [<ffffffffa014bf96>] try_async_pf+0x3f/0x1ca [kvm]
 [<ffffffffa0134992>] ? kvm_host_page_size+0x7d/0x89 [kvm]
 [<ffffffffa014d69a>] tdp_page_fault+0xe8/0x1a1 [kvm]
 [<ffffffffa014c1fd>] kvm_mmu_page_fault+0x2b/0x83 [kvm]
 [<ffffffffa019be81>] handle_ept_violation+0xdb/0xe4 [kvm_intel]
 [<ffffffffa01a0cc0>] vmx_handle_exit+0x5b7/0x5f2 [kvm_intel]
 [<ffffffff81014fec>] ? sched_clock+0x9/0xd
 [<ffffffff81078268>] ? sched_clock_cpu+0x42/0xc6
 [<ffffffffa0146141>] kvm_arch_vcpu_ioctl_run+0xa01/0xca1 [kvm]
 [<ffffffffa013387e>] kvm_vcpu_ioctl+0x11a/0x509 [kvm]
 [<ffffffff810440c2>] ? update_stats_wait_end+0x6d/0xaf
 [<ffffffff811def99>] ? file_has_perm+0xa7/0xc9
 [<ffffffff8113713f>] do_vfs_ioctl+0x452/0x493
 [<ffffffff811371d6>] sys_ioctl+0x56/0x7c
 [<ffffffff814bd902>] system_call_fastpath+0x16/0x1b


https://bugzilla.redhat.com/show_bug.cgi?id=769346
BUG: Bad page state in process gnome-shell  pfn:1faf41
page:ffffea0007ebd040 count:19712 mapcount:0 mapping:0000fd0000000000 index:0xa80000000000
page flags: 0x40930000008000(tail)
Modules linked in: ppdev parport_pc lp parport fuse lockd rfcomm bnep coretemp snd_hda_codec_conexant snd_hda_intel snd_hda_codec snd_hwdep snd_seq thinkpad_acpi snd_seq_device snd_pcm uvcvideo videodev media v4l2_compat_ioctl32 snd_timer snd snd_page_alloc soundcore uinput arc4 iwlagn mac80211 cfg80211 btusb bluetooth e1000e microcode iTCO_wdt sunrpc iTCO_vendor_support i2c_i801 rfkill firewire_ohci firewire_core crc_itu_t sdhci_pci sdhci mmc_core nouveau i915 ttm drm_kms_helper drm i2c_algo_bit mxm_wmi i2c_core wmi video [last unloaded: scsi_wait_scan]
Pid: 1695, comm: gnome-shell Not tainted 3.1.2-1.fc16.x86_64 #1
Call Trace:
 [<ffffffff810e3ec3>] bad_page+0xe7/0xfd
 [<ffffffff810e4469>] free_pages_prepare+0x95/0xe3
 [<ffffffff810e44df>] __free_pages_ok+0x28/0xd8
 [<ffffffff810e45aa>] free_compound_page+0x1b/0x1d
 [<ffffffff810e7d80>] __put_compound_page+0x20/0x24
 [<ffffffff810e7e97>] put_compound_page+0xeb/0xf9
 [<ffffffff810e7f1d>] release_pages+0x78/0x187
 [<ffffffff81109120>] free_pages_and_swap_cache+0x52/0x6d
 [<ffffffff810f9c3c>] tlb_flush_mmu+0x45/0x63
 [<ffffffff810f9c6e>] tlb_finish_mmu+0x14/0x39
 [<ffffffff81100bb9>] exit_mmap+0xd8/0x100
 [<ffffffff81055662>] mmput+0x68/0xd6
 [<ffffffff8105ad5a>] exit_mm+0x136/0x143
 [<ffffffff8105afd8>] do_exit+0x271/0x764
 [<ffffffff81066950>] ? __dequeue_signal+0x1b/0x111
 [<ffffffff8105b750>] do_group_exit+0x7a/0xa2
 [<ffffffff81068cd5>] get_signal_to_deliver+0x47d/0x4c8
 [<ffffffff8100eeec>] do_signal+0x3e/0x629
 [<ffffffff810b4df9>] ? __call_rcu+0x130/0x139
 [<ffffffff81043ff3>] ? should_resched+0xe/0x2d
 [<ffffffff8114035b>] ? mntput_no_expire+0x2b/0xd1
 [<ffffffff8100f518>] do_notify_resume+0x28/0x83
 [<ffffffff814bdbd0>] int_signal+0x12/0x17


https://bugzilla.redhat.com/show_bug.cgi?id=770264
BUG: Bad page state in process khugepaged  pfn:3e1e0
page:ffffea0000f87800 count:0 mapcount:0 mapping: (null) index:0x7fac0cacc
page flags: 0x20000000000014(referenced|dirty)
Modules linked in: tcp_lp ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat xt_CHECKSUM iptable_mangle tun bridge stp llc cls_u32 sch_sfq sch_prio sch_htb nf_conntrack_ipv4 nf_defrag_ipv4 xt_connlimit ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables fuse joydev snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device edac_core sp5100_tco snd_pcm edac_mce_amd serio_raw k8temp i2c_piix4 virtio_net r8169 kvm_amd mii snd_timer snd soundcore snd_page_alloc kvm uinput xts gf128mul dm_crypt pata_acpi ata_generic pata_atiixp wmi radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded: scsi_wait_scan]
Pid: 50, comm: khugepaged Not tainted 3.1.5-6.fc16.x86_64 #1
Call Trace:
 [<ffffffff8111b7af>] bad_page+0xbf/0x110
 [<ffffffff8111d006>] get_page_from_freelist+0x6a6/0x820
 [<ffffffff81061f6b>] ? load_balance+0xcb/0x800
 [<ffffffff8111d40e>] __alloc_pages_nodemask+0x10e/0x8b0
 [<ffffffff8107aa79>] ? lock_timer_base+0x39/0x70
 [<ffffffff8107bc2e>] ? try_to_del_timer_sync+0x8e/0x130
 [<ffffffff8107bd0a>] ? del_timer_sync+0x3a/0x60
 [<ffffffff8115534a>] alloc_pages_vma+0x9a/0x150
 [<ffffffff811642be>] khugepaged+0x6fe/0x1330
 [<ffffffff8108e660>] ? remove_wait_queue+0x50/0x50
 [<ffffffff81163bc0>] ? collect_mm_slot+0xa0/0xa0
 [<ffffffff8108ddbc>] kthread+0x8c/0xa0
 [<ffffffff815de934>] kernel_thread_helper+0x4/0x10
 [<ffffffff8108dd30>] ? kthread_worker_fn+0x190/0x190
 [<ffffffff815de930>] ? gs_change+0x13/0x13


https://bugzilla.redhat.com/show_bug.cgi?id=772794
BUG: Bad page state in process gpg  pfn:201c64
page:ffffea0008071900 count:0 mapcount:0 mapping: (null) index:0x3eb
page flags: 0x40000000000004(referenced)
Modules linked in: nls_utf8 hfsplus tcp_lp ppdev parport_pc lp parport fuse ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat xt_CHECKSUM iptable_mangle tun bridge lockd fcoe libfcoe libfc scsi_transport_fc scsi_tgt 8021q garp stp llc rfcomm bnep ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack arc4 snd_hda_codec_hdmi snd_hda_codec_cirrus snd_hda_intel snd_hda_codec ath9k mac80211 ath9k_common ath9k_hw snd_hwdep uvcvideo snd_seq applesmc snd_seq_device iTCO_wdt ath shpchp intel_ips snd_pcm tg3 videodev media v4l2_compat_ioctl32 virtio_net snd_timer cfg80211 i7core_edac btusb bluetooth rfkill snd soundcore snd_page_alloc sunrpc kvm_intel binfmt_misc microcode edac_core i2c_i801 input_polldev iTCO_vendor_support kvm apple_bl uinput usb_storage firewire_ohci firewire_core crc_itu_t radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded: scsi_wait_scan]
Pid: 22527, comm: gpg Not tainted 3.1.7-1.fc16.x86_64 #1
Call Trace:
 [<ffffffff8111b80f>] bad_page+0xbf/0x110
 [<ffffffff8111d086>] get_page_from_freelist+0x6c6/0x840
 [<ffffffff8111d48e>] __alloc_pages_nodemask+0x10e/0x8b0
 [<ffffffff81228e4b>] ? start_this_handle+0x46b/0x4e0
 [<ffffffff81152b83>] alloc_pages_current+0xa3/0x110
 [<ffffffff81114977>] __page_cache_alloc+0x87/0x90
 [<ffffffff8111509f>] grab_cache_page_write_begin+0x5f/0xe0
 [<ffffffff811f11b0>] ext4_da_write_begin+0xa0/0x210
 [<ffffffff811146ed>] generic_file_buffered_write+0xfd/0x250
 [<ffffffff81115e19>] __generic_file_aio_write+0x229/0x430
 [<ffffffff810712a6>] ? current_fs_time+0x16/0x60
 [<ffffffff81116092>] generic_file_aio_write+0x72/0xe0
 [<ffffffff811eaebf>] ext4_file_write+0xbf/0x250
 [<ffffffff81172202>] do_sync_write+0xd2/0x110
 [<ffffffff81253ccc>] ? security_file_permission+0x2c/0xb0
 [<ffffffff811726a1>] ? rw_verify_area+0x61/0xf0
 [<ffffffff81172a03>] vfs_write+0xb3/0x180
 [<ffffffff81172d2a>] sys_write+0x4a/0x90
 [<ffffffff815dcd82>] system_call_fastpath+0x16/0x1b


https://bugzilla.redhat.com/show_bug.cgi?id=789993
BUG: Bad page state in process tar  pfn:27d36
page:f4bca6c0 count:0 mapcount:0 mapping: (null) index:0x9336e
page flags: 0x40000004(referenced)
Modules linked in: tcp_lp nls_utf8 hfsplus ppdev parport_pc lp parport fuse be2iscsi iscsi_boot_sysfs bnx2i cnic uio cxgb4i cxgb4 cxgb3i libcxgbi cxgb3 mdio nfs fcoe libfcoe libfc scsi_transport_fc 8021q fscache ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr iscsi_tcp libiscsi_tcp garp stp llc libiscsi rfcomm lockd scsi_tgt scsi_transport_iscsi auth_rpcgss nfs_acl bnep binfmt_misc snd_hda_codec_hdmi snd_hda_codec_conexant snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm btusb snd_timer iTCO_wdt snd bluetooth iTCO_vendor_support uvcvideo arc4 r852 iwlwifi sm_common nand nand_ids mtd mac80211 videodev media nand_ecc r592 memstick r8169 soundcore snd_page_alloc virtio_net mii serio_raw asus_laptop cfg80211 sparse_keymap rfkill input_polldev kvm joydev microcode sunrpc uinput usb_storage sdhci_pci sdhci mmc_core firewire_ohci firewire_core crc_itu_t i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
Pid: 8918, comm: tar Not tainted 3.2.3-2.fc16.i686 #1
Call Trace:
 [<c04e9a37>] bad_page+0xa7/0xf0
 [<c04eac8e>] get_page_from_freelist+0x43e/0x4d0
 [<c04eaf6c>] __alloc_pages_nodemask+0xfc/0x6e0
 [<c04e46c0>] ? find_get_page+0x20/0xa0
 [<c04e4761>] ? find_lock_page+0x21/0x70
 [<c04e480b>] grab_cache_page_write_begin+0x5b/0xc0
 [<f9a4ee26>] nfs_write_begin+0x66/0x210 [nfs]
 [<f9a4f028>] ? nfs_write_end+0x58/0x230 [nfs]
 [<c04e3dfc>] generic_file_buffered_write+0xdc/0x210
 [<c04e535c>] __generic_file_aio_write+0x24c/0x4d0
 [<c04e5b60>] ? generic_file_aio_read+0x4b0/0x6f0
 [<c04e5645>] generic_file_aio_write+0x65/0xd0
 [<f9a4e71f>] nfs_file_write+0x8f/0x1b0 [nfs]
 [<c052dddc>] do_sync_write+0xac/0xe0
 [<c052e4cc>] ? rw_verify_area+0x6c/0x120
 [<c052e82f>] vfs_write+0x8f/0x160
 [<c052dd30>] ? wait_on_retry_sync_kiocb+0x50/0x50
 [<c052eb0d>] sys_write+0x3d/0x70
 [<c0921204>] syscall_call+0x7/0xb
 [<c0920000>] ? __mutex_lock_slowpath+0xb0/0x110


https://bugzilla.redhat.com/show_bug.cgi?id=795889
BUG: Bad page state in process swapper  pfn:38382
page:ffffea0000e0e080 count:0 mapcount:0 mapping:00000000000000e8 index:0x0
page flags: 0x10000000005ae8(uptodate|lru|active|slab|arch_1|private|private_2|head)
Modules linked in:
Pid: 0, comm: swapper Not tainted 3.3.0-0.rc3.git7.2.fc17.x86_64 #1
Call Trace:
 [<ffffffff81693aeb>] bad_page+0xe6/0xfb
 [<ffffffff811578ca>] free_pages_prepare+0x23a/0x260
 [<ffffffff8115791f>] __free_pages_ok+0x2f/0x120
 [<ffffffff81157c25>] __free_pages+0x25/0x40
 [<ffffffff81f3e08a>] __free_pages_bootmem+0x7d/0x8a
 [<ffffffff81f16f4b>] free_low_memory_core_early+0x146/0x1df
 [<ffffffff816ab0df>] ? bad_to_user+0x7f9/0x7f9
 [<ffffffff81f0bde4>] numa_free_all_bootmem+0x7b/0x86
 [<ffffffff816ab0df>] ? bad_to_user+0x7f9/0x7f9
 [<ffffffff81f0a85c>] mem_init+0x1e/0xed
 [<ffffffff816900b5>] ? set_nmi_gate+0x48/0x4a
 [<ffffffff81ef6a3a>] start_kernel+0x1f4/0x407
 [<ffffffff81ef6346>] x86_64_start_reservations+0x131/0x135
 [<ffffffff81ef644a>] x86_64_start_kernel+0x100/0x10f


https://bugzilla.redhat.com/show_bug.cgi?id=797187
BUG: Bad page state in process chrome  pfn:00000
page:f50c2000 count:0 mapcount:1 mapping: (null) index:0x0
page flags: 0x0()
Modules linked in: tcp_lp be2iscsi iscsi_boot_sysfs bnx2i cnic uio cxgb4i cxgb4 cxgb3i libcxgbi cxgb3 mdio ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi fcoe libfcoe libfc scsi_transport_fc 8021q garp stp llc scsi_tgt ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ip6table_filter ip6_tables fuse arc4 snd_hda_codec_si3054 snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq ath5k ath mac80211 snd_seq_device snd_pcm cfg80211 8139too 8139cp mii snd_timer snd acer_wmi sparse_keymap i2c_piix4 rfkill microcode joydev soundcore snd_page_alloc serio_raw uinput binfmt_misc ata_generic pata_acpi pata_atiixp video wmi sata_sil radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded: scsi_wait_scan]
Pid: 9665, comm: chrome Tainted: G        W    3.2.6-3.fc16.i686 #1
Call Trace:
 [<c04e9ab7>] bad_page+0xa7/0xf0
 [<c04ea0ca>] free_pages_prepare+0x14a/0x160
 [<c04ea40d>] free_hot_cold_page+0x2d/0x2f0
 [<c04ee251>] __put_single_page+0x21/0x30
 [<c04ee3e5>] put_page+0x25/0x40
 [<c05715ce>] elf_core_dump+0xdfe/0xed0
 [<c05357ae>] do_coredump+0x44e/0xb40
 [<c0460d92>] get_signal_to_deliver+0x1b2/0x560
 [<c0548178>] ? mntput+0x18/0x30
 [<c0505629>] ? print_vma_addr+0x89/0x100
 [<c0924740>] ? vmalloc_fault+0xee/0xee
 [<c0402cdf>] do_signal+0x4f/0x830
 [<c091837c>] ? printk+0x2d/0x2f
 [<c0917d3a>] ? __bad_area_nosemaphore+0x119/0x128
 [<c0917dd8>] ? bad_area_access_error+0x38/0x3e
 [<c0924740>] ? vmalloc_fault+0xee/0xee
 [<c092491f>] ? do_page_fault+0x1df/0x460
 [<c0537c2a>] ? path_put+0x1a/0x20
 [<c04a3446>] ? audit_syscall_exit+0x176/0x1a0
 [<c04a3446>] ? audit_syscall_exit+0x176/0x1a0
 [<c0924740>] ? vmalloc_fault+0xee/0xee
 [<c04036e7>] do_notify_resume+0x87/0xb0
 [<c09213b0>] work_notifysig+0x13/0x1b
 [<c092007b>] ? __mutex_lock_slowpath+0x4b/0x110


https://bugzilla.redhat.com/show_bug.cgi?id=797053
BUG: Bad page state in process Xorg  pfn:08eef
page:ffffea000023bbc0 count:2 mapcount:0 mapping:ffff880008c13d90 index:0x2ce
page flags: 0x20000000080028(uptodate|lru|swapbacked)
Modules linked in: binfmt_misc fuse ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat xt_CHECKSUM iptable_mangle tun bridge lockd fcoe 8021q libfcoe libfc scsi_transport_fc scsi_tgt garp stp llc be2iscsi iscsi_boot_sysfs bnx2i cnic uio cxgb4i cxgb4 cxgb3i libcxgbi cxgb3 mdio ib_iser ip6t_REJECT nf_conntrack_ipv6 rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi nf_conntrack_ipv4 nf_defrag_ipv6 nf_defrag_ipv4 xt_state nf_conntrack ip6table_filter ip6_tables snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device iTCO_wdt snd_pcm iTCO_vendor_support ppdev microcode i2c_i801 snd_timer parport_pc snd parport r8169 mii uinput soundcore sunrpc snd_page_alloc usb_storage i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
Pid: 1137, comm: Xorg Not tainted 3.2.7-1.fc16.x86_64 #1
Call Trace:
 [<ffffffff81120e2f>] bad_page+0xbf/0x110
 [<ffffffff81122694>] get_page_from_freelist+0x6b4/0x830
 [<ffffffff812ca001>] ? list_del+0x11/0x40
 [<ffffffff81122aa0>] __alloc_pages_nodemask+0x110/0x890
 [<ffffffff81266a90>] ? task_has_capability+0xc0/0x140
 [<ffffffff812bbd89>] ? radix_tree_preload+0x39/0xa0
 [<ffffffff8115b48a>] alloc_pages_vma+0x9a/0x150
 [<ffffffff8112fe05>] shmem_alloc_page+0x55/0x60
 [<ffffffff81143d18>] ? __vm_enough_memory+0x38/0x190
 [<ffffffff81267101>] ? selinux_vm_enough_memory+0x51/0x60
 [<ffffffff81131e27>] shmem_getpage_gfp+0x287/0x5d0
 [<ffffffff8114b8b2>] ? insert_vmalloc_vmlist+0x22/0x80
 [<ffffffff811321a1>] shmem_read_mapping_page_gfp+0x31/0x60
 [<ffffffffa0083da5>] i915_gem_object_bind_to_gtt+0x1e5/0x610 [i915]
 [<ffffffff81266c95>] ? selinux_inode_alloc_security+0x45/0xb0
 [<ffffffffa008776f>] i915_gem_object_pin+0x14f/0x1a0 [i915]
 [<ffffffff8126e10a>] ? selinux_file_alloc_security+0x4a/0x80
 [<ffffffffa008a4dc>] i915_gem_execbuffer_reserve+0x28c/0x370 [i915]
 [<ffffffff8116497c>] ? __kmalloc+0x12c/0x190
 [<ffffffffa008afe7>] i915_gem_do_execbuffer+0x677/0x14e0 [i915]
 [<ffffffffa00866b0>] ? i915_gem_object_set_to_gtt_domain+0xd0/0x1e0 [i915]
 [<ffffffff8116498d>] ? __kmalloc+0x13d/0x190
 [<ffffffffa008c313>] i915_gem_execbuffer2+0xa3/0x260 [i915]
 [<ffffffffa0022474>] drm_ioctl+0x444/0x510 [drm]
 [<ffffffffa008c270>] ? i915_gem_execbuffer+0x420/0x420 [i915]
 [<ffffffff812662b0>] ? inode_has_perm+0x30/0x40
 [<ffffffff812696ac>] ? file_has_perm+0xdc/0xf0
 [<ffffffff8118ab58>] do_vfs_ioctl+0x98/0x550
 [<ffffffff8118b0a1>] sys_ioctl+0x91/0xa0
 [<ffffffff815e9d82>] system_call_fastpath+0x16/0x1b


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
