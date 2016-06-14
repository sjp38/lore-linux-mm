Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 483A46B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 11:47:25 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id wy7so57762509lbb.0
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 08:47:25 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id md4si11781829wjb.246.2016.06.14.08.47.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 08:47:23 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id m124so23348181wme.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 08:47:23 -0700 (PDT)
Subject: Re: [RFC 03/18] memcontrol: present maximum used memory also for
 cgroup-v2
References: <1465847065-3577-1-git-send-email-toiwoton@gmail.com>
 <1465847065-3577-4-git-send-email-toiwoton@gmail.com>
 <20160614070130.GB5681@dhcp22.suse.cz>
From: Topi Miettinen <toiwoton@gmail.com>
Message-ID: <b9d04ccd-28d2-993a-2a40-bbed7b6289d4@gmail.com>
Date: Tue, 14 Jun 2016 15:47:20 +0000
MIME-Version: 1.0
In-Reply-To: <20160614070130.GB5681@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, "open list:CONTROL GROUP - MEMORY RESOURCE CONTROLLER (MEMCG)" <cgroups@vger.kernel.org>, "open list:CONTROL GROUP - MEMORY RESOURCE CONTROLLER (MEMCG)" <linux-mm@kvack.org>

On 06/14/16 07:01, Michal Hocko wrote:
> On Mon 13-06-16 22:44:10, Topi Miettinen wrote:
>> Present maximum used memory in cgroup memory.current_max.
> 
> It would be really much more preferable to present the usecase in the
> patch description. It is true that this information is presented in the
> v1 API but the current policy is to export new knobs only when there is
> a reasonable usecase for it.
> 

This was stated in the cover letter:
https://lkml.org/lkml/2016/6/13/857

"There are many basic ways to control processes, including capabilities,
cgroups and resource limits. However, there are far fewer ways to find out
useful values for the limits, except blind trial and error.

This patch series attempts to fix that by giving at least a nice starting
point from the actual maximum values. I looked where each limit is checked
and added a call to limit bump nearby."

"Cgroups
[RFC 02/18] cgroup_pids: track maximum pids
[RFC 03/18] memcontrol: present maximum used memory also for
[RFC 04/18] device_cgroup: track and present accessed devices

For tasks and memory cgroup limits the situation is somewhat better as the
current tasks and memory status can be easily seen with ps(1). However, any
transient tasks or temporary higher memory use might slip from the view.
Device use may be seen with advanced MAC tools, like TOMOYO, but there is no
universal method. Program sources typically give no useful indication about
memory use or how many tasks there could be."

I can add some of this to the commit message, is that sufficient for you?

>> Signed-off-by: Topi Miettinen <toiwoton@gmail.com>
>> ---
>>  include/linux/page_counter.h |  7 ++++++-
>>  mm/memcontrol.c              | 13 +++++++++++++
>>  2 files changed, 19 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/page_counter.h b/include/linux/page_counter.h
>> index 7e62920..be4de17 100644
>> --- a/include/linux/page_counter.h
>> +++ b/include/linux/page_counter.h
>> @@ -9,9 +9,9 @@ struct page_counter {
>>  	atomic_long_t count;
>>  	unsigned long limit;
>>  	struct page_counter *parent;
>> +	unsigned long watermark;
>>  
>>  	/* legacy */
>> -	unsigned long watermark;
>>  	unsigned long failcnt;
>>  };
>>  
>> @@ -34,6 +34,11 @@ static inline unsigned long page_counter_read(struct page_counter *counter)
>>  	return atomic_long_read(&counter->count);
>>  }
>>  
>> +static inline unsigned long page_counter_read_watermark(struct page_counter *counter)
>> +{
>> +	return counter->watermark;
>> +}
>> +
>>  void page_counter_cancel(struct page_counter *counter, unsigned long nr_pages);
>>  void page_counter_charge(struct page_counter *counter, unsigned long nr_pages);
>>  bool page_counter_try_charge(struct page_counter *counter,
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 75e7440..5513771 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -4966,6 +4966,14 @@ static u64 memory_current_read(struct cgroup_subsys_state *css,
>>  	return (u64)page_counter_read(&memcg->memory) * PAGE_SIZE;
>>  }
>>  
>> +static u64 memory_current_max_read(struct cgroup_subsys_state *css,
>> +				   struct cftype *cft)
>> +{
>> +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>> +
>> +	return (u64)page_counter_read_watermark(&memcg->memory) * PAGE_SIZE;
>> +}
>> +
>>  static int memory_low_show(struct seq_file *m, void *v)
>>  {
>>  	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
>> @@ -5179,6 +5187,11 @@ static struct cftype memory_files[] = {
>>  		.read_u64 = memory_current_read,
>>  	},
>>  	{
>> +		.name = "current_max",
>> +		.flags = CFTYPE_NOT_ON_ROOT,
>> +		.read_u64 = memory_current_max_read,
>> +	},
>> +	{
>>  		.name = "low",
>>  		.flags = CFTYPE_NOT_ON_ROOT,
>>  		.seq_show = memory_low_show,
>> -- 
>> 2.8.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
