Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 1A9056B02D7
	for <linux-mm@kvack.org>; Sun, 24 Jun 2012 06:13:16 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so6642367pbb.14
        for <linux-mm@kvack.org>; Sun, 24 Jun 2012 03:13:15 -0700 (PDT)
Date: Sun, 24 Jun 2012 18:13:00 +0800
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: Re: [PATCH] mm/memcg: add MAX_CHARGE_BATCH to limit unnecessary
 charge overhead
Message-ID: <20120624101300.GA10915@kernel>
Reply-To: Wanpeng Li <liwp.linux@gmail.com>
References: <1340504169-5344-1-git-send-email-liwp.linux@gmail.com>
 <20120624094614.GT27816@cmpxchg.org>
 <20120624100812.GA7095@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120624100812.GA7095@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwp.linux@gmail.com>, linux-mm@kvack.org

On Sun, Jun 24, 2012 at 06:08:26PM +0800, Wanpeng Li wrote:
>On Sun, Jun 24, 2012 at 11:46:14AM +0200, Johannes Weiner wrote:
>>On Sun, Jun 24, 2012 at 10:16:09AM +0800, Wanpeng Li wrote:
>>> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
>>> 
>>> Since exceeded unused cached charges would add pressure to
>>> mem_cgroup_do_charge, more overhead would burn cpu cycles when
>>> mem_cgroup_do_charge cause page reclaim or even OOM be triggered
>>> just for such exceeded unused cached charges. Add MAX_CHARGE_BATCH
>>> to limit max cached charges.
>>> 
>>> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
>>> ---
>>>  mm/memcontrol.c |   16 ++++++++++++++++
>>>  1 file changed, 16 insertions(+)
>>> 
>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>> index 0e092eb..1ff317a 100644
>>> --- a/mm/memcontrol.c
>>> +++ b/mm/memcontrol.c
>>> @@ -1954,6 +1954,14 @@ void mem_cgroup_update_page_stat(struct page *page,
>>>   * TODO: maybe necessary to use big numbers in big irons.
>>>   */
>>>  #define CHARGE_BATCH	32U
>>> +
>>> +/*
>>> + * Max size of charge stock. Since exceeded unused cached charges would
>>> + * add pressure to mem_cgroup_do_charge which will cause page reclaim or
>>> + * even oom be triggered.
>>> + */
>>> +#define MAX_CHARGE_BATCH 1024U
>>> +
>>>  struct memcg_stock_pcp {
>>>  	struct mem_cgroup *cached; /* this never be root cgroup */
>>>  	unsigned int nr_pages;
>>> @@ -2250,6 +2258,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>>>  	unsigned int batch = max(CHARGE_BATCH, nr_pages);
>>>  	int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
>>>  	struct mem_cgroup *memcg = NULL;
>>> +	struct memcg_stock_pcp *stock;
>>>  	int ret;
>>>  
>>>  	/*
>>> @@ -2320,6 +2329,13 @@ again:
>>>  		rcu_read_unlock();
>>>  	}
>>>  
>>> +	stock = &get_cpu_var(memcg_stock);
>>> +	if (memcg == stock->cached && stock->nr_pages) {
>>> +		if (stock->nr_pages > MAX_CHARGE_BATCH)
>>> +			batch = nr_pages;
>>> +	}
>>> +	put_cpu_var(memcg_stock);
>>
>>The only way excessive stock can build up is if the charging task gets
>>rescheduled, after trying to consume stock a few lines above, to a cpu
>>it was running on when it built up stock in the past.
>>
>>    consume_stock()
>>      memcg != stock->cached:
>>        return false
>>    do_charge()
>>    <reschedule>
>>    refill_stock()
>>      memcg == stock->cached:
>>        stock->nr_pages += nr_pages
>
>__mem_cgroup_try_charge() {
>	unsigned int batch = max(CHARGE_BATCH, nr_pages);
>	[...]
>	mem_cgroup_do_charge(memcg, gfp_mask, batch, oom_check);
>	[...]
>	if(batch > nr_pages)
>		refill_stock(memcg, batch - nr_pages);
>}
>
>Consider this scenario, If one task wants to charge nr_pages = 1,
>then batch = max(32,1) = 32, this time 31 excess charges
Sorry, the scenario is charge nr_pages = 2, batch = max(32, 2) = 32,
this time 30 excess charges will be charged.
>will be charged in mem_cgroup_do_charge and then add to stock by
>refill_stock. Generally there are many tasks in one memory cgroup and 
>maybe charges frequency. In this situation, limit will reach soon, 
>and cause mem_cgroup_reclaim to call try_to_free_mem_cgroup_pages.
>
>Regards,
>Wanpeng Li
>>
>>It's very unlikely and a single call into target reclaim will drain
>>all stock of the memcg, so this will self-correct quickly.
>>
>>And your patch won't change any of that.
>>
>>What you /could/ do is stick that check into refill_stock() and invoke
>>res_counter_uncharge() if it gets excessive.  But I really don't see a
>>practical problem here...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
