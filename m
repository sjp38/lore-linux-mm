Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6326A6B009D
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 20:25:22 -0500 (EST)
Message-ID: <4B95A379.4000207@cn.fujitsu.com>
Date: Tue, 09 Mar 2010 09:25:13 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH V2 1/4] cpuset: fix the problem that cpuset_mem_spread_node()
 returns an offline node
References: <4B94CB6C.8090601@cn.fujitsu.com> <alpine.DEB.2.00.1003081318460.14689@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1003081318460.14689@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

on 2010-3-9 5:22, David Rientjes wrote:
> On Mon, 8 Mar 2010, Miao Xie wrote:
> 
>> Changes from V1 to V2:
>> - cleanup two unnecessary smp_wmb() at cpuset_migrate_mm()
>>
> 
> This patch is already in -mm without this update, so it's probably better 
> to make this an incremental series basedo n mmotm-2010-03-04-18-05 or 
> later.

ok, I'll do it.

> 
>> @@ -2090,15 +2086,19 @@ static int cpuset_track_online_cpus(struct notifier_block *unused_nb,
>>  static int cpuset_track_online_nodes(struct notifier_block *self,
>>  				unsigned long action, void *arg)
>>  {
>> +	nodemask_t oldmems;
>> +
>>  	cgroup_lock();
>>  	switch (action) {
>>  	case MEM_ONLINE:
>> -	case MEM_OFFLINE:
>> +		oldmems = top_cpuset.mems_allowed;
>>  		mutex_lock(&callback_mutex);
>>  		top_cpuset.mems_allowed = node_states[N_HIGH_MEMORY];
>>  		mutex_unlock(&callback_mutex);
>> -		if (action == MEM_OFFLINE)
>> -			scan_for_empty_cpusets(&top_cpuset);
>> +		update_tasks_nodemask(&top_cpuset, &oldmems, NULL);
>> +		break;
>> +	case MEM_OFFLINE:
>> +		scan_for_empty_cpusets(&top_cpuset);
>>  		break;
>>  	default:
>>  		break;
> 
> This looks wrong, why isn't top_cpuset.mems_allowed updated for 
> MEM_OFFLINE?  If you're going to update it when a new node comes online 
> for (struct memory_notify *)arg->status_change_nid is >= 0, then it should 
> be removed from the nodemask when offlined as well.  You'd be calling 
> scan_for_empty_cpusets() needlessly in this code since it'll never change 
> under your hotplug code.

scan_for_empty_cpusets() will update top_cpuset.mems_allowed when doing MEM_OFFLINE.

The comment of this source is necessary. I'll add it.

Thanks!
Miao

> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
