Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id B89196B005A
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 19:28:41 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so8705692pad.14
        for <linux-mm@kvack.org>; Wed, 17 Oct 2012 16:28:41 -0700 (PDT)
Date: Wed, 17 Oct 2012 16:28:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 09/14] memcg: kmem accounting lifecycle management
In-Reply-To: <1350382611-20579-10-git-send-email-glommer@parallels.com>
Message-ID: <alpine.DEB.2.00.1210171624540.20813@chino.kir.corp.google.com>
References: <1350382611-20579-1-git-send-email-glommer@parallels.com> <1350382611-20579-10-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Tue, 16 Oct 2012, Glauber Costa wrote:

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 1182188..e24b388 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -344,6 +344,7 @@ struct mem_cgroup {
>  /* internal only representation about the status of kmem accounting. */
>  enum {
>  	KMEM_ACCOUNTED_ACTIVE = 0, /* accounted by this cgroup itself */
> +	KMEM_ACCOUNTED_DEAD, /* dead memcg, pending kmem charges */

"dead memcg with pending kmem charges" seems better.

>  };
>  
>  #define KMEM_ACCOUNTED_MASK (1 << KMEM_ACCOUNTED_ACTIVE)
> @@ -353,6 +354,22 @@ static void memcg_kmem_set_active(struct mem_cgroup *memcg)
>  {
>  	set_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_accounted);
>  }
> +
> +static bool memcg_kmem_is_active(struct mem_cgroup *memcg)
> +{
> +	return test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_accounted);
> +}

I think all of these should be inline.

> +
> +static void memcg_kmem_mark_dead(struct mem_cgroup *memcg)
> +{
> +	if (test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_accounted))
> +		set_bit(KMEM_ACCOUNTED_DEAD, &memcg->kmem_accounted);
> +}

The set_bit() doesn't happen atomically with the test_bit(), what 
synchronization is required for this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
