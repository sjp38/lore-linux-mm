Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 78AA36B00E9
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 05:21:39 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3787E3EE0AE
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 19:21:35 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B31545DE5A
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 19:21:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F38FF45DE55
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 19:21:34 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E5C1C1DB8041
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 19:21:34 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BBD71DB8037
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 19:21:34 +0900 (JST)
Date: Mon, 24 Jan 2011 19:15:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] memcg : comment, style fixes for recent patch of
 move_parent
Message-Id: <20110124191535.514ef2d9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110124101402.GT2232@cmpxchg.org>
References: <20110121153431.191134dd.kamezawa.hiroyu@jp.fujitsu.com>
	<20110121153726.54f4a159.kamezawa.hiroyu@jp.fujitsu.com>
	<20110124101402.GT2232@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 24 Jan 2011 11:14:02 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Fri, Jan 21, 2011 at 03:37:26PM +0900, KAMEZAWA Hiroyuki wrote:
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > A fix for 987eba66e0e6aa654d60881a14731a353ee0acb4
> > 
> > A clean up for mem_cgroup_move_parent(). 
> >  - remove unnecessary initialization of local variable.
> >  - rename charge_size -> page_size
> >  - remove unnecessary (wrong) comment.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |   17 +++++++++--------
> >  1 file changed, 9 insertions(+), 8 deletions(-)
> > 
> > Index: mmotm-0107/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-0107.orig/mm/memcontrol.c
> > +++ mmotm-0107/mm/memcontrol.c
> > @@ -2265,7 +2265,7 @@ static int mem_cgroup_move_parent(struct
> >  	struct cgroup *cg = child->css.cgroup;
> >  	struct cgroup *pcg = cg->parent;
> >  	struct mem_cgroup *parent;
> > -	int charge = PAGE_SIZE;
> > +	int page_size;
> >  	unsigned long flags;
> >  	int ret;
> >  
> > @@ -2278,22 +2278,23 @@ static int mem_cgroup_move_parent(struct
> >  		goto out;
> >  	if (isolate_lru_page(page))
> >  		goto put;
> > -	/* The page is isolated from LRU and we have no race with splitting */
> > -	charge = PAGE_SIZE << compound_order(page);
> > +
> > +	page_size = PAGE_SIZE << compound_order(page);
> 
> Okay, so you remove the wrong comment, but that does not make the code
> right.  What protects compound_order from reading garbage because the
> page is currently splitting?
> 

==
static int mem_cgroup_move_account(struct page_cgroup *pc,
                struct mem_cgroup *from, struct mem_cgroup *to,
                bool uncharge, int charge_size)
{
        int ret = -EINVAL;
        unsigned long flags;

        if ((charge_size > PAGE_SIZE) && !PageTransHuge(pc->page))
                return -EBUSY;
==

This is called under compound_lock(). Then, if someone breaks THP,
-EBUSY and retry.


Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
