Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 085186B0006
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 21:06:00 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DF57A3EE0AE
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 10:05:58 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BF9B445DE4E
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 10:05:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A6AE945DE55
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 10:05:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DA4EE0800A
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 10:05:55 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 353F91DB8037
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 10:05:55 +0900 (JST)
Message-ID: <513FD0CB.4000407@jp.fujitsu.com>
Date: Wed, 13 Mar 2013 10:05:15 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] memcg: use global stat directly for root memcg usage
References: <1363082773-3598-1-git-send-email-handai.szj@taobao.com> <1363082920-3711-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1363082920-3711-1-git-send-email-handai.szj@taobao.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, glommer@parallels.com, akpm@linux-foundation.org, mgorman@suse.de, Sha Zhengju <handai.szj@taobao.com>

(2013/03/12 19:08), Sha Zhengju wrote:
> Since mem_cgroup_recursive_stat(root_mem_cgroup, INDEX) will sum up
> all memcg stats without regard to root's use_hierarchy, we may use
> global stats instead for simplicity.
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> ---
>   mm/memcontrol.c |    6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 669d16a..735cd41 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4987,11 +4987,11 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
>   			return res_counter_read_u64(&memcg->memsw, RES_USAGE);
>   	}
>   
> -	val = mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_CACHE);
> -	val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_RSS);
> +	val = global_page_state(NR_FILE_PAGES);
> +	val += global_page_state(NR_ANON_PAGES);
>   
you missed NR_ANON_TRANSPARENT_HUGEPAGES

>   	if (swap)
> -		val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_SWAP);
> +		val += total_swap_pages - atomic_long_read(&nr_swap_pages);
>   
Double count mapped SwapCache ? Did you saw Costa's trial in a week ago ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
