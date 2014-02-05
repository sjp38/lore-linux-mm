Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id BC2926B0035
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 18:10:41 -0500 (EST)
Received: by mail-yk0-f178.google.com with SMTP id 79so2893638ykr.9
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 15:10:41 -0800 (PST)
Received: from relay.sgi.com (relay3.sgi.com. [192.48.152.1])
        by mx.google.com with ESMTP id q48si24854635yhb.127.2014.02.05.15.10.41
        for <linux-mm@kvack.org>;
        Wed, 05 Feb 2014 15:10:41 -0800 (PST)
Message-ID: <52F2C4F0.6080608@sgi.com>
Date: Wed, 5 Feb 2014 17:10:40 -0600
From: Nathan Zimmer <nzimmer@sgi.com>
MIME-Version: 1.0
Subject: Re: [RFC] Move the memory_notifier out of the memory_hotplug lock
References: <1391617743-150518-1-git-send-email-nzimmer@sgi.com> <alpine.DEB.2.02.1402051217520.5616@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1402051217520.5616@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Jiang Liu <liuj97@gmail.com>, Hedi Berriche <hedi@sgi.com>, Mike Travis <travis@sgi.com>

On 02/05/2014 02:29 PM, David Rientjes wrote:
> On Wed, 5 Feb 2014, Nathan Zimmer wrote:
>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 62a0cd1..a3cbd14 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -985,12 +985,12 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>>   		if (need_zonelists_rebuild)
>>   			zone_pcp_reset(zone);
>>   		mutex_unlock(&zonelists_mutex);
>> +		unlock_memory_hotplug();
>>   		printk(KERN_DEBUG "online_pages [mem %#010llx-%#010llx] failed\n",
>>   		       (unsigned long long) pfn << PAGE_SHIFT,
>>   		       (((unsigned long long) pfn + nr_pages)
>>   			    << PAGE_SHIFT) - 1);
>>   		memory_notify(MEM_CANCEL_ONLINE, &arg);
>> -		unlock_memory_hotplug();
>>   		return ret;
>>   	}
>>   
>> @@ -1016,9 +1016,10 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>>   
>>   	writeback_set_ratelimit();
>>   
>> +	unlock_memory_hotplug();
>> +
>>   	if (onlined_pages)
>>   		memory_notify(MEM_ONLINE, &arg);
>> -	unlock_memory_hotplug();
>>   
>>   	return 0;
>>   }
> That looks a little problematic, what happens if a nid is being brought
> online and a registered callback does something like allocate resources
> for the arg->status_change_nid and the above two hunks of this patch end
> up racing?
>
> Before, a registered callback would be guaranteed to see either a
> MEMORY_CANCEL_ONLINE or MEMORY_ONLINE after it has already done
> MEMORY_GOING_ONLINE.
>
> With your patch, we could race and see one cpu doing MEMORY_GOING_ONLINE,
> another cpu doing MEMORY_GOING_ONLINE, and then MEMORY_ONLINE and
> MEMORY_CANCEL_ONLINE in either order.
>
> So I think this patch will break most registered callbacks that actually
> depend on lock_memory_hotplug(), it's a coarse lock for that reason.

Since the argument being passed in is the pfn and size it would be an issue
only if two threads attepted to online the same piece of memory. Right?

That seems very unlikely but if it can happen it needs to be protected against.

Nate



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
