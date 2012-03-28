Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id A68D26B00FB
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 09:40:23 -0400 (EDT)
Date: Wed, 28 Mar 2012 15:40:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V4 04/10] memcg: Add HugeTLB extension
Message-ID: <20120328134020.GG20949@tiehlicka.suse.cz>
References: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1331919570-2264-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1331919570-2264-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Fri 16-03-12 23:09:24, Aneesh Kumar K.V wrote:
[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6728a7a..4b36c5e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
[...]
> @@ -4887,6 +5013,7 @@ err_cleanup:
>  static struct cgroup_subsys_state * __ref
>  mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  {
> +	int idx;
>  	struct mem_cgroup *memcg, *parent;
>  	long error = -ENOMEM;
>  	int node;
> @@ -4929,9 +5056,14 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  		 * mem_cgroup(see mem_cgroup_put).
>  		 */
>  		mem_cgroup_get(parent);
> +		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
> +			res_counter_init(&memcg->hugepage[idx],
> +					 &parent->hugepage[idx]);

Hmm, I do not think we want to make groups deeper in the hierarchy
unlimited as we cannot reclaim. Shouldn't we copy the limit from the parent?
Still not ideal but slightly more expected behavior IMO.

The hierarchy setups are still interesting and the limitations should be
described in the documentation...

>  	} else {
>  		res_counter_init(&memcg->res, NULL);
>  		res_counter_init(&memcg->memsw, NULL);
> +		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
> +			res_counter_init(&memcg->hugepage[idx], NULL);
>  	}
>  	memcg->last_scanned_node = MAX_NUMNODES;
>  	INIT_LIST_HEAD(&memcg->oom_notify);
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
