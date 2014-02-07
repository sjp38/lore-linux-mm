Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 859036B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 04:30:19 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so2959578pad.0
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 01:30:19 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ye6si4313622pbc.230.2014.02.07.01.30.17
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 01:30:17 -0800 (PST)
Message-ID: <52F4A7A3.1040402@linux.intel.com>
Date: Fri, 07 Feb 2014 17:30:11 +0800
From: Jiang Liu <jiang.liu@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [RFC] Move the memory_notifier out of the memory_hotplug lock
References: <1391617743-150518-1-git-send-email-nzimmer@sgi.com> <alpine.DEB.2.02.1402051217520.5616@chino.kir.corp.google.com> <52F2C4F0.6080608@sgi.com> <alpine.DEB.2.02.1402051512490.24489@chino.kir.corp.google.com> <20140206160939.GA107343@asylum.americas.sgi.com>
In-Reply-To: <20140206160939.GA107343@asylum.americas.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>, David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Jiang Liu <liuj97@gmail.com>, Hedi Berriche <hedi@sgi.com>, Mike Travis <travis@sgi.com>

Hi Nathan,
	I feel some registered memory hotplug notification callbacks
may have an assumption that they will be serialized by the memory
hotplug framework. If we relax the lock semantics, we need to scan
all those callbacks and make sure they are safe.
	And it's easy for user to trigger concurrent online/offline
requests through sysfs interfaces. So it would be better to keep
strict lock semantics.
Thanks!
Gerry

On 2014/2/7 0:09, Nathan Zimmer wrote:
> On Wed, Feb 05, 2014 at 03:20:07PM -0800, David Rientjes wrote:
>> On Wed, 5 Feb 2014, Nathan Zimmer wrote:
>>
>>>> That looks a little problematic, what happens if a nid is being brought
>>>> online and a registered callback does something like allocate resources
>>>> for the arg->status_change_nid and the above two hunks of this patch end
>>>> up racing?
>>>>
>>>> Before, a registered callback would be guaranteed to see either a
>>>> MEMORY_CANCEL_ONLINE or MEMORY_ONLINE after it has already done
>>>> MEMORY_GOING_ONLINE.
>>>>
>>>> With your patch, we could race and see one cpu doing MEMORY_GOING_ONLINE,
>>>> another cpu doing MEMORY_GOING_ONLINE, and then MEMORY_ONLINE and
>>>> MEMORY_CANCEL_ONLINE in either order.
>>>>
>>>> So I think this patch will break most registered callbacks that actually
>>>> depend on lock_memory_hotplug(), it's a coarse lock for that reason.
>>>
>>> Since the argument being passed in is the pfn and size it would be an issue
>>> only if two threads attepted to online the same piece of memory. Right?
>>>
>>
>> No, I'm referring to registered callbacks that provide a resource for 
>> arg->status_change_nid.  An example would be the callbacks I added to the 
>> slub allocator in slab_memory_callback().  If we are now able to get a 
>> racy MEM_GOING_ONLINE -> MEM_GOING_ONLINE -> MEM_ONLINE -> 
>> MEM_CANCEL_ONLINE, which is possible with your patch _and_ the node being 
>> successfully onlined at the end, then we get a NULL pointer dereference 
>> because the kmem_cache_node for each slab cache has been freed.
>>
> Ok I think I see now.  In my testing I had only been onlining parts of nodes.
> So all nodes were already had at least some memory online from the beginning.
> 
>>> That seems very unlikely but if it can happen it needs to be protected
>>> against.
>>>
>>
>> The protection for registered memory online or offline callbacks is 
>> lock_memory_hotplug() which is eliminated with your patch, the locking for 
>> memory_notify() that you're citing is irrelevant.
> 
> Would the race still exist if we left the position of the locks alone and 
> broke it up by nid, something like this?
> 
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index ee37657..e797e21 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -913,7 +913,9 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  	int ret;
>  	struct memory_notify arg;
>  
> -	lock_memory_hotplug();
> +	nid = page_to_nid(pfn_to_page(pfn));
> +
> +	lock_memory_hotplug(nid);
>  	/*
>  	 * This doesn't need a lock to do pfn_to_page().
>  	 * The section can't be removed here because of the
> @@ -923,19 +925,19 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  
>  	if ((zone_idx(zone) > ZONE_NORMAL || online_type == ONLINE_MOVABLE) &&
>  	    !can_online_high_movable(zone)) {
> -		unlock_memory_hotplug();
> +		unlock_memory_hotplug(nid);
>  		return -1;
>  	}
>  
>  	if (online_type == ONLINE_KERNEL && zone_idx(zone) == ZONE_MOVABLE) {
>  		if (move_pfn_range_left(zone - 1, zone, pfn, pfn + nr_pages)) {
> -			unlock_memory_hotplug();
> +			unlock_memory_hotplug(nid);
>  			return -1;
>  		}
>  	}
>  	if (online_type == ONLINE_MOVABLE && zone_idx(zone) == ZONE_MOVABLE - 1) {
>  		if (move_pfn_range_right(zone, zone + 1, pfn, pfn + nr_pages)) {
> -			unlock_memory_hotplug();
> +			unlock_memory_hotplug(nid);
>  			return -1;
>  		}
>  	}
> @@ -947,13 +949,11 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  	arg.nr_pages = nr_pages;
>  	node_states_check_changes_online(nr_pages, zone, &arg);
>  
> -	nid = page_to_nid(pfn_to_page(pfn));
> -
>  	ret = memory_notify(MEM_GOING_ONLINE, &arg);
>  	ret = notifier_to_errno(ret);
>  	if (ret) {
>  		memory_notify(MEM_CANCEL_ONLINE, &arg);
> -		unlock_memory_hotplug();
> +		unlock_memory_hotplug(nid);
>  		return ret;
>  	}
>  	/*
> @@ -978,7 +978,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  		       (((unsigned long long) pfn + nr_pages)
>  			    << PAGE_SHIFT) - 1);
>  		memory_notify(MEM_CANCEL_ONLINE, &arg);
> -		unlock_memory_hotplug();
> +		unlock_memory_hotplug(nid);
>  		return ret;
>  	}
>  
> @@ -1006,7 +1006,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  
>  	if (onlined_pages)
>  		memory_notify(MEM_ONLINE, &arg);
> -	unlock_memory_hotplug();
> +	unlock_memory_hotplug(nid);
>  
>  	return 0;
>  }
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
