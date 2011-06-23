Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1794F900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 04:12:11 -0400 (EDT)
Date: Thu, 23 Jun 2011 10:12:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/7] memcg: update numa information based on event counter
Message-ID: <20110623081207.GC31593@tiehlicka.suse.cz>
References: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
 <20110616125400.1145a4e2.kamezawa.hiroyu@jp.fujitsu.com>
 <20110622155309.GH14343@tiehlicka.suse.cz>
 <20110623152734.3a4f867a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110623152734.3a4f867a.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Thu 23-06-11 15:27:34, KAMEZAWA Hiroyuki wrote:
> On Wed, 22 Jun 2011 17:53:09 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Thu 16-06-11 12:54:00, KAMEZAWA Hiroyuki wrote:
[...]
> > > @@ -1616,17 +1629,32 @@ mem_cgroup_select_victim(struct mem_cgro
> > >  /*
> > >   * Always updating the nodemask is not very good - even if we have an empty
> > >   * list or the wrong list here, we can start from some node and traverse all
> > > - * nodes based on the zonelist. So update the list loosely once per 10 secs.
> > > + * nodes based on the zonelist.
> > >   *
> > > + * The counter of mem->numascan_update is updated once per
> > > + * NUMASCAN_EVENTS_TARGET. We update the numa information when we see
> > > + * the number of event is larger than 3% of limit or  64MB pagein/pageout.
> > >   */
> > > +#define NUMASCAN_UPDATE_RATIO	(3)
> > > +#define NUMASCAN_UPDATE_THRESH	(16384UL) /* 16k events of pagein/pageout */
> > >  static void mem_cgroup_may_update_nodemask(struct mem_cgroup *mem)
> > >  {
> > >  	int nid;
> > > -
> > > -	if (time_after(mem->next_scan_node_update, jiffies))
> > > +	unsigned long long limit;
> > > +	/* if no limit, we never reach here */
> > > +	limit = res_counter_read_u64(&mem->res, RES_LIMIT);
> > > +	limit /= PAGE_SIZE;
> > > +	/* 3% of limit */
> > > +	limit = (limit * NUMASCAN_UPDATE_RATIO/100UL);
> > > +	limit = min_t(unsigned long long, limit, NUMASCAN_UPDATE_THRESH);
> > > +	/*
> > > +	 * If the number of pagein/out event is larger than 3% of limit or
> > > +	 * 64MB pagein/out, refresh numa information.
> > > +	 */
> > > +	if (atomic_read(&mem->numascan_update) < limit ||
> > > +	    !mutex_trylock(&mem->numascan_mutex))
> > >  		return;
> > 
> > I am not sure whether a mutex is not overkill here. What about using an
> > atomic operation instead?
> > 
> 
> I think mutex is informative than atomic counter for code readers.
> If influence of overhead is not big, I'd like to use mutex.

I do not have a strong opinion on that. mem_cgroup is not that
widespread structure to think about every single byte. On the other hand
atomic test&set would do the same thing. We are already using atomic
operations to manipulate numascan_update so doing it whole atomic based
sounds natural.

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
