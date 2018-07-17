Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id C14BF6B0006
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 15:11:11 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id q18-v6so1098571pll.3
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:11:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l22-v6sor497944pgo.200.2018.07.17.12.11.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Jul 2018 12:11:10 -0700 (PDT)
Date: Tue, 17 Jul 2018 12:11:07 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: kernel BUG at mm/vmscan.c:LINE!
Message-ID: <20180717191107.GG75957@gmail.com>
References: <0000000000008b09c20570638d45@google.com>
 <eaa5aba7-439b-6c59-0ba3-b70438d03e00@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <eaa5aba7-439b-6c59-0ba3-b70438d03e00@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: syzbot <syzbot+93c67806397421af04d5@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aryabinin@virtuozzo.com, guro@fb.com, hannes@cmpxchg.org, jbacik@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, penguin-kernel@I-love.SAKURA.ne.jp, rientjes@google.com, sfr@canb.auug.org.au, shakeelb@google.com, syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com, willy@infradead.org, ying.huang@intel.com

On Sun, Jul 08, 2018 at 05:50:47PM +0300, Kirill Tkhai wrote:
> On 07.07.2018 10:16, syzbot wrote:
> > Hello,
> > 
> > syzbot found the following crash on:
> > 
> > HEAD commit:    526674536360 Add linux-next specific files for 20180706
> > git tree:       linux-next
> > console output: https://syzkaller.appspot.com/x/log.txt?x=13853f48400000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=c8d1cfc0cb798e48
> > dashboard link: https://syzkaller.appspot.com/bug?extid=93c67806397421af04d5
> > compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> > 
> > Unfortunately, I don't have any reproducer for this crash yet.
> > 
> > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > Reported-by: syzbot+93c67806397421af04d5@syzkaller.appspotmail.com
> > 
> > ------------[ cut here ]------------
> > kernel BUG at mm/vmscan.c:593!
> > invalid opcode: 0000 [#1] SMP KASAN
> > CPU: 0 PID: 5039 Comm: syz-executor5 Not tainted 4.18.0-rc3-next-20180706+ #1
> > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
> > RIP: 0010:shrink_slab_memcg mm/vmscan.c:593 [inline]
> > RIP: 0010:shrink_slab+0xb3e/0xdb0 mm/vmscan.c:672
> > Code: 8d a8 fd ff ff f0 48 0f b3 08 e8 3d b8 da ff 48 8b 85 c0 fd ff ff c7 00 f8 f8 f8 f8 c6 40 04 f8 e9 5d fb ff ff e8 22 b8 da ff <0f> 0b e8 1b b8 da ff 48 8b 9d d8 fd ff ff 31 ff 48 89 de e8 3a b9
> > RSP: 0018:ffff88019aa0eb50 EFLAGS: 00010212
> > RAX: 0000000000040000 RBX: ffff88019aa0eda0 RCX: ffffc90001e24000
> > RDX: 0000000000000b7a RSI: ffffffff81a1c23e RDI: 0000000000000007
> > RBP: ffff88019aa0edc8 R08: ffff88019ed86340 R09: ffffed00399ff4b8
> > R10: ffffed00399ff4b8 R11: ffff8801ccffa5c7 R12: dffffc0000000000
> > R13: ffff8801cc3231f0 R14: 0000000000000000 R15: ffff88019aa0ebe0
> > FS:  00007fa51a834700(0000) GS:ffff8801dae00000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 00007fa51a803008 CR3: 00000001ad011000 CR4: 00000000001406f0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> > Call Trace:
> >  shrink_node+0x429/0x16a0 mm/vmscan.c:2736
> >  shrink_zones mm/vmscan.c:2965 [inline]
> >  do_try_to_free_pages+0x3e7/0x1290 mm/vmscan.c:3027
> >  try_to_free_mem_cgroup_pages+0x49d/0xc90 mm/vmscan.c:3325
> >  memory_high_write+0x283/0x310 mm/memcontrol.c:5597
> >  cgroup_file_write+0x31f/0x840 kernel/cgroup/cgroup.c:3500
> >  kernfs_fop_write+0x2ba/0x480 fs/kernfs/file.c:316
> >  __vfs_write+0x117/0x9f0 fs/read_write.c:485
> >  __kernel_write+0x10c/0x370 fs/read_write.c:506
> >  write_pipe_buf+0x181/0x240 fs/splice.c:798
> >  splice_from_pipe_feed fs/splice.c:503 [inline]
> >  __splice_from_pipe+0x38e/0x7c0 fs/splice.c:627
> >  splice_from_pipe+0x1ea/0x340 fs/splice.c:662
> >  default_file_splice_write+0x3c/0x90 fs/splice.c:810
> >  do_splice_from fs/splice.c:852 [inline]
> >  direct_splice_actor+0x128/0x190 fs/splice.c:1019
> >  splice_direct_to_actor+0x318/0x8f0 fs/splice.c:974
> >  do_splice_direct+0x2d4/0x420 fs/splice.c:1062
> >  do_sendfile+0x62a/0xe20 fs/read_write.c:1440
> >  __do_sys_sendfile64 fs/read_write.c:1495 [inline]
> >  __se_sys_sendfile64 fs/read_write.c:1487 [inline]
> >  __x64_sys_sendfile64+0x15d/0x250 fs/read_write.c:1487
> >  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
> >  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > RIP: 0033:0x455ba9
> > Code: 1d ba fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83 eb b9 fb ff c3 66 2e 0f 1f 84 00 00 00 00
> > RSP: 002b:00007fa51a833c68 EFLAGS: 00000246 ORIG_RAX: 0000000000000028
> > RAX: ffffffffffffffda RBX: 00007fa51a8346d4 RCX: 0000000000455ba9
> > RDX: 0000000020000040 RSI: 0000000000000015 RDI: 0000000000000015
> > RBP: 000000000072bea0 R08: 0000000000000000 R09: 0000000000000000
> > R10: 0000000000000001 R11: 0000000000000246 R12: 00000000ffffffff
> > R13: 00000000004c0dc5 R14: 00000000004d0e78 R15: 0000000000000000
> > Modules linked in:
> > Dumping ftrace buffer:
> >    (ftrace buffer empty)
> > ---[ end trace 607c0e9f278af1e6 ]---
> > RIP: 0010:shrink_slab_memcg mm/vmscan.c:593 [inline]
> > RIP: 0010:shrink_slab+0xb3e/0xdb0 mm/vmscan.c:672
> > Code: 8d a8 fd ff ff f0 48 0f b3 08 e8 3d b8 da ff 48 8b 85 c0 fd ff ff c7 00 f8 f8 f8 f8 c6 40 04 f8 e9 5d fb ff ff e8 22 b8 da ff <0f> 0b e8 1b b8 da ff 48 8b 9d d8 fd ff ff 31 ff 48 89 de e8 3a b9
> > RSP: 0018:ffff88019aa0eb50 EFLAGS: 00010212
> > RAX: 0000000000040000 RBX: ffff88019aa0eda0 RCX: ffffc90001e24000
> > RDX: 0000000000000b7a RSI: ffffffff81a1c23e RDI: 0000000000000007
> > RBP: ffff88019aa0edc8 R08: ffff88019ed86340 R09: ffffed00399ff4b8
> > R10: ffffed00399ff4b8 R11: ffff8801ccffa5c7 R12: dffffc0000000000
> > R13: ffff8801cc3231f0 R14: 0000000000000000 R15: ffff88019aa0ebe0
> > FS:  00007fa51a834700(0000) GS:ffff8801dae00000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 00007fa51a803008 CR3: 00000001ad011000 CR4: 00000000001406f0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> 
> I've found two potential places, which may result in memory problems.
> We need to do INIT_LIST_HEAD() before preallocation of memcg shrinker
> to prevent shrinker to pick it before register_shrinker_prepared()
> is finished.
> 
> Also, nr_deffered has to be freed after the shrinker is unregistered,
> not before.
> 
> ---
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index e385dcb278c9..f8a3b7f99132 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -362,11 +363,6 @@ int prealloc_shrinker(struct shrinker *shrinker)
>  	if (!shrinker->nr_deferred)
>  		return -ENOMEM;
>  
> -	if (shrinker->flags & SHRINKER_MEMCG_AWARE) {
> -		if (prealloc_memcg_shrinker(shrinker))
> -			goto free_deferred;
> -	}
> -
>  	/*
>  	 * There is a window between prealloc_shrinker()
>  	 * and register_shrinker_prepared(). We don't want
> @@ -381,6 +377,12 @@ int prealloc_shrinker(struct shrinker *shrinker)
>  	 * is not registered (id is not assigned).
>  	 */
>  	INIT_LIST_HEAD(&shrinker->list);
> +
> +	if (shrinker->flags & SHRINKER_MEMCG_AWARE) {
> +		if (prealloc_memcg_shrinker(shrinker))
> +			goto free_deferred;
> +	}
> +
>  	return 0;
>  
>  free_deferred:
> @@ -394,11 +396,11 @@ void free_prealloced_shrinker(struct shrinker *shrinker)
>  	if (!shrinker->nr_deferred)
>  		return;
>  
> -	kfree(shrinker->nr_deferred);
> -	shrinker->nr_deferred = NULL;
> -
>  	if (shrinker->flags & SHRINKER_MEMCG_AWARE)
>  		unregister_memcg_shrinker(shrinker);
> +
> +	kfree(shrinker->nr_deferred);
> +	shrinker->nr_deferred = NULL;
>  }
>  
>  void register_shrinker_prepared(struct shrinker *shrinker)
> @@ -569,13 +571,10 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
>  	if (!down_read_trylock(&shrinker_rwsem))
>  		return 0;
>  
> -	/*
> -	 * 1) Caller passes only alive memcg, so map can't be NULL.
> -	 * 2) shrinker_rwsem protects from maps expanding.
> -	 */
>  	map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map,
>  					true);
> -	BUG_ON(!map);
> +	if (unlikely(!map))
> +		goto unlock;
>  
>  	for_each_set_bit(i, map->map, shrinker_nr_max) {
>  		struct shrink_control sc = {
> @@ -628,7 +626,7 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
>  			break;
>  		}
>  	}
> -
> +unlock:
>  	up_read(&shrinker_rwsem);
>  	return freed;
>  }

Kirill's fixes are now in -mm and linux-next as:

	mm-iterate-only-over-charged-shrinkers-during-memcg-shrink_slab-v9

and

	mm-assign-id-to-every-memcg-aware-shrinker-v9

They should later get folded into the original patches, so I'm invalidating this
bug report:

#syz invalid

- Eric
