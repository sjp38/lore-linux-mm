Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 0A6766B0062
	for <linux-mm@kvack.org>; Sun, 17 Jun 2012 21:12:30 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1SgQVz-000265-JE
	for linux-mm@kvack.org; Mon, 18 Jun 2012 03:12:24 +0200
Received: from 121.50.20.41 ([121.50.20.41])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 18 Jun 2012 03:12:23 +0200
Received: from minchan by 121.50.20.41 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 18 Jun 2012 03:12:23 +0200
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] trivial, memory hotplug: add kswapd_is_running() for
 better readability
Date: Mon, 18 Jun 2012 10:12:33 +0900
Message-ID: <4FDE8081.1070500@kernel.org>
References: <4FD97718.6060008@kernel.org> <1339663776-196-1-git-send-email-jiang.liu@huawei.com> <alpine.DEB.2.00.1206161913370.797@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
In-Reply-To: <alpine.DEB.2.00.1206161913370.797@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On 06/17/2012 11:19 AM, David Rientjes wrote:

> On Thu, 14 Jun 2012, Jiang Liu wrote:
> 
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index c84ec68..36249d5 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>> @@ -301,6 +301,11 @@ static inline void scan_unevictable_unregister_node(struct node *node)
>>  
>>  extern int kswapd_run(int nid);
>>  extern void kswapd_stop(int nid);
>> +static inline bool kswapd_is_running(int nid)
>> +{
>> +	return !!(NODE_DATA(nid)->kswapd);
>> +}
>> +
>>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
>>  extern int mem_cgroup_swappiness(struct mem_cgroup *mem);
>>  #else
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 0d7e3ec..88e479d 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -522,7 +522,8 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
>>  	init_per_zone_wmark_min();
>>  
>>  	if (onlined_pages) {
>> -		kswapd_run(zone_to_nid(zone));
>> +		if (!kswapd_is_running(zone_to_nid(zone)))
>> +			kswapd_run(zone_to_nid(zone));
>>  		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
>>  	}
>>  
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 7585101..3dafdbe 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -2941,8 +2941,7 @@ int kswapd_run(int nid)
>>  	pg_data_t *pgdat = NODE_DATA(nid);
>>  	int ret = 0;
>>  
>> -	if (pgdat->kswapd)
>> -		return 0;
>> +	BUG_ON(pgdat->kswapd);
>>  
>>  	pgdat->kswapd = kthread_run(kswapd, pgdat, "kswapd%d", nid);
>>  	if (IS_ERR(pgdat->kswapd)) {
> 
> This isn't better, there's no functional change and you've just added a 
> second conditional for no reason and an unnecessary kswapd_is_running() 
> function.


Tend to agree.
Now that I think about it, it's enough to add comment.

> 
> More concerning is that online_pages() doesn't check the return value of 
> kswapd_run().  We should probably fail the memory hotplug operation that 
> onlines a new node and doesn't have a kswapd running and cleanup after 
> ourselves in online_pages() with some sane error handling.


Yeb. It's more valuable.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
