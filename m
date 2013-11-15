Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 987506B0036
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 10:51:45 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id xa7so3715005pbc.38
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 07:51:45 -0800 (PST)
Received: from psmtp.com ([74.125.245.137])
        by mx.google.com with SMTP id pt8si2350777pac.250.2013.11.15.07.51.42
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 07:51:44 -0800 (PST)
Received: by mail-we0-f174.google.com with SMTP id t61so3747033wes.33
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 07:51:40 -0800 (PST)
From: Diego Calleja <diegocg@gmail.com>
Subject: Re: Disabling in-memory write cache for x86-64 in Linux II
Date: Fri, 15 Nov 2013 16:48:13 +0100
Message-ID: <3934111.dEm1hrGs4E@diego-arch>
In-Reply-To: <20131025233225.GA32051@localhost>
References: <160824051.3072.1382685914055.JavaMail.mail@webmail07> <1999200.Zdacx0scmY@diego-arch> <20131025233225.GA32051@localhost>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: "Artem S. Tashkinov" <t.artem@lycos.com>, david@lang.hm, neilb@suse.de, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, linux-fsdevel@vger.kernel.org, axboe@kernel.dk, linux-mm@kvack.org

El S=E1bado, 26 de octubre de 2013 00:32:25 Fengguang Wu escribi=F3:
> What's the kernel you are running? And it's writing to a hard disk?
> The stalls are most likely caused by either one of
>=20
> 1) write IO starves read IO
> 2) direct page reclaim blocked when
>    - trying to writeout PG_dirty pages
>    - trying to lock PG_writeback pages
>=20
> Which may be confirmed by running
>=20
>         ps -eo ppid,pid,user,stat,pcpu,comm,wchan:32
> or
>         echo w > /proc/sysrq-trigger    # and check dmesg
>=20
> during the stalls. The latter command works more reliably.


Sorry for the delay (background: rsync'ing large files from/to a hard d=
isk
in a desktop with 16GB of RAM makes the whole desktop unreponsive)

I just triggered it today (running 3.12), and run sysrq-w:

[ 5547.001505] SysRq : Show Blocked State
[ 5547.001509]   task                        PC stack   pid father
[ 5547.001516] btrfs-transacti D ffff880425d7a8a0     0   193      2 0x=
00000000
[ 5547.001519]  ffff880425eede10 0000000000000002 ffff880425eedfd8 0000=
000000012e40
[ 5547.001521]  ffff880425eedfd8 0000000000012e40 ffff880425d7a8a0 ffff=
ea00104baa80
[ 5547.001523]  ffff880425eedd90 ffff880425eedd68 ffff880425eedd70 ffff=
ffff81080edd
[ 5547.001525] Call Trace:
[ 5547.001530]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.001533]  [<ffffffff81560ed9>] ? sub_preempt_count+0x49/0x50
[ 5547.001535]  [<ffffffff8155cc86>] ? _raw_spin_unlock+0x16/0x40
[ 5547.001552]  [<ffffffffa008a742>] ? btrfs_run_ordered_operations+0x2=
12/0x2c0 [btrfs]
[ 5547.001554]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.001556]  [<ffffffff81560ed9>] ? sub_preempt_count+0x49/0x50
[ 5547.001557]  [<ffffffff8155d006>] ? _raw_spin_unlock_irqrestore+0x26=
/0x60
[ 5547.001559]  [<ffffffff8155b719>] schedule+0x29/0x70
[ 5547.001566]  [<ffffffffa0072215>] btrfs_commit_transaction+0x265/0x9=
d0 [btrfs]
[ 5547.001569]  [<ffffffff81073d20>] ? wake_up_atomic_t+0x30/0x30
[ 5547.001575]  [<ffffffffa006982d>] transaction_kthread+0x19d/0x220 [b=
trfs]
[ 5547.001581]  [<ffffffffa0069690>] ? free_fs_root+0xc0/0xc0 [btrfs]
[ 5547.001583]  [<ffffffff81072e70>] kthread+0xc0/0xd0
[ 5547.001585]  [<ffffffff81072db0>] ? kthread_create_on_node+0x120/0x1=
20
[ 5547.001587]  [<ffffffff81564bac>] ret_from_fork+0x7c/0xb0
[ 5547.001588]  [<ffffffff81072db0>] ? kthread_create_on_node+0x120/0x1=
20
[ 5547.001590] systemd-journal D ffff880426e19860     0   234      1 0x=
00000000
[ 5547.001592]  ffff880426d77d90 0000000000000002 ffff880426d77fd8 0000=
000000012e40
[ 5547.001593]  ffff880426d77fd8 0000000000012e40 ffff880426e19860 ffff=
ffff8155d7cd
[ 5547.001595]  0000000000000001 0000000000000001 0000000000000000 ffff=
ffff81572560
[ 5547.001596] Call Trace:
[ 5547.001598]  [<ffffffff8155d7cd>] ? retint_restore_args+0xe/0xe
[ 5547.001601]  [<ffffffff8122b47b>] ? queue_unplugged+0x3b/0xe0
[ 5547.001602]  [<ffffffff8122da9b>] ? blk_flush_plug_list+0x1eb/0x230
[ 5547.001604]  [<ffffffff8155b719>] schedule+0x29/0x70
[ 5547.001606]  [<ffffffff8155bb88>] schedule_preempt_disabled+0x18/0x3=
0
[ 5547.001607]  [<ffffffff8155a2f4>] __mutex_lock_slowpath+0x124/0x1f0
[ 5547.001613]  [<ffffffffa0071c9b>] ? btrfs_write_marked_extents+0xbb/=
0xe0 [btrfs]
[ 5547.001615]  [<ffffffff8155a3d7>] mutex_lock+0x17/0x30
[ 5547.001623]  [<ffffffffa00ae06a>] btrfs_sync_log+0x22a/0x690 [btrfs]=

[ 5547.001630]  [<ffffffffa0082f47>] btrfs_sync_file+0x287/0x2e0 [btrfs=
]
[ 5547.001632]  [<ffffffff811abb96>] do_fsync+0x56/0x80
[ 5547.001634]  [<ffffffff811abe20>] SyS_fsync+0x10/0x20
[ 5547.001635]  [<ffffffff81564e5f>] tracesys+0xdd/0xe2
[ 5547.001644] mysqld          D ffff8803f0901860     0   643    579 0x=
00000000
[ 5547.001645]  ffff8803f090de18 0000000000000002 ffff8803f090dfd8 0000=
000000012e40
[ 5547.001647]  ffff8803f090dfd8 0000000000012e40 ffff8803f0901860 ffff=
88016d038000
[ 5547.001648]  ffff880426908d00 0000000024119d80 0000000000000000 0000=
000000000000
[ 5547.001650] Call Trace:
[ 5547.001657]  [<ffffffffa0074d14>] ? btrfs_submit_bio_hook+0x84/0x1f0=
 [btrfs]
[ 5547.001659]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.001660]  [<ffffffff81560ed9>] ? sub_preempt_count+0x49/0x50
[ 5547.001662]  [<ffffffff8155d006>] ? _raw_spin_unlock_irqrestore+0x26=
/0x60
[ 5547.001663]  [<ffffffff8155b719>] schedule+0x29/0x70
[ 5547.001669]  [<ffffffffa007170f>] wait_current_trans.isra.17+0xbf/0x=
120 [btrfs]
[ 5547.001671]  [<ffffffff81073d20>] ? wake_up_atomic_t+0x30/0x30
[ 5547.001677]  [<ffffffffa0072cff>] start_transaction+0x37f/0x570 [btr=
fs]
[ 5547.001680]  [<ffffffff8112632e>] ? do_writepages+0x1e/0x40
[ 5547.001686]  [<ffffffffa0072f0b>] btrfs_start_transaction+0x1b/0x20 =
[btrfs]
[ 5547.001693]  [<ffffffffa0082e3f>] btrfs_sync_file+0x17f/0x2e0 [btrfs=
]
[ 5547.001694]  [<ffffffff811abb96>] do_fsync+0x56/0x80
[ 5547.001696]  [<ffffffff811abe43>] SyS_fdatasync+0x13/0x20
[ 5547.001697]  [<ffffffff81564e5f>] tracesys+0xdd/0xe2
[ 5547.001701] virtuoso-t      D ffff88000310b0c0     0   617    609 0x=
00000000
[ 5547.001702]  ffff8803f4867c20 0000000000000002 ffff8803f4867fd8 0000=
000000012e40
[ 5547.001704]  ffff8803f4867fd8 0000000000012e40 ffff88000310b0c0 ffff=
ffff813ce4af
[ 5547.001705]  ffffffff81860520 ffff8802d8ad8a00 ffff8803f4867ba0 ffff=
ffff81231a0e
[ 5547.001707] Call Trace:
[ 5547.001709]  [<ffffffff813ce4af>] ? scsi_pool_alloc_command+0x3f/0x8=
0
[ 5547.001712]  [<ffffffff81231a0e>] ? __blk_segment_map_sg+0x4e/0x120
[ 5547.001713]  [<ffffffff81231b6b>] ? blk_rq_map_sg+0x8b/0x1f0
[ 5547.001716]  [<ffffffff812481da>] ? cfq_dispatch_requests+0xba/0xc40=

[ 5547.001718]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.001721]  [<ffffffff81119d70>] ? filemap_fdatawait+0x30/0x30
[ 5547.001722]  [<ffffffff8155b719>] schedule+0x29/0x70
[ 5547.001723]  [<ffffffff8155b9bf>] io_schedule+0x8f/0xe0
[ 5547.001725]  [<ffffffff81119d7e>] sleep_on_page+0xe/0x20
[ 5547.001727]  [<ffffffff81559142>] __wait_on_bit+0x62/0x90
[ 5547.001728]  [<ffffffff81119b2f>] wait_on_page_bit+0x7f/0x90
[ 5547.001730]  [<ffffffff81073da0>] ? wake_atomic_t_function+0x40/0x40=

[ 5547.001732]  [<ffffffff81119cbb>] filemap_fdatawait_range+0x11b/0x1a=
0
[ 5547.001734]  [<ffffffff8155cc86>] ? _raw_spin_unlock+0x16/0x40
[ 5547.001740]  [<ffffffffa0071d47>] btrfs_wait_marked_extents+0x87/0xe=
0 [btrfs]
[ 5547.001747]  [<ffffffffa00ae328>] btrfs_sync_log+0x4e8/0x690 [btrfs]=

[ 5547.001754]  [<ffffffffa0082f47>] btrfs_sync_file+0x287/0x2e0 [btrfs=
]
[ 5547.001756]  [<ffffffff811abb96>] do_fsync+0x56/0x80
[ 5547.001758]  [<ffffffff811abe20>] SyS_fsync+0x10/0x20
[ 5547.001759]  [<ffffffff81564e5f>] tracesys+0xdd/0xe2
[ 5547.001761] pool            D ffff88040db1c100     0   657    477 0x=
00000000
[ 5547.001763]  ffff8803ee809ba0 0000000000000002 ffff8803ee809fd8 0000=
000000012e40
[ 5547.001764]  ffff8803ee809fd8 0000000000012e40 ffff88040db1c100 0000=
000000000004
[ 5547.001766]  ffff8803ee809ae8 ffffffff8155cc86 ffff8803ee809bd0 ffff=
ffffa005ada4
[ 5547.001767] Call Trace:
[ 5547.001769]  [<ffffffff8155cc86>] ? _raw_spin_unlock+0x16/0x40
[ 5547.001775]  [<ffffffffa005ada4>] ? reserve_metadata_bytes+0x184/0x9=
30 [btrfs]
[ 5547.001776]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.001778]  [<ffffffff81560ed9>] ? sub_preempt_count+0x49/0x50
[ 5547.001779]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.001781]  [<ffffffff81560ed9>] ? sub_preempt_count+0x49/0x50
[ 5547.001783]  [<ffffffff8155d006>] ? _raw_spin_unlock_irqrestore+0x26=
/0x60
[ 5547.001784]  [<ffffffff8155b719>] schedule+0x29/0x70
[ 5547.001790]  [<ffffffffa007170f>] wait_current_trans.isra.17+0xbf/0x=
120 [btrfs]
[ 5547.001792]  [<ffffffff81073d20>] ? wake_up_atomic_t+0x30/0x30
[ 5547.001798]  [<ffffffffa0072cff>] start_transaction+0x37f/0x570 [btr=
fs]
[ 5547.001804]  [<ffffffffa0072f0b>] btrfs_start_transaction+0x1b/0x20 =
[btrfs]
[ 5547.001810]  [<ffffffffa0080b8b>] btrfs_create+0x3b/0x200 [btrfs]
[ 5547.001813]  [<ffffffff8120ce3c>] ? security_inode_permission+0x1c/0=
x30
[ 5547.001815]  [<ffffffff81189634>] vfs_create+0xb4/0x120
[ 5547.001817]  [<ffffffff8118bcd4>] do_last+0x904/0xea0
[ 5547.001818]  [<ffffffff81188cc0>] ? link_path_walk+0x70/0x930
[ 5547.001820]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.001822]  [<ffffffff8120d0e6>] ? security_file_alloc+0x16/0x20
[ 5547.001824]  [<ffffffff8118c32b>] path_openat+0xbb/0x6b0
[ 5547.001827]  [<ffffffff810dd64f>] ? __acct_update_integrals+0x7f/0x1=
00
[ 5547.001829]  [<ffffffff81085782>] ? account_system_time+0xa2/0x180
[ 5547.001831]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.001833]  [<ffffffff8118d7ca>] do_filp_open+0x3a/0x90
[ 5547.001834]  [<ffffffff8155cc86>] ? _raw_spin_unlock+0x16/0x40
[ 5547.001836]  [<ffffffff81199e47>] ? __alloc_fd+0xa7/0x130
[ 5547.001839]  [<ffffffff8117ce89>] do_sys_open+0x129/0x220
[ 5547.001842]  [<ffffffff8100e795>] ? syscall_trace_enter+0x135/0x230
[ 5547.001844]  [<ffffffff8117cf9e>] SyS_open+0x1e/0x20
[ 5547.001845]  [<ffffffff81564e5f>] tracesys+0xdd/0xe2
[ 5547.001850] akregator       D ffff8803ed1d4100     0   875      1 0x=
00000000
[ 5547.001851]  ffff8803c7f1bba0 0000000000000002 ffff8803c7f1bfd8 0000=
000000012e40
[ 5547.001853]  ffff8803c7f1bfd8 0000000000012e40 ffff8803ed1d4100 0000=
000000000004
[ 5547.001854]  ffff8803c7f1bae8 ffffffff8155cc86 ffff8803c7f1bbd0 ffff=
ffffa005ada4
[ 5547.001856] Call Trace:
[ 5547.001858]  [<ffffffff8155cc86>] ? _raw_spin_unlock+0x16/0x40
[ 5547.001863]  [<ffffffffa005ada4>] ? reserve_metadata_bytes+0x184/0x9=
30 [btrfs]
[ 5547.001865]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.001866]  [<ffffffff81560ed9>] ? sub_preempt_count+0x49/0x50
[ 5547.001868]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.001870]  [<ffffffff81560ed9>] ? sub_preempt_count+0x49/0x50
[ 5547.001871]  [<ffffffff8155d006>] ? _raw_spin_unlock_irqrestore+0x26=
/0x60
[ 5547.001873]  [<ffffffff8155b719>] schedule+0x29/0x70
[ 5547.001879]  [<ffffffffa007170f>] wait_current_trans.isra.17+0xbf/0x=
120 [btrfs]
[ 5547.001881]  [<ffffffff81073d20>] ? wake_up_atomic_t+0x30/0x30
[ 5547.001886]  [<ffffffffa0072cff>] start_transaction+0x37f/0x570 [btr=
fs]
[ 5547.001888]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.001894]  [<ffffffffa0072f0b>] btrfs_start_transaction+0x1b/0x20 =
[btrfs]
[ 5547.001900]  [<ffffffffa0080b8b>] btrfs_create+0x3b/0x200 [btrfs]
[ 5547.001902]  [<ffffffff8120ce3c>] ? security_inode_permission+0x1c/0=
x30
[ 5547.001904]  [<ffffffff81189634>] vfs_create+0xb4/0x120
[ 5547.001906]  [<ffffffff8118bcd4>] do_last+0x904/0xea0
[ 5547.001907]  [<ffffffff81188cc0>] ? link_path_walk+0x70/0x930
[ 5547.001909]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.001911]  [<ffffffff8120d0e6>] ? security_file_alloc+0x16/0x20
[ 5547.001912]  [<ffffffff8118c32b>] path_openat+0xbb/0x6b0
[ 5547.001914]  [<ffffffff810dd64f>] ? __acct_update_integrals+0x7f/0x1=
00
[ 5547.001916]  [<ffffffff81085782>] ? account_system_time+0xa2/0x180
[ 5547.001918]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.001920]  [<ffffffff8118d7ca>] do_filp_open+0x3a/0x90
[ 5547.001921]  [<ffffffff8155cc86>] ? _raw_spin_unlock+0x16/0x40
[ 5547.001923]  [<ffffffff81199e47>] ? __alloc_fd+0xa7/0x130
[ 5547.001925]  [<ffffffff8117ce89>] do_sys_open+0x129/0x220
[ 5547.001927]  [<ffffffff8100e795>] ? syscall_trace_enter+0x135/0x230
[ 5547.001928]  [<ffffffff8117cf9e>] SyS_open+0x1e/0x20
[ 5547.001930]  [<ffffffff81564e5f>] tracesys+0xdd/0xe2
[ 5547.001931] mpegaudioparse3 D ffff880341d10820     0  5917      1 0x=
00000000
[ 5547.001933]  ffff88030f779ce0 0000000000000002 ffff88030f779fd8 0000=
000000012e40
[ 5547.001934]  ffff88030f779fd8 0000000000012e40 ffff880341d10820 ffff=
ffff81122a28
[ 5547.001936]  ffff88043e5ddc00 ffff880400000002 ffff88043e2138d0 0000=
000000000000
[ 5547.001938] Call Trace:
[ 5547.001939]  [<ffffffff81122a28>] ? __alloc_pages_nodemask+0x158/0xb=
00
[ 5547.001941]  [<ffffffff8102af55>] ? native_send_call_func_single_ipi=
+0x35/0x40
[ 5547.001943]  [<ffffffff810b31a8>] ? generic_exec_single+0x98/0xa0
[ 5547.001945]  [<ffffffff81086a18>] ? __enqueue_entity+0x78/0x80
[ 5547.001947]  [<ffffffff8108a837>] ? enqueue_entity+0x197/0x780
[ 5547.001948]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.001950]  [<ffffffff81119d90>] ? sleep_on_page+0x20/0x20
[ 5547.001951]  [<ffffffff8155b719>] schedule+0x29/0x70
[ 5547.001953]  [<ffffffff8155b9bf>] io_schedule+0x8f/0xe0
[ 5547.001954]  [<ffffffff81119d9e>] sleep_on_page_killable+0xe/0x40
[ 5547.001956]  [<ffffffff8155925d>] __wait_on_bit_lock+0x5d/0xc0
[ 5547.001958]  [<ffffffff81119f2a>] __lock_page_killable+0x6a/0x70
[ 5547.001960]  [<ffffffff81073da0>] ? wake_atomic_t_function+0x40/0x40=

[ 5547.001961]  [<ffffffff8111b9e5>] generic_file_aio_read+0x435/0x700
[ 5547.001963]  [<ffffffff8117d2ba>] do_sync_read+0x5a/0x90
[ 5547.001965]  [<ffffffff8117d85a>] vfs_read+0x9a/0x170
[ 5547.001967]  [<ffffffff8117e039>] SyS_read+0x49/0xa0
[ 5547.001968]  [<ffffffff81564e5f>] tracesys+0xdd/0xe2
[ 5547.001970] mozStorage #2   D ffff8803b7aa1860     0   920    477 0x=
00000000
[ 5547.001972]  ffff8803b1473d80 0000000000000002 ffff8803b1473fd8 0000=
000000012e40
[ 5547.001974]  ffff8803b1473fd8 0000000000012e40 ffff8803b7aa1860 0000=
000000000004
[ 5547.001975]  ffff8803b1473cc8 ffffffff8155cc86 ffff8803b1473db0 ffff=
ffffa005ada4
[ 5547.001977] Call Trace:
[ 5547.001978]  [<ffffffff8155cc86>] ? _raw_spin_unlock+0x16/0x40
[ 5547.001984]  [<ffffffffa005ada4>] ? reserve_metadata_bytes+0x184/0x9=
30 [btrfs]
[ 5547.001990]  [<ffffffffa0084729>] ? __btrfs_buffered_write+0x3d9/0x4=
90 [btrfs]
[ 5547.001992]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.001994]  [<ffffffff81560ed9>] ? sub_preempt_count+0x49/0x50
[ 5547.001995]  [<ffffffff8155d006>] ? _raw_spin_unlock_irqrestore+0x26=
/0x60
[ 5547.001997]  [<ffffffff8155b719>] schedule+0x29/0x70
[ 5547.002003]  [<ffffffffa007170f>] wait_current_trans.isra.17+0xbf/0x=
120 [btrfs]
[ 5547.002004]  [<ffffffff81073d20>] ? wake_up_atomic_t+0x30/0x30
[ 5547.002010]  [<ffffffffa0072cff>] start_transaction+0x37f/0x570 [btr=
fs]
[ 5547.002016]  [<ffffffffa0072f0b>] btrfs_start_transaction+0x1b/0x20 =
[btrfs]
[ 5547.002023]  [<ffffffffa007c8a1>] btrfs_setattr+0x101/0x290 [btrfs]
[ 5547.002025]  [<ffffffff810d675c>] ? rcu_eqs_enter+0x5c/0xa0
[ 5547.002027]  [<ffffffff81198a6c>] notify_change+0x1dc/0x360
[ 5547.002029]  [<ffffffff81560ed9>] ? sub_preempt_count+0x49/0x50
[ 5547.002030]  [<ffffffff8117bdcb>] do_truncate+0x6b/0xa0
[ 5547.002032]  [<ffffffff8117f8b9>] ? __sb_start_write+0x49/0x100
[ 5547.002033]  [<ffffffff8117c12b>] SyS_ftruncate+0x10b/0x160
[ 5547.002035]  [<ffffffff81564e5f>] tracesys+0xdd/0xe2
[ 5547.002036] Cache I/O       D ffff8803b7aa28a0     0   922    477 0x=
00000000
[ 5547.002038]  ffff8803b1495e18 0000000000000002 ffff8803b1495fd8 0000=
000000012e40
[ 5547.002039]  ffff8803b1495fd8 0000000000012e40 ffff8803b7aa28a0 ffff=
8803b1495e08
[ 5547.002041]  ffff8803b1495db0 ffffffff8111a25a ffff8803b1495e40 ffff=
8803b1495df0
[ 5547.002043] Call Trace:
[ 5547.002045]  [<ffffffff8111a25a>] ? find_get_pages_tag+0xea/0x180
[ 5547.002047]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.002048]  [<ffffffff81560ed9>] ? sub_preempt_count+0x49/0x50
[ 5547.002050]  [<ffffffff8155d006>] ? _raw_spin_unlock_irqrestore+0x26=
/0x60
[ 5547.002051]  [<ffffffff8155b719>] schedule+0x29/0x70
[ 5547.002057]  [<ffffffffa007170f>] wait_current_trans.isra.17+0xbf/0x=
120 [btrfs]
[ 5547.002059]  [<ffffffff81073d20>] ? wake_up_atomic_t+0x30/0x30
[ 5547.002065]  [<ffffffffa0072cff>] start_transaction+0x37f/0x570 [btr=
fs]
[ 5547.002071]  [<ffffffffa0072f0b>] btrfs_start_transaction+0x1b/0x20 =
[btrfs]
[ 5547.002077]  [<ffffffffa0082e3f>] btrfs_sync_file+0x17f/0x2e0 [btrfs=
]
[ 5547.002079]  [<ffffffff811abb96>] do_fsync+0x56/0x80
[ 5547.002080]  [<ffffffff811abe20>] SyS_fsync+0x10/0x20
[ 5547.002081]  [<ffffffff81564e5f>] tracesys+0xdd/0xe2
[ 5547.002083] mozStorage #6   D ffff8803c0cfa8a0     0   982    477 0x=
00000000
[ 5547.002085]  ffff8803a10f5ba0 0000000000000002 ffff8803a10f5fd8 0000=
000000012e40
[ 5547.002086]  ffff8803a10f5fd8 0000000000012e40 ffff8803c0cfa8a0 0000=
000000000004
[ 5547.002088]  ffff8803a10f5ae8 ffffffff8155cc86 ffff8803a10f5bd0 ffff=
ffffa005ada4
[ 5547.002089] Call Trace:
[ 5547.002091]  [<ffffffff8155cc86>] ? _raw_spin_unlock+0x16/0x40
[ 5547.002096]  [<ffffffffa005ada4>] ? reserve_metadata_bytes+0x184/0x9=
30 [btrfs]
[ 5547.002098]  [<ffffffff8102b067>] ? native_smp_send_reschedule+0x47/=
0x60
[ 5547.002100]  [<ffffffff8107f7bc>] ? resched_task+0x5c/0x60
[ 5547.002101]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.002103]  [<ffffffff81560ed9>] ? sub_preempt_count+0x49/0x50
[ 5547.002104]  [<ffffffff8155d006>] ? _raw_spin_unlock_irqrestore+0x26=
/0x60
[ 5547.002106]  [<ffffffff8155b719>] schedule+0x29/0x70
[ 5547.002112]  [<ffffffffa007170f>] wait_current_trans.isra.17+0xbf/0x=
120 [btrfs]
[ 5547.002113]  [<ffffffff81073d20>] ? wake_up_atomic_t+0x30/0x30
[ 5547.002119]  [<ffffffffa0072cff>] start_transaction+0x37f/0x570 [btr=
fs]
[ 5547.002125]  [<ffffffffa0072f0b>] btrfs_start_transaction+0x1b/0x20 =
[btrfs]
[ 5547.002131]  [<ffffffffa0080b8b>] btrfs_create+0x3b/0x200 [btrfs]
[ 5547.002133]  [<ffffffff8120ce3c>] ? security_inode_permission+0x1c/0=
x30
[ 5547.002134]  [<ffffffff81189634>] vfs_create+0xb4/0x120
[ 5547.002136]  [<ffffffff8118bcd4>] do_last+0x904/0xea0
[ 5547.002138]  [<ffffffff81188cc0>] ? link_path_walk+0x70/0x930
[ 5547.002139]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.002141]  [<ffffffff8120d0e6>] ? security_file_alloc+0x16/0x20
[ 5547.002143]  [<ffffffff8118c32b>] path_openat+0xbb/0x6b0
[ 5547.002145]  [<ffffffff810dd64f>] ? __acct_update_integrals+0x7f/0x1=
00
[ 5547.002147]  [<ffffffff81085782>] ? account_system_time+0xa2/0x180
[ 5547.002148]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.002150]  [<ffffffff8118d7ca>] do_filp_open+0x3a/0x90
[ 5547.002152]  [<ffffffff8155cc86>] ? _raw_spin_unlock+0x16/0x40
[ 5547.002153]  [<ffffffff81199e47>] ? __alloc_fd+0xa7/0x130
[ 5547.002155]  [<ffffffff8117ce89>] do_sys_open+0x129/0x220
[ 5547.002157]  [<ffffffff8100e795>] ? syscall_trace_enter+0x135/0x230
[ 5547.002159]  [<ffffffff8117cf9e>] SyS_open+0x1e/0x20
[ 5547.002160]  [<ffffffff81564e5f>] tracesys+0xdd/0xe2
[ 5547.002164] rsync           D ffff8802dcde0820     0  5803   5802 0x=
00000000
[ 5547.002165]  ffff8802daeb1a90 0000000000000002 ffff8802daeb1fd8 0000=
000000012e40
[ 5547.002167]  ffff8802daeb1fd8 0000000000012e40 ffff8802dcde0820 ffff=
880100000002
[ 5547.002169]  ffff8802daeb19e0 ffffffff81080edd ffff880308b337e0 0000=
000000000000
[ 5547.002170] Call Trace:
[ 5547.002172]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.002173]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.002175]  [<ffffffff81560ed9>] ? sub_preempt_count+0x49/0x50
[ 5547.002177]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.002178]  [<ffffffff81560e8d>] ? add_preempt_count+0x3d/0x40
[ 5547.002180]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.002181]  [<ffffffff8155b719>] schedule+0x29/0x70
[ 5547.002182]  [<ffffffff81558f6a>] schedule_timeout+0x11a/0x230
[ 5547.002185]  [<ffffffff8105e0c0>] ? detach_if_pending+0x120/0x120
[ 5547.002187]  [<ffffffff810a5078>] ? ktime_get_ts+0x48/0xe0
[ 5547.002189]  [<ffffffff8155bd2b>] io_schedule_timeout+0x9b/0xf0
[ 5547.002191]  [<ffffffff811259a9>] balance_dirty_pages_ratelimited+0x=
3d9/0xa10
[ 5547.002198]  [<ffffffffa0c9ad84>] ? ext4_dirty_inode+0x54/0x60 [ext4=
]
[ 5547.002200]  [<ffffffff8111a8c8>] generic_file_buffered_write+0x1b8/=
0x290
[ 5547.002202]  [<ffffffff8111bfd9>] __generic_file_aio_write+0x1a9/0x3=
b0
[ 5547.002203]  [<ffffffff8111c238>] generic_file_aio_write+0x58/0xa0
[ 5547.002208]  [<ffffffffa0c8ef79>] ext4_file_write+0x99/0x3e0 [ext4]
[ 5547.002210]  [<ffffffff810ddaac>] ? acct_account_cputime+0x1c/0x20
[ 5547.002212]  [<ffffffff81085782>] ? account_system_time+0xa2/0x180
[ 5547.002213]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.002215]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.002216]  [<ffffffff8117d34a>] do_sync_write+0x5a/0x90
[ 5547.002218]  [<ffffffff8117d9ed>] vfs_write+0xbd/0x1e0
[ 5547.002220]  [<ffffffff8117e0d9>] SyS_write+0x49/0xa0
[ 5547.002221]  [<ffffffff81564e5f>] tracesys+0xdd/0xe2
[ 5547.002223] ktorrent        D ffff8802e7680820     0  5806      1 0x=
00000000
[ 5547.002224]  ffff8802daf7fba0 0000000000000002 ffff8802daf7ffd8 0000=
000000012e40
[ 5547.002226]  ffff8802daf7ffd8 0000000000012e40 ffff8802e7680820 0000=
000000000004
[ 5547.002227]  ffff8802daf7fae8 ffffffff8155cc86 ffff8802daf7fbd0 ffff=
ffffa005ada4
[ 5547.002229] Call Trace:
[ 5547.002230]  [<ffffffff8155cc86>] ? _raw_spin_unlock+0x16/0x40
[ 5547.002236]  [<ffffffffa005ada4>] ? reserve_metadata_bytes+0x184/0x9=
30 [btrfs]
[ 5547.002241]  [<ffffffffa004ae49>] ? btrfs_set_path_blocking+0x39/0x8=
0 [btrfs]
[ 5547.002246]  [<ffffffffa004fe78>] ? btrfs_search_slot+0x498/0x970 [b=
trfs]
[ 5547.002247]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.002249]  [<ffffffff81560ed9>] ? sub_preempt_count+0x49/0x50
[ 5547.002251]  [<ffffffff8155d006>] ? _raw_spin_unlock_irqrestore+0x26=
/0x60
[ 5547.002252]  [<ffffffff8155b719>] schedule+0x29/0x70
[ 5547.002258]  [<ffffffffa007170f>] wait_current_trans.isra.17+0xbf/0x=
120 [btrfs]
[ 5547.002260]  [<ffffffff81073d20>] ? wake_up_atomic_t+0x30/0x30
[ 5547.002266]  [<ffffffffa0072cff>] start_transaction+0x37f/0x570 [btr=
fs]
[ 5547.002268]  [<ffffffff81560ed9>] ? sub_preempt_count+0x49/0x50
[ 5547.002273]  [<ffffffffa0072f0b>] btrfs_start_transaction+0x1b/0x20 =
[btrfs]
[ 5547.002280]  [<ffffffffa0080b8b>] btrfs_create+0x3b/0x200 [btrfs]
[ 5547.002281]  [<ffffffff8120ce3c>] ? security_inode_permission+0x1c/0=
x30
[ 5547.002283]  [<ffffffff81189634>] vfs_create+0xb4/0x120
[ 5547.002285]  [<ffffffff8118bcd4>] do_last+0x904/0xea0
[ 5547.002287]  [<ffffffff81188cc0>] ? link_path_walk+0x70/0x930
[ 5547.002288]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.002290]  [<ffffffff8120d0e6>] ? security_file_alloc+0x16/0x20
[ 5547.002292]  [<ffffffff8118c32b>] path_openat+0xbb/0x6b0
[ 5547.002293]  [<ffffffff810dd64f>] ? __acct_update_integrals+0x7f/0x1=
00
[ 5547.002295]  [<ffffffff81085782>] ? account_system_time+0xa2/0x180
[ 5547.002297]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.002299]  [<ffffffff8118d7ca>] do_filp_open+0x3a/0x90
[ 5547.002300]  [<ffffffff8155cc86>] ? _raw_spin_unlock+0x16/0x40
[ 5547.002302]  [<ffffffff81199e47>] ? __alloc_fd+0xa7/0x130
[ 5547.002304]  [<ffffffff8117ce89>] do_sys_open+0x129/0x220
[ 5547.002306]  [<ffffffff8100e795>] ? syscall_trace_enter+0x135/0x230
[ 5547.002307]  [<ffffffff8117cf9e>] SyS_open+0x1e/0x20
[ 5547.002309]  [<ffffffff81564e5f>] tracesys+0xdd/0xe2
[ 5547.002311] kworker/u16:0   D ffff88035c5ac920     0  6043      2 0x=
00000000
[ 5547.002313] Workqueue: writeback bdi_writeback_workfn (flush-8:32)
[ 5547.002315]  ffff88036c9cb898 0000000000000002 ffff88036c9cbfd8 0000=
000000012e40
[ 5547.002316]  ffff88036c9cbfd8 0000000000012e40 ffff88035c5ac920 ffff=
8804281de048
[ 5547.002318]  ffff88036c9cb7e8 ffffffff81080edd 0000000000000001 ffff=
88036c9cb800
[ 5547.002319] Call Trace:
[ 5547.002321]  [<ffffffff81080edd>] ? get_parent_ip+0xd/0x50
[ 5547.002323]  [<ffffffff81560ed9>] ? sub_preempt_count+0x49/0x50
[ 5547.002324]  [<ffffffff8155cc86>] ? _raw_spin_unlock+0x16/0x40
[ 5547.002326]  [<ffffffff8122b47b>] ? queue_unplugged+0x3b/0xe0
[ 5547.002328]  [<ffffffff8155b719>] schedule+0x29/0x70
[ 5547.002329]  [<ffffffff8155b9bf>] io_schedule+0x8f/0xe0
[ 5547.002331]  [<ffffffff8122b8aa>] get_request+0x1aa/0x780
[ 5547.002332]  [<ffffffff8123099e>] ? ioc_lookup_icq+0x4e/0x80
[ 5547.002334]  [<ffffffff81073d20>] ? wake_up_atomic_t+0x30/0x30
[ 5547.002336]  [<ffffffff8122db58>] blk_queue_bio+0x78/0x3e0
[ 5547.002337]  [<ffffffff8122c5c2>] generic_make_request+0xc2/0x110
[ 5547.002338]  [<ffffffff8122c683>] submit_bio+0x73/0x160
[ 5547.002344]  [<ffffffffa0c9bae5>] ext4_io_submit+0x25/0x50 [ext4]
[ 5547.002348]  [<ffffffffa0c981d3>] ext4_writepages+0x823/0xe00 [ext4]=

[ 5547.002350]  [<ffffffff8112632e>] do_writepages+0x1e/0x40
[ 5547.002352]  [<ffffffff811a6340>] __writeback_single_inode+0x40/0x33=
0
[ 5547.002353]  [<ffffffff811a7392>] writeback_sb_inodes+0x262/0x450
[ 5547.002355]  [<ffffffff811a761f>] __writeback_inodes_wb+0x9f/0xd0
[ 5547.002357]  [<ffffffff811a797b>] wb_writeback+0x32b/0x360
[ 5547.002358]  [<ffffffff811a8111>] bdi_writeback_workfn+0x221/0x510
[ 5547.002361]  [<ffffffff8106b917>] process_one_work+0x167/0x450
[ 5547.002362]  [<ffffffff8106c6a1>] worker_thread+0x121/0x3a0
[ 5547.002364]  [<ffffffff81560ed9>] ? sub_preempt_count+0x49/0x50
[ 5547.002366]  [<ffffffff8106c580>] ? manage_workers.isra.25+0x2a0/0x2=
a0
[ 5547.002367]  [<ffffffff81072e70>] kthread+0xc0/0xd0
[ 5547.002369]  [<ffffffff81072db0>] ? kthread_create_on_node+0x120/0x1=
20
[ 5547.002371]  [<ffffffff81564bac>] ret_from_fork+0x7c/0xb0
[ 5547.002372]  [<ffffffff81072db0>] ? kthread_create_on_node+0x120/0x1=
20



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
