Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 74CEB6B01FE
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 20:06:48 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2G06kjf005959
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Mar 2010 09:06:46 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D2F8445DE51
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 09:06:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id ACF6945DE4D
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 09:06:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DD621DB8048
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 09:06:45 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 273E6E38004
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 09:06:45 +0900 (JST)
Date: Tue, 16 Mar 2010 09:03:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] memcg: oom kill disable and oom status
Message-Id: <20100316090309.22493838.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100315150020.0cc28341.akpm@linux-foundation.org>
References: <20100312143137.f4cf0a04.kamezawa.hiroyu@jp.fujitsu.com>
	<20100312143435.e648e361.kamezawa.hiroyu@jp.fujitsu.com>
	<20100312143753.420e7ae7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100315150020.0cc28341.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kirill@shutemov.name" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Mar 2010 15:00:20 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 12 Mar 2010 14:37:53 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > 
> > I haven't get enough comment to this patch itself. But works well.
> > Feel free to request me if you want me to change some details.
> > 
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > This adds a feature to disable oom-killer for memcg, if disabled,
> > of course, tasks under memcg will stop.
> > 
> > But now, we have oom-notifier for memcg. And the world around
> > memcg is not under out-of-memory. memcg's out-of-memory just
> > shows memcg hits limit. Then, administrator or
> > management daemon can recover the situation by
> > 	- kill some process
> > 	- enlarge limit, add more swap.
> > 	- migrate some tasks
> > 	- remove file cache on tmps (difficult ?)
> > 
> > Unlike OOM-Kill by the kernel, the users can take snapshot or coredump
> > of guilty process, cgroups.
> > 
> 
> Looks complicated.
> 
In code, hooks are in
	- usage is reduced.
	- limit is enlarged.

Maybe my explanation is bad. It's simpler than it sounds.


> > --- mmotm-2.6.34-Mar9.orig/mm/memcontrol.c
> > +++ mmotm-2.6.34-Mar9/mm/memcontrol.c
> > @@ -235,7 +235,8 @@ struct mem_cgroup {
> >  	 * mem_cgroup ? And what type of charges should we move ?
> >  	 */
> >  	unsigned long 	move_charge_at_immigrate;
> > -
> > +	/* Disable OOM killer */
> > +	unsigned long	oom_kill_disable;
> >  	/*
> >  	 * percpu counter.
> >  	 */
> 
> Would have been better to make this `int' or `bool', and put it next to
> some other 32-bit value in this struct.
> 

Sure, will fix.

-Kame


> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
