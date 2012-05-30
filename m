Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 87E476B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 12:54:02 -0400 (EDT)
Date: Wed, 30 May 2012 12:53:58 -0400
From: Dave Jones <davej@redhat.com>
Subject: mm list corruption/hard lockup.
Message-ID: <20120530165358.GA15856@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org

Just hit this with Linus current tree (4523e1458566a0e8ecfaff90f380dd23acc44d27)


[ 1820.876977] WARNING: at lib/list_debug.c:59 __list_del_entry+0xa1/0xd0()
[ 1820.878686] list_del corruption. prev->next should be ffffea0004b32de0, but was ffffea0004b35660
[ 1820.879605] Modules linked in: fuse nfnetlink dccp_ipv6 dccp_ipv4 dccp tun ipt_ULOG binfmt_misc usb_debug sctp libcrc32c caif_socket caif phonet bluetooth rfkill can llc2 pppoe pppox ppp_generic slhc irda crc_ccitt rds af_key decnet rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables kvm_intel kvm crc32c_intel ghash_clmulni_intel microcode serio_raw i2c_i801 pcspkr lpc_ich mfd_core e1000e nfsd nfs_acl auth_rpcgss lockd sunrpc i915 video i2c_algo_bit drm_kms_helper drm i2c_core [last unloaded: scsi_wait_scan]
[ 1820.883166] Pid: 8742, comm: trinity-child5 Not tainted 3.4.0+ #37
[ 1820.884072] Call Trace:
[ 1820.884980]  [<ffffffff81048fdf>] warn_slowpath_common+0x7f/0xc0
[ 1820.885897]  [<ffffffff810490d6>] warn_slowpath_fmt+0x46/0x50
[ 1820.886824]  [<ffffffff813253a1>] __list_del_entry+0xa1/0xd0
[ 1820.887724]  [<ffffffff811457b9>] move_freepages_block+0x159/0x190
[ 1820.888626]  [<ffffffff811658b3>] suitable_migration_target.isra.15+0x1b3/0x1d0
[ 1820.889537]  [<ffffffff81165afe>] compaction_alloc+0x22e/0x2f0
[ 1820.890452]  [<ffffffff81198227>] migrate_pages+0xc7/0x540
[ 1820.891445]  [<ffffffff811658d0>] ? suitable_migration_target.isra.15+0x1d0/0x1d0
[ 1820.892376]  [<ffffffff81166856>] compact_zone+0x216/0x480
[ 1820.893303]  [<ffffffff810b1208>] ? trace_hardirqs_off_caller+0x28/0xc0
[ 1820.894317]  [<ffffffff81166d9d>] compact_zone_order+0x8d/0xd0
[ 1820.895316]  [<ffffffff81149415>] ? get_page_from_freelist+0x565/0x970
[ 1820.896346]  [<ffffffff81166ea9>] try_to_compact_pages+0xc9/0x140
[ 1820.897369]  [<ffffffff8164ea81>] __alloc_pages_direct_compact+0xaa/0x1d0
[ 1820.898385]  [<ffffffff81149e2b>] __alloc_pages_nodemask+0x60b/0xab0
[ 1820.899400]  [<ffffffff810b1208>] ? trace_hardirqs_off_caller+0x28/0xc0
[ 1820.900424]  [<ffffffff810b4b00>] ? __lock_acquire+0x2c0/0x1aa0
[ 1820.901443]  [<ffffffff81189bb6>] alloc_pages_vma+0xb6/0x190
[ 1820.902466]  [<ffffffff8119cca3>] do_huge_pmd_anonymous_page+0x133/0x310
[ 1820.903482]  [<ffffffff8116bfb2>] handle_mm_fault+0x242/0x2e0
[ 1820.904502]  [<ffffffff8116c262>] __get_user_pages+0x142/0x560
[ 1820.905498]  [<ffffffff81171928>] ? mmap_region+0x3f8/0x630
[ 1820.906495]  [<ffffffff81317b3d>] ? rb_insert_color+0xad/0x150
[ 1820.907473]  [<ffffffff8116c732>] get_user_pages+0x52/0x60
[ 1820.908473]  [<ffffffff8116d622>] make_pages_present+0x92/0xc0
[ 1820.909447]  [<ffffffff811718d6>] mmap_region+0x3a6/0x630
[ 1820.910513]  [<ffffffff81050a6c>] ? do_setitimer+0x1cc/0x310
[ 1820.910515]  [<ffffffff81171ebd>] do_mmap_pgoff+0x35d/0x3b0
[ 1820.910517]  [<ffffffff81171f76>] ? sys_mmap_pgoff+0x66/0x240
[ 1820.910520]  [<ffffffff81171f94>] sys_mmap_pgoff+0x84/0x240
[ 1820.910522]  [<ffffffff8131eeee>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 1820.910524]  [<ffffffff81006ca2>] sys_mmap+0x22/0x30
[ 1820.910527]  [<ffffffff816613d2>] system_call_fastpath+0x16/0x1b
[ 1820.910528] ---[ end trace f74f2364aa4221df ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
