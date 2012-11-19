Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 489956B005D
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 10:11:36 -0500 (EST)
Date: Mon, 19 Nov 2012 16:11:30 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 2/5] memcg: rework mem_cgroup_iter to use cgroup iterators
Message-ID: <20121119151130.GB16803@dhcp22.suse.cz>
References: <1352820639-13521-1-git-send-email-mhocko@suse.cz>
 <1352820639-13521-3-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1352820639-13521-3-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>

On Tue 13-11-12 16:30:36, Michal Hocko wrote:
[...]
> +		/*
> +		 * Root is not visited by cgroup iterators so it needs a special
> +		 * treatment.
> +		 */
> +		if (!last_visited) {
> +			css = &root->css;
> +		} else {
> +			struct cgroup *next_cgroup;
> +
> +			next_cgroup = cgroup_next_descendant_pre(
> +					last_visited->css.cgroup,
> +					root->css.cgroup);
> +			if (next_cgroup)
> +				css = cgroup_subsys_state(next_cgroup,
> +						mem_cgroup_subsys_id);

This is not correct because cgroup_next_descendant_pre expects pos to be
NULL for the first iteration but the way we do iterate (visit the root
first) means that the second iteration will have last_visited != NULL
and if root doesn't have any children the iteration would go unleashed
to to the endless loop. We need something like:
	struct cgroup *prev_cgroup = (last_visited == root) ? NULL 
					: last_visited->css.cgroup;
	next_cgroup = cgroup_next_descendant_pre(prev_cgroup,
				root->css.gtoup);

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
