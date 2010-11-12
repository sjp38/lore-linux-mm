Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5AF7D8D0001
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 15:40:45 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH 4/6] memcg: simplify mem_cgroup_page_stat()
References: <1289294671-6865-1-git-send-email-gthelen@google.com>
	<1289294671-6865-5-git-send-email-gthelen@google.com>
	<20101112081957.GF9131@cmpxchg.org>
Date: Fri, 12 Nov 2010 12:40:22 -0800
Message-ID: <xr93pquaxoll.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Johannes Weiner <hannes@cmpxchg.org> writes:

> On Tue, Nov 09, 2010 at 01:24:29AM -0800, Greg Thelen wrote:
>> The cgroup given to mem_cgroup_page_stat() is no allowed to be
>> NULL or the root cgroup.  So there is no need to complicate the code
>> handling those cases.
>> 
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>> ---
>>  mm/memcontrol.c |   48 ++++++++++++++++++++++--------------------------
>>  1 files changed, 22 insertions(+), 26 deletions(-)
>> 
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index eb621ee..f8df350 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -1364,12 +1364,10 @@ memcg_hierarchical_free_pages(struct mem_cgroup *mem)
>>  
>>  /*
>>   * mem_cgroup_page_stat() - get memory cgroup file cache statistics
>> - * @mem:	optional memory cgroup to query.  If NULL, use current task's
>> - *		cgroup.
>> + * @mem:	memory cgroup to query
>>   * @item:	memory statistic item exported to the kernel
>>   *
>> - * Return the accounted statistic value or negative value if current task is
>> - * root cgroup.
>> + * Return the accounted statistic value.
>>   */
>>  long mem_cgroup_page_stat(struct mem_cgroup *mem,
>>  			  enum mem_cgroup_nr_pages_item item)
>> @@ -1377,29 +1375,27 @@ long mem_cgroup_page_stat(struct mem_cgroup *mem,
>>  	struct mem_cgroup *iter;
>>  	long value;
>>  
>> +	VM_BUG_ON(!mem);
>> +	VM_BUG_ON(mem_cgroup_is_root(mem));
>> +
>>  	get_online_cpus();
>> -	rcu_read_lock();
>> -	if (!mem)
>> -		mem = mem_cgroup_from_task(current);
>> -	if (__mem_cgroup_has_dirty_limit(mem)) {
>
> What about mem->use_hierarchy that is checked in
> __mem_cgroup_has_dirty_limit()?  Is it no longer needed?

It is no longer needed because the callers of mem_cgroup_page_stat()
call __mem_cgroup_has_dirty_limit().  In the current implementation, if
use_hierarchy=1 then the cgroup does not have dirty limits, so calls
into mem_cgroup_page_stat() are avoided.  Specifically the callers of
mem_cgroup_page_stat() are:

1. mem_cgroup_dirty_info() which calls __mem_cgroup_has_dirty_limit()
   and returns false if use_hierarchy=1.

2. throttle_vm_writeout() which calls mem_dirty_info() ->
   mem_cgroup_dirty_info() -> __mem_cgroup_has_dirty_limit() will fall
   back to global limits if use_hierarchy=1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
