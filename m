Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3D3B36B024D
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 07:13:27 -0400 (EDT)
Date: Fri, 23 Jul 2010 21:13:10 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: VFS scalability git tree
Message-ID: <20100723111310.GI32635@dastard>
References: <20100722190100.GA22269@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100722190100.GA22269@amd>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frank Mayhar <fmayhar@google.com>, John Stultz <johnstul@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 23, 2010 at 05:01:00AM +1000, Nick Piggin wrote:
> I'm pleased to announce I have a git tree up of my vfs scalability work.
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.git
> http://git.kernel.org/?p=linux/kernel/git/npiggin/linux-npiggin.git
> 
> Branch vfs-scale-working

I've got a couple of patches needed to build XFS - they shrinker
merge left some bad fragments - I'll post them in a minute. This
email is for the longest ever lockdep warning I've seen that
occurred on boot.

Cheers,

Dave.

[    6.368707] ======================================================
[    6.369773] [ INFO: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected ]
[    6.370379] 2.6.35-rc5-dgc+ #58
[    6.370882] ------------------------------------------------------
[    6.371475] pmcd/2124 [HC0[0]:SC0[1]:HE1:SE0] is trying to acquire:
[    6.372062]  (&sb->s_type->i_lock_key#6){+.+...}, at: [<ffffffff81736f8c>] socket_get_id+0x3c/0x60
[    6.372268] 
[    6.372268] and this task is already holding:
[    6.372268]  (&(&hashinfo->ehash_locks[i])->rlock){+.-...}, at: [<ffffffff81791750>] established_get_first+0x60/0x120
[    6.372268] which would create a new lock dependency:
[    6.372268]  (&(&hashinfo->ehash_locks[i])->rlock){+.-...} -> (&sb->s_type->i_lock_key#6){+.+...}
[    6.372268] 
[    6.372268] but this new dependency connects a SOFTIRQ-irq-safe lock:
[    6.372268]  (&(&hashinfo->ehash_locks[i])->rlock){+.-...}
[    6.372268] ... which became SOFTIRQ-irq-safe at:
[    6.372268]   [<ffffffff810b3b26>] __lock_acquire+0x576/0x1450
[    6.372268]   [<ffffffff810b4aa6>] lock_acquire+0xa6/0x160
[    6.372268]   [<ffffffff8182bb26>] _raw_spin_lock+0x36/0x70
[    6.372268]   [<ffffffff8177a1ba>] __inet_hash_nolisten+0xfa/0x180
[    6.372268]   [<ffffffff8179392a>] tcp_v4_syn_recv_sock+0x1aa/0x2d0
[    6.372268]   [<ffffffff81795502>] tcp_check_req+0x202/0x440
[    6.372268]   [<ffffffff817948c4>] tcp_v4_do_rcv+0x304/0x4f0
[    6.372268]   [<ffffffff81795134>] tcp_v4_rcv+0x684/0x7e0
[    6.372268]   [<ffffffff81771512>] ip_local_deliver+0xe2/0x1c0
[    6.372268]   [<ffffffff81771af7>] ip_rcv+0x397/0x760
[    6.372268]   [<ffffffff8174d067>] __netif_receive_skb+0x277/0x330
[    6.372268]   [<ffffffff8174d1f4>] process_backlog+0xd4/0x1e0
[    6.372268]   [<ffffffff8174dc38>] net_rx_action+0x188/0x2b0
[    6.372268]   [<ffffffff81084cc2>] __do_softirq+0xd2/0x260
[    6.372268]   [<ffffffff81035edc>] call_softirq+0x1c/0x50
[    6.372268]   [<ffffffff8108551b>] local_bh_enable_ip+0xeb/0xf0
[    6.372268]   [<ffffffff8182c544>] _raw_spin_unlock_bh+0x34/0x40
[    6.372268]   [<ffffffff8173c59e>] release_sock+0x14e/0x1a0
[    6.372268]   [<ffffffff817a3975>] inet_stream_connect+0x75/0x320
[    6.372268]   [<ffffffff81737917>] sys_connect+0xa7/0xc0
[    6.372268]   [<ffffffff81034ff2>] system_call_fastpath+0x16/0x1b
[    6.372268] 
[    6.372268] to a SOFTIRQ-irq-unsafe lock:
[    6.372268]  (&sb->s_type->i_lock_key#6){+.+...}
[    6.372268] ... which became SOFTIRQ-irq-unsafe at:
[    6.372268] ...  [<ffffffff810b3b73>] __lock_acquire+0x5c3/0x1450
[    6.372268]   [<ffffffff810b4aa6>] lock_acquire+0xa6/0x160
[    6.372268]   [<ffffffff8182bb26>] _raw_spin_lock+0x36/0x70
[    6.372268]   [<ffffffff8116af72>] new_inode+0x52/0xd0
[    6.372268]   [<ffffffff81174a40>] get_sb_pseudo+0xb0/0x180
[    6.372268]   [<ffffffff81735a41>] sockfs_get_sb+0x21/0x30
[    6.372268]   [<ffffffff81152dba>] vfs_kern_mount+0x8a/0x1e0
[    6.372268]   [<ffffffff81152f29>] kern_mount_data+0x19/0x20
[    6.372268]   [<ffffffff81e1c075>] sock_init+0x4e/0x59
[    6.372268]   [<ffffffff810001dc>] do_one_initcall+0x3c/0x1a0
[    6.372268]   [<ffffffff81de5767>] kernel_init+0x17a/0x204
[    6.372268]   [<ffffffff81035de4>] kernel_thread_helper+0x4/0x10
[    6.372268] 
[    6.372268] other info that might help us debug this:
[    6.372268] 
[    6.372268] 3 locks held by pmcd/2124:
[    6.372268]  #0:  (&p->lock){+.+.+.}, at: [<ffffffff81171dae>] seq_read+0x3e/0x430
[    6.372268]  #1:  (&(&hashinfo->ehash_locks[i])->rlock){+.-...}, at: [<ffffffff81791750>] established_get_first+0x60/0x120
[    6.372268]  #2:  (clock-AF_INET){++....}, at: [<ffffffff8173b6ae>] sock_i_ino+0x2e/0x70
[    6.372268] 
[    6.372268] the dependencies between SOFTIRQ-irq-safe lock and the holding lock:
[    6.372268] -> (&(&hashinfo->ehash_locks[i])->rlock){+.-...} ops: 3 {
[    6.372268]    HARDIRQ-ON-W at:
[    6.372268]                                        [<ffffffff810b3b47>] __lock_acquire+0x597/0x1450
[    6.372268]                                        [<ffffffff810b4aa6>] lock_acquire+0xa6/0x160
[    6.372268]                                        [<ffffffff8182bb26>] _raw_spin_lock+0x36/0x70
[    6.372268]                                        [<ffffffff8177a1ba>] __inet_hash_nolisten+0xfa/0x180
[    6.372268]                                        [<ffffffff8177ab6a>] __inet_hash_connect+0x33a/0x3d0
[    6.372268]                                        [<ffffffff8177ac4f>] inet_hash_connect+0x4f/0x60
[    6.372268]                                        [<ffffffff81792522>] tcp_v4_connect+0x272/0x4f0
[    6.372268]                                        [<ffffffff817a3b8e>] inet_stream_connect+0x28e/0x320
[    6.372268]                                        [<ffffffff81737917>] sys_connect+0xa7/0xc0
[    6.372268]                                        [<ffffffff81034ff2>] system_call_fastpath+0x16/0x1b
[    6.372268]    IN-SOFTIRQ-W at:
[    6.372268]                                        [<ffffffff810b3b26>] __lock_acquire+0x576/0x1450
[    6.372268]                                        [<ffffffff810b4aa6>] lock_acquire+0xa6/0x160
[    6.372268]                                        [<ffffffff8182bb26>] _raw_spin_lock+0x36/0x70
[    6.372268]                                        [<ffffffff8177a1ba>] __inet_hash_nolisten+0xfa/0x180
[    6.372268]                                        [<ffffffff8179392a>] tcp_v4_syn_recv_sock+0x1aa/0x2d0
[    6.372268]                                        [<ffffffff81795502>] tcp_check_req+0x202/0x440
[    6.372268]                                        [<ffffffff817948c4>] tcp_v4_do_rcv+0x304/0x4f0
[    6.372268]                                        [<ffffffff81795134>] tcp_v4_rcv+0x684/0x7e0
[    6.372268]                                        [<ffffffff81771512>] ip_local_deliver+0xe2/0x1c0
[    6.372268]                                        [<ffffffff81771af7>] ip_rcv+0x397/0x760
[    6.372268]                                        [<ffffffff8174d067>] __netif_receive_skb+0x277/0x330
[    6.372268]                                        [<ffffffff8174d1f4>] process_backlog+0xd4/0x1e0
[    6.372268]                                        [<ffffffff8174dc38>] net_rx_action+0x188/0x2b0
[    6.372268]                                        [<ffffffff81084cc2>] __do_softirq+0xd2/0x260
[    6.372268]                                        [<ffffffff81035edc>] call_softirq+0x1c/0x50
[    6.372268]                                        [<ffffffff8108551b>] local_bh_enable_ip+0xeb/0xf0
[    6.372268]                                        [<ffffffff8182c544>] _raw_spin_unlock_bh+0x34/0x40
[    6.372268]                                        [<ffffffff8173c59e>] release_sock+0x14e/0x1a0
[    6.372268]                                        [<ffffffff817a3975>] inet_stream_connect+0x75/0x320
[    6.372268]                                        [<ffffffff81737917>] sys_connect+0xa7/0xc0
[    6.372268]                                        [<ffffffff81034ff2>] system_call_fastpath+0x16/0x1b
[    6.372268]    INITIAL USE at:
[    6.372268]                                       [<ffffffff810b37e2>] __lock_acquire+0x232/0x1450
[    6.372268]                                       [<ffffffff810b4aa6>] lock_acquire+0xa6/0x160
[    6.372268]                                       [<ffffffff8182bb26>] _raw_spin_lock+0x36/0x70
[    6.372268]                                       [<ffffffff8177a1ba>] __inet_hash_nolisten+0xfa/0x180
[    6.372268]                                       [<ffffffff8177ab6a>] __inet_hash_connect+0x33a/0x3d0
[    6.372268]                                       [<ffffffff8177ac4f>] inet_hash_connect+0x4f/0x60
[    6.372268]                                       [<ffffffff81792522>] tcp_v4_connect+0x272/0x4f0
[    6.372268]                                       [<ffffffff817a3b8e>] inet_stream_connect+0x28e/0x320
[    6.372268]                                       [<ffffffff81737917>] sys_connect+0xa7/0xc0
[    6.372268]                                       [<ffffffff81034ff2>] system_call_fastpath+0x16/0x1b
[    6.372268]  }
[    6.372268]  ... key      at: [<ffffffff8285ddf8>] __key.47027+0x0/0x8
[    6.372268]  ... acquired at:
[    6.372268]    [<ffffffff810b2940>] check_irq_usage+0x60/0xf0
[    6.372268]    [<ffffffff810b41ff>] __lock_acquire+0xc4f/0x1450
[    6.372268]    [<ffffffff810b4aa6>] lock_acquire+0xa6/0x160
[    6.372268]    [<ffffffff8182bb26>] _raw_spin_lock+0x36/0x70
[    6.372268]    [<ffffffff81736f8c>] socket_get_id+0x3c/0x60
[    6.372268]    [<ffffffff8173b6c3>] sock_i_ino+0x43/0x70
[    6.372268]    [<ffffffff81790fc9>] tcp4_seq_show+0x1a9/0x520
[    6.372268]    [<ffffffff81172005>] seq_read+0x295/0x430
[    6.372268]    [<ffffffff811ad9f4>] proc_reg_read+0x84/0xc0
[    6.372268]    [<ffffffff81150165>] vfs_read+0xb5/0x170
[    6.372268]    [<ffffffff81150274>] sys_read+0x54/0x90
[    6.372268]    [<ffffffff81034ff2>] system_call_fastpath+0x16/0x1b
[    6.372268] 
[    6.372268] 
[    6.372268] the dependencies between the lock to be acquired and SOFTIRQ-irq-unsafe lock:
[    6.372268] -> (&sb->s_type->i_lock_key#6){+.+...} ops: 1185 {
[    6.372268]    HARDIRQ-ON-W at:
[    6.372268]                                        [<ffffffff810b3b47>] __lock_acquire+0x597/0x1450
[    6.372268]                                        [<ffffffff810b4aa6>] lock_acquire+0xa6/0x160
[    6.372268]                                        [<ffffffff8182bb26>] _raw_spin_lock+0x36/0x70
[    6.372268]                                        [<ffffffff8116af72>] new_inode+0x52/0xd0
[    6.372268]                                        [<ffffffff81174a40>] get_sb_pseudo+0xb0/0x180
[    6.372268]                                        [<ffffffff81735a41>] sockfs_get_sb+0x21/0x30
[    6.372268]                                        [<ffffffff81152dba>] vfs_kern_mount+0x8a/0x1e0
[    6.372268]                                        [<ffffffff81152f29>] kern_mount_data+0x19/0x20
[    6.372268]                                        [<ffffffff81e1c075>] sock_init+0x4e/0x59
[    6.372268]                                        [<ffffffff810001dc>] do_one_initcall+0x3c/0x1a0
[    6.372268]                                        [<ffffffff81de5767>] kernel_init+0x17a/0x204
[    6.372268]                                        [<ffffffff81035de4>] kernel_thread_helper+0x4/0x10
[    6.372268]    SOFTIRQ-ON-W at:
[    6.372268]                                        [<ffffffff810b3b73>] __lock_acquire+0x5c3/0x1450
[    6.372268]                                        [<ffffffff810b4aa6>] lock_acquire+0xa6/0x160
[    6.372268]                                        [<ffffffff8182bb26>] _raw_spin_lock+0x36/0x70
[    6.372268]                                        [<ffffffff8116af72>] new_inode+0x52/0xd0
[    6.372268]                                        [<ffffffff81174a40>] get_sb_pseudo+0xb0/0x180
[    6.372268]                                        [<ffffffff81735a41>] sockfs_get_sb+0x21/0x30
[    6.372268]                                        [<ffffffff81152dba>] vfs_kern_mount+0x8a/0x1e0
[    6.372268]                                        [<ffffffff81152f29>] kern_mount_data+0x19/0x20
[    6.372268]                                        [<ffffffff81e1c075>] sock_init+0x4e/0x59
[    6.372268]                                        [<ffffffff810001dc>] do_one_initcall+0x3c/0x1a0
[    6.372268]                                        [<ffffffff81de5767>] kernel_init+0x17a/0x204
[    6.372268]                                        [<ffffffff81035de4>] kernel_thread_helper+0x4/0x10
[    6.372268]    INITIAL USE at:
[    6.372268]                                       [<ffffffff810b37e2>] __lock_acquire+0x232/0x1450
[    6.372268]                                       [<ffffffff810b4aa6>] lock_acquire+0xa6/0x160
[    6.372268]                                       [<ffffffff8182bb26>] _raw_spin_lock+0x36/0x70
[    6.372268]                                       [<ffffffff8116af72>] new_inode+0x52/0xd0
[    6.372268]                                       [<ffffffff81174a40>] get_sb_pseudo+0xb0/0x180
[    6.372268]                                       [<f                          [<ffffffff81152dba>] vfs_kern_mount+0x8a/0x1e0
[    6.372268]                                       [<ffffffff81152f29>] kern_mount_data+0x19/0x20
[    6.372268]                                       [<ffffffff81e1c075>] sock_init+0x4e/0x59
[    6.372268]                                       [<ffffffff810001dc>] do_one_initcall+0x3c/0x1a0
[    6.372268]                                       [<ffffffff81de5767>] kernel_init+0x17a/0x204
[    6.372268]                                       [<ffffffff81035de4>] kernel_thread_helper+0x4/0x10
[    6.372268]  }
[    6.372268]  ... key      at: [<ffffffff81bd5bd8>] sock_fs_type+0x58/0x80
[    6.372268]  ... acquired at:
[    6.372268]    [<ffffffff810b2940>] check_irq_usage+0x60/0xf0
[    6.372268]    [<ffffffff810b41ff>] __lock_acquire+0xc4f/0x1450
[    6.372268]    [<ffffffff810b4aa6>] lock_acquire+0xa6/0x160
[    6.372268]    [<ffffffff8182bb26>] _raw_spin_lock+0x36/0x70
[    6.372268]    [<ffffffff81736f8c>] socket_get_id+0x3c/0x60
[    6.372268]    [<ffffffff8173b6c3>] sock_i_ino+0x43/0x70
[    6.372268]    [<ffffffff81790fc9>] tcp4_seq_show+0x1a9/0x520
[    6.372268]    [<ffffffff81172005>] seq_read+0x295/0x430
[    6.372268]    [<ffffffff811ad9f4>] proc_reg_read+0x84/0xc0
[    6.372268]    [<ffffffff81150165>] vfs_read+0xb5/0x170
[    6.372268]    [<ffffffff81150274>] sys_read+0x54/0x90
[    6.372268]    [<ffffffff81034ff2>] system_call_fastpath+0x16/0x1b
[    6.372268] 
[    6.372268] 
[    6.372268] stack backtrace:
[    6.372268] Pid: 2124, comm: pmcd Not tainted 2.6.35-rc5-dgc+ #58
[    6.372268] Call Trace:
[    6.372268]  [<ffffffff810b28d9>] check_usage+0x499/0x4a0
[    6.372268]  [<ffffffff810b24c6>] ? check_usage+0x86/0x4a0
[    6.372268]  [<ffffffff810af729>] ? __bfs+0x129/0x260
[    6.372268]  [<ffffffff810b2940>] check_irq_usage+0x60/0xf0
[    6.372268]  [<ffffffff810b41ff>] __lock_acquire+0xc4f/0x1450
[    6.372268]  [<ffffffff810b4aa6>] lock_acquire+0xa6/0x160
[    6.372268]  [<ffffffff81736f8c>] ? socket_get_id+0x3c/0x60
[    6.372268]  [<ffffffff8182bb26>] _raw_spin_lock+0x36/0x70
[    6.372268]  [<ffffffff81736f8c>] ? socket_get_id+0x3c/0x60
[    6.372268]  [<ffffffff81736f8c>] socket_get_id+0x3c/0x60
[    6.372268]  [<ffffffff8173b6c3>] sock_i_ino+0x43/0x70
[    6.372268]  [<ffffffff81790fc9>] tcp4_seq_show+0x1a9/0x520
[    6.372268]  [<ffffffff81791750>] ? established_get_first+0x60/0x120
[    6.372268]  [<ffffffff8182beb7>] ? _raw_spin_lock_bh+0x67/0x70
[    6.372268]  [<ffffffff81172005>] seq_read+0x295/0x430
[    6.372268]  [<ffffffff81171d70>] ? seq_read+0x0/0x430
[    6.372268]  [<ffffffff811ad9f4>] proc_reg_read+0x84/0xc0
[    6.372268]  [<ffffffff81150165>] vfs_read+0xb5/0x170
[    6.372268]  [<ffffffff81150274>] sys_read+0x54/0x90
[    6.372268]  [<ffffffff81034ff2>] system_call_fastpath+0x16/0x1b

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
