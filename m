Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9A9296B016A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 20:23:55 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AB80B3EE0BD
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 09:23:52 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8786345DEB6
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 09:23:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 65C1545DE9E
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 09:23:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5968B1DB8041
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 09:23:52 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1540A1DB8038
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 09:23:52 +0900 (JST)
Date: Fri, 26 Aug 2011 09:16:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Subject: [PATCH V7 2/4] mm: frontswap: core code
Message-Id: <20110826091619.1ad27e9c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <d0b4c414-e90f-4ae0-9b70-fd5b54d2b011@default>
References: <20110823145815.GA23190@ca-server1.us.oracle.com
 20110825150532.a4d282b1.kamezawa.hiroyu@jp.fujitsu.com>
	<d0b4c414-e90f-4ae0-9b70-fd5b54d2b011@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com

On Thu, 25 Aug 2011 10:37:05 -0700 (PDT)
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> > From: KAMEZAWA Hiroyuki [mailto:kamezawa.hiroyu@jp.fujitsu.com]
> > Subject: Re: Subject: [PATCH V7 2/4] mm: frontswap: core code

> > BTW, Do I have a chance to implement frontswap accounting per cgroup
> > (under memcg) ? Or Do I need to enable/disale switch for frontswap per memcg ?
> > Do you think it is worth to do ?
> 
> I'm not very familiar with cgroups or memcg but I think it may be possible
> to implement transcendent memory with cgroup as the "guest" and the default
> cgroup as the "host" to allow for more memory elasticity for cgroups.
> (See http://lwn.net/Articles/454795/ for a good overview of all of
> transcendent memory.)
> 
Ok, I'll see it.

I just wonder following case.

Assume 2 memcgs.
	memcg X: memory limit = 300M.
	memcg Y: memory limit = 300M.

This limitation is done for performance isolation.
When using frontswap, X and Y can cause resource confliction in frontswap and
performance of X and Y cannot be predictable.


> > > +/*
> > > + * This global enablement flag reduces overhead on systems where frontswap_ops
> > > + * has not been registered, so is preferred to the slower alternative: a
> > > + * function call that checks a non-global.
> > > + */
> > > +int frontswap_enabled;
> > > +EXPORT_SYMBOL(frontswap_enabled);
> > > +
> > > +/* useful stats available in /sys/kernel/mm/frontswap */
> > > +static unsigned long frontswap_gets;
> > > +static unsigned long frontswap_succ_puts;
> > > +static unsigned long frontswap_failed_puts;
> > > +static unsigned long frontswap_flushes;
> > > +
> > 
> > What lock guard these ? swap_lock ?
> 
> These are informational statistics so do not need to be protected
> by a lock or an atomic-type.  If an increment is lost due to a cpu
> race, it is not a problem.
> 

Hmm...Personally, I don't like incorrect counters. Could you add comments ?
Or How anout using percpu_counter ? (see lib/percpu_counter.c)


> > > +/* Called when a swap device is swapon'd */
> > > +void __frontswap_init(unsigned type)
> > > +{
> > > +	struct swap_info_struct *sis = swap_info[type];
> > > +
> > > +	BUG_ON(sis == NULL);
> > > +	if (sis->frontswap_map == NULL)
> > > +		return;
> > > +	if (frontswap_enabled)
> > > +		(*frontswap_ops.init)(type);
> > > +}
> > > +EXPORT_SYMBOL(__frontswap_init);
> > > +
> > > +/*
> > > + * "Put" data from a page to frontswap and associate it with the page's
> > > + * swaptype and offset.  Page must be locked and in the swap cache.
> > > + * If frontswap already contains a page with matching swaptype and
> > > + * offset, the frontswap implmentation may either overwrite the data
> > > + * and return success or flush the page from frontswap and return failure
> > > + */
> > 
> > What lock should be held to guard global variables ? swap_lock ?
> 
> Which global variables do you mean and in what routines?  I think the
> page lock is required for put/get (as documented in the comments)
> but not the swap_lock.
> 

My concern was race in counters. Even you allow race in frontswap_succ_puts++,

Don't you need some lock for
	sis->frontswap_pages++
	sis->frontswap_pages--
?

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
