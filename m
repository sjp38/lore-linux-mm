Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 5F5396B0044
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 20:49:16 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 719773EE0BD
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 09:49:14 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 56D6945DD74
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 09:49:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C3BF45DE4E
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 09:49:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D39C1DB8044
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 09:49:14 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D380F1DB803A
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 09:49:13 +0900 (JST)
Message-ID: <4F692521.8010607@jp.fujitsu.com>
Date: Wed, 21 Mar 2012 09:47:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/3] memcg: reduce size of struct page_cgroup.
References: <4F66E6A5.10804@jp.fujitsu.com> <4F66E7D7.4040406@jp.fujitsu.com> <CABCjUKAr+F=Pz-JCWfjGfyL4AcHt6m97p13=0VdwjeVm5SKW7w@mail.gmail.com>
In-Reply-To: <CABCjUKAr+F=Pz-JCWfjGfyL4AcHt6m97p13=0VdwjeVm5SKW7w@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <suleiman@google.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, n-horiguchi@ah.jp.nec.com, khlebnikov@openvz.org, Tejun Heo <tj@kernel.org>

(2012/03/20 7:20), Suleiman Souhlal wrote:

> 2012/3/19 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
>> Now, page_cgroup->flags has only 3bits. Considering alignment of
>> struct mem_cgroup, which is allocated by kmalloc(), we can encode
>> pointer to mem_cgroup and flags into a word.
>>
>> After this patch, pc->flags is encoded as
>>
>>  63                           2     0
>>  | pointer to memcg..........|flags|
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>>  include/linux/page_cgroup.h |   15 ++++++++++++---
>>  1 files changed, 12 insertions(+), 3 deletions(-)
>>
>> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
>> index 92768cb..bca5447 100644
>> --- a/include/linux/page_cgroup.h
>> +++ b/include/linux/page_cgroup.h
>> @@ -1,6 +1,10 @@
>>  #ifndef __LINUX_PAGE_CGROUP_H
>>  #define __LINUX_PAGE_CGROUP_H
>>
>> +/*
>> + * Because these flags are encoded into ->flags with a pointer,
>> + * we cannot have too much flags.
>> + */
>>  enum {
>>        /* flags for mem_cgroup */
>>        PCG_LOCK,  /* Lock for pc->mem_cgroup and following bits. */
>> @@ -9,6 +13,8 @@ enum {
>>        __NR_PCG_FLAGS,
>>  };
>>
>> +#define PCG_FLAGS_MASK ((1 << __NR_PCG_FLAGS) - 1)
>> +
>>  #ifndef __GENERATING_BOUNDS_H
>>  #include <generated/bounds.h>
>>
>> @@ -21,10 +27,12 @@ enum {
>>  * page_cgroup helps us identify information about the cgroup
>>  * All page cgroups are allocated at boot or memory hotplug event,
>>  * then the page cgroup for pfn always exists.
>> + *
>> + * flags and a pointer to memory cgroup are encoded into ->flags.
>> + * Lower 3bits are used for flags and others are used for a pointer to memcg.
> 
> Would it be worth adding a BUILD_BUG_ON(__NR_PCG_FLAGS > 3) ?
> 


Ok, I'll add that.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
