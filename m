Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 84A0D6B004F
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 03:47:18 -0500 (EST)
Date: Mon, 16 Jan 2012 09:47:15 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix compile warning on non-numa systems
Message-ID: <20120116084715.GA1639@tiehlicka.suse.cz>
References: <4F13BE05.70505@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F13BE05.70505@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: linux-mm@kvack.org, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Mon 16-01-12 14:04:53, Li Zefan wrote:
> Fix this warning:
> 
>   CC      mm/memcontrol.o
> mm/memcontrol.c: In function 'memcg_check_events':
> mm/memcontrol.c:779:22: warning: unused variable 'do_numainfo'

This has been already posted by Kirill and I didn't like the solution
(https://lkml.org/lkml/2011/12/27/86). He then reposted with a different
version (https://lkml.org/lkml/2012/1/6/281).
The later one looks better but I still think this is not worth
complicate the code just to get rid of this warning.

> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> ---
>  mm/memcontrol.c |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 602207b..c8aeab8 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -776,14 +776,16 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
>  	/* threshold event is triggered in finer grain than soft limit */
>  	if (unlikely(mem_cgroup_event_ratelimit(memcg,
>  						MEM_CGROUP_TARGET_THRESH))) {
> -		bool do_softlimit, do_numainfo;
> -
> -		do_softlimit = mem_cgroup_event_ratelimit(memcg,
> -						MEM_CGROUP_TARGET_SOFTLIMIT);
> +		bool do_softlimit;
>  #if MAX_NUMNODES > 1
> +		bool do_numainfo;
> +
>  		do_numainfo = mem_cgroup_event_ratelimit(memcg,
>  						MEM_CGROUP_TARGET_NUMAINFO);
>  #endif
> +
> +		do_softlimit = mem_cgroup_event_ratelimit(memcg,
> +						MEM_CGROUP_TARGET_SOFTLIMIT);
>  		preempt_enable();
>  
>  		mem_cgroup_threshold(memcg);
> -- 
> 1.7.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
