Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 13B296B03AF
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 19:23:54 -0400 (EDT)
Date: Mon, 25 Jun 2012 16:23:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 09/11] memcg: propagate kmem limiting information to
 children
Message-Id: <20120625162352.51997c5a.akpm@linux-foundation.org>
In-Reply-To: <1340633728-12785-10-git-send-email-glommer@parallels.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com>
	<1340633728-12785-10-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Mon, 25 Jun 2012 18:15:26 +0400
Glauber Costa <glommer@parallels.com> wrote:

> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -287,7 +287,11 @@ struct mem_cgroup {
>  	 * Should the accounting and control be hierarchical, per subtree?
>  	 */
>  	bool use_hierarchy;
> -	bool kmem_accounted;
> +	/*
> +	 * bit0: accounted by this cgroup
> +	 * bit1: accounted by a parent.
> +	 */
> +	volatile unsigned long kmem_accounted;

I suggest

	unsigned long kmem_accounted;	/* See KMEM_ACCOUNTED_*, below */

>  	bool		oom_lock;
>  	atomic_t	under_oom;
> @@ -340,6 +344,9 @@ struct mem_cgroup {
>  #endif
>  };
>  
> +#define KMEM_ACCOUNTED_THIS	0
> +#define KMEM_ACCOUNTED_PARENT	1

And then document the fields here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
