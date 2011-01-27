Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BA6388D0039
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 21:19:55 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 634863EE0AE
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 11:19:53 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CBDE45DE4F
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 11:19:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 37C0E45DE4E
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 11:19:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BFAB1DB803E
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 11:19:53 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E25571DB8037
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 11:19:52 +0900 (JST)
Date: Thu, 27 Jan 2011 11:13:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX v2] memcg: fix res_counter_read_u64 lock aware (Was Re:
 [PATCH] oom: handle overflow in mem_cgroup_out_of_memory()
Message-Id: <20110127111350.cc5b3111.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110126175722.01b0db3a.akpm@linux-foundation.org>
References: <1296030555-3594-1-git-send-email-gthelen@google.com>
	<20110126170713.GA2401@cmpxchg.org>
	<xr93y667lgdm.fsf@gthelen.mtv.corp.google.com>
	<20110126183023.GB2401@cmpxchg.org>
	<xr9362tbl83f.fsf@gthelen.mtv.corp.google.com>
	<20110126142909.0b710a0c.akpm@linux-foundation.org>
	<20110127092434.df18c7a6.kamezawa.hiroyu@jp.fujitsu.com>
	<20110127095342.3d81cf5f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110127104339.0f580bac.kamezawa.hiroyu@jp.fujitsu.com>
	<20110126175722.01b0db3a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 26 Jan 2011 17:57:22 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 27 Jan 2011 10:43:39 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > --- mmotm-0125.orig/kernel/res_counter.c
> > +++ mmotm-0125/kernel/res_counter.c
> > @@ -126,10 +126,24 @@ ssize_t res_counter_read(struct res_coun
> >  			pos, buf, s - buf);
> >  }
> >  
> > +#if BITS_PER_LONG == 32
> > +u64 res_counter_read_u64(struct res_counter *counter, int member)
> > +{
> > +	unsigned long flags;
> > +	u64 ret;
> > +
> > +	spin_lock_irqsave(&counter->lock, flags);
> > +	ret = *res_counter_member(counter, member);
> > +	spin_unlock_irqrestore(&counter->lock, flags);
> > +
> > +	return ret;
> > +}
> > +#else
> >  u64 res_counter_read_u64(struct res_counter *counter, int member)
> >  {
> >  	return *res_counter_member(counter, member);
> >  }
> > +#endif
> 
> _irqsave is only needed if the lock will be taken from irq context. 
> Does that happen?
> 
I just obey current desing of res_counter, as bugfix.
This counter is designed to be safe against irq context.
Adding CC: to Balbir.

To be honest, it has never happened since res_counter is introduced. I imagine
there was a big plan when this counter was designed. But I think it will 
be never called other than memcg because cpu, blkio controller haven't
use res_counter, finally. And memcg tends to use per-cpu counter because of
performance.

If I need to remove irq flags from this function, I'll do in another patch
which changes total design of res_counter and make it not safe agaisnt irq context.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
