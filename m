Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3F26B004A
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 03:02:49 -0400 (EDT)
Message-ID: <4E0D7108.5070802@oracle.com>
Date: Fri, 01 Jul 2011 00:02:32 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: mmotm 2011-06-30-15-59 uploaded (mm/memcontrol.c)
References: <201106302259.p5UMxh5i019162@imap1.linux-foundation.org>	<20110630172054.49287627.randy.dunlap@oracle.com>	<20110701091525.bd8095f1.kamezawa.hiroyu@jp.fujitsu.com> <20110701095433.71c2aa18.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110701095433.71c2aa18.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 06/30/11 17:54, KAMEZAWA Hiroyuki wrote:
> On Fri, 1 Jul 2011 09:15:25 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
>> On Thu, 30 Jun 2011 17:20:54 -0700
>> Randy Dunlap <randy.dunlap@oracle.com> wrote:
>>
>>> On Thu, 30 Jun 2011 15:59:43 -0700 akpm@linux-foundation.org wrote:
>>>
>>>> The mm-of-the-moment snapshot 2011-06-30-15-59 has been uploaded to
>>>>
>>>>    http://userweb.kernel.org/~akpm/mmotm/
>>>>
>>>> and will soon be available at
>>>>    git://zen-kernel.org/kernel/mmotm.git
>>>> or
>>>>    git://git.cmpxchg.org/linux-mmotm.git
>>>>
>>>> It contains the following patches against 3.0-rc5:
>>>
>>> I see several of these build errors:
>>>
>>> mmotm-2011-0630-1559/mm/memcontrol.c:1579: error: implicit declaration of function 'mem_cgroup_node_nr_file_lru_pages'
>>> mmotm-2011-0630-1559/mm/memcontrol.c:1583: error: implicit declaration of function 'mem_cgroup_node_nr_anon_lru_pages'
>>>
>>
>> Thanks...maybe !CONFIG_NUMA again. will post a fix soon.
>>
> 
> fix here. compiled and booted on !CONFIG_NUMA on my host.
> I think I should do total cleanup of functions in mm/memcontrol.c 
> in the next week..several functions implements similar logics....
> ==
> From 8773fc8b596dc56adf52fd0780c1b034291185ee Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Fri, 1 Jul 2011 09:49:54 +0900
> Subject: [PATCH]memcg-fix-reclaimable-lru-check-in-memcg-fix2.patch
> 
> 
>  memcg-fix-reclaimable-lru-check-in-memcg.patch
>  causes following error with !CONFIG_NUMA.
> 
>> mmotm-2011-0630-1559/mm/memcontrol.c:1579: error: implicit declaration of function 'mem_cgroup_node_nr_file_lru_pages'
>> mmotm-2011-0630-1559/mm/memcontrol.c:1583: error: implicit declaration of function 'mem_cgroup_node_nr_anon_lru_pages'
>>
> 
> This patch fixes it by moving functions out of #ifdef.
> 
> Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Thanks.

> ---
>  mm/memcontrol.c |   23 +++++++++++------------
>  1 files changed, 11 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index db70176..fb7338f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1134,7 +1134,6 @@ unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
>  	return MEM_CGROUP_ZSTAT(mz, lru);
>  }
>  
> -#ifdef CONFIG_NUMA
>  static unsigned long mem_cgroup_node_nr_file_lru_pages(struct mem_cgroup *memcg,
>  							int nid)
>  {
> @@ -1146,6 +1145,17 @@ static unsigned long mem_cgroup_node_nr_file_lru_pages(struct mem_cgroup *memcg,
>  	return ret;
>  }
>  
> +static unsigned long mem_cgroup_node_nr_anon_lru_pages(struct mem_cgroup *memcg,
> +							int nid)
> +{
> +	unsigned long ret;
> +
> +	ret = mem_cgroup_get_zonestat_node(memcg, nid, LRU_INACTIVE_ANON) +
> +		mem_cgroup_get_zonestat_node(memcg, nid, LRU_ACTIVE_ANON);
> +	return ret;
> +}
> +
> +#if MAX_NUMNODES > 1
>  static unsigned long mem_cgroup_nr_file_lru_pages(struct mem_cgroup *memcg)
>  {
>  	u64 total = 0;
> @@ -1157,17 +1167,6 @@ static unsigned long mem_cgroup_nr_file_lru_pages(struct mem_cgroup *memcg)
>  	return total;
>  }
>  
> -static unsigned long mem_cgroup_node_nr_anon_lru_pages(struct mem_cgroup *memcg,
> -							int nid)
> -{
> -	unsigned long ret;
> -
> -	ret = mem_cgroup_get_zonestat_node(memcg, nid, LRU_INACTIVE_ANON) +
> -		mem_cgroup_get_zonestat_node(memcg, nid, LRU_ACTIVE_ANON);
> -
> -	return ret;
> -}
> -
>  static unsigned long mem_cgroup_nr_anon_lru_pages(struct mem_cgroup *memcg)
>  {
>  	u64 total = 0;


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
