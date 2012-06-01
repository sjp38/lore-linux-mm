Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id E35A66B004D
	for <linux-mm@kvack.org>; Thu, 31 May 2012 22:31:12 -0400 (EDT)
Date: Thu, 31 May 2012 22:31:07 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: WARNING: at mm/page-writeback.c:1990
 __set_page_dirty_nobuffers+0x13a/0x170()
Message-ID: <20120601023107.GA19445@redhat.com>
References: <20120530163317.GA13189@redhat.com>
 <20120531005739.GA4532@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120531005739.GA4532@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Cong Wang <amwang@redhat.com>

On Wed, May 30, 2012 at 08:57:40PM -0400, Dave Jones wrote:
 > On Wed, May 30, 2012 at 12:33:17PM -0400, Dave Jones wrote:
 >  > Just saw this on Linus tree as of 731a7378b81c2f5fa88ca1ae20b83d548d5613dc
 >  > 
 >  > WARNING: at mm/page-writeback.c:1990 __set_page_dirty_nobuffers+0x13a/0x170()
 >  > Modules linked in: ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_CHECKSUM iptable_mangle bridge stp llc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables snd_emu10k1 snd_util_mem snd_ac97_codec ac97_bus snd_hwdep snd_rawmidi snd_seq_device snd_pcm microcode snd_page_alloc pcspkr snd_timer snd lpc_ich i2c_i801 mfd_core e1000e soundcore vhost_net tun macvtap macvlan kvm_intel nfsd kvm nfs_acl auth_rpcgss lockd sunrpc btrfs libcrc32c zlib_deflate firewire_ohci firewire_core sata_sil crc_itu_t floppy radeon i2c_algo_bit drm_kms_helper ttm drm i2c_core [last unloaded: scsi_wait_scan]
 >  > Pid: 35, comm: khugepaged Not tainted 3.4.0+ #75
 >  > Call Trace:
 >  >  [<ffffffff8104897f>] warn_slowpath_common+0x7f/0xc0
 >  >  [<ffffffff810489da>] warn_slowpath_null+0x1a/0x20
 >  >  [<ffffffff81146bda>] __set_page_dirty_nobuffers+0x13a/0x170
 >  >  [<ffffffff81193322>] migrate_page_copy+0x1e2/0x260
 >  >  [<ffffffff811933fb>] migrate_page+0x5b/0x70
 >  >  [<ffffffff811934b5>] move_to_new_page+0xa5/0x260
 >  >  [<ffffffff81193ca8>] migrate_pages+0x4c8/0x540
 >  >  [<ffffffff811610d0>] ? suitable_migration_target.isra.15+0x1d0/0x1d0
 >  >  [<ffffffff81162056>] compact_zone+0x216/0x480
 >  >  [<ffffffff81321ad8>] ? debug_check_no_obj_freed+0x88/0x210
 >  >  [<ffffffff8116259d>] compact_zone_order+0x8d/0xd0
 >  >  [<ffffffff811626a9>] try_to_compact_pages+0xc9/0x140
 >  >  [<ffffffff81649f4e>] __alloc_pages_direct_compact+0xaa/0x1d0
 >  >  [<ffffffff8114562b>] __alloc_pages_nodemask+0x60b/0xab0
 >  >  [<ffffffff81321bbc>] ? debug_check_no_obj_freed+0x16c/0x210
 >  >  [<ffffffff81185236>] alloc_pages_vma+0xb6/0x190
 >  >  [<ffffffff81195d8d>] khugepaged+0x95d/0x1570
 >  >  [<ffffffff81073350>] ? wake_up_bit+0x40/0x40
 >  >  [<ffffffff81195430>] ? collect_mm_slot+0xa0/0xa0
 >  >  [<ffffffff81072c37>] kthread+0xb7/0xc0
 >  >  [<ffffffff8165dc14>] kernel_thread_helper+0x4/0x10
 >  >  [<ffffffff8165511d>] ? retint_restore_args+0xe/0xe
 >  >  [<ffffffff81072b80>] ? flush_kthread_worker+0x190/0x190
 >  >  [<ffffffff8165dc10>] ? gs_change+0xb/0xb
 > 
 > Seems this can be triggered from mmap, as well as from khugepaged..
 > 
 > WARNING: at mm/page-writeback.c:1990 __set_page_dirty_nobuffers+0x13a/0x170()
 > Modules linked in: tun dccp_ipv4 dccp nfnetlink sctp libcrc32c fuse ipt_ULOG binfmt_misc caif_socket caif phonet bluetooth rfkill can llc2 pppoe pppox ppp_generic slhc irda crc_ccitt rds af_key decnet rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables kvm_intel kvm crc32c_intel ghash_clmulni_intel serio_raw microcode pcspkr i2c_i801 usb_debug lpc_ich mfd_core e1000e nfsd nfs_acl auth_rpcgss lockd sunrpc i915 video i2c_algo_bit drm_kms_helper drm i2c_core [last unloaded: scsi_wait_scan]
 > Pid: 1171, comm: trinity-child4 Not tainted 3.4.0+ #38
 > Call Trace:
 >  [<ffffffff810490ef>] warn_slowpath_common+0x7f/0xc0
 >  [<ffffffff8104914a>] warn_slowpath_null+0x1a/0x20
 >  [<ffffffff8114b4ea>] __set_page_dirty_nobuffers+0x13a/0x170
 >  [<ffffffff81197db2>] migrate_page_copy+0x1e2/0x260
 >  [<ffffffff81197e8b>] migrate_page+0x5b/0x70
 >  [<ffffffff81197f45>] move_to_new_page+0xa5/0x260
 >  [<ffffffff81198738>] migrate_pages+0x4c8/0x540
 >  [<ffffffff811659e0>] ? suitable_migration_target.isra.15+0x1d0/0x1d0
 >  [<ffffffff81166966>] compact_zone+0x216/0x480
 >  [<ffffffff810b1318>] ? trace_hardirqs_off_caller+0x28/0xc0
 >  [<ffffffff81166ead>] compact_zone_order+0x8d/0xd0
 >  [<ffffffff81149525>] ? get_page_from_freelist+0x565/0x970
 >  [<ffffffff81166fb9>] try_to_compact_pages+0xc9/0x140
 >  [<ffffffff81652591>] __alloc_pages_direct_compact+0xaa/0x1d0
 >  [<ffffffff81149f3b>] __alloc_pages_nodemask+0x60b/0xab0
 >  [<ffffffff810b1318>] ? trace_hardirqs_off_caller+0x28/0xc0
 >  [<ffffffff810b4c00>] ? __lock_acquire+0x2b0/0x1aa0
 >  [<ffffffff81189cc6>] alloc_pages_vma+0xb6/0x190
 >  [<ffffffff8119cdb3>] do_huge_pmd_anonymous_page+0x133/0x310
 >  [<ffffffff8116c0c2>] handle_mm_fault+0x242/0x2e0
 >  [<ffffffff8116c372>] __get_user_pages+0x142/0x560
 >  [<ffffffff81171a38>] ? mmap_region+0x3f8/0x630
 >  [<ffffffff8116c842>] get_user_pages+0x52/0x60
 >  [<ffffffff8116d732>] make_pages_present+0x92/0xc0
 >  [<ffffffff811719e6>] mmap_region+0x3a6/0x630
 >  [<ffffffff81050b7c>] ? do_setitimer+0x1cc/0x310
 >  [<ffffffff81171fcd>] do_mmap_pgoff+0x35d/0x3b0
 >  [<ffffffff81172086>] ? sys_mmap_pgoff+0x66/0x240
 >  [<ffffffff811720a4>] sys_mmap_pgoff+0x84/0x240
 >  [<ffffffff813225be>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 >  [<ffffffff81006ca2>] sys_mmap+0x22/0x30
 >  [<ffffffff81664ed2>] system_call_fastpath+0x16/0x1b
 > ---[ end trace 336c91f371296e41 ]---
 > 
 > 
 > 
 > I'd bisect this, but it takes a few hours to trigger, which makes it hard
 > to distinguish between 'good kernel' and 'hasn't triggered yet'.

So I bisected it anyway, and it led to ...


3f31d07571eeea18a7d34db9af21d2285b807a17 is the first bad commit
commit 3f31d07571eeea18a7d34db9af21d2285b807a17
Author: Hugh Dickins <hughd@google.com>
Date:   Tue May 29 15:06:40 2012 -0700

    mm/fs: route MADV_REMOVE to FALLOC_FL_PUNCH_HOLE
    
    Now tmpfs supports hole-punching via fallocate(), switch madvise_remove()
    to use do_fallocate() instead of vmtruncate_range(): which extends
    madvise(,,MADV_REMOVE) support from tmpfs to ext4, ocfs2 and xfs.
    
    There is one more user of vmtruncate_range() in our tree,
    staging/android's ashmem_shrink(): convert it to use do_fallocate() too
    (but if its unpinned areas are already unmapped - I don't know - then it
    would do better to use shmem_truncate_range() directly).
    
    Based-on-patch-by: Cong Wang <amwang@redhat.com>
    Signed-off-by: Hugh Dickins <hughd@google.com>
    Cc: Christoph Hellwig <hch@infradead.org>
    Cc: Al Viro <viro@zeniv.linux.org.uk>
    Cc: Colin Cross <ccross@android.com>
    Cc: John Stultz <john.stultz@linaro.org>
    Cc: Greg Kroah-Hartman <gregkh@linux-foundation.org>
    Cc: "Theodore Ts'o" <tytso@mit.edu>
    Cc: Andreas Dilger <adilger@dilger.ca>
    Cc: Mark Fasheh <mfasheh@suse.de>
    Cc: Joel Becker <jlbec@evilplan.org>
    Cc: Dave Chinner <david@fromorbit.com>
    Cc: Ben Myers <bpm@sgi.com>
    Cc: Michael Kerrisk <mtk.manpages@gmail.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>


Hugh ?

I'll repeat the bisect tomorrow just to be sure. (It took all day, even though
there were only a half dozen bisect points, as I ran the test for an hour on
each build to see what fell out).

Here's what I found..

git bisect start 'mm/'
# bad: [4b395d7ea79472ac240ee8768b4930ca9ce096ef] Merge /home/davej/src/git-trees/kernel/linux
git bisect bad 4b395d7ea79472ac240ee8768b4930ca9ce096ef
# good: [76e10d158efb6d4516018846f60c2ab5501900bc] Linux 3.4
git bisect good 76e10d158efb6d4516018846f60c2ab5501900bc
# good: [c6785b6bf1b2a4b47238b24ee56f61e27c3af682] mm: bootmem: rename alloc_bootmem_core to alloc_bootmem_bdata
git bisect good c6785b6bf1b2a4b47238b24ee56f61e27c3af682
# bad: [89abfab133ef1f5902abafb744df72793213ac19] mm/memcg: move reclaim_stat into lruvec
git bisect bad 89abfab133ef1f5902abafb744df72793213ac19
# bad: [4fb5ef089b288942c6fc3f85c4ecb4016c1aa4c3] tmpfs: support SEEK_DATA and SEEK_HOLE
git bisect bad 4fb5ef089b288942c6fc3f85c4ecb4016c1aa4c3
# good: [bde05d1ccd512696b09db9dd2e5f33ad19152605] shmem: replace page if mapping excludes its zone
git bisect good bde05d1ccd512696b09db9dd2e5f33ad19152605
# bad: [3f31d07571eeea18a7d34db9af21d2285b807a17] mm/fs: route MADV_REMOVE to FALLOC_FL_PUNCH_HOLE
git bisect bad 3f31d07571eeea18a7d34db9af21d2285b807a17
# good: [ec9516fbc5fa814014991e1ae7f8860127122105] tmpfs: optimize clearing when writing
git bisect good ec9516fbc5fa814014991e1ae7f8860127122105
# good: [83e4fa9c16e4af7122e31be3eca5d57881d236fe] tmpfs: support fallocate FALLOC_FL_PUNCH_HOLE
git bisect good 83e4fa9c16e4af7122e31be3eca5d57881d236fe


This has been a challenge to bisect additionally because I'm not sure if the other mm
bug I reported in the last few days (the list_debug/list_add corruption warnings in the
compaction code) are related or not. Sometimes during the bisect these errors happened
in pairs, sometimes only together.  The 'good' builds showed no errors at all.

As a reminder, the list_add corruption looks like this...

WARNING: at lib/list_debug.c:29 __list_add+0x6c/0x90()
list_add corruption. next->prev should be prev (ffff88014e5d9ed8), but was ffffea0004f48360. (next=ffffea0004b23920).
Modules linked in: ipt_ULOG fuse tun nfnetlink binfmt_misc sctp libcrc32c caif_socket caif phonet bluetooth rfkill can llc2 pppoe pppox ppp_generic slhc irda crc_ccitt rds af_key decnet rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables kvm_intel kvm crc32c_intel ghash_clmulni_intel microcode usb_debug serio_raw i2c_i801 pcspkr e1000e nfsd nfs_acl auth_rpcgss lockd sunrpc i915 video i2c_algo_bit drm_kms_helper drm i2c_core [last unloaded: scsi_wait_scan]
Pid: 24594, comm: trinity-child1 Not tainted 3.4.0+ #42
Call Trace:
 [<ffffffff81048fdf>] warn_slowpath_common+0x7f/0xc0
 [<ffffffff810490d6>] warn_slowpath_fmt+0x46/0x50
 [<ffffffff810b767d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff813259dc>] __list_add+0x6c/0x90
 [<ffffffff8114591d>] move_freepages_block+0x16d/0x190
 [<ffffffff81165773>] suitable_migration_target.isra.14+0x1b3/0x1d0
 [<ffffffff81165cab>] compaction_alloc+0x1db/0x2f0
 [<ffffffff81198357>] migrate_pages+0xc7/0x540
 [<ffffffff81165ad0>] ? isolate_freepages_block+0x260/0x260
 [<ffffffff81166946>] compact_zone+0x216/0x480
 [<ffffffff81166e8d>] compact_zone_order+0x8d/0xd0
 [<ffffffff81149565>] ? get_page_from_freelist+0x565/0x970
 [<ffffffff81166f99>] try_to_compact_pages+0xc9/0x140
 [<ffffffff8163b7f2>] __alloc_pages_direct_compact+0xaa/0x1d0
 [<ffffffff81149f7b>] __alloc_pages_nodemask+0x60b/0xab0
 [<ffffffff810b12d8>] ? trace_hardirqs_off_caller+0x28/0xc0
 [<ffffffff810b4c00>] ? __lock_acquire+0x2f0/0x1aa0
 [<ffffffff81189ce6>] alloc_pages_vma+0xb6/0x190
 [<ffffffff8119cd83>] do_huge_pmd_anonymous_page+0x133/0x310
 [<ffffffff8116c0a2>] handle_mm_fault+0x242/0x2e0
 [<ffffffff8116c352>] __get_user_pages+0x142/0x560
 [<ffffffff81171a18>] ? mmap_region+0x3f8/0x630
 [<ffffffff8116c822>] get_user_pages+0x52/0x60
 [<ffffffff8116d712>] make_pages_present+0x92/0xc0
 [<ffffffff811719c6>] mmap_region+0x3a6/0x630
 [<ffffffff81050a3c>] ? do_setitimer+0x1cc/0x310
 [<ffffffff81171fad>] do_mmap_pgoff+0x35d/0x3b0
 [<ffffffff81172066>] ? sys_mmap_pgoff+0x66/0x240
 [<ffffffff81172084>] sys_mmap_pgoff+0x84/0x240
 [<ffffffff8131f31e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff81006ca2>] sys_mmap+0x22/0x30
 [<ffffffff8164e012>] system_call_fastpath+0x16/0x1b
---[ end trace b606ea2a53bf1425 ]---

On an affected kernel, it'll show up within an hour of fuzzing on a fast machine.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
