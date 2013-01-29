Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id E6D186B0092
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 10:16:12 -0500 (EST)
Message-ID: <5107E7B2.4090609@oracle.com>
Date: Tue, 29 Jan 2013 23:16:02 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/6] memcg: introduce memsw_accounting_users
References: <510658E3.1020306@oracle.com> <510658F0.9050802@oracle.com> <20130129142447.GD29574@dhcp22.suse.cz>
In-Reply-To: <20130129142447.GD29574@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org

On 01/29/2013 10:24 PM, Michal Hocko wrote:
> On Mon 28-01-13 18:54:40, Jeff Liu wrote:
>> As we don't account the swap stat number for the root_mem_cgroup anymore,
>> here we can just return an invalid CSS ID if there is no non-root memcg
>> is alive.  Also, introduce memsw_accounting_users to track the number of
>> active non-root memcgs.
>>
>> Signed-off-by: Jie Liu <jeff.liu@oracle.com>
>> CC: Glauber Costa <glommer@parallels.com>
>> CC: Michal Hocko <mhocko@suse.cz>
>> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Johannes Weiner <hannes@cmpxchg.org>
>> CC: Mel Gorman <mgorman@suse.de>
>> CC: Andrew Morton <akpm@linux-foundation.org>
>> CC: Sha Zhengju <handai.szj@taobao.com>
>>
>> ---
>>  mm/page_cgroup.c |   16 +++++++++++++++-
>>  1 file changed, 15 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
>> index c945254..189fbf5 100644
>> --- a/mm/page_cgroup.c
>> +++ b/mm/page_cgroup.c
>> @@ -336,6 +336,8 @@ struct swap_cgroup {
>>  };
>>  #define SC_PER_PAGE	(PAGE_SIZE/sizeof(struct swap_cgroup))
>>  
>> +static atomic_t memsw_accounting_users = ATOMIC_INIT(0);
> 
> Nobody manipulates whith this number. I suspect the next patch will do
> but it is generally better to have also users of the introduced counters
> in the same patch. For one thing this patch would introduce a regression
> because no pages would be accounted at this stage (for example during
> git bisect).
Ah, I'll revise it accordingly.

Thanks,
-Jeff
> 
>> +
>>  /*
>>   * SwapCgroup implements "lookup" and "exchange" operations.
>>   * In typical usage, this swap_cgroup is accessed via memcg's charge/uncharge
>> @@ -389,6 +391,9 @@ static struct swap_cgroup *lookup_swap_cgroup(swp_entry_t ent,
>>  	struct page *mappage;
>>  	struct swap_cgroup *sc;
>>  
>> +	if (!atomic_read(&memsw_accounting_users))
>> +		return NULL;
>> +
>>  	ctrl = &swap_cgroup_ctrl[swp_type(ent)];
>>  	if (ctrlp)
>>  		*ctrlp = ctrl;
>> @@ -416,6 +421,8 @@ unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
>>  	unsigned short retval;
>>  
>>  	sc = lookup_swap_cgroup(ent, &ctrl);
>> +	if (!sc)
>> +		return 0;
>>  
>>  	spin_lock_irqsave(&ctrl->lock, flags);
>>  	retval = sc->id;
>> @@ -443,6 +450,8 @@ unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
>>  	unsigned long flags;
>>  
>>  	sc = lookup_swap_cgroup(ent, &ctrl);
>> +	if (!sc)
>> +		return 0;
>>  
>>  	spin_lock_irqsave(&ctrl->lock, flags);
>>  	old = sc->id;
>> @@ -460,7 +469,9 @@ unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
>>   */
>>  unsigned short lookup_swap_cgroup_id(swp_entry_t ent)
>>  {
>> -	return lookup_swap_cgroup(ent, NULL)->id;
>> +	struct swap_cgroup *sc = lookup_swap_cgroup(ent, NULL);
>> +
>> +	return sc ? sc->id : 0;
>>  }
>>  
>>  int swap_cgroup_swapon(int type, unsigned long max_pages)
>> @@ -471,6 +482,9 @@ int swap_cgroup_swapon(int type, unsigned long max_pages)
>>  	if (!do_swap_account)
>>  		return 0;
>>  
>> +	if (!atomic_read(&memsw_accounting_users))
>> +		return 0;
>> +
>>  	length = DIV_ROUND_UP(max_pages, SC_PER_PAGE);
>>  
>>  	ctrl = &swap_cgroup_ctrl[type];
>> -- 
>> 1.7.9.5
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
