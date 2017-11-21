Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 787946B0033
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 06:12:02 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id g202so865488ita.4
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 03:12:02 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b75si1129442itb.60.2017.11.21.03.12.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Nov 2017 03:12:00 -0800 (PST)
Subject: Re: general protection fault in __list_del_entry_valid (2)
References: <001a113f996099503a055e793dd3@google.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <0e1109ef-6d4a-e873-a809-6548776a00f9@I-love.SAKURA.ne.jp>
Date: Tue, 21 Nov 2017 20:11:26 +0900
MIME-Version: 1.0
In-Reply-To: <001a113f996099503a055e793dd3@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+065a25551da6c9ab4283b7ae889c707a37ab2de3@syzkaller.appspotmail.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, mhocko@suse.com, minchan@kernel.org, shli@fb.com, syzkaller-bugs@googlegroups.com, ying.huang@intel.com

On 2017/11/21 16:35, syzbot wrote:
> Hello,
> 
> syzkaller hit the following crash on ca91659962303d4fd5211a5e4e13df5cbb11e744
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> 
> Unfortunately, I don't have any reproducer for this bug yet.

Fault injection found an unchecked register_shrinker() return code.
Wow, register_shrinker()/unregister_shinker() is possibly frequently called path?


struct super_block *sget_userns(struct file_system_type *type,
				int (*test)(struct super_block *,void *),
				int (*set)(struct super_block *,void *),
				int flags, struct user_namespace *user_ns,
				void *data)
{
(...snipped...)
	spin_unlock(&sb_lock);
	get_filesystem(type);
	register_shrinker(&s->s_shrink); // Error check required.
	return s;
}

[  554.881422] FAULT_INJECTION: forcing a failure.
[  554.881422] name failslab, interval 1, probability 0, space 0, times 0
[  554.881438] CPU: 1 PID: 13231 Comm: syz-executor1 Not tainted 4.14.0-rc8+ #82
[  554.881443] Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
[  554.881445] Call Trace:
[  554.881459]  dump_stack+0x194/0x257
[  554.881474]  ? arch_local_irq_restore+0x53/0x53
[  554.881486]  ? find_held_lock+0x35/0x1d0
[  554.881507]  should_fail+0x8c0/0xa40
[  554.881522]  ? fault_create_debugfs_attr+0x1f0/0x1f0
[  554.881537]  ? check_noncircular+0x20/0x20
[  554.881546]  ? find_next_zero_bit+0x2c/0x40
[  554.881560]  ? ida_get_new_above+0x421/0x9d0
[  554.881577]  ? find_held_lock+0x35/0x1d0
[  554.881594]  ? __lock_is_held+0xb6/0x140
[  554.881628]  ? check_same_owner+0x320/0x320
[  554.881634]  ? lock_downgrade+0x990/0x990
[  554.881649]  ? find_held_lock+0x35/0x1d0
[  554.881672]  should_failslab+0xec/0x120
[  554.881684]  __kmalloc+0x63/0x760
[  554.881692]  ? lock_downgrade+0x990/0x990
[  554.881712]  ? register_shrinker+0x10e/0x2d0
[  554.881721]  ? trace_event_raw_event_module_request+0x320/0x320
[  554.881737]  register_shrinker+0x10e/0x2d0
[  554.881747]  ? prepare_kswapd_sleep+0x1f0/0x1f0
[  554.881755]  ? _down_write_nest_lock+0x120/0x120
[  554.881765]  ? memcpy+0x45/0x50
[  554.881785]  sget_userns+0xbcd/0xe20
[  554.881792]  ? set_anon_super+0x20/0x20
[  554.881809]  ? put_filp+0x90/0x90
[  554.881822]  ? __sb_start_write+0x2a0/0x2a0
[  554.881829]  ? alloc_pages_current+0xbe/0x1e0
[  554.881846]  ? free_pages+0x51/0x90
[  554.881858]  ? selinux_sb_copy_data+0x4a1/0x610
[  554.881864]  ? __lockdep_init_map+0xe4/0x650
[  554.881882]  ? selinux_quota_on+0x320/0x320
[  554.881892]  ? __lockdep_init_map+0xe4/0x650
[  554.881906]  ? lockdep_init_map+0x9/0x10
[  554.881936]  ? mqueue_get_inode+0xc60/0xc60
[  554.881944]  mount_ns+0x6d/0x190
[  554.881960]  mqueue_mount+0xbe/0xe0
[  554.881975]  mount_fs+0x66/0x2d0
[  554.881991]  vfs_kern_mount.part.26+0xc6/0x4a0
[  554.882004]  ? may_umount+0xa0/0xa0
[  554.882013]  ? compat_SyS_msgrcv+0x50/0x50
[  554.882023]  ? ida_remove+0x3e0/0x3e0
[  554.882034]  ? kmem_cache_alloc_trace+0x456/0x750
[  554.882048]  kern_mount_data+0x50/0xb0

[  554.898693] kasan: CONFIG_KASAN_INLINE enabled
[  554.898724] kasan: GPF could be caused by NULL-ptr deref or user memory access
[  554.898732] general protection fault: 0000 [#1] SMP KASAN
[  554.898737] Dumping ftrace buffer:
[  554.898741]    (ftrace buffer empty)
[  554.898743] Modules linked in:
[  554.898752] CPU: 1 PID: 13231 Comm: syz-executor1 Not tainted 4.14.0-rc8+ #82
[  554.898755] Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
[  554.898760] task: ffff8801d1dbe5c0 task.stack: ffff8801c9e38000
[  554.898772] RIP: 0010:__list_del_entry_valid+0x7e/0x150
[  554.898775] RSP: 0018:ffff8801c9e3f108 EFLAGS: 00010246
[  554.898780] RAX: dffffc0000000000 RBX: 0000000000000000 RCX: 0000000000000000
[  554.898784] RDX: 0000000000000000 RSI: ffff8801c53c6f98 RDI: ffff8801c53c6fa0
[  554.898788] RBP: ffff8801c9e3f120 R08: 1ffff100393c7d55 R09: 0000000000000004
[  554.898791] R10: ffff8801c9e3ef70 R11: 0000000000000000 R12: 0000000000000000
[  554.898795] R13: dffffc0000000000 R14: 1ffff100393c7e45 R15: ffff8801c53c6f98
[  554.898800] FS:  0000000000000000(0000) GS:ffff8801db300000(0000) knlGS:0000000000000000
[  554.898804] CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
[  554.898807] CR2: 00000000dbc23000 CR3: 00000001c7269000 CR4: 00000000001406e0
[  554.898813] DR0: 0000000020000000 DR1: 0000000020000000 DR2: 0000000000000000
[  554.898816] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
[  554.898818] Call Trace:
[  554.898828]  unregister_shrinker+0x79/0x300
[  554.898837]  ? perf_trace_mm_vmscan_writepage+0x750/0x750
[  554.898844]  ? down_write+0x87/0x120
[  554.898851]  ? deactivate_super+0x139/0x1b0
[  554.898857]  ? down_read+0x150/0x150
[  554.898864]  ? check_same_owner+0x320/0x320
[  554.898875]  deactivate_locked_super+0x64/0xd0
[  554.898883]  deactivate_super+0x141/0x1b0
[  554.898893]  ? mount_ns+0x190/0x190
[  554.898901]  ? dput.part.24+0x175/0x740
[  554.898912]  cleanup_mnt+0xb2/0x150
[  554.898919]  mntput_no_expire+0x6e0/0xa90
[  554.898926]  ? call_rcu_bh+0x20/0x20
[  554.898934]  ? mnt_get_count+0x150/0x150
[  554.898942]  ? trace_raw_output_rcu_utilization+0xb0/0xb0
[  554.898954]  ? __might_sleep+0x95/0x190
[  554.898964]  kern_unmount+0x9c/0xd0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
