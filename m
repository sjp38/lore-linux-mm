Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C29426B0266
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 07:21:30 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id a9so2215059pgf.12
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 04:21:30 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0127.outbound.protection.outlook.com. [104.47.1.127])
        by mx.google.com with ESMTPS id y7si13625800plk.63.2018.01.11.04.21.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 11 Jan 2018 04:21:29 -0800 (PST)
Subject: Re: [PATCH v4] mm/memcg: try harder to decrease
 [memory,memsw].limit_in_bytes
References: <20180109152622.31ca558acb0cc25a1b14f38c@linux-foundation.org>
 <20180110124317.28887-1-aryabinin@virtuozzo.com>
 <20180111104239.GZ1732@dhcp22.suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <4a8f667d-c2ae-e3df-00fd-edc01afe19e1@virtuozzo.com>
Date: Thu, 11 Jan 2018 15:21:33 +0300
MIME-Version: 1.0
In-Reply-To: <20180111104239.GZ1732@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>



On 01/11/2018 01:42 PM, Michal Hocko wrote:
> On Wed 10-01-18 15:43:17, Andrey Ryabinin wrote:
> [...]
>> @@ -2506,15 +2480,13 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>>  		if (!ret)
>>  			break;
>>  
>> -		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, !memsw);
>> -
>> -		curusage = page_counter_read(counter);
>> -		/* Usage is reduced ? */
>> -		if (curusage >= oldusage)
>> -			retry_count--;
>> -		else
>> -			oldusage = curusage;
>> -	} while (retry_count);
>> +		usage = page_counter_read(counter);
>> +		if (!try_to_free_mem_cgroup_pages(memcg, usage - limit,
>> +						GFP_KERNEL, !memsw)) {
> 
> If the usage drops below limit in the meantime then you get underflow
> and reclaim the whole memcg. I do not think this is a good idea. This
> can also lead to over reclaim. Why don't you simply stick with the
> original SWAP_CLUSTER_MAX (aka 1 for try_to_free_mem_cgroup_pages)?
> 

Because, if new limit is gigabytes bellow the current usage, retrying to set
new limit after reclaiming only 32 pages seems unreasonable.

So, I made this:


From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: mm-memcg-try-harder-to-decrease-limit_in_bytes-fix

Protect from overreclaim if usage become lower than limit.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/memcontrol.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4671ae8a8b1a..6120bb619547 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2455,7 +2455,7 @@ static DEFINE_MUTEX(memcg_limit_mutex);
 static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 				   unsigned long limit, bool memsw)
 {
-	unsigned long usage;
+	unsigned long nr_pages;
 	bool enlarge = false;
 	int ret;
 	bool limits_invariant;
@@ -2487,8 +2487,8 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
-		usage = page_counter_read(counter);
-		if (!try_to_free_mem_cgroup_pages(memcg, usage - limit,
+		nr_pages = max_t(long, 1, page_counter_read(counter) - limit);
+		if (!try_to_free_mem_cgroup_pages(memcg, nr_pages,
 						GFP_KERNEL, !memsw)) {
 			ret = -EBUSY;
 			break;
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
