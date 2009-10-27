Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 38DC86B005A
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 04:58:59 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9R8wu9d005823
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 27 Oct 2009 17:58:57 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AABFD45DE51
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 17:58:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 69AA945DD70
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 17:58:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 52B001DB803C
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 17:58:56 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F25341DB803E
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 17:58:55 +0900 (JST)
Date: Tue, 27 Oct 2009 17:56:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] oom_kill: avoid depends on total_vm and use real
 RSS/swap value for oom_score (Re: Memory overcommit
Message-Id: <20091027175627.3986104e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091027175243.31105265.minchan.kim@barrios-desktop>
References: <hav57c$rso$1@ger.gmane.org>
	<hb2cfu$r08$2@ger.gmane.org>
	<20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com>
	<4ADE3121.6090407@gmail.com>
	<20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
	<4AE5CB4E.4090504@gmail.com>
	<20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
	<2f11576a0910262310g7aea23c0n9bfc84c900879d45@mail.gmail.com>
	<20091027153429.b36866c4.minchan.kim@barrios-desktop>
	<20091027153626.c5a4b5be.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262360910262355p3cac5c1bla4de9d42ea67fb4e@mail.gmail.com>
	<20091027164526.da6a23cb.kamezawa.hiroyu@jp.fujitsu.com>
	<20091027165628.acda4540.kamezawa.hiroyu@jp.fujitsu.com>
	<20091027171441.ca9600ea.minchan.kim@barrios-desktop>
	<20091027173308.cc0eb535.kamezawa.hiroyu@jp.fujitsu.com>
	<20091027175243.31105265.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, vedran.furac@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 27 Oct 2009 17:52:43 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Tue, 27 Oct 2009 17:33:08 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Tue, 27 Oct 2009 17:14:41 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> > 
> > > On Tue, 27 Oct 2009 16:56:28 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > 
> > > > On Tue, 27 Oct 2009 16:45:26 +0900
> > > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > >   	/*
> > > > >  	 * After this unlock we can no longer dereference local variable `mm'
> > > > > @@ -92,8 +93,13 @@ unsigned long badness(struct task_struct
> > > > >  	 */
> > > > >  	list_for_each_entry(child, &p->children, sibling) {
> > > > >  		task_lock(child);
> > > > > -		if (child->mm != mm && child->mm)
> > > > > -			points += child->mm->total_vm/2 + 1;
> > > > > +		if (child->mm != mm && child->mm) {
> > > > > +			unsigned long cpoint;
> > > > > +			/* At considering child, we don't count swap */
> > > > > +			cpoint = get_mm_counter(child->mm, anon_rss) +
> > > > > +				 get_mm_counter(child->mm, file_rss);
> > > > > +			points += cpoint/2 + 1;
> > > > > +		}
> > > > >  		task_unlock(child);
> > > > 
> > > > BTW, I'd like to get rid of this code.
> > > > 
> > > > Can't we use other techniques for detecting fork-bomb ?
> > > > 
> > > > This check can't catch following type, anyway.
> > > > 
> > > >    fork()
> > > >      -> fork()
> > > >           -> fork()
> > > >                -> fork()
> > > >                     ....
> > > > 
> > > > but I have no good idea.
> > > > What is the difference with task-launcher and fork bomb()...
> > > > 
> > > 
> > > I think it's good as-is. 
> > > Kernel is hard to know it by effiecient method.
> > > It depends on applications. so Doesnt's task-launcher 
> > > like gnome-session have to control his oom_score? 
> > > 
> > > Welcome to any ideas if kernel can do it well.
> > > 
> > Hmmm, check system-wide fork/sec and fork-depth ? Maybe not difficult to calculate..
> 
> Yes. We can do anything to achieve the goal in kernel. 
> Maybe check the time or fork-depth counting. 
> What I have a concern is how we can do it nicely if it is a serious
> problem in kernel. ;)
> 
yes...only the user knows whether user is wrong, finally. Especially in case
of memory leak.

> I think most of program which have many child are victims of OOM killing.
> It make sense to me. There is some cases to not make sense like task-launcher.
> So I think if task-launcher which is very rare and special program can change
> oom_adj by itself, it's good than thing that add new heuristic in kernel.
> 
> It's just my opinon. :)
> 
I know KDE already adjsut oom_adj for their 3.5 release ;)
Okay, concentrate on avoiding total_vm issue for a while.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
