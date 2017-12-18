Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C6C426B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 12:55:05 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id a72so9356598ioe.13
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 09:55:05 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id k6si8643991ioc.287.2017.12.18.09.55.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Dec 2017 09:55:04 -0800 (PST)
Subject: Re: Memory hotplug regression in 4.13
References: <20170919164114.f4ef6oi3yhhjwkqy@ubuntu-xps13>
 <20170920092931.m2ouxfoy62wr65ld@dhcp22.suse.cz>
 <20170921054034.judv6ovyg5yks4na@ubuntu-hedt>
 <20170925125825.zpgasjhjufupbias@dhcp22.suse.cz>
 <20171201142327.GA16952@ubuntu-xps13> <20171218145320.GO16951@dhcp22.suse.cz>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <94586175-08bd-11ad-6586-3792c24b0e78@infradead.org>
Date: Mon, 18 Dec 2017 09:54:51 -0800
MIME-Version: 1.0
In-Reply-To: <20171218145320.GO16951@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Seth Forshee <seth.forshee@canonical.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/18/2017 06:53 AM, Michal Hocko wrote:
> On Fri 01-12-17 08:23:27, Seth Forshee wrote:
>> On Mon, Sep 25, 2017 at 02:58:25PM +0200, Michal Hocko wrote:
>>> On Thu 21-09-17 00:40:34, Seth Forshee wrote:
> [...]
>>>> It seems I don't have that kernel anymore, but I've got a 4.14-rc1 build
>>>> and the problem still occurs there. It's pointing to the call to
>>>> __builtin_memcpy in memcpy (include/linux/string.h line 340), which we
>>>> get to via wp_page_copy -> cow_user_page -> copy_user_highpage.
>>>
>>> Hmm, this is interesting. That would mean that we have successfully
>>> mapped the destination page but its memory is still not accessible.
>>>
>>> Right now I do not see how the patch you have bisected to could make any
>>> difference because it only postponed the onlining to be independent but
>>> your config simply onlines automatically so there shouldn't be any
>>> semantic change. Maybe there is some sort of off-by-one or something.
>>>
>>> I will try to investigate some more. Do you think it would be possible
>>> to configure kdump on your system and provide me with the vmcore in some
>>> way?
>>
>> Sorry, I got busy with other stuff and this kind of fell off my radar.
>> It came to my attention again recently though.
> 
> Apology on my side. This has completely fall of my radar.
> 
>> I was looking through the hotplug rework changes, and I noticed that
>> 32-bit x86 previously was using ZONE_HIGHMEM as a default but after the
>> rework it doesn't look like it's possible for memory to be associated
>> with ZONE_HIGHMEM when onlining. So I made the change below against 4.14
>> and am now no longer seeing the oopses.
> 
> Thanks a lot for debugging! Do I read the above correctly that the
> current code simply returns ZONE_NORMAL and maps an unrelated pfn into
> this zone and that leads to later blowups? Could you attach the fresh
> boot dmesg output please?
> 
>> I'm sure this isn't the correct fix, but I think it does confirm that
>> the problem is that the memory should be associated with ZONE_HIGHMEM
>> but is not.
> 
> 
> Yes, the fix is not quite right. HIGHMEM is not a _kernel_ memory
> zone. The kernel cannot access that memory directly. It is essentially a
> movable zone from the hotplug API POV. We simply do not have any way to
> tell into which zone we want to online this memory range in.
> Unfortunately both zones _can_ be present. It would require an explicit
> configuration (movable_node and a NUMA hoptlugable nodes running in 32b
> or and movable memory configured explicitly on the kernel command line).
> 
> The below patch is not really complete but I would rather start simple.
> Maybe we do not even have to care as most 32b users will never use both
> zones at the same time. I've placed a warning to learn about those.
> 
> Does this pass your testing?
> ---
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 262bfd26baf9..18fec18bdb60 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -855,12 +855,29 @@ static struct zone *default_kernel_zone_for_pfn(int nid, unsigned long start_pfn
>  	return &pgdat->node_zones[ZONE_NORMAL];
>  }
>  
> +static struct zone *default_movable_zone_for_pfn(int nid)
> +{
> +	/*
> +	 * Please note that 32b HIGHMEM systems might have 2 movable zones

Please spell out 32-bit.  It took me a bit to realize what "32b" was.

ta.

> +	 * actually so we have to check for both. This is rather ugly hack
> +	 * to enforce using Highmem on those systems but we do not have a
> +	 * good user API to tell into which movable zone we should online.
> +	 * WARN if we have a movable zone which is not highmem.
> +	 */
> +#ifdef CONFIG_HIGHMEM
> +	WARN_ON_ONCE(!zone_movable_is_highmem());
> +	return &NODE_DATA(nid)->node_zones[ZONE_HIGHMEM];
> +#else
> +	return &NODE_DATA(nid)->node_zones[ZONE_MOVABLE];
> +#endif
> +}
> +
>  static inline struct zone *default_zone_for_pfn(int nid, unsigned long start_pfn,
>  		unsigned long nr_pages)
>  {
>  	struct zone *kernel_zone = default_kernel_zone_for_pfn(nid, start_pfn,
>  			nr_pages);
> -	struct zone *movable_zone = &NODE_DATA(nid)->node_zones[ZONE_MOVABLE];
> +	struct zone *movable_zone = default_movable_zone_for_pfn(nid);
>  	bool in_kernel = zone_intersects(kernel_zone, start_pfn, nr_pages);
>  	bool in_movable = zone_intersects(movable_zone, start_pfn, nr_pages);
>  
> @@ -886,7 +903,7 @@ struct zone * zone_for_pfn_range(int online_type, int nid, unsigned start_pfn,
>  		return default_kernel_zone_for_pfn(nid, start_pfn, nr_pages);
>  
>  	if (online_type == MMOP_ONLINE_MOVABLE)
> -		return &NODE_DATA(nid)->node_zones[ZONE_MOVABLE];
> +		return default_movable_zone_for_pfn(nid);
>  
>  	return default_zone_for_pfn(nid, start_pfn, nr_pages);
>  }
> 


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
