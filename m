Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id BC15D6B005D
	for <linux-mm@kvack.org>; Wed, 30 May 2012 20:57:43 -0400 (EDT)
Date: Wed, 30 May 2012 20:57:40 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: WARNING: at mm/page-writeback.c:1990
 __set_page_dirty_nobuffers+0x13a/0x170()
Message-ID: <20120531005739.GA4532@redhat.com>
References: <20120530163317.GA13189@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120530163317.GA13189@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, May 30, 2012 at 12:33:17PM -0400, Dave Jones wrote:
 > Just saw this on Linus tree as of 731a7378b81c2f5fa88ca1ae20b83d548d5613dc
 > 
 > WARNING: at mm/page-writeback.c:1990 __set_page_dirty_nobuffers+0x13a/0x170()
 > Modules linked in: ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_CHECKSUM iptable_mangle bridge stp llc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables snd_emu10k1 snd_util_mem snd_ac97_codec ac97_bus snd_hwdep snd_rawmidi snd_seq_device snd_pcm microcode snd_page_alloc pcspkr snd_timer snd lpc_ich i2c_i801 mfd_core e1000e soundcore vhost_net tun macvtap macvlan kvm_intel nfsd kvm nfs_acl auth_rpcgss lockd sunrpc btrfs libcrc32c zlib_deflate firewire_ohci firewire_core sata_sil crc_itu_t floppy radeon i2c_algo_bit drm_kms_helper ttm drm i2c_core [last unloaded: scsi_wait_scan]
 > Pid: 35, comm: khugepaged Not tainted 3.4.0+ #75
 > Call Trace:
 >  [<ffffffff8104897f>] warn_slowpath_common+0x7f/0xc0
 >  [<ffffffff810489da>] warn_slowpath_null+0x1a/0x20
 >  [<ffffffff81146bda>] __set_page_dirty_nobuffers+0x13a/0x170
 >  [<ffffffff81193322>] migrate_page_copy+0x1e2/0x260
 >  [<ffffffff811933fb>] migrate_page+0x5b/0x70
 >  [<ffffffff811934b5>] move_to_new_page+0xa5/0x260
 >  [<ffffffff81193ca8>] migrate_pages+0x4c8/0x540
 >  [<ffffffff811610d0>] ? suitable_migration_target.isra.15+0x1d0/0x1d0
 >  [<ffffffff81162056>] compact_zone+0x216/0x480
 >  [<ffffffff81321ad8>] ? debug_check_no_obj_freed+0x88/0x210
 >  [<ffffffff8116259d>] compact_zone_order+0x8d/0xd0
 >  [<ffffffff811626a9>] try_to_compact_pages+0xc9/0x140
 >  [<ffffffff81649f4e>] __alloc_pages_direct_compact+0xaa/0x1d0
 >  [<ffffffff8114562b>] __alloc_pages_nodemask+0x60b/0xab0
 >  [<ffffffff81321bbc>] ? debug_check_no_obj_freed+0x16c/0x210
 >  [<ffffffff81185236>] alloc_pages_vma+0xb6/0x190
 >  [<ffffffff81195d8d>] khugepaged+0x95d/0x1570
 >  [<ffffffff81073350>] ? wake_up_bit+0x40/0x40
 >  [<ffffffff81195430>] ? collect_mm_slot+0xa0/0xa0
 >  [<ffffffff81072c37>] kthread+0xb7/0xc0
 >  [<ffffffff8165dc14>] kernel_thread_helper+0x4/0x10
 >  [<ffffffff8165511d>] ? retint_restore_args+0xe/0xe
 >  [<ffffffff81072b80>] ? flush_kthread_worker+0x190/0x190
 >  [<ffffffff8165dc10>] ? gs_change+0xb/0xb

Seems this can be triggered from mmap, as well as from khugepaged..

WARNING: at mm/page-writeback.c:1990 __set_page_dirty_nobuffers+0x13a/0x170()
Modules linked in: tun dccp_ipv4 dccp nfnetlink sctp libcrc32c fuse ipt_ULOG binfmt_misc caif_socket caif phonet bluetooth rfkill can llc2 pppoe pppox ppp_generic slhc irda crc_ccitt rds af_key decnet rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables kvm_intel kvm crc32c_intel ghash_clmulni_intel serio_raw microcode pcspkr i2c_i801 usb_debug lpc_ich mfd_core e1000e nfsd nfs_acl auth_rpcgss lockd sunrpc i915 video i2c_algo_bit drm_kms_helper drm i2c_core [last unloaded: scsi_wait_scan]
Pid: 1171, comm: trinity-child4 Not tainted 3.4.0+ #38
Call Trace:
 [<ffffffff810490ef>] warn_slowpath_common+0x7f/0xc0
 [<ffffffff8104914a>] warn_slowpath_null+0x1a/0x20
 [<ffffffff8114b4ea>] __set_page_dirty_nobuffers+0x13a/0x170
 [<ffffffff81197db2>] migrate_page_copy+0x1e2/0x260
 [<ffffffff81197e8b>] migrate_page+0x5b/0x70
 [<ffffffff81197f45>] move_to_new_page+0xa5/0x260
 [<ffffffff81198738>] migrate_pages+0x4c8/0x540
 [<ffffffff811659e0>] ? suitable_migration_target.isra.15+0x1d0/0x1d0
 [<ffffffff81166966>] compact_zone+0x216/0x480
 [<ffffffff810b1318>] ? trace_hardirqs_off_caller+0x28/0xc0
 [<ffffffff81166ead>] compact_zone_order+0x8d/0xd0
 [<ffffffff81149525>] ? get_page_from_freelist+0x565/0x970
 [<ffffffff81166fb9>] try_to_compact_pages+0xc9/0x140
 [<ffffffff81652591>] __alloc_pages_direct_compact+0xaa/0x1d0
 [<ffffffff81149f3b>] __alloc_pages_nodemask+0x60b/0xab0
 [<ffffffff810b1318>] ? trace_hardirqs_off_caller+0x28/0xc0
 [<ffffffff810b4c00>] ? __lock_acquire+0x2b0/0x1aa0
 [<ffffffff81189cc6>] alloc_pages_vma+0xb6/0x190
 [<ffffffff8119cdb3>] do_huge_pmd_anonymous_page+0x133/0x310
 [<ffffffff8116c0c2>] handle_mm_fault+0x242/0x2e0
 [<ffffffff8116c372>] __get_user_pages+0x142/0x560
 [<ffffffff81171a38>] ? mmap_region+0x3f8/0x630
 [<ffffffff8116c842>] get_user_pages+0x52/0x60
 [<ffffffff8116d732>] make_pages_present+0x92/0xc0
 [<ffffffff811719e6>] mmap_region+0x3a6/0x630
 [<ffffffff81050b7c>] ? do_setitimer+0x1cc/0x310
 [<ffffffff81171fcd>] do_mmap_pgoff+0x35d/0x3b0
 [<ffffffff81172086>] ? sys_mmap_pgoff+0x66/0x240
 [<ffffffff811720a4>] sys_mmap_pgoff+0x84/0x240
 [<ffffffff813225be>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff81006ca2>] sys_mmap+0x22/0x30
 [<ffffffff81664ed2>] system_call_fastpath+0x16/0x1b
---[ end trace 336c91f371296e41 ]---



I'd bisect this, but it takes a few hours to trigger, which makes it hard
to distinguish between 'good kernel' and 'hasn't triggered yet'.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
