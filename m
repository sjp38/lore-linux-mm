Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 883816B0303
	for <linux-mm@kvack.org>; Sun, 24 Jun 2012 23:04:25 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 63CA43EE0C0
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:04:23 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 45EB345DE5D
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:04:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F80045DE5A
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:04:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2159AE38008
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:04:23 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BED3EE38001
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:04:22 +0900 (JST)
Message-ID: <4FE7D4B1.4040803@jp.fujitsu.com>
Date: Mon, 25 Jun 2012 12:02:09 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/memcg: add MAX_CHARGE_BATCH to limit unnecessary charge
 overhead
References: <1340504169-5344-1-git-send-email-liwp.linux@gmail.com> <20120624094614.GT27816@cmpxchg.org> <20120624100812.GA7095@kernel> <20120624101948.GU27816@cmpxchg.org> <20120624103258.GB10915@kernel>
In-Reply-To: <20120624103258.GB10915@kernel>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org

(2012/06/24 19:32), Wanpeng Li wrote:
> On Sun, Jun 24, 2012 at 12:19:48PM +0200, Johannes Weiner wrote:
>> On Sun, Jun 24, 2012 at 06:08:26PM +0800, Wanpeng Li wrote:
>>> On Sun, Jun 24, 2012 at 11:46:14AM +0200, Johannes Weiner wrote:
>>>> On Sun, Jun 24, 2012 at 10:16:09AM +0800, Wanpeng Li wrote:
>>>>> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
>>>>>
>>>>> Since exceeded unused cached charges would add pressure to
>>>>> mem_cgroup_do_charge, more overhead would burn cpu cycles when
>>>>> mem_cgroup_do_charge cause page reclaim or even OOM be triggered
>>>>> just for such exceeded unused cached charges. Add MAX_CHARGE_BATCH
>>>>> to limit max cached charges.
>>>>>
>>>>> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
>>>>> ---
>>>>>   mm/memcontrol.c |   16 ++++++++++++++++
>>>>>   1 file changed, 16 insertions(+)
>>>>>
>>>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>>>> index 0e092eb..1ff317a 100644
>>>>> --- a/mm/memcontrol.c
>>>>> +++ b/mm/memcontrol.c
>>>>> @@ -1954,6 +1954,14 @@ void mem_cgroup_update_page_stat(struct page *page,
>>>>>    * TODO: maybe necessary to use big numbers in big irons.
>>>>>    */
>>>>>   #define CHARGE_BATCH	32U
>>>>> +
>>>>> +/*
>>>>> + * Max size of charge stock. Since exceeded unused cached charges would
>>>>> + * add pressure to mem_cgroup_do_charge which will cause page reclaim or
>>>>> + * even oom be triggered.
>>>>> + */
>>>>> +#define MAX_CHARGE_BATCH 1024U
>>>>> +
>>>>>   struct memcg_stock_pcp {
>>>>>   	struct mem_cgroup *cached; /* this never be root cgroup */
>>>>>   	unsigned int nr_pages;
>>>>> @@ -2250,6 +2258,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>>>>>   	unsigned int batch = max(CHARGE_BATCH, nr_pages);
>>>>>   	int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
>>>>>   	struct mem_cgroup *memcg = NULL;
>>>>> +	struct memcg_stock_pcp *stock;
>>>>>   	int ret;
>>>>>
>>>>>   	/*
>>>>> @@ -2320,6 +2329,13 @@ again:
>>>>>   		rcu_read_unlock();
>>>>>   	}
>>>>>
>>>>> +	stock = &get_cpu_var(memcg_stock);
>>>>> +	if (memcg == stock->cached && stock->nr_pages) {
>>>>> +		if (stock->nr_pages > MAX_CHARGE_BATCH)
>>>>> +			batch = nr_pages;
>>>>> +	}
>>>>> +	put_cpu_var(memcg_stock);
>>>>
>>>> The only way excessive stock can build up is if the charging task gets
>>>> rescheduled, after trying to consume stock a few lines above, to a cpu
>>>> it was running on when it built up stock in the past.
>>>>
>>>>     consume_stock()
>>>>       memcg != stock->cached:
>>>>         return false
>>>>     do_charge()
>>>>     <reschedule>
>>>>     refill_stock()
>>>>       memcg == stock->cached:
>>>>         stock->nr_pages += nr_pages
>>>
>>> __mem_cgroup_try_charge() {
>>> 	unsigned int batch = max(CHARGE_BATCH, nr_pages);
>>> 	[...]
>>> 	mem_cgroup_do_charge(memcg, gfp_mask, batch, oom_check);
>>> 	[...]
>>> 	if(batch > nr_pages)
>>> 		refill_stock(memcg, batch - nr_pages);
>>> }
>>>
>>> Consider this scenario, If one task wants to charge nr_pages = 1,
>>> then batch = max(32,1) = 32, this time 31 excess charges
>>> will be charged in mem_cgroup_do_charge and then add to stock by
>>> refill_stock. Generally there are many tasks in one memory cgroup and
>>> maybe charges frequency. In this situation, limit will reach soon,
>>> and cause mem_cgroup_reclaim to call try_to_free_mem_cgroup_pages.
>>
>> But the stock is not a black hole that gets built up for giggles!  The
>> next time the processes want to charge a page on this cpu, they will
>> consume it from the stock.  Not add more pages to it.  Look at where
>> consume_stock() is called.
>
> if(nr_pages == 1 && consume_stock(memcg))
> 	goto done;
>
> Only when charge one page will call consume_stock. You can see the codes
> in mem_cgroup_charge_common() which also call __mem_cgroup_try_charge,
> when both transparent huge and hugetlbfs pages, nr_pages will larger than 1.
>

Because THP charges 2M bytes at once, the optimization by 'stock' will have no
effects. (It merges 512page faults into a page fault.)
I think you can't see any performance difference even if we handle THP
pages with 'stock'.

And I think MAX_CHARGE_BATCH=1024 is too big...If you have 256cpus, you'll
have 1GB of cached charges...it means 1GB of inaccuracy of usage.
If you want to enlarge it, please show performance benefit.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
