Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3056B026C
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 11:27:33 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id m203so9425806wma.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 08:27:33 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id u3si7640514wjk.221.2016.12.16.08.27.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 08:27:31 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id a20so6403532wme.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 08:27:31 -0800 (PST)
Message-ID: <1481905648.4304.12.camel@gmail.com>
Subject: Re: [PATCH 0/9 v2] scope GFP_NOFS api
From: Mike Galbraith <umgwanakikbuti@gmail.com>
Date: Fri, 16 Dec 2016 17:27:28 +0100
In-Reply-To: <20161216153502.GP13940@dhcp22.suse.cz>
References: <20161215140715.12732-1-mhocko@kernel.org>
	 <1481900758.31172.20.camel@gmail.com>
	 <20161216153502.GP13940@dhcp22.suse.cz>
Content-Type: text/plain; charset="us-ascii"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>

On Fri, 2016-12-16 at 16:35 +0100, Michal Hocko wrote:
> On Fri 16-12-16 16:05:58, Mike Galbraith wrote:
> > On Thu, 2016-12-15 at 15:07 +0100, Michal Hocko wrote:
> > > Hi,
> > > I have posted the previous version here [1]. Since then I have added a
> > > support to suppress reclaim lockdep warnings (__GFP_NOLOCKDEP) to allow
> > > removing GFP_NOFS usage motivated by the lockdep false positives. On top
> > > of that I've tried to convert few KM_NOFS usages to use the new flag in
> > > the xfs code base. This would need a review from somebody familiar with
> > > xfs of course.
> > 
> > The wild ass guess below prevents the xfs explosion below when running
> > ltp zram tests.
> 
> Yes this looks correct. Thanks for noticing. I will fold it to the
> patch2. Thanks for testing Mike!

I had ulterior motives, was hoping you might have made the irksome RT
gripe below just _go away_, as staring at it ain't working out ;-)

[ 1441.309006] =========================================================
[ 1441.309006] [ INFO: possible irq lock inversion dependency detected ]
[ 1441.309007] 4.10.0-rt9-rt #11 Tainted: G            E  
[ 1441.309007] ---------------------------------------------------------
[ 1441.309008] kswapd0/165 just changed the state of lock:
[ 1441.309009]  (&journal->j_state_lock){+.+.-.}, at: [<ffffffffa00a6d60>] jbd2_complete_transaction+0x20/0x90 [jbd2]
[ 1441.309017] but this lock took another, RECLAIM_FS-unsafe lock in the past:
[ 1441.309017]  (&tb->tb6_lock){+.+.+.}
[ 1441.309018] and interrupts could create inverse lock ordering between them.
[ 1441.309018] other info that might help us debug this:
[ 1441.309018] Chain exists of: &journal->j_state_lock --> &journal->j_list_lock --> &tb->tb6_lock
[ 1441.309019]  Possible interrupt unsafe locking scenario:
[ 1441.309019]        CPU0                    CPU1
[ 1441.309019]        ----                    ----
[ 1441.309019]   lock(&tb->tb6_lock);
[ 1441.309020]                                local_irq_disable();
[ 1441.309020]                                lock(&journal->j_state_lock);
[ 1441.309020]                                lock(&journal->j_list_lock);
[ 1441.309021]   <Interrupt>
[ 1441.309021]     lock(&journal->j_state_lock);
[ 1441.309021] *** DEADLOCK ***
[ 1441.309022] 2 locks held by kswapd0/165:
[ 1441.309022]  #0:  (shrinker_rwsem){+.+...}, at: [<ffffffff811efa2a>] shrink_slab+0x7a/0x6c0
[ 1441.309027]  #1:  (&type->s_umount_key#29){+.+.+.}, at: [<ffffffff8126f20b>] trylock_super+0x1b/0x50
[ 1441.309030] the shortest dependencies between 2nd lock and 1st lock:
[ 1441.309031]    -> (&tb->tb6_lock){+.+.+.} ops: 271 {
[ 1441.309032]       HARDIRQ-ON-W at:
[ 1441.309035] [<ffffffff810e11b8>] __lock_acquire+0x938/0x1770
[ 1441.309036] [<ffffffff810e2564>] lock_acquire+0xd4/0x270
[ 1441.309039] [<ffffffff8174d291>] rt_write_lock+0x31/0x40
[ 1441.309041] [<ffffffff816e66e3>] __ip6_ins_rt+0x33/0x70
[ 1441.309043] [<ffffffff816eccd1>] ip6_route_add+0x81/0xd0
[ 1441.309044] [<ffffffff816dbf33>] addrconf_prefix_route+0x133/0x1d0
[ 1441.309046] [<ffffffff816e16eb>] inet6_addr_add+0x1eb/0x250
[ 1441.309047] [<ffffffff816e294b>] inet6_rtm_newaddr+0x33b/0x410
[ 1441.309049] [<ffffffff81613c35>] rtnetlink_rcv_msg+0x95/0x220
[ 1441.309051] [<ffffffff8163a477>] netlink_rcv_skb+0xa7/0xc0
[ 1441.309053] [<ffffffff8160de88>] rtnetlink_rcv+0x28/0x30
[ 1441.309054] [<ffffffff81639e53>] netlink_unicast+0x143/0x1f0
[ 1441.309055] [<ffffffff8163a222>] netlink_sendmsg+0x322/0x3a0
[ 1441.309057] [<ffffffff815d5c48>] sock_sendmsg+0x38/0x50
[ 1441.309058] [<ffffffff815d60a6>] SYSC_sendto+0xf6/0x170
[ 1441.309060] [<ffffffff815d6f6e>] SyS_sendto+0xe/0x10
[ 1441.309061] [<ffffffff8174d545>] entry_SYSCALL_64_fastpath+0x23/0xc6
[ 1441.309061]       SOFTIRQ-ON-W at:
[ 1441.309063] [<ffffffff810e0b03>] __lock_acquire+0x283/0x1770
[ 1441.309064] [<ffffffff810e2564>] lock_acquire+0xd4/0x270
[ 1441.309064] [<ffffffff8174d291>] rt_write_lock+0x31/0x40
[ 1441.309065] [<ffffffff816e66e3>] __ip6_ins_rt+0x33/0x70
[ 1441.309067] [<ffffffff816eccd1>] ip6_route_add+0x81/0xd0
[ 1441.309067] [<ffffffff816dbf33>] addrconf_prefix_route+0x133/0x1d0
[ 1441.309068] [<ffffffff816e16eb>] inet6_addr_add+0x1eb/0x250
[ 1441.309069] [<ffffffff816e294b>] inet6_rtm_newaddr+0x33b/0x410
[ 1441.309071] [<ffffffff81613c35>] rtnetlink_rcv_msg+0x95/0x220
[ 1441.309073] [<ffffffff8163a477>] netlink_rcv_skb+0xa7/0xc0
[ 1441.309074] [<ffffffff8160de88>] rtnetlink_rcv+0x28/0x30
[ 1441.309075] [<ffffffff81639e53>] netlink_unicast+0x143/0x1f0
[ 1441.309077] [<ffffffff8163a222>] netlink_sendmsg+0x322/0x3a0
[ 1441.309078] [<ffffffff815d5c48>] sock_sendmsg+0x38/0x50
[ 1441.309079] [<ffffffff815d60a6>] SYSC_sendto+0xf6/0x170
[ 1441.309080] [<ffffffff815d6f6e>] SyS_sendto+0xe/0x10
[ 1441.309081] [<ffffffff8174d545>] entry_SYSCALL_64_fastpath+0x23/0xc6
[ 1441.309081]       RECLAIM_FS-ON-W at:
[ 1441.309082] [<ffffffff810e0316>] mark_held_locks+0x66/0x90
[ 1441.309084] [<ffffffff810e34a8>] lockdep_trace_alloc+0xd8/0x120
[ 1441.309085] [<ffffffff81246df6>] kmem_cache_alloc_node+0x36/0x310
[ 1441.309086] [<ffffffff815dfd4e>] __alloc_skb+0x4e/0x280
[ 1441.309088] [<ffffffff816ee6ac>] inet6_rt_notify+0x5c/0x130
[ 1441.309089] [<ffffffff816f101b>] fib6_add+0x56b/0xa30
[ 1441.309090] [<ffffffff816e66f8>] __ip6_ins_rt+0x48/0x70
[ 1441.309091] [<ffffffff816eccd1>] ip6_route_add+0x81/0xd0
[ 1441.309092] [<ffffffff816dbf33>] addrconf_prefix_route+0x133/0x1d0
[ 1441.309093] [<ffffffff816e16eb>] inet6_addr_add+0x1eb/0x250
[ 1441.309094] [<ffffffff816e294b>] inet6_rtm_newaddr+0x33b/0x410
[ 1441.309096] [<ffffffff81613c35>] rtnetlink_rcv_msg+0x95/0x220
[ 1441.309097] [<ffffffff8163a477>] netlink_rcv_skb+0xa7/0xc0
[ 1441.309098] [<ffffffff8160de88>] rtnetlink_rcv+0x28/0x30
[ 1441.309099] [<ffffffff81639e53>] netlink_unicast+0x143/0x1f0
[ 1441.309100] [<ffffffff8163a222>] netlink_sendmsg+0x322/0x3a0
[ 1441.309102] [<ffffffff815d5c48>] sock_sendmsg+0x38/0x50
[ 1441.309103] [<ffffffff815d60a6>] SYSC_sendto+0xf6/0x170
[ 1441.309104] [<ffffffff815d6f6e>] SyS_sendto+0xe/0x10
[ 1441.309105] [<ffffffff8174d545>] entry_SYSCALL_64_fastpath+0x23/0xc6
[ 1441.309105]       INITIAL USE at:
[ 1441.309106] [<ffffffff810e0b4e>] __lock_acquire+0x2ce/0x1770
[ 1441.309107] [<ffffffff810e2564>] lock_acquire+0xd4/0x270
[ 1441.309108] [<ffffffff8174d291>] rt_write_lock+0x31/0x40
[ 1441.309109] [<ffffffff816e66e3>] __ip6_ins_rt+0x33/0x70
[ 1441.309110] [<ffffffff816eccd1>] ip6_route_add+0x81/0xd0
[ 1441.309111] [<ffffffff816dbf33>] addrconf_prefix_route+0x133/0x1d0
[ 1441.309112] [<ffffffff816e16eb>] inet6_addr_add+0x1eb/0x250
[ 1441.309113] [<ffffffff816e294b>] inet6_rtm_newaddr+0x33b/0x410
[ 1441.309115] [<ffffffff81613c35>] rtnetlink_rcv_msg+0x95/0x220
[ 1441.309116] [<ffffffff8163a477>] netlink_rcv_skb+0xa7/0xc0
[ 1441.309117] [<ffffffff8160de88>] rtnetlink_rcv+0x28/0x30
[ 1441.309118] [<ffffffff81639e53>] netlink_unicast+0x143/0x1f0
[ 1441.309119] [<ffffffff8163a222>] netlink_sendmsg+0x322/0x3a0
[ 1441.309120] [<ffffffff815d5c48>] sock_sendmsg+0x38/0x50
[ 1441.309121] [<ffffffff815d60a6>] SYSC_sendto+0xf6/0x170
[ 1441.309122] [<ffffffff815d6f6e>] SyS_sendto+0xe/0x10
[ 1441.309123] [<ffffffff8174d545>] entry_SYSCALL_64_fastpath+0x23/0xc6
[ 1441.309123]     }
[ 1441.309125]     ... key      at: [<ffffffff82dd96e0>] __key.59908+0x0/0x8
[ 1441.309125]     ... acquired at:
[ 1441.309126] [<ffffffff810e2564>] lock_acquire+0xd4/0x270
[ 1441.309127] [<ffffffff8174d307>] rt_read_lock+0x47/0x60
[ 1441.309128] [<ffffffff816ea541>] ip6_pol_route+0x61/0xa60
[ 1441.309130] [<ffffffff816eaf5a>] ip6_pol_route_input+0x1a/0x20
[ 1441.309131] [<ffffffff81718f21>] fib6_rule_action+0xa1/0x1e0
[ 1441.309133] [<ffffffff81621e53>] fib_rules_lookup+0x153/0x2e0
[ 1441.309134] [<ffffffff81719219>] fib6_rule_lookup+0x59/0xc0
[ 1441.309135] [<ffffffff816e6a3e>] ip6_route_input_lookup+0x4e/0x60
[ 1441.309136] [<ffffffff816ec59d>] ip6_route_input+0xdd/0x1a0
[ 1441.309137] [<ffffffff816d87d0>] ip6_rcv_finish+0x60/0x200
[ 1441.309139] [<ffffffffa09e00b0>] ip_sabotage_in+0x30/0x40 [br_netfilter]
[ 1441.309141] [<ffffffff8163c7ac>] nf_hook_slow+0x2c/0xf0
[ 1441.309142] [<ffffffff816d998a>] ipv6_rcv+0x72a/0x980
[ 1441.309143] [<ffffffff815f81ef>] __netif_receive_skb_core+0x38f/0xd20
[ 1441.309144] [<ffffffff815f8b98>] __netif_receive_skb+0x18/0x60
[ 1441.309145] [<ffffffff815fa4c1>] netif_receive_skb_internal+0x61/0x1d0
[ 1441.309147] [<ffffffff815fa668>] netif_receive_skb+0x38/0x180
[ 1441.309151] [<ffffffffa09b77e5>] br_pass_frame_up+0xd5/0x2c0 [bridge]
[ 1441.309154] [<ffffffffa09b7d66>] br_handle_frame_finish+0x256/0x5c0 [bridge]
[ 1441.309156] [<ffffffffa09e159c>] br_nf_hook_thresh+0xac/0x220 [br_netfilter]
[ 1441.309157] [<ffffffffa09e2ee3>] br_nf_pre_routing_finish_ipv6+0x1c3/0x340 [br_netfilter]
[ 1441.309158] [<ffffffffa09e349d>] br_nf_pre_routing_ipv6+0xdd/0x27a [br_netfilter]
[ 1441.309159] [<ffffffffa09e2942>] br_nf_pre_routing+0x1b2/0x540 [br_netfilter]
[ 1441.309160] [<ffffffff8163c7ac>] nf_hook_slow+0x2c/0xf0
[ 1441.309163] [<ffffffffa09b82f7>] br_handle_frame+0x227/0x5b0 [bridge]
[ 1441.309164] [<ffffffff815f8036>] __netif_receive_skb_core+0x1d6/0xd20
[ 1441.309165] [<ffffffff815f8b98>] __netif_receive_skb+0x18/0x60
[ 1441.309166] [<ffffffff815fa4c1>] netif_receive_skb_internal+0x61/0x1d0
[ 1441.309167] [<ffffffff815fbca2>] napi_gro_receive+0x192/0x250
[ 1441.309171] [<ffffffffa03f2163>] rtl8169_poll+0x183/0x6a0 [r8169]
[ 1441.309172] [<ffffffff815faea0>] net_rx_action+0x3b0/0x700
[ 1441.309173] [<ffffffff810841a5>] do_current_softirqs+0x285/0x680
[ 1441.309174] [<ffffffff81084607>] __local_bh_enable+0x67/0x80
[ 1441.309177] [<ffffffff810f7d81>] irq_forced_thread_fn+0x41/0x60
[ 1441.309178] [<ffffffff810f832f>] irq_thread+0x13f/0x1e0
[ 1441.309179] [<ffffffff810a5ecc>] kthread+0x10c/0x140
[ 1441.309180] [<ffffffff8174d7da>] ret_from_fork+0x2a/0x40
[ 1441.309181]   -> (&per_cpu(local_softirq_locks[i], __cpu).lock){+.+...} ops: 3582145 {
[ 1441.309182]      HARDIRQ-ON-W at:
[ 1441.309183] [<ffffffff810e11b8>] __lock_acquire+0x938/0x1770
[ 1441.309184] [<ffffffff810e2564>] lock_acquire+0xd4/0x270
[ 1441.309185] [<ffffffff8174cdea>] rt_spin_lock__no_mg+0x5a/0x70
[ 1441.309186] [<ffffffff81084094>] do_current_softirqs+0x174/0x680
[ 1441.309187] [<ffffffff81084607>] __local_bh_enable+0x67/0x80
[ 1441.309188] [<ffffffff8113c631>] cgroup_idr_alloc.constprop.41+0x61/0x80
[ 1441.309190] [<ffffffff811d4d5b>] cgroup_setup_root+0x65/0x28f
[ 1441.309191] [<ffffffff81d9ef88>] cgroup_init+0xf7/0x3e5
[ 1441.309193] [<ffffffff81d770d1>] start_kernel+0x43f/0x484
[ 1441.309194] [<ffffffff81d76599>] x86_64_start_reservations+0x2a/0x2c
[ 1441.309195] [<ffffffff81d766d8>] x86_64_start_kernel+0x13d/0x14c
[ 1441.309196] [<ffffffff810001b5>] start_cpu+0x5/0x14
[ 1441.309196]      SOFTIRQ-ON-W at:
[ 1441.309197] [<ffffffff810e0b03>] __lock_acquire+0x283/0x1770
[ 1441.309198] [<ffffffff810e2564>] lock_acquire+0xd4/0x270
[ 1441.309199] [<ffffffff8174cdea>] rt_spin_lock__no_mg+0x5a/0x70
[ 1441.309200] [<ffffffff81084094>] do_current_softirqs+0x174/0x680
[ 1441.309201] [<ffffffff81084607>] __local_bh_enable+0x67/0x80
[ 1441.309202] [<ffffffff8113c631>] cgroup_idr_alloc.constprop.41+0x61/0x80
[ 1441.309203] [<ffffffff811d4d5b>] cgroup_setup_root+0x65/0x28f
[ 1441.309204] [<ffffffff81d9ef88>] cgroup_init+0xf7/0x3e5
[ 1441.309204] [<ffffffff81d770d1>] start_kernel+0x43f/0x484
[ 1441.309205] [<ffffffff81d76599>] x86_64_start_reservations+0x2a/0x2c
[ 1441.309206] [<ffffffff81d766d8>] x86_64_start_kernel+0x13d/0x14c
[ 1441.309207] [<ffffffff810001b5>] start_cpu+0x5/0x14
[ 1441.309207]      INITIAL USE at:
[ 1441.309208] [<ffffffff810e0b4e>] __lock_acquire+0x2ce/0x1770
[ 1441.309209] [<ffffffff810e2564>] lock_acquire+0xd4/0x270
[ 1441.309210] [<ffffffff8174cdea>] rt_spin_lock__no_mg+0x5a/0x70
[ 1441.309211] [<ffffffff81084094>] do_current_softirqs+0x174/0x680
[ 1441.309212] [<ffffffff81084607>] __local_bh_enable+0x67/0x80
[ 1441.309213] [<ffffffff8113c631>] cgroup_idr_alloc.constprop.41+0x61/0x80
[ 1441.309213] [<ffffffff811d4d5b>] cgroup_setup_root+0x65/0x28f
[ 1441.309215] [<ffffffff81d9ef88>] cgroup_init+0xf7/0x3e5
[ 1441.309216] [<ffffffff81d770d1>] start_kernel+0x43f/0x484
[ 1441.309216] [<ffffffff81d76599>] x86_64_start_reservations+0x2a/0x2c
[ 1441.309217] [<ffffffff81d766d8>] x86_64_start_kernel+0x13d/0x14c
[ 1441.309218] [<ffffffff810001b5>] start_cpu+0x5/0x14
[ 1441.309218]    }
[ 1441.309220]    ... key      at: [<ffffffff81f6c110>] __key.38555+0x0/0x8
[ 1441.309220]    ... acquired at:
[ 1441.309221] [<ffffffff810e2564>] lock_acquire+0xd4/0x270
[ 1441.309222] [<ffffffff8174cdea>] rt_spin_lock__no_mg+0x5a/0x70
[ 1441.309222] [<ffffffff81084094>] do_current_softirqs+0x174/0x680
[ 1441.309223] [<ffffffff81084607>] __local_bh_enable+0x67/0x80
[ 1441.309225] [<ffffffff81200bc9>] wb_wakeup_delayed+0x69/0x70
[ 1441.309226] [<ffffffff812a0aab>] __mark_inode_dirty+0x60b/0x7c0
[ 1441.309227] [<ffffffff812ab235>] mark_buffer_dirty+0xb5/0x240
[ 1441.309231] [<ffffffffa009ba1d>] __jbd2_journal_temp_unlink_buffer+0xbd/0xe0 [jbd2]
[ 1441.309233] [<ffffffffa009e40a>] __jbd2_journal_refile_buffer+0xba/0xe0 [jbd2]
[ 1441.309235] [<ffffffffa009fbed>] jbd2_journal_commit_transaction+0x112d/0x2130 [jbd2]
[ 1441.309237] [<ffffffffa00a53dd>] kjournald2+0xcd/0x270 [jbd2]
[ 1441.309239] [<ffffffff810a5ecc>] kthread+0x10c/0x140
[ 1441.309239] [<ffffffff8174d7da>] ret_from_fork+0x2a/0x40
[ 1441.309240]  -> (&journal->j_list_lock){+.+...} ops: 587416 {
[ 1441.309241]     HARDIRQ-ON-W at:
[ 1441.309242] [<ffffffff810e11b8>] __lock_acquire+0x938/0x1770
[ 1441.309243] [<ffffffff810e2564>] lock_acquire+0xd4/0x270
[ 1441.309244] [<ffffffff8174cd6f>] rt_spin_lock+0x5f/0x80
[ 1441.309246] [<ffffffffa009d529>] do_get_write_access+0x3b9/0x5c0 [jbd2]
[ 1441.309248] [<ffffffffa009d761>] jbd2_journal_get_write_access+0x31/0x60 [jbd2]
[ 1441.309259] [<ffffffffa0105259>] __ext4_journal_get_write_access+0x49/0x90 [ext4]
[ 1441.309264] [<ffffffffa00c5cb2>] ext4_file_open+0x1c2/0x230 [ext4]
[ 1441.309265] [<ffffffff81268281>] do_dentry_open+0x231/0x360
[ 1441.309266] [<ffffffff81269642>] vfs_open+0x52/0x80
[ 1441.309268] [<ffffffff8127b206>] path_openat+0x476/0xdd0
[ 1441.309269] [<ffffffff8127d64e>] do_filp_open+0x7e/0xd0
[ 1441.309270] [<ffffffff812723b7>] do_open_execat+0x67/0x150
[ 1441.309271] [<ffffffff812739ec>] do_execveat_common.isra.34+0x25c/0x9a0
[ 1441.309272] [<ffffffff8127415c>] do_execve+0x2c/0x30
[ 1441.309274] [<ffffffff81098c46>] call_usermodehelper_exec_async+0xf6/0x130
[ 1441.309274] [<ffffffff8174d7da>] ret_from_fork+0x2a/0x40
[ 1441.309275]     SOFTIRQ-ON-W at:
[ 1441.309276] [<ffffffff810e0b03>] __lock_acquire+0x283/0x1770
[ 1441.309277] [<ffffffff810e2564>] lock_acquire+0xd4/0x270
[ 1441.309277] [<ffffffff8174cd6f>] rt_spin_lock+0x5f/0x80
[ 1441.309279] [<ffffffffa009d529>] do_get_write_access+0x3b9/0x5c0 [jbd2]
[ 1441.309281] [<ffffffffa009d761>] jbd2_journal_get_write_access+0x31/0x60 [jbd2]
[ 1441.309288] [<ffffffffa0105259>] __ext4_journal_get_write_access+0x49/0x90 [ext4]
[ 1441.309293] [<ffffffffa00c5cb2>] ext4_file_open+0x1c2/0x230 [ext4]
[ 1441.309294] [<ffffffff81268281>] do_dentry_open+0x231/0x360
[ 1441.309295] [<ffffffff81269642>] vfs_open+0x52/0x80
[ 1441.309296] [<ffffffff8127b206>] path_openat+0x476/0xdd0
[ 1441.309297] [<ffffffff8127d64e>] do_filp_open+0x7e/0xd0
[ 1441.309298] [<ffffffff812723b7>] do_open_execat+0x67/0x150
[ 1441.309299] [<ffffffff812739ec>] do_execveat_common.isra.34+0x25c/0x9a0
[ 1441.309300] [<ffffffff8127415c>] do_execve+0x2c/0x30
[ 1441.309301] [<ffffffff81098c46>] call_usermodehelper_exec_async+0xf6/0x130
[ 1441.309302] [<ffffffff8174d7da>] ret_from_fork+0x2a/0x40
[ 1441.309302]     INITIAL USE at:
[ 1441.309303] [<ffffffff810e0b4e>] __lock_acquire+0x2ce/0x1770
[ 1441.309304] [<ffffffff810e2564>] lock_acquire+0xd4/0x270
[ 1441.309305] [<ffffffff8174cd6f>] rt_spin_lock+0x5f/0x80
[ 1441.309307] [<ffffffffa009d529>] do_get_write_access+0x3b9/0x5c0 [jbd2]
[ 1441.309308] [<ffffffffa009d761>] jbd2_journal_get_write_access+0x31/0x60 [jbd2]
[ 1441.309314] [<ffffffffa0105259>] __ext4_journal_get_write_access+0x49/0x90 [ext4]
[ 1441.309319] [<ffffffffa00c5cb2>] ext4_file_open+0x1c2/0x230 [ext4]
[ 1441.309319] [<ffffffff81268281>] do_dentry_open+0x231/0x360
[ 1441.309320] [<ffffffff81269642>] vfs_open+0x52/0x80
[ 1441.309321] [<ffffffff8127b206>] path_openat+0x476/0xdd0
[ 1441.309322] [<ffffffff8127d64e>] do_filp_open+0x7e/0xd0
[ 1441.309323] [<ffffffff812723b7>] do_open_execat+0x67/0x150
[ 1441.309324] [<ffffffff812739ec>] do_execveat_common.isra.34+0x25c/0x9a0
[ 1441.309325] [<ffffffff8127415c>] do_execve+0x2c/0x30
[ 1441.309326] [<ffffffff81098c46>] call_usermodehelper_exec_async+0xf6/0x130
[ 1441.309327] [<ffffffff8174d7da>] ret_from_fork+0x2a/0x40
[ 1441.309327]   }
[ 1441.309330]   ... key      at: [<ffffffffa00af5c0>] __key.47251+0x0/0xffffffffffff9a40 [jbd2]
[ 1441.309330]   ... acquired at:
[ 1441.309331] [<ffffffff810e2564>] lock_acquire+0xd4/0x270
[ 1441.309331] [<ffffffff8174cd6f>] rt_spin_lock+0x5f/0x80
[ 1441.309333] [<ffffffffa009ee25>] jbd2_journal_commit_transaction+0x365/0x2130 [jbd2]
[ 1441.309335] [<ffffffffa00a53dd>] kjournald2+0xcd/0x270 [jbd2]
[ 1441.309337] [<ffffffff810a5ecc>] kthread+0x10c/0x140
[ 1441.309337] [<ffffffff8174d7da>] ret_from_fork+0x2a/0x40
[ 1441.309338] -> (&journal->j_state_lock){+.+.-.} ops: 5849939 {
[ 1441.309339]    HARDIRQ-ON-W at:
[ 1441.309340] [<ffffffff810e11b8>] __lock_acquire+0x938/0x1770
[ 1441.309341] [<ffffffff810e2564>] lock_acquire+0xd4/0x270
[ 1441.309341] [<ffffffff8174d291>] rt_write_lock+0x31/0x40
[ 1441.309348] [<ffffffffa00e9c0d>] ext4_init_journal_params+0x4d/0xc0 [ext4]
[ 1441.309353] [<ffffffffa00f515e>] ext4_fill_super+0x1e4e/0x3770 [ext4]
[ 1441.309355] [<ffffffff8126ee4a>] mount_bdev+0x18a/0x1c0
[ 1441.309360] [<ffffffffa00e9705>] ext4_mount+0x15/0x20 [ext4]
[ 1441.309361] [<ffffffff8126fa79>] mount_fs+0x39/0x170
[ 1441.309362] [<ffffffff81290817>] vfs_kern_mount+0x67/0x130
[ 1441.309363] [<ffffffff812939fb>] do_mount+0x1bb/0xc60
[ 1441.309364] [<ffffffff81294773>] SyS_mount+0x83/0xd0
[ 1441.309365] [<ffffffff8174d545>] entry_SYSCALL_64_fastpath+0x23/0xc6
[ 1441.309365]    SOFTIRQ-ON-W at:
[ 1441.309366] [<ffffffff810e0b03>] __lock_acquire+0x283/0x1770
[ 1441.309367] [<ffffffff810e2564>] lock_acquire+0xd4/0x270
[ 1441.309368] [<ffffffff8174d291>] rt_write_lock+0x31/0x40
[ 1441.309373] [<ffffffffa00e9c0d>] ext4_init_journal_params+0x4d/0xc0 [ext4]
[ 1441.309378] [<ffffffffa00f515e>] ext4_fill_super+0x1e4e/0x3770 [ext4]
[ 1441.309379] [<ffffffff8126ee4a>] mount_bdev+0x18a/0x1c0
[ 1441.309383] [<ffffffffa00e9705>] ext4_mount+0x15/0x20 [ext4]
[ 1441.309385] [<ffffffff8126fa79>] mount_fs+0x39/0x170
[ 1441.309385] [<ffffffff81290817>] vfs_kern_mount+0x67/0x130
[ 1441.309386] [<ffffffff812939fb>] do_mount+0x1bb/0xc60
[ 1441.309387] [<ffffffff81294773>] SyS_mount+0x83/0xd0
[ 1441.309388] [<ffffffff8174d545>] entry_SYSCALL_64_fastpath+0x23/0xc6
[ 1441.309388]    IN-RECLAIM_FS-W at:
[ 1441.309390] [<ffffffff810e0b36>] __lock_acquire+0x2b6/0x1770
[ 1441.309391] [<ffffffff810e2564>] lock_acquire+0xd4/0x270
[ 1441.309391] [<ffffffff8174d307>] rt_read_lock+0x47/0x60
[ 1441.309394] [<ffffffffa00a6d60>] jbd2_complete_transaction+0x20/0x90 [jbd2]
[ 1441.309398] [<ffffffffa00d472e>] ext4_evict_inode+0x37e/0x700 [ext4]
[ 1441.309400] [<ffffffff8128b221>] evict+0xd1/0x1a0
[ 1441.309401] [<ffffffff8128b33d>] dispose_list+0x4d/0x70
[ 1441.309402] [<ffffffff8128c60b>] prune_icache_sb+0x4b/0x60
[ 1441.309404] [<ffffffff8126f381>] super_cache_scan+0x141/0x190
[ 1441.309405] [<ffffffff811efc27>] shrink_slab+0x277/0x6c0
[ 1441.309406] [<ffffffff811f4523>] shrink_node+0x2e3/0x2f0
[ 1441.309407] [<ffffffff811f5a7f>] kswapd+0x34f/0x980
[ 1441.309409] [<ffffffff810a5ecc>] kthread+0x10c/0x140
[ 1441.309409] [<ffffffff8174d7da>] ret_from_fork+0x2a/0x40
[ 1441.309410]    INITIAL USE at:
[ 1441.309411] [<ffffffff810e0b4e>] __lock_acquire+0x2ce/0x1770
[ 1441.309412] [<ffffffff810e2564>] lock_acquire+0xd4/0x270
[ 1441.309412] [<ffffffff8174d291>] rt_write_lock+0x31/0x40
[ 1441.309417] [<ffffffffa00e9c0d>] ext4_init_journal_params+0x4d/0xc0 [ext4]
[ 1441.309422] [<ffffffffa00f515e>] ext4_fill_super+0x1e4e/0x3770 [ext4]
[ 1441.309423] [<ffffffff8126ee4a>] mount_bdev+0x18a/0x1c0
[ 1441.309427] [<ffffffffa00e9705>] ext4_mount+0x15/0x20 [ext4]
[ 1441.309429] [<ffffffff8126fa79>] mount_fs+0x39/0x170
[ 1441.309429] [<ffffffff81290817>] vfs_kern_mount+0x67/0x130
[ 1441.309430] [<ffffffff812939fb>] do_mount+0x1bb/0xc60
[ 1441.309431] [<ffffffff81294773>] SyS_mount+0x83/0xd0
[ 1441.309432] [<ffffffff8174d545>] entry_SYSCALL_64_fastpath+0x23/0xc6
[ 1441.309432]  }
[ 1441.309435]  ... key      at: [<ffffffffa00af5b0>] __key.47253+0x0/0xffffffffffff9a50 [jbd2]
[ 1441.309435]  ... acquired at:
[ 1441.309436] [<ffffffff810df99e>] check_usage_forwards+0x11e/0x120
[ 1441.309437] [<ffffffff810e01a8>] mark_lock+0x1e8/0x2f0
[ 1441.309437] [<ffffffff810e0b36>] __lock_acquire+0x2b6/0x1770
[ 1441.309438] [<ffffffff810e2564>] lock_acquire+0xd4/0x270
[ 1441.309439] [<ffffffff8174d307>] rt_read_lock+0x47/0x60
[ 1441.309441] [<ffffffffa00a6d60>] jbd2_complete_transaction+0x20/0x90 [jbd2]
[ 1441.309446] [<ffffffffa00d472e>] ext4_evict_inode+0x37e/0x700 [ext4]
[ 1441.309447] [<ffffffff8128b221>] evict+0xd1/0x1a0
[ 1441.309448] [<ffffffff8128b33d>] dispose_list+0x4d/0x70
[ 1441.309449] [<ffffffff8128c60b>] prune_icache_sb+0x4b/0x60
[ 1441.309450] [<ffffffff8126f381>] super_cache_scan+0x141/0x190
[ 1441.309451] [<ffffffff811efc27>] shrink_slab+0x277/0x6c0
[ 1441.309452] [<ffffffff811f4523>] shrink_node+0x2e3/0x2f0
[ 1441.309453] [<ffffffff811f5a7f>] kswapd+0x34f/0x980
[ 1441.309454] [<ffffffff810a5ecc>] kthread+0x10c/0x140
[ 1441.309455] [<ffffffff8174d7da>] ret_from_fork+0x2a/0x40
[ 1441.309455] stack backtrace:
[ 1441.309457] CPU: 0 PID: 165 Comm: kswapd0 Tainted: G            E   4.10.0-rt9-rt #11
[ 1441.309457] Hardware name: MEDION MS-7848/MS-7848, BIOS M7848W08.20C 09/23/2013
[ 1441.309457] Call Trace:
[ 1441.309459]  dump_stack+0x85/0xc8
[ 1441.309461]  print_irq_inversion_bug.part.34+0x1ac/0x1b8
[ 1441.309462]  check_usage_forwards+0x11e/0x120
[ 1441.309463]  ? check_usage_backwards+0x120/0x120
[ 1441.309463]  mark_lock+0x1e8/0x2f0
[ 1441.309464]  __lock_acquire+0x2b6/0x1770
[ 1441.309465]  ? __lock_acquire+0x420/0x1770
[ 1441.309466]  lock_acquire+0xd4/0x270
[ 1441.309468]  ? jbd2_complete_transaction+0x20/0x90 [jbd2]
[ 1441.309469]  rt_read_lock+0x47/0x60
[ 1441.309471]  ? jbd2_complete_transaction+0x20/0x90 [jbd2]
[ 1441.309472]  jbd2_complete_transaction+0x20/0x90 [jbd2]
[ 1441.309477]  ext4_evict_inode+0x37e/0x700 [ext4]
[ 1441.309478]  evict+0xd1/0x1a0
[ 1441.309479]  dispose_list+0x4d/0x70
[ 1441.309480]  prune_icache_sb+0x4b/0x60
[ 1441.309481]  super_cache_scan+0x141/0x190
[ 1441.309482]  shrink_slab+0x277/0x6c0
[ 1441.309483]  shrink_node+0x2e3/0x2f0
[ 1441.309485]  kswapd+0x34f/0x980
[ 1441.309487]  kthread+0x10c/0x140
[ 1441.309488]  ? mem_cgroup_shrink_node+0x390/0x390
[ 1441.309488]  ? kthread_park+0x90/0x90
[ 1441.309489]  ret_from_fork+0x2a/0x40

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
