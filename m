Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C8083900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 02:34:40 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 347C23EE0C0
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:34:36 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 12D6345DE68
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:34:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E9AA545DE6A
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:34:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DD7A0E08003
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:34:35 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A55F3E08001
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:34:35 +0900 (JST)
Date: Thu, 23 Jun 2011 15:27:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/7] memcg: update numa information based on event
 counter
Message-Id: <20110623152734.3a4f867a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110622155309.GH14343@tiehlicka.suse.cz>
References: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110616125400.1145a4e2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110622155309.GH14343@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Wed, 22 Jun 2011 17:53:09 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 16-06-11 12:54:00, KAMEZAWA Hiroyuki wrote:
> > From 88090fe10e225ad8769ba0ea01692b7314e8b973 Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Wed, 15 Jun 2011 16:19:46 +0900
> > Subject: [PATCH 4/7] memcg: update numa information based on event counter
> > 
> > commit 889976 adds an numa node round-robin for memcg. But the information
> > is updated once per 10sec.
> > 
> > This patch changes the update trigger from jiffies to memcg's event count.
> > After this patch, numa scan information will be updated when
> > 
> >   - the number of pagein/out events is larger than 3% of limit
> >   or
> >   - the number of pagein/out events is larger than 16k
> >     (==64MB pagein/pageout if pagesize==4k.)
> > 
> > The counter of mem->numascan_update the sum of percpu events counter.
> > When a task hits limit, it checks mem->numascan_update. If it's over
> > min(3% of limit, 16k), numa information will be updated.
> 
> Yes, I like the event based approach more than the origin (time) based
> one.
> 
> > 
> > This patch also adds mutex for updating information. This will allow us
> > to avoid unnecessary scan.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |   51 +++++++++++++++++++++++++++++++++++++++++++++------
> >  1 file changed, 45 insertions(+), 6 deletions(-)
> > 
> > Index: mmotm-0615/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-0615.orig/mm/memcontrol.c
> > +++ mmotm-0615/mm/memcontrol.c
> > @@ -108,10 +108,12 @@ enum mem_cgroup_events_index {
> >  enum mem_cgroup_events_target {
> >  	MEM_CGROUP_TARGET_THRESH,
> >  	MEM_CGROUP_TARGET_SOFTLIMIT,
> > +	MEM_CGROUP_TARGET_NUMASCAN,
> 
> Shouldn't it be defined only for MAX_NUMNODES > 1
> 

Hmm, yes. But I want to reduce #ifdefs..


> >  	MEM_CGROUP_NTARGETS,
> >  };
> >  #define THRESHOLDS_EVENTS_TARGET (128)
> >  #define SOFTLIMIT_EVENTS_TARGET (1024)
> > +#define NUMASCAN_EVENTS_TARGET  (1024)
> >  
> >  struct mem_cgroup_stat_cpu {
> >  	long count[MEM_CGROUP_STAT_NSTATS];
> > @@ -288,8 +290,9 @@ struct mem_cgroup {
> >  	int last_scanned_node;
> >  #if MAX_NUMNODES > 1
> >  	nodemask_t	scan_nodes;
> > -	unsigned long   next_scan_node_update;
> > +	struct mutex	numascan_mutex;
> >  #endif
> > +	atomic_t	numascan_update;
> 
> Why it is out of ifdef?
> 

This was for avoiding #ifdef in mem_cgroup_create()...but it's not used now.
I'll fix this.



> >  	/*
> >  	 * Should the accounting and control be hierarchical, per subtree?
> >  	 */
> > @@ -741,6 +744,9 @@ static void __mem_cgroup_target_update(s
> >  	case MEM_CGROUP_TARGET_SOFTLIMIT:
> >  		next = val + SOFTLIMIT_EVENTS_TARGET;
> >  		break;
> > +	case MEM_CGROUP_TARGET_NUMASCAN:
> > +		next = val + NUMASCAN_EVENTS_TARGET;
> > +		break;
> 
> MAX_NUMNODES > 1
> 
> >  	default:
> >  		return;
> >  	}
> > @@ -764,6 +770,13 @@ static void memcg_check_events(struct me
> >  			__mem_cgroup_target_update(mem,
> >  				MEM_CGROUP_TARGET_SOFTLIMIT);
> >  		}
> > +		if (unlikely(__memcg_event_check(mem,
> > +			MEM_CGROUP_TARGET_NUMASCAN))) {
> > +			atomic_add(MEM_CGROUP_TARGET_NUMASCAN,
> > +				&mem->numascan_update);
> > +			__mem_cgroup_target_update(mem,
> > +				MEM_CGROUP_TARGET_NUMASCAN);
> > +		}
> >  	}
> 
> again MAX_NUMNODES > 1
> 

Hmm, ok, I will add #ifdef only here.



> >  }
> >  
> > @@ -1616,17 +1629,32 @@ mem_cgroup_select_victim(struct mem_cgro
> >  /*
> >   * Always updating the nodemask is not very good - even if we have an empty
> >   * list or the wrong list here, we can start from some node and traverse all
> > - * nodes based on the zonelist. So update the list loosely once per 10 secs.
> > + * nodes based on the zonelist.
> >   *
> > + * The counter of mem->numascan_update is updated once per
> > + * NUMASCAN_EVENTS_TARGET. We update the numa information when we see
> > + * the number of event is larger than 3% of limit or  64MB pagein/pageout.
> >   */
> > +#define NUMASCAN_UPDATE_RATIO	(3)
> > +#define NUMASCAN_UPDATE_THRESH	(16384UL) /* 16k events of pagein/pageout */
> >  static void mem_cgroup_may_update_nodemask(struct mem_cgroup *mem)
> >  {
> >  	int nid;
> > -
> > -	if (time_after(mem->next_scan_node_update, jiffies))
> > +	unsigned long long limit;
> > +	/* if no limit, we never reach here */
> > +	limit = res_counter_read_u64(&mem->res, RES_LIMIT);
> > +	limit /= PAGE_SIZE;
> > +	/* 3% of limit */
> > +	limit = (limit * NUMASCAN_UPDATE_RATIO/100UL);
> > +	limit = min_t(unsigned long long, limit, NUMASCAN_UPDATE_THRESH);
> > +	/*
> > +	 * If the number of pagein/out event is larger than 3% of limit or
> > +	 * 64MB pagein/out, refresh numa information.
> > +	 */
> > +	if (atomic_read(&mem->numascan_update) < limit ||
> > +	    !mutex_trylock(&mem->numascan_mutex))
> >  		return;
> 
> I am not sure whether a mutex is not overkill here. What about using an
> atomic operation instead?
> 

I think mutex is informative than atomic counter for code readers.
If influence of overhead is not big, I'd like to use mutex.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
