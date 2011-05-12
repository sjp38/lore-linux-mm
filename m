Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A29A36B0011
	for <linux-mm@kvack.org>; Thu, 12 May 2011 10:47:33 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4CEJ3Fg011595
	for <linux-mm@kvack.org>; Thu, 12 May 2011 10:19:03 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4CEcn6O119018
	for <linux-mm@kvack.org>; Thu, 12 May 2011 10:38:49 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4CEcme7021489
	for <linux-mm@kvack.org>; Thu, 12 May 2011 10:38:49 -0400
Date: Thu, 12 May 2011 07:38:44 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4] oom: kill younger process first
Message-ID: <20110512143844.GQ2258@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20110509182110.167F.A69D9226@jp.fujitsu.com>
 <20110510171335.16A7.A69D9226@jp.fujitsu.com>
 <20110510171641.16AF.A69D9226@jp.fujitsu.com>
 <20110512095243.c57e3e83.kamezawa.hiroyu@jp.fujitsu.com>
 <BANLkTi=ya1rAqC+nMPHkBaMsoXpsCeHH=w@mail.gmail.com>
 <20110512105351.a57970d7.kamezawa.hiroyu@jp.fujitsu.com>
 <BANLkTimWOtKKj+Jq1vqHfOfQ2UvP7Xxa3g@mail.gmail.com>
 <20110512123942.4b641e2d.kamezawa.hiroyu@jp.fujitsu.com>
 <BANLkTi=dvb5tXxzLwY+vgG8o4eYq5f_X8Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTi=dvb5tXxzLwY+vgG8o4eYq5f_X8Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, CAI Qian <caiqian@redhat.com>, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

On Thu, May 12, 2011 at 01:17:13PM +0900, Minchan Kim wrote:
> On Thu, May 12, 2011 at 12:39 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Thu, 12 May 2011 11:23:38 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >
> >> On Thu, May 12, 2011 at 10:53 AM, KAMEZAWA Hiroyuki
> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> > On Thu, 12 May 2011 10:30:45 +0900
> >> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >
> >> > As above implies, (B)->prev pointer is invalid pointer after list_del().
> >> > So, there will be race with list modification and for_each_list_reverse under
> >> > rcu_read__lock()
> >> >
> >> > So, when you need to take atomic lock (as tasklist lock is) is...
> >> >
> >> >  1) You can't check 'entry' is valid or not...
> >> >    In above for_each_list_rcu(), you may visit an object which is under removing.
> >> >    You need some flag or check to see the object is valid or not.
> >> >
> >> >  2) you want to use list_for_each_safe().
> >> >    You can't do list_del() an object which is under removing...
> >> >
> >> >  3) You want to walk the list in reverse.
> >> >
> >> >  3) Some other reasons. For example, you'll access an object pointed by the
> >> >    'entry' and the object is not rcu safe.
> >> >
> >> > make sense ?
> >>
> >> Yes. Thanks, Kame.
> >> It seems It is caused by prev poisoning of list_del_rcu.
> >> If we remove it, isn't it possible to traverse reverse without atomic lock?
> >>
> >
> > IIUC, it's possible (Fix me if I'm wrong) but I don't like that because of 2 reasons.
> >
> > 1. LIST_POISON is very important information at debug.
> 
> Indeed.
> But if we can get a better something although we lost debug facility,
> I think it would be okay.
> 
> >
> > 2. If we don't clear prev pointer, ok, we'll allow 2 directional walk of list
> >   under RCU.
> >   But, in following case
> >   1. you are now at (C). you'll visit (C)->next...(D)
> >   2. you are now at (D). you want to go back to (C) via (D)->prev.
> >   3. But (D)->prev points to (B)
> >
> >  It's not a 2 directional list, something other or broken one.
> 
> Yes. but it shouldn't be a problem in RCU semantics.
> If you need such consistency, you should use lock.
> 
> I recall old thread about it.
> In http://lwn.net/Articles/262464/, mmutz and Paul already discussed
> about it. :)
> 
> >  Then, the rculist is 1 directional list in nature, I think.
> 
> Yes. But Why RCU become 1 directional list is we can't find a useful usecases.
> 
> >
> > So, without very very big reason, we should keep POISON.
> 
> Agree.
> I don't insist on it as it's not a useful usecase for persuading Paul.
> That's because it's not a hot path.
> 
> It's started from just out of curiosity.
> Thanks for very much clarifying that, Kame!

Indeed, we would need a large performance/scalability/simplicity advantage
to put up with such a loss of debugging information.  If it turns out
that you really need this, please let me know, but please also provide
data supporting your need.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
