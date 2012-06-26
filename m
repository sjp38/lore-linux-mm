Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id D93536B0073
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 11:50:14 -0400 (EDT)
Date: Tue, 26 Jun 2012 17:50:12 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: first step towards hierarchical controller
Message-ID: <20120626155012.GG9566@tiehlicka.suse.cz>
References: <1340717428-9009-1-git-send-email-glommer@parallels.com>
 <20120626152711.GF9566@tiehlicka.suse.cz>
 <4FE9D501.3050004@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FE9D501.3050004@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Tue 26-06-12 19:28:01, Glauber Costa wrote:
[...]
> >>diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >>index 9e710bc..037ddd4 100644
> >>--- a/mm/memcontrol.c
> >>+++ b/mm/memcontrol.c
> >>@@ -3949,6 +3949,8 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
> >>  	if (memcg->use_hierarchy == val)
> >>  		goto out;
> >>
> >>+	WARN_ONCE((!parent_memcg && memcg->use_hierarchy && val == false),
> >>+		"Non-hierarchical memcg is considered for deprecation");
> >>  	/*
> >>  	 * If parent's use_hierarchy is set, we can't make any modifications
> >>  	 * in the child subtrees. If it is unset, then the change can
> >>@@ -5175,6 +5177,7 @@ mem_cgroup_create(struct cgroup *cont)
> >>  			INIT_WORK(&stock->work, drain_local_stock);
> >>  		}
> >>  		hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
> >>+		memcg->use_hierarchy = true;
> >
> >So the only way to disable hierarchies is to do it on the root first
> >(before any children exist) and then start creating your groups?
> 
> Yes.
> 
> This is true after my patch.
> This is also true before my patch, if you set it to 1 in the root,
> and then tries to flip it back.

OK, fair enough. Having another tweaks for the 1st level cgroups would
change the behavior from the current state which is bad (so it wouldn't
be just hackish but stupid as well...).

Just make sure we are warning also deeper in the hierarchy (for cgconfig
cases) suggested by Johannes and you can add my Acked-by.

Please also mention that if anybody is really interested in the original
behavior, for what ever reasons, then the following cgconfig.conf should
do the trick

group . {
	memory {
		memory.use_hierarchy = 0;
	}
}

Thanks
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
