Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 6FD5A6B0385
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 14:29:12 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so8600044pbb.14
        for <linux-mm@kvack.org>; Mon, 25 Jun 2012 11:29:11 -0700 (PDT)
Date: Mon, 25 Jun 2012 11:29:07 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 09/11] memcg: propagate kmem limiting information to
 children
Message-ID: <20120625182907.GF3869@google.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com>
 <1340633728-12785-10-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340633728-12785-10-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

Feeling like a nit pervert but..

On Mon, Jun 25, 2012 at 06:15:26PM +0400, Glauber Costa wrote:
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

Is the volatile declaration really necessary?  Why is it necessary?
Why no comment explaining it?

> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> +static void mem_cgroup_update_kmem_limit(struct mem_cgroup *memcg, u64 val)
> +{
> +	struct mem_cgroup *iter;
> +
> +	mutex_lock(&set_limit_mutex);
> +	if (!test_and_set_bit(KMEM_ACCOUNTED_THIS, &memcg->kmem_accounted) &&
> +		val != RESOURCE_MAX) {
> +
> +		/*
> +		 * Once enabled, can't be disabled. We could in theory
> +		 * disable it if we haven't yet created any caches, or
> +		 * if we can shrink them all to death.
> +		 *
> +		 * But it is not worth the trouble
> +		 */
> +		static_key_slow_inc(&mem_cgroup_kmem_enabled_key);
> +
> +		if (!memcg->use_hierarchy)
> +			goto out;
> +
> +		for_each_mem_cgroup_tree(iter, memcg) {
> +			if (iter == memcg)
> +				continue;
> +			set_bit(KMEM_ACCOUNTED_PARENT, &iter->kmem_accounted);
> +		}
> +
> +	} else if (test_and_clear_bit(KMEM_ACCOUNTED_THIS, &memcg->kmem_accounted)
> +		&& val == RESOURCE_MAX) {
> +
> +		if (!memcg->use_hierarchy)
> +			goto out;
> +
> +		for_each_mem_cgroup_tree(iter, memcg) {
> +			struct mem_cgroup *parent;

Blank line between decl and body please.

> +			if (iter == memcg)
> +				continue;
> +			/*
> +			 * We should only have our parent bit cleared if none of
> +			 * ouri parents are accounted. The transversal order of

                              ^ type

> +			 * our iter function forces us to always look at the
> +			 * parents.

Also, it's okay here but the text filling in comments and patch
descriptions tend to be quite inconsistent.  If you're on emacs, alt-q
is your friend and I'm sure vim can do text filling pretty nicely too.

> +			 */
> +			parent = parent_mem_cgroup(iter);
> +			while (parent && (parent != memcg)) {
> +				if (test_bit(KMEM_ACCOUNTED_THIS, &parent->kmem_accounted))
> +					goto noclear;
> +					
> +				parent = parent_mem_cgroup(parent);
> +			}

Better written in for (;;)?  Also, if we're breaking on parent ==
memcg, can we ever hit NULL parent in the above loop?

> +			clear_bit(KMEM_ACCOUNTED_PARENT, &iter->kmem_accounted);
> +noclear:
> +			continue;
> +		}
> +	}
> +out:
> +	mutex_unlock(&set_limit_mutex);

Can we please branch on val != RECOURSE_MAX first?  I'm not even sure
whether the above conditionals are correct.  If the user updates an
existing kmem limit, the first test_and_set_bit() returns non-zero, so
the code proceeds onto clearing KMEM_ACCOUNTED_THIS, which succeeds
but val == RESOURCE_MAX fails so it doesn't do anything.  If the user
changes it again, it will set ACCOUNTED_THIS again.  So, changing an
existing kmem limit toggles KMEM_ACCOUNTED_THIS, which just seems
wacky to me.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
