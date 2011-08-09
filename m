Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 89D8E6B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 06:14:48 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 99E233EE0BC
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:14:44 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 80A1245DE7E
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:14:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 66C6345DE61
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:14:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A5581DB802C
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:14:44 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 21A391DB803A
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:14:44 +0900 (JST)
Date: Tue, 9 Aug 2011 19:07:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH RFC] memcg: fix drain_all_stock crash
Message-Id: <20110809190725.96309c88.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110809100944.GE7463@tiehlicka.suse.cz>
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
	<20110809100944.GE7463@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Tue, 9 Aug 2011 12:09:44 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Tue 09-08-11 18:53:13, KAMEZAWA Hiroyuki wrote:
> > On Tue, 9 Aug 2011 11:45:03 +0200
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > On Tue 09-08-11 18:32:16, KAMEZAWA Hiroyuki wrote:
> > > > On Tue, 9 Aug 2011 11:31:50 +0200
> > > > Michal Hocko <mhocko@suse.cz> wrote:
> > > > 
> > > > > What do you think about the half backed patch bellow? I didn't manage to
> > > > > test it yet but I guess it should help. I hate asymmetry of drain_lock
> > > > > locking (it is acquired somewhere else than it is released which is
> > > > > not). I will think about a nicer way how to do it.
> > > > > Maybe I should also split the rcu part in a separate patch.
> > > > > 
> > > > > What do you think?
> > > > 
> > > > 
> > > > I'd like to revert 8521fc50 first and consider total design change
> > > > rather than ad-hoc fix.
> > > 
> > > Agreed. Revert should go into 3.0 stable as well. Although the global
> > > mutex is buggy we have that behavior for a long time without any reports.
> > > We should address it but it can wait for 3.2.
> 
> I will send the revert request to Linus.
> 
> > What "buggy" means here ? "problematic" or "cause OOps ?"
> 
> I have described that in an earlier email. Consider pathological case
> when CPU0 wants to async. drain a memcg which has a lot of cached charges while
> CPU1 is already draining so it holds the mutex. CPU0 backs off so it has
> to reclaim although we could prevent from it by getting rid of cached
> charges. This is not critical though.
> 

That problem should be fixed by background reclaim.
I'll do it after fixing numascan. (and dirty-ratio problem...)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
