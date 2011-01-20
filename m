Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 58CC38D0069
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 18:45:34 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 40DA33EE0B3
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 08:45:31 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2523245DE4D
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 08:45:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 05E2445DE57
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 08:45:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E5B5BE18004
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 08:45:30 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A9FD4E08002
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 08:45:30 +0900 (JST)
Date: Fri, 21 Jan 2011 08:39:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] memcg: fix rmdir, force_empty with THP
Message-Id: <20110121083930.d803126f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110120134108.GO2232@cmpxchg.org>
References: <20110118113528.fd24928f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110118114348.9e1dba9b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110120134108.GO2232@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 20 Jan 2011 14:41:08 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Tue, Jan 18, 2011 at 11:43:48AM +0900, KAMEZAWA Hiroyuki wrote:
> > 
> > Now, when THP is enabled, memcg's rmdir() function is broken
> > because move_account() for THP page is not supported.
> > 
> > This will cause account leak or -EBUSY issue at rmdir().
> > This patch fixes the issue by supporting move_account() THP pages.
> > 
> > Changelog:
> >  - style fix.
> >  - add compound_lock for avoiding races.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |   37 ++++++++++++++++++++++++++-----------
> >  1 file changed, 26 insertions(+), 11 deletions(-)
> > 
> > Index: mmotm-0107/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-0107.orig/mm/memcontrol.c
> > +++ mmotm-0107/mm/memcontrol.c
> 
> > @@ -2267,6 +2274,8 @@ static int mem_cgroup_move_parent(struct
> >  	struct cgroup *cg = child->css.cgroup;
> >  	struct cgroup *pcg = cg->parent;
> >  	struct mem_cgroup *parent;
> > +	int charge = PAGE_SIZE;
> 
> No need to initialize, you assign it unconditionally below.
> 
> It's also a bit unfortunate that the parameter/variable with this
> meaning appears under a whole bunch of different names.  page_size,
> charge_size, and now charge.  Could you stick with page_size?
> 

charge_size != page_size.

Clean up as you like, later. I'll Ack.

> > @@ -2278,17 +2287,23 @@ static int mem_cgroup_move_parent(struct
> >  		goto out;
> >  	if (isolate_lru_page(page))
> >  		goto put;
> > +	/* The page is isolated from LRU and we have no race with splitting */
> > +	charge = PAGE_SIZE << compound_order(page);
> 
> Why is LRU isolation preventing the splitting?
> 

That's my mistake of comment, which was in the older patch.
I use compound_lock now. I'll post clean up.

> I think we need the compound lock to get a stable read, like
> compound_trans_order() does.
> 

Thanks,
-Kame

> 	Hannes
> 
> >  	parent = mem_cgroup_from_cont(pcg);
> > -	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false,
> > -				      PAGE_SIZE);
> > +	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false, charge);
> >  	if (ret || !parent)
> >  		goto put_back;
> >  
> > -	ret = mem_cgroup_move_account(pc, child, parent, true);
> > +	if (charge > PAGE_SIZE)
> > +		flags = compound_lock_irqsave(page);
> > +
> > +	ret = mem_cgroup_move_account(pc, child, parent, true, charge);
> >  	if (ret)
> > -		mem_cgroup_cancel_charge(parent, PAGE_SIZE);
> > +		mem_cgroup_cancel_charge(parent, charge);
> >  put_back:
> > +	if (charge > PAGE_SIZE)
> > +		compound_unlock_irqrestore(page, flags);
> >  	putback_lru_page(page);
> >  put:
> >  	put_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
