Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 912566B005D
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 05:13:37 -0400 (EDT)
Date: Thu, 19 Jul 2012 12:14:20 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/memcg: wrap mem_cgroup_from_css function
Message-ID: <20120719091420.GA2549@shutemov.name>
References: <a>
 <1342580730-25703-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1342580730-25703-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Gavin Shan <shangw@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

On Wed, Jul 18, 2012 at 11:05:30AM +0800, Wanpeng Li wrote:
> wrap mem_cgroup_from_css function to clarify get mem cgroup
> from cgroup_subsys_state.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Gavin Shan <shangw@linux.vnet.ibm.com>
> Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Cc: linux-kernel@vger.kernel.org
> ---
>  mm/memcontrol.c |   14 ++++++++++----
>  1 files changed, 10 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 58a08fc..20f6a15 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -396,6 +396,12 @@ static void mem_cgroup_put(struct mem_cgroup *memcg);
>  #include <net/sock.h>
>  #include <net/ip.h>
>  
> +static inline
> +struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
> +{
> +	return container_of(s, struct mem_cgroup, css);
> +}
> +
>  static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
>  void sock_update_memcg(struct sock *sk)
>  {
> @@ -820,7 +826,7 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
>  
>  struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
>  {
> -	return container_of(cgroup_subsys_state(cont,
> +	return mem_cgroup_from_css(cgroup_subsys_state(cont,
>  				mem_cgroup_subsys_id), struct mem_cgroup,
>  				css);

Hm?.. Here and below too many args to mem_cgroup_from_css().
Have you tested the code?

>  }
> @@ -835,7 +841,7 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
>  	if (unlikely(!p))
>  		return NULL;
>  
> -	return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
> +	return mem_cgroup_from_css(task_subsys_state(p, mem_cgroup_subsys_id),
>  				struct mem_cgroup, css);
>  }
>  
> @@ -922,7 +928,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  		css = css_get_next(&mem_cgroup_subsys, id + 1, &root->css, &id);
>  		if (css) {
>  			if (css == &root->css || css_tryget(css))
> -				memcg = container_of(css,
> +				memcg = mem_cgroup_from_css(css,
>  						     struct mem_cgroup, css);
>  		} else
>  			id = 0;
> @@ -2406,7 +2412,7 @@ static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
>  	css = css_lookup(&mem_cgroup_subsys, id);
>  	if (!css)
>  		return NULL;
> -	return container_of(css, struct mem_cgroup, css);
> +	return mem_cgroup_from_css(css, struct mem_cgroup, css);
>  }
>  
>  struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
> -- 
> 1.7.5.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
