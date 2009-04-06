Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 421235F0001
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 19:56:31 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n36NvMUh022020
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 7 Apr 2009 08:57:23 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A7D4E45DD72
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 08:57:22 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 83FD245DE4F
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 08:57:22 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C8BC1DB8040
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 08:57:22 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BA66E18002
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 08:57:22 +0900 (JST)
Date: Tue, 7 Apr 2009 08:55:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 4/9] soft limit queue and priority
Message-Id: <20090407085555.a8818209.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090406110534.GJ7082@balbir.in.ibm.com>
References: <20090403170835.a2d6cbc3.kamezawa.hiroyu@jp.fujitsu.com>
	<20090403171248.df3e1b03.kamezawa.hiroyu@jp.fujitsu.com>
	<20090406110534.GJ7082@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Apr 2009 16:35:34 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-03 17:12:48]:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Softlimitq. for memcg.
> > 
> > Implements an array of queue to list memcgs, array index is determined by
> > the amount of memory usage excess the soft limit.
> > 
> > While Balbir's one uses RB-tree and my old one used a per-zone queue
> > (with round-robin), this is one of mixture of them.
> > (I'd like to use rotation of queue in later patches)
> > 
> > Priority is determined by following.
> >    Assume unit = total pages/1024. (the code uses different value)
> >    if excess is...
> >       < unit,          priority = 0, 
> >       < unit*2,        priority = 1,
> >       < unit*2*2,      priority = 2,
> >       ...
> >       < unit*2^9,      priority = 9,
> >       < unit*2^10,     priority = 10, (> 50% to total mem)
> > 
> > This patch just includes queue management part and not includes 
> > selection logic from queue. Some trick will be used for selecting victims at
> > soft limit in efficient way.
> > 
> > And this equips 2 queues, for anon and file. Inset/Delete of both list is
> > done at once but scan will be independent. (These 2 queues are used later.)
> > 
> > Major difference from Balbir's one other than RB-tree is bahavior under
> > hierarchy. This one adds all children to queue by checking hierarchical
> > priority. This is for helping per-zone usage check on victim-selection logic.
> > 
> > Changelog: v1->v2
> >  - fixed comments.
> >  - change base size to exponent.
> >  - some micro optimization to reduce code size.
> >  - considering memory hotplug, it's not good to record a value calculated
> >    from totalram_pages at boot and using it later is bad manner. Fixed it.
> >  - removed soft_limit_lock (spinlock) 
> >  - added soft_limit_update counter for avoiding mulptiple update at once.
> >    
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |  118 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
> >  1 file changed, 117 insertions(+), 1 deletion(-)
> > 
> > Index: softlimit-test2/mm/memcontrol.c
> > ===================================================================
> > --- softlimit-test2.orig/mm/memcontrol.c
> > +++ softlimit-test2/mm/memcontrol.c
> > @@ -192,7 +192,14 @@ struct mem_cgroup {
> >  	atomic_t	refcnt;
> > 
> >  	unsigned int	swappiness;
> > -
> > +	/*
> > +	 * For soft limit.
> > +	 */
> > +	int soft_limit_priority;
> > +	struct list_head soft_limit_list[2];
> > +#define SL_ANON (0)
> > +#define SL_FILE (1)
> 
> Comments for the #define please.
> 
Sure.

> > +	atomic_t soft_limit_update;
> >  	/*
> >  	 * statistics. This must be placed at the end of memcg.
> >  	 */
> > @@ -938,11 +945,115 @@ static bool mem_cgroup_soft_limit_check(
> >  	return ret;
> >  }
> > 
> > +/*
> > + * Assume "base_amount", and excess = usage - soft limit.
> > + *
> > + * 0...... if excess < base_amount
> > + * 1...... if excess < base_amount * 2
> > + * 2...... if excess < base_amount * 2^2
> > + * 3.......if excess < base_amount * 2^3
> > + * ....
> > + * 9.......if excess < base_amount * 2^9
> > + * 10 .....if excess < base_amount * 2^10
> > + *
> > + * base_amount is detemined from total pages in the system.
> > + */
> > +
> > +#define SLQ_MAXPRIO (11)
> > +static struct {
> > +	spinlock_t lock;
> > +	struct list_head queue[SLQ_MAXPRIO][2]; /* 0:anon 1:file */
> > +} softlimitq;
> > +
> > +#define SLQ_PRIO_FACTOR (1024) /* 2^10 */
> > +
> > +static int __calc_soft_limit_prio(unsigned long excess)
> > +{
> > +	unsigned long factor = totalram_pages /SLQ_PRIO_FACTOR;
> 
> I would prefer to use global_lru_pages()
> 
Hmm, ok.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
