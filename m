Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id DDDEC6B00AA
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 04:52:37 -0500 (EST)
Date: Thu, 15 Nov 2012 10:52:35 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 2/5] memcg: rework mem_cgroup_iter to use cgroup iterators
Message-ID: <20121115095235.GC11990@dhcp22.suse.cz>
References: <1352820639-13521-1-git-send-email-mhocko@suse.cz>
 <1352820639-13521-3-git-send-email-mhocko@suse.cz>
 <50A2E3B3.6080007@jp.fujitsu.com>
 <20121114101052.GD17111@dhcp22.suse.cz>
 <50A46BB6.6070902@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50A46BB6.6070902@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>

On Thu 15-11-12 13:12:38, KAMEZAWA Hiroyuki wrote:
> (2012/11/14 19:10), Michal Hocko wrote:
> >On Wed 14-11-12 09:20:03, KAMEZAWA Hiroyuki wrote:
> >>(2012/11/14 0:30), Michal Hocko wrote:
> >[...]
> >>>@@ -1096,30 +1096,64 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
> >>>   			mz = mem_cgroup_zoneinfo(root, nid, zid);
> >>>   			iter = &mz->reclaim_iter[reclaim->priority];
> >>>   			spin_lock(&iter->iter_lock);
> >>>+			last_visited = iter->last_visited;
> >>>   			if (prev && reclaim->generation != iter->generation) {
> >>>+				if (last_visited) {
> >>>+					mem_cgroup_put(last_visited);
> >>>+					iter->last_visited = NULL;
> >>>+				}
> >>>   				spin_unlock(&iter->iter_lock);
> >>>   				return NULL;
> >>>   			}
> >>>-			id = iter->position;
> >>>   		}
> >>>
> >>>   		rcu_read_lock();
> >>>-		css = css_get_next(&mem_cgroup_subsys, id + 1, &root->css, &id);
> >>>-		if (css) {
> >>>-			if (css == &root->css || css_tryget(css))
> >>>-				memcg = mem_cgroup_from_css(css);
> >>>-		} else
> >>>-			id = 0;
> >>>-		rcu_read_unlock();
> >>>+		/*
> >>>+		 * Root is not visited by cgroup iterators so it needs a special
> >>>+		 * treatment.
> >>>+		 */
> >>>+		if (!last_visited) {
> >>>+			css = &root->css;
> >>>+		} else {
> >>>+			struct cgroup *next_cgroup;
> >>>+
> >>>+			next_cgroup = cgroup_next_descendant_pre(
> >>>+					last_visited->css.cgroup,
> >>>+					root->css.cgroup);
> >>
> >>Maybe I miss something but.... last_visited is holded by memcg's refcnt.
> >>The cgroup pointed by css.cgroup is by cgroup's refcnt which can be freed
> >>before memcg is freed and last_visited->css.cgroup is out of RCU cycle.
> >>Is this safe ?
> >
> >Good spotted. You are right. What I need to do is to check that the
> >last_visited is alive and restart from the root if not. Something like
> >the bellow (incremental patch on top of this one) should help, right?
> >
> >diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >index 30efd7e..c0a91a3 100644
> >--- a/mm/memcontrol.c
> >+++ b/mm/memcontrol.c
> >@@ -1105,6 +1105,16 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
> >  				spin_unlock(&iter->iter_lock);
> >  				return NULL;
> >  			}
> >+			/*
> >+			 * memcg is still valid because we hold a reference but
> >+			 * its cgroup might have vanished in the meantime so
> >+			 * we have to double check it is alive and restart the
> >+			 * tree walk otherwise.
> >+			 */
> >+			if (last_visited && !css_tryget(&last_visited->css)) {
> >+				mem_cgroup_put(last_visited);
> >+				last_visited = NULL;
> >+			}
> >  		}
> >
> >  		rcu_read_lock();
> >@@ -1136,8 +1146,10 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
> >  		if (reclaim) {
> >  			struct mem_cgroup *curr = memcg;
> >
> >-			if (last_visited)
> >+			if (last_visited) {
> >+				css_put(&last_visited->css);
> >  				mem_cgroup_put(last_visited);
> >+			}
> >
> >  			if (css && !memcg)
> >  				curr = mem_cgroup_from_css(css);
> >
> 
> I think this will work.

Thanks for double checking. The updated patch:
---
