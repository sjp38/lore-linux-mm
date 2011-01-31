Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C1C778D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 18:56:26 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E0D143EE0B3
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 08:56:23 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C597345DE61
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 08:56:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ABBFB45DE4E
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 08:56:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9ED911DB803E
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 08:56:23 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 692A01DB8038
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 08:56:23 +0900 (JST)
Date: Tue, 1 Feb 2011 08:50:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 2/3] memcg: prevent endless loop when charging huge
 pages to near-limit group
Message-Id: <20110201085021.fa975a56.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110131144131.6733aa3a.akpm@linux-foundation.org>
References: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
	<1296482635-13421-3-git-send-email-hannes@cmpxchg.org>
	<20110131144131.6733aa3a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 31 Jan 2011 14:41:31 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 31 Jan 2011 15:03:54 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > +static inline bool res_counter_check_margin(struct res_counter *cnt,
> > +					    unsigned long bytes)
> > +{
> > +	bool ret;
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(&cnt->lock, flags);
> > +	ret = cnt->limit - cnt->usage >= bytes;
> > +	spin_unlock_irqrestore(&cnt->lock, flags);
> > +	return ret;
> > +}
> > +
> >  static inline bool res_counter_check_under_soft_limit(struct res_counter *cnt)
> >  {
> >  	bool ret;
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 73ea323..c28072f 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1111,6 +1111,15 @@ static bool mem_cgroup_check_under_limit(struct mem_cgroup *mem)
> >  	return false;
> >  }
> >  
> > +static bool mem_cgroup_check_margin(struct mem_cgroup *mem, unsigned long bytes)
> > +{
> > +	if (!res_counter_check_margin(&mem->res, bytes))
> > +		return false;
> > +	if (do_swap_account && !res_counter_check_margin(&mem->memsw, bytes))
> > +		return false;
> > +	return true;
> > +}
> 
> argh.
> 
> If you ever have a function with the string "check" in its name, it's a
> good sign that you did something wrong.
> 
> Check what?  Against what?  Returning what?
> 
> mem_cgroup_check_under_limit() isn't toooo bad - the name tells you
> what's being checked and tells you what to expect the return value to
> mean.
> 
> But "res_counter_check_margin" and "mem_cgroup_check_margin" are just
> awful.  Something like
> 
> 	bool res_counter_may_charge(counter, bytes)
> 
> would be much clearer.
> 
> If we really want to stick with the "check" names (perhaps as an ironic
> reference to res_counter's past mistakes) then please at least document
> the sorry things?
> 

Ah, I ack the concept of patch.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Johannes, could you change name ? I'm sorry.



 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
