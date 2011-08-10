Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 04D666B016B
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 20:29:43 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0DC3E3EE0C8
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 09:29:41 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E572C3266C2
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 09:29:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C938F45DE55
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 09:29:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B829D1DB8055
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 09:29:40 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FF5E1DB8046
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 09:29:40 +0900 (JST)
Date: Wed, 10 Aug 2011 09:22:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2 v2] memcg: make oom_lock 0 and 1 based rather than
 coutner
Message-Id: <20110810092224.7085ca7f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110809153732.GC13411@redhat.com>
References: <cover.1310732789.git.mhocko@suse.cz>
	<44ec61829ed8a83b55dc90a7aebffdd82fe0e102.1310732789.git.mhocko@suse.cz>
	<20110809140312.GA2265@redhat.com>
	<20110809152218.GK7463@tiehlicka.suse.cz>
	<20110809153732.GC13411@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Tue, 9 Aug 2011 17:37:32 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> On Tue, Aug 09, 2011 at 05:22:18PM +0200, Michal Hocko wrote:
> > On Tue 09-08-11 16:03:12, Johannes Weiner wrote:
> > >  	struct mem_cgroup *iter, *failed = NULL;
> > >  	bool cond = true;
> > >  
> > >  	for_each_mem_cgroup_tree_cond(iter, mem, cond) {
> > > -		bool locked = iter->oom_lock;
> > > -
> > > -		iter->oom_lock = true;
> > > -		if (lock_count == -1)
> > > -			lock_count = iter->oom_lock;
> > > -		else if (lock_count != locked) {
> > > +		if (iter->oom_lock) {
> > >  			/*
> > >  			 * this subtree of our hierarchy is already locked
> > >  			 * so we cannot give a lock.
> > >  			 */
> > > -			lock_count = 0;
> > >  			failed = iter;
> > >  			cond = false;
> > > -		}
> > > +		} else
> > > +			iter->oom_lock = true;
> > >  	}
> > >  
> > >  	if (!failed)
> > 
> > We can return here and get rid of done label.
> 
> Ah, right you are.  Here is an update.
> 
> ---
> From 86b36904033e6c6a1af4716e9deef13ebd31e64c Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <jweiner@redhat.com>
> Date: Tue, 9 Aug 2011 15:31:30 +0200
> Subject: [patch] memcg: fix hierarchical oom locking
> 
> Commit "79dfdac memcg: make oom_lock 0 and 1 based rather than
> counter" tried to oom lock the hierarchy and roll back upon
> encountering an already locked memcg.
> 
> The code is confused when it comes to detecting a locked memcg,
> though, so it would fail and rollback after locking one memcg and
> encountering an unlocked second one.
> 
> The result is that oom-locking hierarchies fails unconditionally and
> that every oom killer invocation simply goes to sleep on the oom
> waitqueue forever.  The tasks practically hang forever without anyone
> intervening, possibly holding locks that trip up unrelated tasks, too.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks,
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
