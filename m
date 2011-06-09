Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 105F86B0078
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 09:12:09 -0400 (EDT)
Date: Thu, 9 Jun 2011 15:12:03 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
Message-ID: <20110609131203.GB3994@tiehlicka.suse.cz>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 01-06-11 08:25:13, Johannes Weiner wrote:
[...]

Just a minor thing. I am really slow at reviewing these days due to
other work that has to be done...

> +struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgroup *root,
> +					     struct mem_cgroup *prev)
> +{
> +	struct mem_cgroup *mem;

You want mem = NULL here because you might end up using it unitialized
AFAICS (css_get_next returns with NULL).

> +
> +	if (mem_cgroup_disabled())
> +		return NULL;
> +
> +	if (!root)
> +		root = root_mem_cgroup;
> +	/*
> +	 * Even without hierarchy explicitely enabled in the root
> +	 * memcg, it is the ultimate parent of all memcgs.
> +	 */
> +	if (!(root == root_mem_cgroup || root->use_hierarchy))
> +		return root;
> +	if (prev && prev != root)
> +		css_put(&prev->css);
> +	do {
> +		int id = root->last_scanned_child;
> +		struct cgroup_subsys_state *css;
> +
> +		rcu_read_lock();
> +		css = css_get_next(&mem_cgroup_subsys, id + 1, &root->css, &id);
> +		if (css && (css == &root->css || css_tryget(css)))
> +			mem = container_of(css, struct mem_cgroup, css);
> +		rcu_read_unlock();
> +		if (!css)
> +			id = 0;
> +		root->last_scanned_child = id;
> +	} while (!mem);
> +	return mem;

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
