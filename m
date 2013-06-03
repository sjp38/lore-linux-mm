Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 0AE816B0002
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 12:51:32 -0400 (EDT)
Date: Mon, 3 Jun 2013 12:51:20 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, memcg: add oom killer delay
Message-ID: <20130603165120.GH15576@cmpxchg.org>
References: <alpine.DEB.2.02.1305291817280.520@chino.kir.corp.google.com>
 <20130530150539.GA18155@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com>
 <20130531081052.GA32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com>
 <20130531112116.GC32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305311224330.3434@chino.kir.corp.google.com>
 <20130601061151.GC15576@cmpxchg.org>
 <20130603163012.GA23257@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130603163012.GA23257@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon, Jun 03, 2013 at 06:31:34PM +0200, Michal Hocko wrote:
> On Sat 01-06-13 02:11:51, Johannes Weiner wrote:
> > @@ -2076,6 +2077,7 @@ static void memcg_wakeup_oom(struct mem_cgroup *memcg)
> >  {
> >  	/* for filtering, pass "memcg" as argument. */
> >  	__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, memcg);
> > +	atomic_inc(&memcg->oom_wakeups);
> >  }
> >  
> >  static void memcg_oom_recover(struct mem_cgroup *memcg)
> [...]
> > +	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
> > +	/* Only sleep if we didn't miss any wakeups since OOM */
> > +	if (atomic_read(&memcg->oom_wakeups) == current->memcg_oom.wakeups)
> > +		schedule();
> 
> On the way home it occured to me that the ordering might be wrong here.
> The wake up can be lost here.
> 					__wake_up(memcg_oom_waitq)
> 					<preempted>
> prepare_to_wait
> atomic_read(&memcg->oom_wakeups)
> 					atomic_inc(oom_wakeups)
> 
> I guess we want atomic_inc before __wake_up, right?

I think you are right, thanks for spotting this.  Will be fixed in
version 2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
