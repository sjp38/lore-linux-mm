Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7F35D6B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 06:09:50 -0400 (EDT)
Date: Tue, 9 Aug 2011 12:09:44 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RFC] memcg: fix drain_all_stock crash
Message-ID: <20110809100944.GE7463@tiehlicka.suse.cz>
References: <cover.1311338634.git.mhocko@suse.cz>
 <a9244082ba28c4c2e4a6997311d5493bdaa117e9.1311338634.git.mhocko@suse.cz>
 <20110808184738.GA7749@redhat.com>
 <20110808214704.GA4396@tiehlicka.suse.cz>
 <20110808231912.GA29002@redhat.com>
 <20110809072615.GA7463@tiehlicka.suse.cz>
 <20110809093150.GC7463@tiehlicka.suse.cz>
 <20110809183216.97daf2b0.kamezawa.hiroyu@jp.fujitsu.com>
 <20110809094503.GD7463@tiehlicka.suse.cz>
 <20110809185313.dc784d70.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110809185313.dc784d70.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Tue 09-08-11 18:53:13, KAMEZAWA Hiroyuki wrote:
> On Tue, 9 Aug 2011 11:45:03 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Tue 09-08-11 18:32:16, KAMEZAWA Hiroyuki wrote:
> > > On Tue, 9 Aug 2011 11:31:50 +0200
> > > Michal Hocko <mhocko@suse.cz> wrote:
> > > 
> > > > What do you think about the half backed patch bellow? I didn't manage to
> > > > test it yet but I guess it should help. I hate asymmetry of drain_lock
> > > > locking (it is acquired somewhere else than it is released which is
> > > > not). I will think about a nicer way how to do it.
> > > > Maybe I should also split the rcu part in a separate patch.
> > > > 
> > > > What do you think?
> > > 
> > > 
> > > I'd like to revert 8521fc50 first and consider total design change
> > > rather than ad-hoc fix.
> > 
> > Agreed. Revert should go into 3.0 stable as well. Although the global
> > mutex is buggy we have that behavior for a long time without any reports.
> > We should address it but it can wait for 3.2.

I will send the revert request to Linus.

> What "buggy" means here ? "problematic" or "cause OOps ?"

I have described that in an earlier email. Consider pathological case
when CPU0 wants to async. drain a memcg which has a lot of cached charges while
CPU1 is already draining so it holds the mutex. CPU0 backs off so it has
to reclaim although we could prevent from it by getting rid of cached
charges. This is not critical though.

> 
> > > Personally, I don't like to have spin-lock in per-cpu area.
> > 
> > spinlock is not that different from what we already have with the bit
> > lock.
> 
> maybe. The best is lockless style...but pointer in percpu cache is problem..
> 
> Thanks,
> -Kame

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
