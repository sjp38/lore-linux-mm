Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 63FC06B0254
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 07:13:08 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so114290825pac.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 04:13:08 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id is9si36921344pbc.208.2015.09.21.04.13.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 04:13:07 -0700 (PDT)
Subject: Re: [PATCH] mm, vmscan: Warn about possible deadlock at shirink_inactive_list
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1442833794-23117-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1442833794-23117-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201509212013.HGH18247.JOFOQMSVFLOFtH@I-love.SAKURA.ne.jp>
Date: Mon, 21 Sep 2015 20:13:04 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
Cc: xfs@oss.sgi.com, linux-mm@kvack.org

(Oops. I forgot to append below description.)

David, I got a backtrace where the system stalled forever with 0% CPU usage
because all memory allocating tasks are sleeping at congestion_wait()
in shrink_inactive_list() without triggering the OOM killer
(uptime > 100 of http://I-love.SAKURA.ne.jp/tmp/serial-20150920.txt.xz ).
Could you please have a look whether this is really a deadlock.
(Even if it was not a deadlock, sleeping for 2 minutes at congestion_wait()
is unusable...)

Tetsuo Handa wrote:
> This is a difficult-to-trigger silent hang up bug.
> 
> The kswapd is allowed to bypass too_many_isolated() check in
> shrink_inactive_list(). But the kswapd can be blocked by locks in
> shrink_page_list() in shrink_inactive_list(). If the task which is
> blocking the kswapd is trying to allocate memory with the locks held,
> it forms memory reclaim deadlock.
> 
> ----------
> [  142.870301] kswapd0         D ffff88007fcd5b80     0    51      2 0x00000000
> [  142.871941]  ffff88007c98f660 0000000000000046 ffff88007cde4c80 ffff88007c990000
> [  142.873772]  ffff880035d08b40 ffff880035d08b58 ffff880079e4a828 ffff88007c98f890
> [  142.875544]  ffff88007c98f678 ffffffff81632c68 ffff88007cde4c80 ffff88007c98f6d8
> [  142.877338] Call Trace:
> [  142.878220]  [<ffffffff81632c68>] schedule+0x38/0x90
> [  142.879477]  [<ffffffff81636163>] rwsem_down_read_failed+0xd3/0x140
> [  142.880937]  [<ffffffff81328314>] call_rwsem_down_read_failed+0x14/0x30
> [  142.882595]  [<ffffffff81635b12>] ? down_read+0x12/0x20
> [  142.883882]  [<ffffffff8126488b>] xfs_log_commit_cil+0x5b/0x460
> [  142.885326]  [<ffffffff8125f67b>] __xfs_trans_commit+0x10b/0x1f0
> [  142.886756]  [<ffffffff8125f9eb>] xfs_trans_commit+0xb/0x10
> [  142.888085]  [<ffffffff81251505>] xfs_iomap_write_allocate+0x165/0x320
> [  142.889657]  [<ffffffff8123f4aa>] xfs_map_blocks+0x15a/0x170
> [  142.891002]  [<ffffffff8124045b>] xfs_vm_writepage+0x18b/0x5a0
> [  142.892372]  [<ffffffff811295bc>] pageout.isra.42+0x18c/0x250
> [  142.893813]  [<ffffffff8112a720>] shrink_page_list+0x650/0xa10
> [  142.895182]  [<ffffffff8112b1f2>] shrink_inactive_list+0x1f2/0x560
> [  142.896606]  [<ffffffff8112bedf>] shrink_lruvec+0x59f/0x760
> [  142.898037]  [<ffffffff8112c146>] shrink_zone+0xa6/0x2d0
> [  142.899320]  [<ffffffff8112d162>] kswapd+0x4c2/0x8e0
> [  142.900545]  [<ffffffff8112cca0>] ? mem_cgroup_shrink_node_zone+0xe0/0xe0
> [  142.902152]  [<ffffffff81086fb3>] kthread+0xd3/0xf0
> [  142.903381]  [<ffffffff81086ee0>] ? kthread_create_on_node+0x1a0/0x1a0
> [  142.904919]  [<ffffffff81637b9f>] ret_from_fork+0x3f/0x70
> [  142.906237]  [<ffffffff81086ee0>] ? kthread_create_on_node+0x1a0/0x1a0
> (...snipped...)
> [  148.995189] a.out           D ffffffff813360c7     0  7821   7788 0x00000080
> [  148.996854]  ffff88007c6b73d8 0000000000000086 ffff880078e7f2c0 ffff88007c6b8000
> [  148.998583]  ffff88007c6b7410 ffff88007fc8dfc0 00000000fffd94f9 0000000000000002
> [  149.000560]  ffff88007c6b73f0 ffffffff81632c68 ffff88007fc8dfc0 ffff88007c6b7470
> [  149.002415] Call Trace:
> [  149.003285]  [<ffffffff81632c68>] schedule+0x38/0x90
> [  149.004624]  [<ffffffff816366e2>] schedule_timeout+0x122/0x1c0
> [  149.006003]  [<ffffffff8108fc63>] ? preempt_count_add+0x43/0x90
> [  149.007412]  [<ffffffff810c81b0>] ? cascade+0x90/0x90
> [  149.008704]  [<ffffffff81632291>] io_schedule_timeout+0xa1/0x110
> [  149.010109]  [<ffffffff811359bd>] congestion_wait+0x7d/0xd0
> [  149.011536]  [<ffffffff810a64a0>] ? wait_woken+0x80/0x80
> [  149.012891]  [<ffffffff8112b519>] shrink_inactive_list+0x519/0x560
> [  149.014327]  [<ffffffff8109aa6e>] ? check_preempt_wakeup+0x10e/0x1f0
> [  149.015867]  [<ffffffff8112bedf>] shrink_lruvec+0x59f/0x760
> [  149.017340]  [<ffffffff8117bb4f>] ? mem_cgroup_iter+0xef/0x4e0
> [  149.018742]  [<ffffffff8112c146>] shrink_zone+0xa6/0x2d0
> [  149.020150]  [<ffffffff8112c6e4>] do_try_to_free_pages+0x164/0x420
> [  149.021605]  [<ffffffff8112ca34>] try_to_free_pages+0x94/0xc0
> [  149.022968]  [<ffffffff8112101b>] __alloc_pages_nodemask+0x4fb/0x930
> [  149.024476]  [<ffffffff811626bc>] alloc_pages_current+0x8c/0x100
> [  149.025883]  [<ffffffff81169b68>] new_slab+0x458/0x4d0
> [  149.027209]  [<ffffffff8116bdbe>] ___slab_alloc+0x49e/0x610
> [  149.028580]  [<ffffffff81260014>] ? kmem_alloc+0x74/0xe0
> [  149.029864]  [<ffffffff81099548>] ? update_curr+0x58/0xe0
> [  149.031327]  [<ffffffff8109969d>] ? update_cfs_shares+0xad/0xf0
> [  149.032808]  [<ffffffff81099af9>] ? dequeue_entity+0x1e9/0x800
> [  149.034301]  [<ffffffff811889be>] __slab_alloc.isra.67+0x53/0x6f
> [  149.035780]  [<ffffffff81260014>] ? kmem_alloc+0x74/0xe0
> [  149.037076]  [<ffffffff81260014>] ? kmem_alloc+0x74/0xe0
> [  149.038344]  [<ffffffff8116c23d>] __kmalloc+0x14d/0x1a0
> [  149.039677]  [<ffffffff81260014>] kmem_alloc+0x74/0xe0
> [  149.040940]  [<ffffffff81264b82>] xfs_log_commit_cil+0x352/0x460
> [  149.042321]  [<ffffffff8125f67b>] __xfs_trans_commit+0x10b/0x1f0
> [  149.043733]  [<ffffffff8125f9eb>] xfs_trans_commit+0xb/0x10
> [  149.045065]  [<ffffffff81251b9f>] xfs_vn_update_time+0xdf/0x130
> [  149.046430]  [<ffffffff811a4768>] file_update_time+0xb8/0x110
> [  149.047833]  [<ffffffff81249cde>] xfs_file_aio_write_checks+0x16e/0x1c0
> [  149.049386]  [<ffffffff8124a089>] xfs_file_buffered_aio_write+0x79/0x1f0
> [  149.051031]  [<ffffffff81636fd5>] ? _raw_spin_lock_irqsave+0x25/0x50
> [  149.052581]  [<ffffffff8163709f>] ? _raw_spin_unlock_irqrestore+0x1f/0x40
> [  149.054084]  [<ffffffff8124a274>] xfs_file_write_iter+0x74/0x110
> [  149.055729]  [<ffffffff8118ada7>] __vfs_write+0xc7/0x100
> [  149.057023]  [<ffffffff8118b574>] vfs_write+0xa4/0x190
> [  149.058330]  [<ffffffff8118c200>] SyS_write+0x50/0xc0
> [  149.059553]  [<ffffffff811b7c78>] ? do_fsync+0x38/0x60
> [  149.060811]  [<ffffffff8163782e>] entry_SYSCALL_64_fastpath+0x12/0x71
> (...snipped...)
> [  264.199092] kswapd0         D ffff88007fcd5b80     0    51      2 0x00000000
> [  264.200724]  ffff88007c98f660 0000000000000046 ffff88007cde4c80 ffff88007c990000
> [  264.202469]  ffff880035d08b40 ffff880035d08b58 ffff880079e4a828 ffff88007c98f890
> [  264.204233]  ffff88007c98f678 ffffffff81632c68 ffff88007cde4c80 ffff88007c98f6d8
> [  264.206173] Call Trace:
> [  264.207202]  [<ffffffff81632c68>] schedule+0x38/0x90
> [  264.208536]  [<ffffffff81636163>] rwsem_down_read_failed+0xd3/0x140
> [  264.210044]  [<ffffffff81328314>] call_rwsem_down_read_failed+0x14/0x30
> [  264.211602]  [<ffffffff81635b12>] ? down_read+0x12/0x20
> [  264.212929]  [<ffffffff8126488b>] xfs_log_commit_cil+0x5b/0x460
> [  264.214369]  [<ffffffff8125f67b>] __xfs_trans_commit+0x10b/0x1f0
> [  264.215820]  [<ffffffff8125f9eb>] xfs_trans_commit+0xb/0x10
> [  264.217193]  [<ffffffff81251505>] xfs_iomap_write_allocate+0x165/0x320
> [  264.218721]  [<ffffffff8123f4aa>] xfs_map_blocks+0x15a/0x170
> [  264.220109]  [<ffffffff8124045b>] xfs_vm_writepage+0x18b/0x5a0
> [  264.221586]  [<ffffffff811295bc>] pageout.isra.42+0x18c/0x250
> [  264.222989]  [<ffffffff8112a720>] shrink_page_list+0x650/0xa10
> [  264.224404]  [<ffffffff8112b1f2>] shrink_inactive_list+0x1f2/0x560
> [  264.225876]  [<ffffffff8112bedf>] shrink_lruvec+0x59f/0x760
> [  264.227248]  [<ffffffff8112c146>] shrink_zone+0xa6/0x2d0
> [  264.228573]  [<ffffffff8112d162>] kswapd+0x4c2/0x8e0
> [  264.229840]  [<ffffffff8112cca0>] ? mem_cgroup_shrink_node_zone+0xe0/0xe0
> [  264.231407]  [<ffffffff81086fb3>] kthread+0xd3/0xf0
> [  264.232662]  [<ffffffff81086ee0>] ? kthread_create_on_node+0x1a0/0x1a0
> [  264.234185]  [<ffffffff81637b9f>] ret_from_fork+0x3f/0x70
> [  264.235527]  [<ffffffff81086ee0>] ? kthread_create_on_node+0x1a0/0x1a0
> (...snipped...)
> [  270.339774] a.out           D ffffffff813360c7     0  7821   7788 0x00000080
> [  270.341391]  ffff88007c6b73d8 0000000000000086 ffff880078e7f2c0 ffff88007c6b8000
> [  270.343114]  ffff88007c6b7410 ffff88007fc4dfc0 00000000ffff8b29 0000000000000002
> [  270.344859]  ffff88007c6b73f0 ffffffff81632c68 ffff88007fc4dfc0 ffff88007c6b7470
> [  270.346670] Call Trace:
> [  270.347608]  [<ffffffff81632c68>] schedule+0x38/0x90
> [  270.348929]  [<ffffffff816366e2>] schedule_timeout+0x122/0x1c0
> [  270.350354]  [<ffffffff8108fc63>] ? preempt_count_add+0x43/0x90
> [  270.351790]  [<ffffffff810c81b0>] ? cascade+0x90/0x90
> [  270.353106]  [<ffffffff81632291>] io_schedule_timeout+0xa1/0x110
> [  270.354558]  [<ffffffff811359bd>] congestion_wait+0x7d/0xd0
> [  270.355958]  [<ffffffff810a64a0>] ? wait_woken+0x80/0x80
> [  270.357298]  [<ffffffff8112b519>] shrink_inactive_list+0x519/0x560
> [  270.358779]  [<ffffffff8109aa6e>] ? check_preempt_wakeup+0x10e/0x1f0
> [  270.360307]  [<ffffffff8112bedf>] shrink_lruvec+0x59f/0x760
> [  270.361687]  [<ffffffff8117bb4f>] ? mem_cgroup_iter+0xef/0x4e0
> [  270.363147]  [<ffffffff8112c146>] shrink_zone+0xa6/0x2d0
> [  270.364462]  [<ffffffff8112c6e4>] do_try_to_free_pages+0x164/0x420
> [  270.365898]  [<ffffffff8112ca34>] try_to_free_pages+0x94/0xc0
> [  270.367261]  [<ffffffff8112101b>] __alloc_pages_nodemask+0x4fb/0x930
> [  270.368744]  [<ffffffff811626bc>] alloc_pages_current+0x8c/0x100
> [  270.370151]  [<ffffffff81169b68>] new_slab+0x458/0x4d0
> [  270.371420]  [<ffffffff8116bdbe>] ___slab_alloc+0x49e/0x610
> [  270.372769]  [<ffffffff81260014>] ? kmem_alloc+0x74/0xe0
> [  270.374053]  [<ffffffff81099548>] ? update_curr+0x58/0xe0
> [  270.375351]  [<ffffffff8109969d>] ? update_cfs_shares+0xad/0xf0
> [  270.376748]  [<ffffffff81099af9>] ? dequeue_entity+0x1e9/0x800
> [  270.378200]  [<ffffffff811889be>] __slab_alloc.isra.67+0x53/0x6f
> [  270.379604]  [<ffffffff81260014>] ? kmem_alloc+0x74/0xe0
> [  270.380879]  [<ffffffff81260014>] ? kmem_alloc+0x74/0xe0
> [  270.382148]  [<ffffffff8116c23d>] __kmalloc+0x14d/0x1a0
> [  270.383424]  [<ffffffff81260014>] kmem_alloc+0x74/0xe0
> [  270.384668]  [<ffffffff81264b82>] xfs_log_commit_cil+0x352/0x460
> [  270.386049]  [<ffffffff8125f67b>] __xfs_trans_commit+0x10b/0x1f0
> [  270.387449]  [<ffffffff8125f9eb>] xfs_trans_commit+0xb/0x10
> [  270.388761]  [<ffffffff81251b9f>] xfs_vn_update_time+0xdf/0x130
> [  270.390126]  [<ffffffff811a4768>] file_update_time+0xb8/0x110
> [  270.391484]  [<ffffffff81249cde>] xfs_file_aio_write_checks+0x16e/0x1c0
> [  270.392962]  [<ffffffff8124a089>] xfs_file_buffered_aio_write+0x79/0x1f0
> [  270.394728]  [<ffffffff81636fd5>] ? _raw_spin_lock_irqsave+0x25/0x50
> [  270.396218]  [<ffffffff8163709f>] ? _raw_spin_unlock_irqrestore+0x1f/0x40
> [  270.397769]  [<ffffffff8124a274>] xfs_file_write_iter+0x74/0x110
> [  270.399194]  [<ffffffff8118ada7>] __vfs_write+0xc7/0x100
> [  270.400507]  [<ffffffff8118b574>] vfs_write+0xa4/0x190
> [  270.401788]  [<ffffffff8118c200>] SyS_write+0x50/0xc0
> [  270.403048]  [<ffffffff811b7c78>] ? do_fsync+0x38/0x60
> [  270.404324]  [<ffffffff8163782e>] entry_SYSCALL_64_fastpath+0x12/0x71
> ----------
> 
> While OOM-killer deadlock shows OOM-killer messages and CPU usage remains
> 100%, this hang up shows no kernel messages and CPU usage remains 0% as if
> the system is completely idle.
> 
> This patch shows progress of shrinking inactive list in order to assist
> warning about possible deadlock. So far I haven't succeeded to reproduce
> this bug after applying this patch; excuse me for output messages example
> is not available.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/vmscan.c | 45 +++++++++++++++++++++++++++++++--------------
>  1 file changed, 31 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index db5339d..0464537 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1476,20 +1476,12 @@ int isolate_lru_page(struct page *page)
>  	return ret;
>  }
>  
> -static int __too_many_isolated(struct zone *zone, int file,
> -			       struct scan_control *sc, int safe)
> +static inline unsigned long inactive_pages(struct zone *zone, int file,
> +					   struct scan_control *sc, int safe)
>  {
> -	unsigned long inactive, isolated;
> -
> -	if (safe) {
> -		inactive = zone_page_state_snapshot(zone,
> -				NR_INACTIVE_ANON + 2 * file);
> -		isolated = zone_page_state_snapshot(zone,
> -				NR_ISOLATED_ANON + file);
> -	} else {
> -		inactive = zone_page_state(zone, NR_INACTIVE_ANON + 2 * file);
> -		isolated = zone_page_state(zone, NR_ISOLATED_ANON + file);
> -	}
> +	unsigned long inactive = safe ?
> +		zone_page_state_snapshot(zone, NR_INACTIVE_ANON + 2 * file) :
> +		zone_page_state(zone, NR_INACTIVE_ANON + 2 * file);
>  
>  	/*
>  	 * GFP_NOIO/GFP_NOFS callers are allowed to isolate more pages, so they
> @@ -1498,8 +1490,21 @@ static int __too_many_isolated(struct zone *zone, int file,
>  	 */
>  	if ((sc->gfp_mask & GFP_IOFS) == GFP_IOFS)
>  		inactive >>= 3;
> +	return inactive;
> +}
>  
> -	return isolated > inactive;
> +static inline unsigned long isolated_pages(struct zone *zone, int file,
> +					   int safe)
> +{
> +	return safe ? zone_page_state_snapshot(zone, NR_ISOLATED_ANON + file) :
> +		zone_page_state(zone, NR_ISOLATED_ANON + file);
> +}
> +
> +static int __too_many_isolated(struct zone *zone, int file,
> +			       struct scan_control *sc, int safe)
> +{
> +	return isolated_pages(zone, file, safe) >
> +		inactive_pages(zone, file, sc, safe);
>  }
>  
>  /*
> @@ -1619,8 +1624,20 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	int file = is_file_lru(lru);
>  	struct zone *zone = lruvec_zone(lruvec);
>  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> +	unsigned long start = jiffies;
> +	unsigned long prev = start + 30 * HZ;
>  
>  	while (unlikely(too_many_isolated(zone, file, sc))) {
> +		unsigned long now = jiffies;
> +
> +		if (time_after(now, prev)) {
> +			pr_warn("vmscan: %s(%u) is waiting for %lu seconds at %s (mode:0x%x,isolated:%lu,inactive:%lu)\n",
> +				current->comm, current->pid, (now - start) / HZ,
> +				__func__, sc->gfp_mask,
> +				isolated_pages(zone, file, 1),
> +				inactive_pages(zone, file, sc, 1));
> +			prev = now + 30 * HZ;
> +		}
>  		congestion_wait(BLK_RW_ASYNC, HZ/10);
>  
>  		/* We are about to die and free our memory. Return now. */
> -- 
> 1.8.3.1
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
