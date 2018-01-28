Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2EC066B0003
	for <linux-mm@kvack.org>; Sat, 27 Jan 2018 20:17:10 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id r65so2626369oih.19
        for <linux-mm@kvack.org>; Sat, 27 Jan 2018 17:17:10 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p43si154107otc.249.2018.01.27.17.17.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 27 Jan 2018 17:17:08 -0800 (PST)
Subject: Re: [4.15-rc9] fs_reclaim lockdep trace
References: <20180124013651.GA1718@codemonkey.org.uk>
 <20180127222433.GA24097@codemonkey.org.uk>
 <CA+55aFx6w9+C-WM9=xqsmnrMwKzDHeCwVNR5Lbnc9By00b6dzw@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <d726458d-3d3b-5580-ddfc-2914cbf756ba@I-love.SAKURA.ne.jp>
Date: Sun, 28 Jan 2018 10:16:02 +0900
MIME-Version: 1.0
In-Reply-To: <CA+55aFx6w9+C-WM9=xqsmnrMwKzDHeCwVNR5Lbnc9By00b6dzw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Dave Jones <davej@codemonkey.org.uk>, Peter Zijlstra <peterz@infradead.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Network Development <netdev@vger.kernel.org>

Linus Torvalds wrote:
> On Sat, Jan 27, 2018 at 2:24 PM, Dave Jones <davej@codemonkey.org.uk> wrote:
>> On Tue, Jan 23, 2018 at 08:36:51PM -0500, Dave Jones wrote:
>>  > Just triggered this on a server I was rsync'ing to.
>>
>> Actually, I can trigger this really easily, even with an rsync from one
>> disk to another.  Though that also smells a little like networking in
>> the traces. Maybe netdev has ideas.
> 
> Is this new to 4.15? Or is it just that you're testing something new?
> 
> If it's new and easy to repro, can you just bisect it? And if it isn't
> new, can you perhaps check whether it's new to 4.14 (ie 4.13 being
> ok)?
> 
> Because that fs_reclaim_acquire/release() debugging isn't new to 4.15,
> but it was rewritten for 4.14.. I'm wondering if that remodeling ended
> up triggering something.

--- linux-4.13.16/mm/page_alloc.c
+++ linux-4.14.15/mm/page_alloc.c
@@ -3527,53 +3519,12 @@
 			return true;
 	}
 	return false;
 }
 #endif /* CONFIG_COMPACTION */
 
-#ifdef CONFIG_LOCKDEP
-struct lockdep_map __fs_reclaim_map =
-	STATIC_LOCKDEP_MAP_INIT("fs_reclaim", &__fs_reclaim_map);
-
-static bool __need_fs_reclaim(gfp_t gfp_mask)
-{
-	gfp_mask = current_gfp_context(gfp_mask);
-
-	/* no reclaim without waiting on it */
-	if (!(gfp_mask & __GFP_DIRECT_RECLAIM))
-		return false;
-
-	/* this guy won't enter reclaim */
-	if ((current->flags & PF_MEMALLOC) && !(gfp_mask & __GFP_NOMEMALLOC))
-		return false;
-
-	/* We're only interested __GFP_FS allocations for now */
-	if (!(gfp_mask & __GFP_FS))
-		return false;
-
-	if (gfp_mask & __GFP_NOLOCKDEP)
-		return false;
-
-	return true;
-}
-
-void fs_reclaim_acquire(gfp_t gfp_mask)
-{
-	if (__need_fs_reclaim(gfp_mask))
-		lock_map_acquire(&__fs_reclaim_map);
-}
-EXPORT_SYMBOL_GPL(fs_reclaim_acquire);
-
-void fs_reclaim_release(gfp_t gfp_mask)
-{
-	if (__need_fs_reclaim(gfp_mask))
-		lock_map_release(&__fs_reclaim_map);
-}
-EXPORT_SYMBOL_GPL(fs_reclaim_release);
-#endif
-
 /* Perform direct synchronous page reclaim */
 static int
 __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 					const struct alloc_context *ac)
 {
 	struct reclaim_state reclaim_state;
@@ -3582,21 +3533,21 @@
 
 	cond_resched();
 
 	/* We now go into synchronous reclaim */
 	cpuset_memory_pressure_bump();
 	noreclaim_flag = memalloc_noreclaim_save();
-	fs_reclaim_acquire(gfp_mask);
+	lockdep_set_current_reclaim_state(gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
 	current->reclaim_state = &reclaim_state;
 
 	progress = try_to_free_pages(ac->zonelist, order, gfp_mask,
 								ac->nodemask);
 
 	current->reclaim_state = NULL;
-	fs_reclaim_release(gfp_mask);
+	lockdep_clear_current_reclaim_state();
 	memalloc_noreclaim_restore(noreclaim_flag);
 
 	cond_resched();
 
 	return progress;
 }

> 
> Adding PeterZ to the participants list in case he has ideas. I'm not
> seeing what would be the problem in that call chain from hell.
> 
>                Linus

Dave Jones wrote:
> ============================================
> WARNING: possible recursive locking detected
> 4.15.0-rc9-backup-debug+ #1 Not tainted
> --------------------------------------------
> sshd/24800 is trying to acquire lock:
>  (fs_reclaim){+.+.}, at: [<0000000084f438c2>] fs_reclaim_acquire.part.102+0x5/0x30
> 
> but task is already holding lock:
>  (fs_reclaim){+.+.}, at: [<0000000084f438c2>] fs_reclaim_acquire.part.102+0x5/0x30
> 
> other info that might help us debug this:
>  Possible unsafe locking scenario:
> 
>        CPU0
>        ----
>   lock(fs_reclaim);
>   lock(fs_reclaim);
> 
>  *** DEADLOCK ***
> 
>  May be due to missing lock nesting notation
> 
> 2 locks held by sshd/24800:
>  #0:  (sk_lock-AF_INET6){+.+.}, at: [<000000001a069652>] tcp_sendmsg+0x19/0x40
>  #1:  (fs_reclaim){+.+.}, at: [<0000000084f438c2>] fs_reclaim_acquire.part.102+0x5/0x30
> 
> stack backtrace:
> CPU: 3 PID: 24800 Comm: sshd Not tainted 4.15.0-rc9-backup-debug+ #1
> Call Trace:
>  dump_stack+0xbc/0x13f
>  __lock_acquire+0xa09/0x2040
>  lock_acquire+0x12e/0x350
>  fs_reclaim_acquire.part.102+0x29/0x30
>  kmem_cache_alloc+0x3d/0x2c0
>  alloc_extent_state+0xa7/0x410
>  __clear_extent_bit+0x3ea/0x570
>  try_release_extent_mapping+0x21a/0x260
>  __btrfs_releasepage+0xb0/0x1c0
>  btrfs_releasepage+0x161/0x170
>  try_to_release_page+0x162/0x1c0
>  shrink_page_list+0x1d5a/0x2fb0
>  shrink_inactive_list+0x451/0x940
>  shrink_node_memcg.constprop.88+0x4c9/0x5e0
>  shrink_node+0x12d/0x260
>  try_to_free_pages+0x418/0xaf0
>  __alloc_pages_slowpath+0x976/0x1790
>  __alloc_pages_nodemask+0x52c/0x5c0
>  new_slab+0x374/0x3f0
>  ___slab_alloc.constprop.81+0x47e/0x5a0
>  __slab_alloc.constprop.80+0x32/0x60
>  __kmalloc_track_caller+0x267/0x310
>  __kmalloc_reserve.isra.40+0x29/0x80
>  __alloc_skb+0xee/0x390
>  sk_stream_alloc_skb+0xb8/0x340
>  tcp_sendmsg_locked+0x8e6/0x1d30
>  tcp_sendmsg+0x27/0x40
>  inet_sendmsg+0xd0/0x310
>  sock_write_iter+0x17a/0x240
>  __vfs_write+0x2ab/0x380
>  vfs_write+0xfb/0x260
>  SyS_write+0xb6/0x140
>  do_syscall_64+0x1e5/0xc05
>  entry_SYSCALL64_slow_path+0x25/0x25

> ============================================
> WARNING: possible recursive locking detected
> 4.15.0-rc9-backup-debug+ #7 Not tainted
> --------------------------------------------
> snmpd/892 is trying to acquire lock:
>  (fs_reclaim){+.+.}, at: [<0000000002e4c185>] fs_reclaim_acquire.part.101+0x5/0x30
> 
> but task is already holding lock:
>  (fs_reclaim){+.+.}, at: [<0000000002e4c185>] fs_reclaim_acquire.part.101+0x5/0x30
> 
> other info that might help us debug this:
>  Possible unsafe locking scenario:
> 
>        CPU0
>        ----
>   lock(fs_reclaim);
>   lock(fs_reclaim);
> 
>  *** DEADLOCK ***
> 
>  May be due to missing lock nesting notation
> 
> 2 locks held by snmpd/892:
>  #0:  (rtnl_mutex){+.+.}, at: [<00000000dcd3ba2f>] netlink_dump+0x89/0x520
>  #1:  (fs_reclaim){+.+.}, at: [<0000000002e4c185>] fs_reclaim_acquire.part.101+0x5/0x30
> 
> stack backtrace:
> CPU: 5 PID: 892 Comm: snmpd Not tainted 4.15.0-rc9-backup-debug+ #7
> Call Trace:
>  dump_stack+0xbc/0x13f
>  __lock_acquire+0xa09/0x2040
>  lock_acquire+0x12e/0x350
>  fs_reclaim_acquire.part.101+0x29/0x30
>  kmem_cache_alloc+0x3d/0x2c0
>  alloc_extent_state+0xa7/0x410
>  __clear_extent_bit+0x3ea/0x570
>  try_release_extent_mapping+0x21a/0x260
>  __btrfs_releasepage+0xb0/0x1c0
>  btrfs_releasepage+0x161/0x170
>  try_to_release_page+0x162/0x1c0
>  shrink_page_list+0x1d5a/0x2fb0
>  shrink_inactive_list+0x451/0x940
>  shrink_node_memcg.constprop.84+0x4c9/0x5e0
>  shrink_node+0x1c2/0x510
>  try_to_free_pages+0x425/0xb90
>  __alloc_pages_slowpath+0x955/0x1a00
>  __alloc_pages_nodemask+0x52c/0x5c0
>  new_slab+0x374/0x3f0
>  ___slab_alloc.constprop.81+0x47e/0x5a0
>  __slab_alloc.constprop.80+0x32/0x60
>  __kmalloc_track_caller+0x267/0x310
>  __kmalloc_reserve.isra.40+0x29/0x80
>  __alloc_skb+0xee/0x390
>  netlink_dump+0x2e1/0x520
>  __netlink_dump_start+0x201/0x280
>  rtnetlink_rcv_msg+0x6d6/0xa90
>  netlink_rcv_skb+0xb6/0x1d0
>  netlink_unicast+0x298/0x320
>  netlink_sendmsg+0x57e/0x630
>  SYSC_sendto+0x296/0x320
>  do_syscall_64+0x1e5/0xc05
>  entry_SYSCALL64_slow_path+0x25/0x25
> RIP: 0033:0x7f204299f54d
> RSP: 002b:00007ffc49024fd8 EFLAGS: 00000246 ORIG_RAX: 000000000000002c
> RAX: ffffffffffffffda RBX: 000000000000000a RCX: 00007f204299f54d
> RDX: 0000000000000018 RSI: 00007ffc49025010 RDI: 0000000000000012
> RBP: 0000000000000001 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000012
> R13: 00007ffc49029550 R14: 000055e31307a250 R15: 00007ffc49029530

Both traces are identical and no fs locks held? And therefore,
doing GFP_KERNEL allocation should be safe (as long as there is
PF_MEMALLOC safeguard which prevents infinite recursion), isn't it?

Then, I think that "git bisect" should reach commit d92a8cfcb37ecd13
("locking/lockdep: Rework FS_RECLAIM annotation").

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
