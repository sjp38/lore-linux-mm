Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 022C26B0035
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 15:29:31 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so803846pab.4
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 12:29:31 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id n8si30328967pax.15.2014.02.05.12.29.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Feb 2014 12:29:29 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so794264pad.8
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 12:29:29 -0800 (PST)
Date: Wed, 5 Feb 2014 12:29:27 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] Move the memory_notifier out of the memory_hotplug lock
In-Reply-To: <1391617743-150518-1-git-send-email-nzimmer@sgi.com>
Message-ID: <alpine.DEB.2.02.1402051217520.5616@chino.kir.corp.google.com>
References: <1391617743-150518-1-git-send-email-nzimmer@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Jiang Liu <liuj97@gmail.com>, Hedi Berriche <hedi@sgi.com>, Mike Travis <travis@sgi.com>

On Wed, 5 Feb 2014, Nathan Zimmer wrote:

> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 62a0cd1..a3cbd14 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -985,12 +985,12 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  		if (need_zonelists_rebuild)
>  			zone_pcp_reset(zone);
>  		mutex_unlock(&zonelists_mutex);
> +		unlock_memory_hotplug();
>  		printk(KERN_DEBUG "online_pages [mem %#010llx-%#010llx] failed\n",
>  		       (unsigned long long) pfn << PAGE_SHIFT,
>  		       (((unsigned long long) pfn + nr_pages)
>  			    << PAGE_SHIFT) - 1);
>  		memory_notify(MEM_CANCEL_ONLINE, &arg);
> -		unlock_memory_hotplug();
>  		return ret;
>  	}
>  
> @@ -1016,9 +1016,10 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  
>  	writeback_set_ratelimit();
>  
> +	unlock_memory_hotplug();
> +
>  	if (onlined_pages)
>  		memory_notify(MEM_ONLINE, &arg);
> -	unlock_memory_hotplug();
>  
>  	return 0;
>  }

That looks a little problematic, what happens if a nid is being brought 
online and a registered callback does something like allocate resources 
for the arg->status_change_nid and the above two hunks of this patch end 
up racing?

Before, a registered callback would be guaranteed to see either a 
MEMORY_CANCEL_ONLINE or MEMORY_ONLINE after it has already done 
MEMORY_GOING_ONLINE.

With your patch, we could race and see one cpu doing MEMORY_GOING_ONLINE, 
another cpu doing MEMORY_GOING_ONLINE, and then MEMORY_ONLINE and 
MEMORY_CANCEL_ONLINE in either order.

So I think this patch will break most registered callbacks that actually 
depend on lock_memory_hotplug(), it's a coarse lock for that reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
