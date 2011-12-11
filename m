Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 6F6966B0085
	for <linux-mm@kvack.org>; Sun, 11 Dec 2011 18:39:48 -0500 (EST)
Received: by iahk25 with SMTP id k25so10257293iah.14
        for <linux-mm@kvack.org>; Sun, 11 Dec 2011 15:39:47 -0800 (PST)
Date: Sun, 11 Dec 2011 15:39:43 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: memcg: keep root group unchanged if fail to create
 new
In-Reply-To: <CAJd=RBB_AoJmyPd7gfHn+Kk39cn-+Wn-pFvU0ZWRZhw2fxoihw@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1112111520510.2297@eggly>
References: <CAJd=RBB_AoJmyPd7gfHn+Kk39cn-+Wn-pFvU0ZWRZhw2fxoihw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Balbir Singh <bsingharora@gmail.com>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Sun, 11 Dec 2011, Hillf Danton wrote:

> If the request is not to create root group and we fail to meet it,
> we'd leave the root unchanged.

I didn't understand that at first: please say "we should" rather
than "we'd", which I take to be an abbreviation for "we would".

> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>

Yes indeed, well caught:
Acked-by: Hugh Dickins <hughd@google.com>

I wonder what was going through the author's mind when he wrote it
that way?  I wonder if it's one of those bugs that creeps in when
you start from a perfectly functional patch, then make refinements
to suit feedback from reviewers.

On which topic: wouldn't this patch be better just to move the
"root_mem_cgroup = memcg;" two lines lower down (and of course
remove free_out's "root_mem_cgroup = NULL;" as you already did)?
I can't see mem_cgroup_soft_limit_tree_init() relying on
root_mem_cgroup at all.

Should your patch go to stable, even to 2.6.32-longterm?
Matter of taste, really: while it's not quite impossible for
alloc_mem_cgroup_per_zone_info() to fail, it is very unlikely.

> ---
> 
> --- a/mm/memcontrol.c	Fri Dec  9 21:57:40 2011
> +++ b/mm/memcontrol.c	Sun Dec 11 09:04:48 2011
> @@ -4849,8 +4849,10 @@ mem_cgroup_create(struct cgroup_subsys *
>  		enable_swap_cgroup();
>  		parent = NULL;
>  		root_mem_cgroup = memcg;
> -		if (mem_cgroup_soft_limit_tree_init())
> +		if (mem_cgroup_soft_limit_tree_init()) {
> +			root_mem_cgroup = NULL;
>  			goto free_out;
> +		}
>  		for_each_possible_cpu(cpu) {
>  			struct memcg_stock_pcp *stock =
>  						&per_cpu(memcg_stock, cpu);
> @@ -4888,7 +4890,6 @@ mem_cgroup_create(struct cgroup_subsys *
>  	return &memcg->css;
>  free_out:
>  	__mem_cgroup_free(memcg);
> -	root_mem_cgroup = NULL;
>  	return ERR_PTR(error);
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
