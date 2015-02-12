Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 96C306B0038
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 10:40:27 -0500 (EST)
Received: by mail-vc0-f180.google.com with SMTP id im6so3894174vcb.11
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 07:40:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c5si2579263vcf.50.2015.02.12.07.40.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Feb 2015 07:40:26 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH 0/3] memory_hotplug: hyperv: fix deadlock between memory adding and onlining
References: <1423669462-30918-1-git-send-email-vkuznets@redhat.com>
	<alpine.DEB.2.10.1502111229500.16711@chino.kir.corp.google.com>
	<alpine.DEB.2.10.1502112216400.23384@chino.kir.corp.google.com>
Date: Thu, 12 Feb 2015 16:39:52 +0100
In-Reply-To: <alpine.DEB.2.10.1502112216400.23384@chino.kir.corp.google.com>
	(David Rientjes's message of "Wed, 11 Feb 2015 22:39:24 -0800 (PST)")
Message-ID: <87vbj7xho7.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, Fabian Frederick <fabf@skynet.be>, Zhang Zhen <zhenzhang.zhang@huawei.com>, Vladimir Davydov <vdavydov@parallels.com>, Wang Nan <wangnan0@huawei.com>, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, linux-mm@kvack.org

David Rientjes <rientjes@google.com> writes:

> On Wed, 11 Feb 2015, David Rientjes wrote:
>
>> > If newly added memory is brought online with e.g. udev rule:
>> > SUBSYSTEM=="memory", ACTION=="add", ATTR{state}="online"
>> > the following deadlock is observed (and easily reproducable):
>> > 
>> > First participant, worker thread doing add_memory():
>> > 
>> > [  724.948846] kworker/0:1     D ffff88000412f9c8 13248    27      2 0x00000000
>> > [  724.973543] Workqueue: events hot_add_req [hv_balloon]
>> > [  724.991736]  ffff88000412f9c8 0000000000000000 ffff88003fa1dc30 00000000000151c0
>> > [  725.019725]  0000000000000246 ffff88000412ffd8 00000000000151c0 ffff88003a77a4e0
>> > [  725.046486]  ffff88003fa1dc30 00000001032a6000 ffff88003a7ca838 ffff88003a7ca898
>> > [  725.072969] Call Trace:
>> > [  725.082690]  [<ffffffff81aac0a9>] schedule_preempt_disabled+0x29/0x70
>> > [  725.103799]  [<ffffffff81aae33b>] mutex_lock_nested+0x14b/0x470
>> > [  725.122367]  [<ffffffff815ed773>] ? device_attach+0x23/0xb0
>> > [  725.140992]  [<ffffffff815ed773>] device_attach+0x23/0xb0
>> > [  725.159131]  [<ffffffff815ecba0>] bus_probe_device+0xb0/0xe0
>> > [  725.177055]  [<ffffffff815ea693>] device_add+0x443/0x650
>> > [  725.195558]  [<ffffffff815ea8be>] device_register+0x1e/0x30
>> > [  725.213133]  [<ffffffff81601790>] init_memory_block+0xd0/0xf0
>> > [  725.231533]  [<ffffffff816018f1>] register_new_memory+0xb1/0xd0
>> > [  725.250769]  [<ffffffff81a961cf>] __add_pages+0x13f/0x250
>> > [  725.269642]  [<ffffffff81063770>] ? arch_add_memory+0x70/0xf0
>> > [  725.288764]  [<ffffffff81063770>] arch_add_memory+0x70/0xf0
>> > [  725.306117]  [<ffffffff81a95f8f>] add_memory+0xef/0x1f0
>> > [  725.322466]  [<ffffffffa00293af>] hot_add_req+0x33f/0xf90 [hv_balloon]
>> > [  725.342777]  [<ffffffff8109509f>] process_one_work+0x1df/0x4e0
>> > [  725.361459]  [<ffffffff8109502d>] ? process_one_work+0x16d/0x4e0
>> > [  725.380390]  [<ffffffff810954bb>] worker_thread+0x11b/0x450
>> > [  725.397684]  [<ffffffff810953a0>] ? process_one_work+0x4e0/0x4e0
>> > [  725.416533]  [<ffffffff8109ac33>] kthread+0xf3/0x110
>> > [  725.433372]  [<ffffffff8109ab40>] ? kthread_create_on_node+0x240/0x240
>> > [  725.453749]  [<ffffffff81ab1dfc>] ret_from_fork+0x7c/0xb0
>> > [  725.470994]  [<ffffffff8109ab40>] ? kthread_create_on_node+0x240/0x240
>> > [  725.491469] 6 locks held by kworker/0:1/27:
>> > [  725.505037]  #0:  ("events"){......}, at: [<ffffffff8109502d>] process_one_work+0x16d/0x4e0
>> > [  725.533370]  #1:  ((&dm_device.ha_wrk.wrk)){......}, at: [<ffffffff8109502d>] process_one_work+0x16d/0x4e0
>> > [  725.565580]  #2:  (mem_hotplug.lock){......}, at: [<ffffffff811e6525>] mem_hotplug_begin+0x5/0x80
>> > [  725.594369]  #3:  (mem_hotplug.lock#2){......}, at: [<ffffffff811e656f>] mem_hotplug_begin+0x4f/0x80
>> > [  725.628554]  #4:  (mem_sysfs_mutex){......}, at: [<ffffffff81601873>] register_new_memory+0x33/0xd0
>> > [  725.658519]  #5:  (&dev->mutex){......}, at: [<ffffffff815ed773>] device_attach+0x23/0xb0
>> > 
>> > Second participant, udev:
>> > 
>> > [  725.750889] systemd-udevd   D ffff88003b94fc68 14016   888    530 0x00000004
>> > [  725.773767]  ffff88003b94fc68 0000000000000000 ffff8800034949c0 00000000000151c0
>> > [  725.798332]  ffffffff8210d980 ffff88003b94ffd8 00000000000151c0 ffff880037a69270
>> > [  725.822841]  ffff8800034949c0 0000000100000001 ffff8800034949c0 ffffffff81ff2b48
>> > [  725.849184] Call Trace:
>> > [  725.858987]  [<ffffffff81aac0a9>] schedule_preempt_disabled+0x29/0x70
>> > [  725.879231]  [<ffffffff81aae33b>] mutex_lock_nested+0x14b/0x470
>> > [  725.897860]  [<ffffffff811e656f>] ? mem_hotplug_begin+0x4f/0x80
>> > [  725.916698]  [<ffffffff811e656f>] mem_hotplug_begin+0x4f/0x80
>> > [  725.935064]  [<ffffffff811e6525>] ? mem_hotplug_begin+0x5/0x80
>> > [  725.953464]  [<ffffffff81a9631b>] online_pages+0x3b/0x520
>> > [  725.971542]  [<ffffffff815eb0b3>] ? device_online+0x23/0xa0
>> > [  725.989207]  [<ffffffff81601524>] memory_subsys_online+0x64/0xc0
>> > [  726.008513]  [<ffffffff815eb0fd>] device_online+0x6d/0xa0
>> > [  726.025579]  [<ffffffff816012eb>] store_mem_state+0x5b/0xe0
>> > [  726.043400]  [<ffffffff815e8258>] dev_attr_store+0x18/0x30
>> > [  726.060506]  [<ffffffff8127a808>] sysfs_kf_write+0x48/0x60
>> > [  726.077940]  [<ffffffff81279d1b>] kernfs_fop_write+0x13b/0x1a0
>> > [  726.099416]  [<ffffffff811f9f67>] vfs_write+0xb7/0x1f0
>> > [  726.115748]  [<ffffffff811fabf8>] SyS_write+0x58/0xd0
>> > [  726.131933]  [<ffffffff81ab1ea9>] system_call_fastpath+0x12/0x17
>> > [  726.150691] 7 locks held by systemd-udevd/888:
>> > [  726.165044]  #0:  (sb_writers#3){......}, at: [<ffffffff811fa063>] vfs_write+0x1b3/0x1f0
>> > [  726.192422]  #1:  (&of->mutex){......}, at: [<ffffffff81279c46>] kernfs_fop_write+0x66/0x1a0
>> > [  726.220289]  #2:  (s_active#60){......}, at: [<ffffffff81279c4e>] kernfs_fop_write+0x6e/0x1a0
>> > [  726.249382]  #3:  (device_hotplug_lock){......}, at: [<ffffffff815e9c15>] lock_device_hotplug_sysfs+0x15/0x50
>> > [  726.281901]  #4:  (&dev->mutex){......}, at: [<ffffffff815eb0b3>] device_online+0x23/0xa0
>> > [  726.308619]  #5:  (mem_hotplug.lock){......}, at: [<ffffffff811e6525>] mem_hotplug_begin+0x5/0x80
>> > [  726.337994]  #6:  (mem_hotplug.lock#2){......}, at: [<ffffffff811e656f>] mem_hotplug_begin+0x4f/0x80
>> > 
>> > In short: onlining grabs device lock and then tries to do mem_hotplug_begin()
>> > while add_memory() is between mem_hotplug_begin() and mem_hotplug_done() and it
>> > tries grabbing device lock.
>> > 
>> > To my understanding ACPI memory hotplug doesn't have the same issue as
>> > device_hotplug_lock is being grabbed when the ACPI device is added.
>> > 
>> > Solve the issue by grabbing device_hotplug_lock before doing add_memory(). If
>> > we do that, lock_device_hotplug_sysfs() will cause syscall retry which will
>> > eventually succeed. To support the change we need to export lock_device_hotplug/
>> > unlock_device_hotplug. This approach can be completely wrong though.
>> 
>> Saying the approach could be completely wrong doesn't inspire a lot of 
>> confidence.  I assume this output is from the hung task detector, is there 
>> any other lockdep output that suggests there's a possible deadlock?
>> 
>
> Ok, I looked at this and the problem is that kworker/0 is onlining memory 
> and serializes memory hot-add with mem_hotplug_begin() before registering 
> the new memory block.  This is the appropriate lock ordering, we want to 
> do mem_hotplug_begin() before device_lock(dev) which takes dev->mutex 
> since we must disallow concurrent hot-add events from looking up the same 
> memory block.
>
> The issue only arises when systemd-udevd takes device_lock(dev) to 
> transition a memory block from offline to online and 
> memory_subsys_online() callbacks require mem_hotplug_begin().
>
> Understanding this is pretty simple: in the kworker/0 case, we must create 
> a memory block and add the range by probing; in the systemd-udevd case, we 
> already have a memory block and need to transition its state.
>
> Your approach to resolve this dependency is to serialize all of this with 
> device_hotplug_lock so that only one thread can be doing 
> mem_hotplug_begin() -> device_lock() or device_lock() -> 
> mem_hotplug_begin() at a time.  I don't think resolving a locking 
> dependency is appropriate by just serializing them with another lock; 
> rather, I think the solution is to truly make one lock depend on the other 
> for memory hotplug.
>
> I already mentioned that the appropriate lock ordering is 
> mem_hotplug_begin() -> device_lock() since we can't possibly know the 
> device that we are onlining for probe (we must create a new device, it 
> didn't exist before probe).
>
> So all we need to do is require store_mem_state() to take 
> mem_hotplug_begin() before doing device_online() and requiring all  
> memory_subsys_online() callbacks to assume the protection, which they 
> already require anyway.
>
> Could you try this patch out instead of your series?  I did it for memory 
> hot-remove as well just to simplify the dependency, but it would also be 
> possible to just do mem_hotplug_begin() when onlining since we already 
> have the memory block registered for hot-remove.  It's simpler this
> way.

Thanks, I tested your patch and it also solves the issue. Haven't tested
hotremove though (as it is not supported by Hyper-V).

I also agree this approach is better. Please let me know in case you
want me to send it out.

> ---
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -219,6 +219,7 @@ static bool pages_correctly_reserved(unsigned long start_pfn)
>  /*
>   * MEMORY_HOTPLUG depends on SPARSEMEM in mm/Kconfig, so it is
>   * OK to have direct references to sparsemem variables in here.
> + * Must already be protected by mem_hotplug_begin().
>   */
>  static int
>  memory_block_action(unsigned long phys_index, unsigned long action, int online_type)
> @@ -286,6 +287,7 @@ static int memory_subsys_online(struct device *dev)
>  	if (mem->online_type < 0)
>  		mem->online_type = MMOP_ONLINE_KEEP;
>
> +	/* Already under protection of mem_hotplug_begin() */
>  	ret = memory_block_change_state(mem, MEM_ONLINE, MEM_OFFLINE);
>
>  	/* clear online_type */
> @@ -328,17 +330,19 @@ store_mem_state(struct device *dev,
>  		goto err;
>  	}
>
> +	/*
> +	 * Memory hotplug needs to hold mem_hotplug_begin() for probe to find
> +	 * the correct memory block to online before doing device_online(dev),
> +	 * which will take dev->mutex.  Take the lock early to prevent an
> +	 * inversion, memory_subsys_online() callbacks will be implemented by
> +	 * assuming it's already protected.
> +	 */
> +	mem_hotplug_begin();
> +
>  	switch (online_type) {
>  	case MMOP_ONLINE_KERNEL:
>  	case MMOP_ONLINE_MOVABLE:
>  	case MMOP_ONLINE_KEEP:
> -		/*
> -		 * mem->online_type is not protected so there can be a
> -		 * race here.  However, when racing online, the first
> -		 * will succeed and the second will just return as the
> -		 * block will already be online.  The online type
> -		 * could be either one, but that is expected.
> -		 */
>  		mem->online_type = online_type;
>  		ret = device_online(&mem->dev);
>  		break;
> @@ -349,6 +353,8 @@ store_mem_state(struct device *dev,
>  		ret = -EINVAL; /* should never happen */
>  	}
>
> +	mem_hotplug_done();
> +
>  err:
>  	unlock_device_hotplug();
>
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -192,6 +192,9 @@ extern void get_page_bootmem(unsigned long ingo, struct page *page,
>  void get_online_mems(void);
>  void put_online_mems(void);
>
> +void mem_hotplug_begin(void);
> +void mem_hotplug_done(void);
> +
>  #else /* ! CONFIG_MEMORY_HOTPLUG */
>  /*
>   * Stub functions for when hotplug is off
> @@ -231,6 +234,9 @@ static inline int try_online_node(int nid)
>  static inline void get_online_mems(void) {}
>  static inline void put_online_mems(void) {}
>
> +static inline void mem_hotplug_begin(void) {}
> +static inline void mem_hotplug_done(void) {}
> +
>  #endif /* ! CONFIG_MEMORY_HOTPLUG */
>
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -104,7 +104,7 @@ void put_online_mems(void)
>
>  }
>
> -static void mem_hotplug_begin(void)
> +void mem_hotplug_begin(void)
>  {
>  	mem_hotplug.active_writer = current;
>
> @@ -119,7 +119,7 @@ static void mem_hotplug_begin(void)
>  	}
>  }
>
> -static void mem_hotplug_done(void)
> +void mem_hotplug_done(void)
>  {
>  	mem_hotplug.active_writer = NULL;
>  	mutex_unlock(&mem_hotplug.lock);
> @@ -959,6 +959,7 @@ static void node_states_set_node(int node, struct memory_notify *arg)
>  }
>
> +/* Must be protected by mem_hotplug_begin() */
>  int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_type)
>  {
>  	unsigned long flags;
> @@ -969,7 +970,6 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  	int ret;
>  	struct memory_notify arg;
>
> -	mem_hotplug_begin();
>  	/*
>  	 * This doesn't need a lock to do pfn_to_page().
>  	 * The section can't be removed here because of the
> @@ -977,21 +977,20 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  	 */
>  	zone = page_zone(pfn_to_page(pfn));
>
> -	ret = -EINVAL;
>  	if ((zone_idx(zone) > ZONE_NORMAL ||
>  	    online_type == MMOP_ONLINE_MOVABLE) &&
>  	    !can_online_high_movable(zone))
> -		goto out;
> +		return -EINVAL;
>
>  	if (online_type == MMOP_ONLINE_KERNEL &&
>  	    zone_idx(zone) == ZONE_MOVABLE) {
>  		if (move_pfn_range_left(zone - 1, zone, pfn, pfn + nr_pages))
> -			goto out;
> +			return -EINVAL;
>  	}
>  	if (online_type == MMOP_ONLINE_MOVABLE &&
>  	    zone_idx(zone) == ZONE_MOVABLE - 1) {
>  		if (move_pfn_range_right(zone, zone + 1, pfn, pfn + nr_pages))
> -			goto out;
> +			return -EINVAL;
>  	}
>
>  	/* Previous code may changed the zone of the pfn range */
> @@ -1007,7 +1006,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  	ret = notifier_to_errno(ret);
>  	if (ret) {
>  		memory_notify(MEM_CANCEL_ONLINE, &arg);
> -		goto out;
> +		return ret;
>  	}
>  	/*
>  	 * If this zone is not populated, then it is not in zonelist.
> @@ -1031,7 +1030,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  		       (((unsigned long long) pfn + nr_pages)
>  			    << PAGE_SHIFT) - 1);
>  		memory_notify(MEM_CANCEL_ONLINE, &arg);
> -		goto out;
> +		return ret;
>  	}
>
>  	zone->present_pages += onlined_pages;
> @@ -1061,9 +1060,8 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>
>  	if (onlined_pages)
>  		memory_notify(MEM_ONLINE, &arg);
> -out:
> -	mem_hotplug_done();
> -	return ret;
> +
> +	return 0;
>  }
>  #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
>
> @@ -1684,21 +1682,18 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	if (!test_pages_in_a_zone(start_pfn, end_pfn))
>  		return -EINVAL;
>
> -	mem_hotplug_begin();
> -
>  	zone = page_zone(pfn_to_page(start_pfn));
>  	node = zone_to_nid(zone);
>  	nr_pages = end_pfn - start_pfn;
>
> -	ret = -EINVAL;
>  	if (zone_idx(zone) <= ZONE_NORMAL && !can_offline_normal(zone, nr_pages))
> -		goto out;
> +		return -EINVAL;
>
>  	/* set above range as isolated */
>  	ret = start_isolate_page_range(start_pfn, end_pfn,
>  				       MIGRATE_MOVABLE, true);
>  	if (ret)
> -		goto out;
> +		return ret;
>
>  	arg.start_pfn = start_pfn;
>  	arg.nr_pages = nr_pages;
> @@ -1791,7 +1786,6 @@ repeat:
>  	writeback_set_ratelimit();
>
>  	memory_notify(MEM_OFFLINE, &arg);
> -	mem_hotplug_done();
>  	return 0;
>
>  failed_removal:
> @@ -1801,12 +1795,10 @@ failed_removal:
>  	memory_notify(MEM_CANCEL_OFFLINE, &arg);
>  	/* pushback to free area */
>  	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
> -
> -out:
> -	mem_hotplug_done();
>  	return ret;
>  }
>
> +/* Must be protected by mem_hotplug_begin() */
>  int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
>  {
>  	return __offline_pages(start_pfn, start_pfn + nr_pages, 120 * HZ);

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
