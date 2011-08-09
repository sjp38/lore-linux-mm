Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DFAEE6B00EE
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 20:01:56 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D32B83EE0BD
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 09:01:53 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B695345DE61
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 09:01:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D51A45DE6A
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 09:01:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 81F381DB8038
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 09:01:53 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 407A61DB802C
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 09:01:53 +0900 (JST)
Date: Wed, 10 Aug 2011 08:54:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH RFC] memcg: fix drain_all_stock crash
Message-Id: <20110810085437.ed023651.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110809114642.GG7463@tiehlicka.suse.cz>
References: <20110808184738.GA7749@redhat.com>
	<20110808214704.GA4396@tiehlicka.suse.cz>
	<20110808231912.GA29002@redhat.com>
	<20110809072615.GA7463@tiehlicka.suse.cz>
	<20110809093150.GC7463@tiehlicka.suse.cz>
	<20110809183216.97daf2b0.kamezawa.hiroyu@jp.fujitsu.com>
	<20110809094503.GD7463@tiehlicka.suse.cz>
	<20110809185313.dc784d70.kamezawa.hiroyu@jp.fujitsu.com>
	<20110809100944.GE7463@tiehlicka.suse.cz>
	<20110809190725.96309c88.kamezawa.hiroyu@jp.fujitsu.com>
	<20110809114642.GG7463@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Tue, 9 Aug 2011 13:46:42 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Tue 09-08-11 19:07:25, KAMEZAWA Hiroyuki wrote:
> > On Tue, 9 Aug 2011 12:09:44 +0200
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > On Tue 09-08-11 18:53:13, KAMEZAWA Hiroyuki wrote:
> > > > On Tue, 9 Aug 2011 11:45:03 +0200
> > > > Michal Hocko <mhocko@suse.cz> wrote:
> > > > 
> > > > > On Tue 09-08-11 18:32:16, KAMEZAWA Hiroyuki wrote:
> > > > > > On Tue, 9 Aug 2011 11:31:50 +0200
> > > > > > Michal Hocko <mhocko@suse.cz> wrote:
> > > > > > 
> > > > > > > What do you think about the half backed patch bellow? I didn't manage to
> > > > > > > test it yet but I guess it should help. I hate asymmetry of drain_lock
> > > > > > > locking (it is acquired somewhere else than it is released which is
> > > > > > > not). I will think about a nicer way how to do it.
> > > > > > > Maybe I should also split the rcu part in a separate patch.
> > > > > > > 
> > > > > > > What do you think?
> > > > > > 
> > > > > > 
> > > > > > I'd like to revert 8521fc50 first and consider total design change
> > > > > > rather than ad-hoc fix.
> > > > > 
> > > > > Agreed. Revert should go into 3.0 stable as well. Although the global
> > > > > mutex is buggy we have that behavior for a long time without any reports.
> > > > > We should address it but it can wait for 3.2.
> > > 
> > > I will send the revert request to Linus.
> > > 
> > > > What "buggy" means here ? "problematic" or "cause OOps ?"
> > > 
> > > I have described that in an earlier email. Consider pathological case
> > > when CPU0 wants to async. drain a memcg which has a lot of cached charges while
> > > CPU1 is already draining so it holds the mutex. CPU0 backs off so it has
> > > to reclaim although we could prevent from it by getting rid of cached
> > > charges. This is not critical though.
> > > 
> > 
> > That problem should be fixed by background reclaim.
> 
> How? Do you plan to rework locking or the charge caching completely?
> 

>From your description, the problem is not the lock itself but a task
may go into _unnecessary_ direct-reclaim even if there are remaining
chages on per-cpu stocks, which cause latency.

In (all) my automatic background reclaim tests, no direct reclaim happens
if background reclaim is enabled. And as I said before, we may be able to
add a flag not to cache more. It's set by some condition ....as usage is
near to the limit.

Thanks,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
