Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 8C9086B0129
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 20:07:06 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1E4DF3EE0BC
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 09:07:05 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 077A645DE58
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 09:07:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E60ED45DE54
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 09:07:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D65BBE38006
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 09:07:04 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C878E38001
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 09:07:04 +0900 (JST)
Message-ID: <4FE3B69E.3040801@jp.fujitsu.com>
Date: Fri, 22 Jun 2012 09:04:46 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memcg: clean up force_empty_list() return value check
References: <4FDF17A3.9060202@jp.fujitsu.com> <4FDF1830.1000504@jp.fujitsu.com> <20120619165815.5ce24be7.akpm@linux-foundation.org> <4FE2D747.20506@jp.fujitsu.com> <4FE2D87D.2090500@jp.fujitsu.com> <20120621131328.1e906266.akpm@linux-foundation.org>
In-Reply-To: <20120621131328.1e906266.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

(2012/06/22 5:13), Andrew Morton wrote:
> On Thu, 21 Jun 2012 17:17:01 +0900
> Kamezawa Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>  wrote:
>
>> Now, mem_cgroup_force_empty_list() just returns 0 or -EBUSY and
>> -EBUSY is just indicating 'you need to retry.'.
>> This patch makes mem_cgroup_force_empty_list() as boolean function and
>> make the logic simpler.
>>
>
> For some reason I'm having trouble applying these patches - many
> rejects, need to massage it in by hand.
>

Oh, sorry. Is it space breakage or some ? (I had mailer troubles in the last week..)
Or, maybe, my tree/patch queue was too old.
I'll rebased to new -mm tree when I post new patch.

>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -3797,7 +3797,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>>     * This routine traverse page_cgroup in given list and drop them all.
>>     * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
>>     */
>> -static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
>> +static bool mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
>>    				int node, int zid, enum lru_list lru)
>
> Let's document the return value.  The mem_cgroup_force_empty_list()
> comment is a mess so I tried to help it a bit.  How does this look?
>
> --- a/mm/memcontrol.c~memcg-make-mem_cgroup_force_empty_list-return-bool-fix
> +++ a/mm/memcontrol.c
> @@ -3609,8 +3609,10 @@ unsigned long mem_cgroup_soft_limit_recl
>   }
>
>   /*
> - * This routine traverse page_cgroup in given list and drop them all.
> - * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
> + * Traverse a specified page_cgroup list and try to drop them all.  This doesn't
> + * reclaim the pages page themselves - it just removes the page_cgroups.
> + * Returns true if some page_cgroups were not freed, indicating that the caller
> + * must retry this operation.
>    */
>   static bool mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
>   				int node, int zid, enum lru_list lru)
> _

Seems nice! Thank you very much.

Regards,
-Kame
  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
