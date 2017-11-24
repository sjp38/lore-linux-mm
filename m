Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8BA996B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 07:21:51 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id z14so9398600wrb.12
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 04:21:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n10si836917edf.443.2017.11.24.04.21.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 04:21:50 -0800 (PST)
Date: Fri, 24 Nov 2017 13:21:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm,vmscan: Make unregister_shrinker() no-op if
 register_shrinker() failed.
Message-ID: <20171124122148.qevmiogh3pzr4zix@dhcp22.suse.cz>
References: <1511523385-6433-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511523385-6433-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Al Viro <viro@zeniv.linux.org.uk>, Glauber Costa <glauber@scylladb.com>, syzbot <syzkaller@googlegroups.com>

On Fri 24-11-17 20:36:24, Tetsuo Handa wrote:
> Syzbot caught an oops at unregister_shrinker() because combination of
> commit 1d3d4437eae1bb29 ("vmscan: per-node deferred work") and fault
> injection made register_shrinker() fail and the caller of
> register_shrinker() did not check for failure.
> 
> ----------
> [  554.881422] FAULT_INJECTION: forcing a failure.
> [  554.881422] name failslab, interval 1, probability 0, space 0, times 0
> [  554.881438] CPU: 1 PID: 13231 Comm: syz-executor1 Not tainted 4.14.0-rc8+ #82
> [  554.881443] Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
> [  554.881445] Call Trace:
> [  554.881459]  dump_stack+0x194/0x257
> [  554.881474]  ? arch_local_irq_restore+0x53/0x53
> [  554.881486]  ? find_held_lock+0x35/0x1d0
> [  554.881507]  should_fail+0x8c0/0xa40
> [  554.881522]  ? fault_create_debugfs_attr+0x1f0/0x1f0
> [  554.881537]  ? check_noncircular+0x20/0x20
> [  554.881546]  ? find_next_zero_bit+0x2c/0x40
> [  554.881560]  ? ida_get_new_above+0x421/0x9d0
> [  554.881577]  ? find_held_lock+0x35/0x1d0
> [  554.881594]  ? __lock_is_held+0xb6/0x140
> [  554.881628]  ? check_same_owner+0x320/0x320
> [  554.881634]  ? lock_downgrade+0x990/0x990
> [  554.881649]  ? find_held_lock+0x35/0x1d0
> [  554.881672]  should_failslab+0xec/0x120
> [  554.881684]  __kmalloc+0x63/0x760
> [  554.881692]  ? lock_downgrade+0x990/0x990
> [  554.881712]  ? register_shrinker+0x10e/0x2d0
> [  554.881721]  ? trace_event_raw_event_module_request+0x320/0x320
> [  554.881737]  register_shrinker+0x10e/0x2d0
> [  554.881747]  ? prepare_kswapd_sleep+0x1f0/0x1f0
> [  554.881755]  ? _down_write_nest_lock+0x120/0x120
> [  554.881765]  ? memcpy+0x45/0x50
> [  554.881785]  sget_userns+0xbcd/0xe20
> (...snipped...)
> [  554.898693] kasan: CONFIG_KASAN_INLINE enabled
> [  554.898724] kasan: GPF could be caused by NULL-ptr deref or user memory access
> [  554.898732] general protection fault: 0000 [#1] SMP KASAN
> [  554.898737] Dumping ftrace buffer:
> [  554.898741]    (ftrace buffer empty)
> [  554.898743] Modules linked in:
> [  554.898752] CPU: 1 PID: 13231 Comm: syz-executor1 Not tainted 4.14.0-rc8+ #82
> [  554.898755] Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
> [  554.898760] task: ffff8801d1dbe5c0 task.stack: ffff8801c9e38000
> [  554.898772] RIP: 0010:__list_del_entry_valid+0x7e/0x150
> [  554.898775] RSP: 0018:ffff8801c9e3f108 EFLAGS: 00010246
> [  554.898780] RAX: dffffc0000000000 RBX: 0000000000000000 RCX: 0000000000000000
> [  554.898784] RDX: 0000000000000000 RSI: ffff8801c53c6f98 RDI: ffff8801c53c6fa0
> [  554.898788] RBP: ffff8801c9e3f120 R08: 1ffff100393c7d55 R09: 0000000000000004
> [  554.898791] R10: ffff8801c9e3ef70 R11: 0000000000000000 R12: 0000000000000000
> [  554.898795] R13: dffffc0000000000 R14: 1ffff100393c7e45 R15: ffff8801c53c6f98
> [  554.898800] FS:  0000000000000000(0000) GS:ffff8801db300000(0000) knlGS:0000000000000000
> [  554.898804] CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
> [  554.898807] CR2: 00000000dbc23000 CR3: 00000001c7269000 CR4: 00000000001406e0
> [  554.898813] DR0: 0000000020000000 DR1: 0000000020000000 DR2: 0000000000000000
> [  554.898816] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
> [  554.898818] Call Trace:
> [  554.898828]  unregister_shrinker+0x79/0x300
> [  554.898837]  ? perf_trace_mm_vmscan_writepage+0x750/0x750
> [  554.898844]  ? down_write+0x87/0x120
> [  554.898851]  ? deactivate_super+0x139/0x1b0
> [  554.898857]  ? down_read+0x150/0x150
> [  554.898864]  ? check_same_owner+0x320/0x320
> [  554.898875]  deactivate_locked_super+0x64/0xd0
> [  554.898883]  deactivate_super+0x141/0x1b0
> ----------
> 
> Since allowing register_shrinker() callers to call unregister_shrinker()
> when register_shrinker() failed can simplify error recovery path, this
> patch makes unregister_shrinker() no-op when register_shrinker() failed.

Well, the primary point of this patch is to not blow up, in the first
place. It is not to woraround missing register_shrinker handling which
what one could understand from the above. Yes we are making it noop
because it is easier for users but they still _have_ to check the error
path otherwise we have silent memory pressure issues potentially.

> Since we can encourage register_shrinker() callers to check for failure
> by marking register_shrinker() as __must_check, unregister_shrinker()
> can stay silent.

I am not sure __must_check is the right way. We already do get
allocation warning if the registration fails so silent unregister is
acceptable. Unchecked register_shrinker is a bug like any other
unchecked error path.
 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Reported-by: syzbot <syzkaller@googlegroups.com>
> Cc: Glauber Costa <glauber@scylladb.com>
> Cc: Al Viro <viro@zeniv.linux.org.uk>

With the changelog updated
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmscan.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 6a5a72b..d01177b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -297,6 +297,8 @@ int register_shrinker(struct shrinker *shrinker)
>   */
>  void unregister_shrinker(struct shrinker *shrinker)
>  {
> +	if (!shrinker->nr_deferred)
> +		return;
>  	down_write(&shrinker_rwsem);
>  	list_del(&shrinker->list);
>  	up_write(&shrinker_rwsem);
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
