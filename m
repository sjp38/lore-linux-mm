Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 94D486B00AC
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 04:54:04 -0400 (EDT)
Message-ID: <50504CE1.8030509@parallels.com>
Date: Wed, 12 Sep 2012 12:50:41 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/memcontrol.c: Remove duplicate inclusion of sock.h
 file
References: <1347350934-17712-1-git-send-email-sachin.kamat@linaro.org> <20120911095200.GB8058@dhcp22.suse.cz> <20120912072520.GB17516@dhcp22.suse.cz>
In-Reply-To: <20120912072520.GB17516@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Sachin Kamat <sachin.kamat@linaro.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

On 09/12/2012 11:25 AM, Michal Hocko wrote:
> Just realized that Glauber is not in the CC list. Glauber, could you
> have a look? The thread started here:
> http://www.spinics.net/lists/linux-mm/msg41725.html
> 
> Thanks!
> 
> On Tue 11-09-12 11:52:00, Michal Hocko wrote:
>> On Tue 11-09-12 13:38:54, Sachin Kamat wrote:
>>> net/sock.h is included unconditionally at the beginning of the file.
>>> Hence, another conditional include is not required.
>>
>> I guess we can do little bit better. What do you think about the
>> following?  I have compile tested this with:
>> - CONFIG_INET=y && CONFIG_MEMCG_KMEM=n
>> - CONFIG_MEMCG_KMEM=y
>> ---
>> From 83c5a97e893b5379b7e93cfdc933d5e37756e70a Mon Sep 17 00:00:00 2001
>> From: Michal Hocko <mhocko@suse.cz>
>> Date: Tue, 11 Sep 2012 10:38:42 +0200
>> Subject: [PATCH] memcg: clean up networking headers file inclusion
>>
>> Memory controller doesn't need anything from the networking stack unless
>> CONFIG_MEMCG_KMEM is selected.
>> Now we are including net/sock.h and net/tcp_memcontrol.h unconditionally
>> which is not necessary. Moreover struct mem_cgroup contains tcp_mem even
>> if CONFIG_MEMCG_KMEM is not selected which is not necessary.
>>
>> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
>> Signed-off-by: Michal Hocko <mhocko@suse.cz>
>> ---
>>  mm/memcontrol.c |    8 +++++---
>>  1 file changed, 5 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 795e525..85ec9ff 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -50,8 +50,12 @@
>>  #include <linux/cpu.h>
>>  #include <linux/oom.h>
>>  #include "internal.h"
>> +
>> +#ifdef CONFIG_MEMCG_KMEM
>>  #include <net/sock.h>
>> +#include <net/ip.h>
>>  #include <net/tcp_memcontrol.h>
>> +#endif
>>  
>>  #include <asm/uaccess.h>
>>  
>> @@ -326,7 +330,7 @@ struct mem_cgroup {
>>  	struct mem_cgroup_stat_cpu nocpu_base;
>>  	spinlock_t pcp_counter_lock;
>>  
>> -#ifdef CONFIG_INET
>> +#ifdef CONFIG_MEMCG_KMEM
>>  	struct tcp_memcontrol tcp_mem;
>>  #endif
>>  };

If you are changing this, why not test for both? This field will be
useless with inet disabled. I usually don't like conditional in
structures (note that the "kmem" res counter in my patchsets is not
conditional to KMEM!!), but since the decision was made to make this one
conditional, I think INET is a much better test. I am fine with both though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
