Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 4F2C06B004A
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 03:25:06 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DBDE93EE0BB
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:25:04 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BF76945DEB6
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:25:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9859F45DE9E
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:25:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7EC591DB8047
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:25:04 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C7F921DB8038
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:25:03 +0900 (JST)
Message-ID: <4F8E6BDC.6050703@jp.fujitsu.com>
Date: Wed, 18 Apr 2012 16:23:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/6] memcg: add pc_set_mem_cgroup_and_flags()
References: <4F72EB84.7080000@jp.fujitsu.com> <4F72ED25.60307@jp.fujitsu.com> <CALWz4izNDGdGYmkJzHCRFspCk9QwoZtvRWpKmn=0YZRaVrcVAA@mail.gmail.com>
In-Reply-To: <CALWz4izNDGdGYmkJzHCRFspCk9QwoZtvRWpKmn=0YZRaVrcVAA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Suleiman Souhlal <suleiman@google.com>

(2012/04/18 6:17), Ying Han wrote:

> On Wed, Mar 28, 2012 at 3:51 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> Consolidate a code for setting pc->mem_cgroup and USED bit which requires smp_wmb().
>> And remove a macro PCGF_NOCOPY_AT_SPLIT which isn't helpful to read code, now.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>>  include/linux/page_cgroup.h |   18 ++++++++++++++++++
>>  mm/memcontrol.c             |   18 ++++--------------
>>  2 files changed, 22 insertions(+), 14 deletions(-)
>>
>> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
>> index 92768cb..2707809 100644
>> --- a/include/linux/page_cgroup.h
>> +++ b/include/linux/page_cgroup.h
>> @@ -1,6 +1,8 @@
>>  #ifndef __LINUX_PAGE_CGROUP_H
>>  #define __LINUX_PAGE_CGROUP_H
>>
>> +#include <linux/smp.h>
>> +
>>  enum {
>>        /* flags for mem_cgroup */
>>        PCG_LOCK,  /* Lock for pc->mem_cgroup and following bits. */
>> @@ -94,6 +96,22 @@ pc_set_mem_cgroup(struct page_cgroup *pc, struct mem_cgroup *memcg)
>>        pc->mem_cgroup = memcg;
>>  }
>>
>> +static inline void
>> +pc_set_mem_cgroup_and_flags(struct page_cgroup *pc, struct mem_cgroup *memcg,
>> +                       unsigned long flags)
>> +{
>> +       pc->mem_cgroup = memcg;
>> +       /*
>> +        * We access a page_cgroup asynchronously without lock_page_cgroup().
>> +        * Especially when a page_cgroup is taken from a page, pc's mem_cgroup
>> +        * is accessed after testing USED bit. To make pc's mem_cgroup visible
>> +        * before USED bit, we need memory barrier here.
>> +        * See mem_cgroup_add_lru_list(), etc.
>> +        */
>> +       smp_wmb();
>> +       pc->flags = flags;
>> +}
>> +
>>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>>  struct page_cgroup;
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 8077460..d366b60 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -2511,16 +2511,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
>>                }
>>        }
>>
>> -       pc_set_mem_cgroup(pc, memcg);
>> -       /*
>> -        * We access a page_cgroup asynchronously without lock_page_cgroup().
>> -        * Especially when a page_cgroup is taken from a page, pc's mem_cgroup
>> -        * is accessed after testing USED bit. To make pc's mem_cgroup visible
>> -        * before USED bit, we need memory barrier here.
>> -        * See mem_cgroup_add_lru_list(), etc.
>> -        */
>> -       smp_wmb();
>> -       SetPageCgroupUsed(pc);
> 
> I might be confused. We removed this SetPageCgroupUsed() but not
> adding it back elsewhere ?
> 
> --Ying
> 
>> +       pc_set_mem_cgroup_and_flags(pc, memcg, BIT(PCG_USED) | BIT(PCG_LOCK));


Added here. This sets  

  | memcg pointer | Used | Locked |


Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
