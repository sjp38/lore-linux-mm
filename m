Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id A2E6F6B0080
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 19:08:48 -0400 (EDT)
Date: Wed, 5 Jun 2013 16:08:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 30/35] memcg: scan cache objects hierarchically
Message-Id: <20130605160846.3b91290652d555a2a19aa6af@linux-foundation.org>
In-Reply-To: <1370287804-3481-31-git-send-email-glommer@openvz.org>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
	<1370287804-3481-31-git-send-email-glommer@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>

On Mon,  3 Jun 2013 23:29:59 +0400 Glauber Costa <glommer@openvz.org> wrote:

> When reaching shrink_slab, we should descent in children memcg searching

"descend into child memcgs"

> for objects that could be shrunk. This is true even if the memcg does

"can be"

> not have kmem limits on, since the kmem res_counter will also be billed
> against the user res_counter of the parent.
> 
> It is possible that we will free objects and not free any pages, that
> will just harm the child groups without helping the parent group at all.
> But at this point, we basically are prepared to pay the price.
> 
> ...
>
>  #ifdef CONFIG_MEMCG_KMEM
> +bool memcg_kmem_should_reclaim(struct mem_cgroup *memcg)
> +{
> +	struct mem_cgroup *iter;
> +
> +	for_each_mem_cgroup_tree(iter, memcg) {
> +		if (memcg_kmem_is_active(iter)) {
> +			mem_cgroup_iter_break(memcg, iter);
> +			return true;
> +		}
> +	}
> +	return false;
> +}

Locking requirements for this function?  Perhaps the
for_each_mem_cgroup_tree() definition site would be an appropriate
place to document this.

>  static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
>  {
>  	return !mem_cgroup_disabled() && !mem_cgroup_is_root(memcg) &&
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
