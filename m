Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 19291800D8
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 06:41:07 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 31so4376815wru.0
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 03:41:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y71si725452wmd.200.2018.01.25.03.41.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Jan 2018 03:41:05 -0800 (PST)
Date: Thu, 25 Jan 2018 12:41:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
Message-ID: <20180125114104.GP28465@dhcp22.suse.cz>
References: <20171115140020.GA6771@cmpxchg.org>
 <20171115141113.2nw4c4nejermhckb@dhcp22.suse.cz>
 <201801250204.w0P24NKZ033992@www262.sakura.ne.jp>
 <20180125083604.GM28465@dhcp22.suse.cz>
 <201801251956.FAH73425.VFJLFFtSHOOMQO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201801251956.FAH73425.VFJLFFtSHOOMQO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, linux-mm@lists.ewheeler.net, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, akpm@linux-foundation.org, shakeelb@google.com, gthelen@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 25-01-18 19:56:59, Tetsuo Handa wrote:
[...]
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 1afb2af..9858449 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -410,6 +410,9 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  	return freed;
>  }
>  
> +struct lockdep_map __shrink_slab_map =
> +	STATIC_LOCKDEP_MAP_INIT("shrink_slab", &__shrink_slab_map);
> +
>  /**
>   * shrink_slab - shrink slab caches
>   * @gfp_mask: allocation context
> @@ -453,6 +456,8 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  		goto out;
>  	}
>  
> +	lock_map_acquire(&__shrink_slab_map);
> +
>  	list_for_each_entry(shrinker, &shrinker_list, list) {
>  		struct shrink_control sc = {
>  			.gfp_mask = gfp_mask,
> @@ -491,6 +496,8 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  		}
>  	}
>  
> +	lock_map_release(&__shrink_slab_map);
> +
>  	up_read(&shrinker_rwsem);
>  out:
>  	cond_resched();

I am not an expert on lockdep annotations. But is this something that
makes sense? Don't you need lock_acquire_shared otherwise it will simply
consider this a lockup if we succeed on trylock twice? But in any case
the trylock already notes any dependency as the lockdep is involved when
the lock is taken and we do not take any action otherwise. So what is
the point?

I am not familiar with XFS to read the lockdep trace properly.

[...]
 
> Normally shrinker_rwsem acts like a shared lock. But when
> register_shrinker()/unregister_shrinker() called down_write(),
> shrinker_rwsem suddenly starts acting like an exclusive lock.

How come? We only do trylock and that means that we won't take it
_after_ the write claims the lock.

> What is unfortunate is that down_write() is called independent of
> memory allocation requests. That is, shrinker_rwsem is essentially
> a mutex (and hence the debug patch shown above).
> 
> ----------------------------------------
> [<ffffffffac7538d3>] call_rwsem_down_write_failed+0x13/0x20
> [<ffffffffac1cb985>] register_shrinker+0x45/0xa0
> [<ffffffffac250f68>] sget_userns+0x468/0x4a0
> [<ffffffffac25106a>] mount_nodev+0x2a/0xa0
> [<ffffffffac251be4>] mount_fs+0x34/0x150
> [<ffffffffac2701f2>] vfs_kern_mount+0x62/0x120
> [<ffffffffac272a0e>] do_mount+0x1ee/0xc50
> [<ffffffffac27377e>] SyS_mount+0x7e/0xd0
> [<ffffffffac003831>] do_syscall_64+0x61/0x1a0
> [<ffffffffac80012c>] entry_SYSCALL64_slow_path+0x25/0x25
> [<ffffffffffffffff>] 0xffffffffffffffff
> ----------------------------------------
> 
> Therefore, I think that when do_shrink_slab() for GFP_KERNEL is in progress
> and down_read_trylock() starts failing because somebody else started waiting at
> down_write(), do_shrink_slab() for GFP_NOFS or GFP_NOIO cannot be called.
> Doesn't such race cause unexpected results?

This is really hard to tell. I would expect that a skipped shrinkers
would lead to an OOM killer sooner or later. As soon as the shrinker
managed memory is the only one left for reclaim then we should OOM.
And I do not see anything obvious that would prevent that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
