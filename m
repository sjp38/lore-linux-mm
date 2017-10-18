Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 94CB86B0268
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 13:16:49 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id c36so6465055qtc.12
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 10:16:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t85si6974729qkt.371.2017.10.18.10.16.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 10:16:47 -0700 (PDT)
Date: Wed, 18 Oct 2017 20:16:44 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio: avoid possible OOM lockup at
 virtballoon_oom_notify()
Message-ID: <20171018201013-mutt-send-email-mst@kernel.org>
References: <201710140141.JFF26087.FLQHOFOOtFMVSJ@I-love.SAKURA.ne.jp>
 <20171015030921-mutt-send-email-mst@kernel.org>
 <201710151438.FAD86443.tOOFHVOSFQJLMF@I-love.SAKURA.ne.jp>
 <201710161958.IAE65151.HFOLMQSFOVFJtO@I-love.SAKURA.ne.jp>
 <20171016195317-mutt-send-email-mst@kernel.org>
 <201710181959.ACI05296.JLMVQOOFtHSOFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201710181959.ACI05296.JLMVQOOFtHSOFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, wei.w.wang@intel.com, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, rmaksudova@parallels.com, den@openvz.org

On Wed, Oct 18, 2017 at 07:59:23PM +0900, Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > 20171016-deflate.log.xz continued printing "puff" messages without any OOM
> > killer messages, for fill_balloon() always inflates faster than leak_balloon()
> > deflates.
> > 
> > Since the OOM killer cannot be invoked unless leak_balloon() completely
> > deflates faster than fill_balloon() inflates, the guest remained unusable
> > (e.g. unable to login via ssh) other than printing "puff" messages.
> > This result was worse than 20171016-default.log.xz , for the system was
> > not able to make any forward progress (i.e. complete OOM lockup).
> 
> I tested further and found that it is not complete OOM lockup.
> 
> It turned out that the reason of being unable to login via ssh was that fork()
> was failing because __vm_enough_memory() was failing because
> /proc/sys/vm/overcommit_memory was set to 0. Although virtio_balloon driver
> was ready to release pages if asked via virtballoon_oom_notify() from
> out_of_memory(), __vm_enough_memory() was not able to take such pages into
> account. As a result, operations which need to use fork() were failing without
> calling out_of_memory().
> ( http://lkml.kernel.org/r/201710181954.FHH51594.MtFOFLOQFSOHVJ@I-love.SAKURA.ne.jp )
> 
> Do you see anything wrong with the patch I used for emulating
> VIRTIO_BALLOON_F_DEFLATE_ON_OOM path (shown below) ?
> 
> ----------------------------------------
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index f0b3a0b..a679ac2 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -164,7 +164,7 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  		}
>  		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
>  		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
> -		if (!virtio_has_feature(vb->vdev,
> +		if (virtio_has_feature(vb->vdev,
>  					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
>  			adjust_managed_page_count(page, -1);
>  	}
> @@ -184,7 +184,7 @@ static void release_pages_balloon(struct virtio_balloon *vb,
>  	struct page *page, *next;
>  
>  	list_for_each_entry_safe(page, next, pages, lru) {
> -		if (!virtio_has_feature(vb->vdev,
> +		if (virtio_has_feature(vb->vdev,
>  					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
>  			adjust_managed_page_count(page, 1);
>  		list_del(&page->lru);
> @@ -363,7 +363,7 @@ static int virtballoon_oom_notify(struct notifier_block *self,
>  	unsigned num_freed_pages;
>  
>  	vb = container_of(self, struct virtio_balloon, nb);
> -	if (!virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
>  		return NOTIFY_OK;
>  
>  	freed = parm;
> ----------------------------------------

Looks right but it's probably easier to configure qemu to set that
feature bit. Basically you just add deflate-on-oom=on to the
balloon device.


> > As I demonstrated above, VIRTIO_BALLOON_F_DEFLATE_ON_OOM can lead to complete
> > OOM lockup because out_of_memory() => fill_balloon() => out_of_memory() =>
> > fill_balloon() sequence can effectively disable the OOM killer when the host
> > assumed that it's safe to inflate the balloon to a large portion of guest
> > memory and this won't cause an OOM situation.
> 
> The other problem is that, although it is not complete OOM lockup, it is too
> slow to wait if we hit out_of_memory() => fill_balloon() => out_of_memory() =>
> fill_balloon() sequence.
> 
> > If leak_balloon() from out_of_memory() should be stronger than
> > fill_balloon() from update_balloon_size_func(), we need to make
> > sure that update_balloon_size_func() stops calling fill_balloon()
> > when leak_balloon() was called from out_of_memory().
> 
> I tried below patch to reduce the possibility of hitting out_of_memory() =>
> fill_balloon() => out_of_memory() => fill_balloon() sequence.
> 
> ----------------------------------------
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index a679ac2..9037fee 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -57,7 +57,7 @@ struct virtio_balloon {
>  
>  	/* The balloon servicing is delegated to a freezable workqueue. */
>  	struct work_struct update_balloon_stats_work;
> -	struct work_struct update_balloon_size_work;
> +	struct delayed_work update_balloon_size_work;
>  
>  	/* Prevent updating balloon when it is being canceled. */
>  	spinlock_t stop_update_lock;
> @@ -88,6 +88,7 @@ struct virtio_balloon {
>  
>  	/* To register callback in oom notifier call chain */
>  	struct notifier_block nb;
> +	struct timer_list deflate_on_oom_timer;
>  };
>  
>  static struct virtio_device_id id_table[] = {
> @@ -141,7 +142,8 @@ static void set_page_pfns(struct virtio_balloon *vb,
>  					  page_to_balloon_pfn(page) + i);
>  }
>  
> -static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
> +static unsigned fill_balloon(struct virtio_balloon *vb, size_t num,
> +			     unsigned long *delay)
>  {
>  	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
>  	unsigned num_allocated_pages;
> @@ -152,14 +154,21 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  	mutex_lock(&vb->balloon_lock);
>  	for (vb->num_pfns = 0; vb->num_pfns < num;
>  	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
> -		struct page *page = balloon_page_enqueue(vb_dev_info);
> +		struct page *page;
> +
> +		if (timer_pending(&vb->deflate_on_oom_timer)) {
> +			/* Wait for hold off timer expiracy. */
> +			*delay = HZ;
> +			break;
> +		}
> +		page = balloon_page_enqueue(vb_dev_info);
>  
>  		if (!page) {
>  			dev_info_ratelimited(&vb->vdev->dev,
>  					     "Out of puff! Can't get %u pages\n",
>  					     VIRTIO_BALLOON_PAGES_PER_PAGE);
>  			/* Sleep for at least 1/5 of a second before retry. */
> -			msleep(200);
> +			*delay = HZ / 5;
>  			break;
>  		}
>  		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> @@ -310,7 +319,8 @@ static void virtballoon_changed(struct virtio_device *vdev)
>  
>  	spin_lock_irqsave(&vb->stop_update_lock, flags);
>  	if (!vb->stop_update)
> -		queue_work(system_freezable_wq, &vb->update_balloon_size_work);
> +		queue_delayed_work(system_freezable_wq,
> +				   &vb->update_balloon_size_work, 0);
>  	spin_unlock_irqrestore(&vb->stop_update_lock, flags);
>  }
>  
> @@ -366,9 +376,13 @@ static int virtballoon_oom_notify(struct notifier_block *self,
>  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
>  		return NOTIFY_OK;
>  
> +	/* Hold off fill_balloon() for 60 seconds. */
> +	mod_timer(&vb->deflate_on_oom_timer, jiffies + 60 * HZ);
>  	freed = parm;
>  	num_freed_pages = leak_balloon(vb, oom_pages);
>  	update_balloon_size(vb);
> +	dev_info_ratelimited(&vb->vdev->dev, "Released %u pages. Remains %u pages.\n",
> +			     num_freed_pages, vb->num_pages);
>  	*freed += num_freed_pages;
>  
>  	return NOTIFY_OK;
> @@ -387,19 +401,21 @@ static void update_balloon_size_func(struct work_struct *work)
>  {
>  	struct virtio_balloon *vb;
>  	s64 diff;
> +	unsigned long delay = 0;
>  
> -	vb = container_of(work, struct virtio_balloon,
> +	vb = container_of(to_delayed_work(work), struct virtio_balloon,
>  			  update_balloon_size_work);
>  	diff = towards_target(vb);
>  
>  	if (diff > 0)
> -		diff -= fill_balloon(vb, diff);
> +		diff -= fill_balloon(vb, diff, &delay);
>  	else if (diff < 0)
>  		diff += leak_balloon(vb, -diff);
>  	update_balloon_size(vb);
>  
>  	if (diff)
> -		queue_work(system_freezable_wq, work);
> +		queue_delayed_work(system_freezable_wq, to_delayed_work(work),
> +				   delay);
>  }
>  
>  static int init_vqs(struct virtio_balloon *vb)
> @@ -521,6 +537,10 @@ static struct dentry *balloon_mount(struct file_system_type *fs_type,
>  
>  #endif /* CONFIG_BALLOON_COMPACTION */
>  
> +static void timer_expired(unsigned long unused)
> +{
> +}
> +
>  static int virtballoon_probe(struct virtio_device *vdev)
>  {
>  	struct virtio_balloon *vb;
> @@ -539,7 +559,8 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  	}
>  
>  	INIT_WORK(&vb->update_balloon_stats_work, update_balloon_stats_func);
> -	INIT_WORK(&vb->update_balloon_size_work, update_balloon_size_func);
> +	INIT_DELAYED_WORK(&vb->update_balloon_size_work,
> +			  update_balloon_size_func);
>  	spin_lock_init(&vb->stop_update_lock);
>  	vb->stop_update = false;
>  	vb->num_pages = 0;
> @@ -553,6 +574,7 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  	if (err)
>  		goto out_free_vb;
>  
> +	setup_timer(&vb->deflate_on_oom_timer, timer_expired, 0);
>  	vb->nb.notifier_call = virtballoon_oom_notify;
>  	vb->nb.priority = VIRTBALLOON_OOM_NOTIFY_PRIORITY;
>  	err = register_oom_notifier(&vb->nb);
> @@ -564,6 +586,7 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  	if (IS_ERR(balloon_mnt)) {
>  		err = PTR_ERR(balloon_mnt);
>  		unregister_oom_notifier(&vb->nb);
> +		del_timer_sync(&vb->deflate_on_oom_timer);
>  		goto out_del_vqs;
>  	}
>  
> @@ -573,6 +596,7 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  		err = PTR_ERR(vb->vb_dev_info.inode);
>  		kern_unmount(balloon_mnt);
>  		unregister_oom_notifier(&vb->nb);
> +		del_timer_sync(&vb->deflate_on_oom_timer);
>  		vb->vb_dev_info.inode = NULL;
>  		goto out_del_vqs;
>  	}
> @@ -611,11 +635,12 @@ static void virtballoon_remove(struct virtio_device *vdev)
>  	struct virtio_balloon *vb = vdev->priv;
>  
>  	unregister_oom_notifier(&vb->nb);
> +	del_timer_sync(&vb->deflate_on_oom_timer);
>  
>  	spin_lock_irq(&vb->stop_update_lock);
>  	vb->stop_update = true;
>  	spin_unlock_irq(&vb->stop_update_lock);
> -	cancel_work_sync(&vb->update_balloon_size_work);
> +	cancel_delayed_work_sync(&vb->update_balloon_size_work);
>  	cancel_work_sync(&vb->update_balloon_stats_work);
>  
>  	remove_common(vb);
> ----------------------------------------

OK. Or if you use my patch, you can just set a flag and go
	if (vb->oom)
		msleep(1000);
at beginning of fill_balloon.



> While response was better than now, inflating again spoiled the effort.
> Retrying to inflate until allocation fails is already too painful.
> 
> Complete log is at http://I-love.SAKURA.ne.jp/tmp/20171018-deflate.log.xz .
> ----------------------------------------
> [   19.529096] kworker/0:2: page allocation failure: order:0, mode:0x14310ca(GFP_HIGHUSER_MOVABLE|__GFP_NORETRY|__GFP_NOMEMALLOC), nodemask=(null)
> [   19.530721] kworker/0:2 cpuset=/ mems_allowed=0
> [   19.531581] CPU: 0 PID: 111 Comm: kworker/0:2 Not tainted 4.14.0-rc5+ #302
> [   19.532397] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2011
> [   19.533285] Workqueue: events_freezable update_balloon_size_func [virtio_balloon]
> [   19.534143] Call Trace:
> [   19.535015]  dump_stack+0x63/0x87
> [   19.535844]  warn_alloc+0x114/0x1c0
> [   19.536667]  __alloc_pages_slowpath+0x9a6/0xba7
> [   19.537491]  ? sched_clock_cpu+0x11/0xb0
> [   19.538311]  __alloc_pages_nodemask+0x26a/0x290
> [   19.539188]  alloc_pages_current+0x6a/0xb0
> [   19.540004]  balloon_page_enqueue+0x25/0xf0
> [   19.540818]  update_balloon_size_func+0xe1/0x260 [virtio_balloon]
> [   19.541626]  process_one_work+0x149/0x360
> [   19.542417]  worker_thread+0x4d/0x3c0
> [   19.543186]  kthread+0x109/0x140
> [   19.543930]  ? rescuer_thread+0x380/0x380
> [   19.544716]  ? kthread_park+0x60/0x60
> [   19.545426]  ret_from_fork+0x25/0x30
> [   19.546141] virtio_balloon virtio3: Out of puff! Can't get 1 pages
> [   19.547903] virtio_balloon virtio3: Released 256 pages. Remains 1984834 pages.
> [   19.659660] virtio_balloon virtio3: Released 256 pages. Remains 1984578 pages.
> [   21.891392] virtio_balloon virtio3: Released 256 pages. Remains 1984322 pages.
> [   21.894719] virtio_balloon virtio3: Released 256 pages. Remains 1984066 pages.
> [   22.490131] virtio_balloon virtio3: Released 256 pages. Remains 1983810 pages.
> [   31.939666] virtio_balloon virtio3: Released 256 pages. Remains 1983554 pages.
> [   95.524753] kworker/0:2: page allocation failure: order:0, mode:0x14310ca(GFP_HIGHUSER_MOVABLE|__GFP_NORETRY|__GFP_NOMEMALLOC), nodemask=(null)
> [   95.525641] kworker/0:2 cpuset=/ mems_allowed=0
> [   95.526110] CPU: 0 PID: 111 Comm: kworker/0:2 Not tainted 4.14.0-rc5+ #302
> [   95.526552] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2011
> [   95.527018] Workqueue: events_freezable update_balloon_size_func [virtio_balloon]
> [   95.527492] Call Trace:
> [   95.527969]  dump_stack+0x63/0x87
> [   95.528469]  warn_alloc+0x114/0x1c0
> [   95.528922]  __alloc_pages_slowpath+0x9a6/0xba7
> [   95.529388]  ? qxl_image_free_objects+0x56/0x60 [qxl]
> [   95.529849]  ? qxl_draw_opaque_fb+0x102/0x3a0 [qxl]
> [   95.530315]  __alloc_pages_nodemask+0x26a/0x290
> [   95.530777]  alloc_pages_current+0x6a/0xb0
> [   95.531243]  balloon_page_enqueue+0x25/0xf0
> [   95.531703]  update_balloon_size_func+0xe1/0x260 [virtio_balloon]
> [   95.532180]  process_one_work+0x149/0x360
> [   95.532645]  worker_thread+0x4d/0x3c0
> [   95.533143]  kthread+0x109/0x140
> [   95.533622]  ? rescuer_thread+0x380/0x380
> [   95.534100]  ? kthread_park+0x60/0x60
> [   95.534568]  ret_from_fork+0x25/0x30
> [   95.535093] warn_alloc_show_mem: 1 callbacks suppressed
> [   95.535093] Mem-Info:
> [   95.536072] active_anon:11171 inactive_anon:2084 isolated_anon:0
> [   95.536072]  active_file:8 inactive_file:70 isolated_file:0
> [   95.536072]  unevictable:0 dirty:0 writeback:0 unstable:0
> [   95.536072]  slab_reclaimable:3554 slab_unreclaimable:6848
> [   95.536072]  mapped:588 shmem:2144 pagetables:749 bounce:0
> [   95.536072]  free:25859 free_pcp:72 free_cma:0
> [   95.538922] Node 0 active_anon:44684kB inactive_anon:8336kB active_file:32kB inactive_file:280kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:2352kB dirty:0kB writeback:0kB shmem:8576kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 10240kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
> [   95.540516] Node 0 DMA free:15900kB min:132kB low:164kB high:196kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> [   95.542325] lowmem_reserve[]: 0 2954 7925 7925 7925
> [   95.543020] Node 0 DMA32 free:44748kB min:25144kB low:31428kB high:37712kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129308kB managed:3063740kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> [   95.544949] lowmem_reserve[]: 0 0 4970 4970 4970
> [   95.545624] Node 0 Normal free:42788kB min:42304kB low:52880kB high:63456kB active_anon:44684kB inactive_anon:8336kB active_file:32kB inactive_file:108kB unevictable:0kB writepending:0kB present:5242880kB managed:5093540kB mlocked:0kB kernel_stack:1984kB pagetables:2996kB bounce:0kB free_pcp:372kB local_pcp:220kB free_cma:0kB
> [   95.547739] lowmem_reserve[]: 0 0 0 0 0
> [   95.548464] Node 0 DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15900kB
> [   95.549988] Node 0 DMA32: 3*4kB (UM) 4*8kB (UM) 2*16kB (U) 2*32kB (U) 1*64kB (U) 0*128kB 2*256kB (UM) 2*512kB (UM) 2*1024kB (UM) 2*2048kB (UM) 9*4096kB (M) = 44748kB
> [   95.551551] Node 0 Normal: 925*4kB (UME) 455*8kB (UME) 349*16kB (UME) 137*32kB (UME) 37*64kB (UME) 23*128kB (UME) 8*256kB (UME) 5*512kB (UM) 3*1024kB (UM) 6*2048kB (U) 0*4096kB = 42588kB
> [   95.553147] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
> [   95.554030] 2224 total pagecache pages
> [   95.554874] 0 pages in swap cache
> [   95.555667] Swap cache stats: add 0, delete 0, find 0/0
> [   95.556469] Free swap  = 0kB
> [   95.557280] Total swap = 0kB
> [   95.558079] 2097045 pages RAM
> [   95.558856] 0 pages HighMem/MovableOnly
> [   95.559652] 53748 pages reserved
> [   95.560444] 0 pages cma reserved
> [   95.561262] 0 pages hwpoisoned
> [   95.562086] virtio_balloon virtio3: Out of puff! Can't get 1 pages
> [   95.565779] virtio_balloon virtio3: Released 256 pages. Remains 1984947 pages.
> [   96.265255] virtio_balloon virtio3: Released 256 pages. Remains 1984691 pages.
> [  105.498910] virtio_balloon virtio3: Released 256 pages. Remains 1984435 pages.
> [  105.500518] virtio_balloon virtio3: Released 256 pages. Remains 1984179 pages.
> [  105.520034] virtio_balloon virtio3: Released 256 pages. Remains 1983923 pages.
> ----------------------------------------
> 
> Michael S. Tsirkin wrote:
> > I think that's the case. Question is, when can we inflate again?
> 
> I think that it is when the host explicitly asked again, for
> VIRTIO_BALLOON_F_DEFLATE_ON_OOM path does not schedule for later inflation.

Problem is host has no idea when it's safe.
If we expect host to ask again after X seconds we
might just as well do it in the guest.





























--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
