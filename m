Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 88C7C8D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 04:45:03 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DC4D53EE0AE
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 17:45:00 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C35F745DE56
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 17:45:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A2ABA45DE54
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 17:45:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D7DA1DB804A
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 17:45:00 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 47A491DB8042
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 17:45:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH V7 7/9] Per-memcg background reclaim.
In-Reply-To: <BANLkTi=BewF6TtSAsqY+bYQB6UUR_yt9yQ@mail.gmail.com>
References: <20110422150050.FA6E.A69D9226@jp.fujitsu.com> <BANLkTi=BewF6TtSAsqY+bYQB6UUR_yt9yQ@mail.gmail.com>
Message-Id: <20110422174554.71F2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 22 Apr 2011 17:44:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

> > > @@ -111,6 +113,8 @@ struct scan_control {
> > >        * are scanned.
> > >        */
> > >       nodemask_t      *nodemask;
> > > +
> > > +     int priority;
> > >  };
> >
> > Bah!
> > If you need sc.priority, you have to make cleanup patch at first. and
> > all current reclaim path have to use sc.priority. Please don't increase
> > unnecessary mess.
> >
> > hmm. so then I would change it by passing the priority
> > as separate parameter.

ok.

> > > +             /*
> > > +              * If we've done a decent amount of scanning and
> > > +              * the reclaim ratio is low, start doing writepage
> > > +              * even in laptop mode
> > > +              */
> > > +             if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
> > > +                 total_scanned > sc->nr_reclaimed + sc->nr_reclaimed /
> > 2) {
> > > +                     sc->may_writepage = 1;
> >
> > please make helper function for may_writepage. iow, don't cut-n-paste.
> >
> > hmm, can you help to clarify that?

I meant completely cut-n-paste code and comments is here.


> > > +     total_scanned = 0;
> > > +
> > > +     do_nodes = node_states[N_ONLINE];
> >
> > Why do we need care memoryless node? N_HIGH_MEMORY is wrong?
> >
> hmm, let me look into that.


> > > +             sc.priority = priority;
> > > +             /* The swap token gets in the way of swapout... */
> > > +             if (!priority)
> > > +                     disable_swap_token();
> >
> > Why?
> >
> > disable swap token mean "Please devest swap preventation privilege from
> > owner task. Instead we endure swap storm and performance hit".
> > However I doublt memcg memory shortage is good situation to make swap
> > storm.
> >
> 
> I am not sure about that either way. we probably can leave as it is and make
> corresponding change if real problem is observed?

Why?
This is not only memcg issue, but also can lead to global swap ping-pong.

But I give up. I have no time to persuade you.


> > > +                     nid = mem_cgroup_select_victim_node(mem_cont,
> > > +                                                     &do_nodes);
> > > +
> > > +                     pgdat = NODE_DATA(nid);
> > > +                     shrink_memcg_node(pgdat, order, &sc);
> > > +                     total_scanned += sc.nr_scanned;
> > > +
> > > +                     for (i = pgdat->nr_zones - 1; i >= 0; i--) {
> > > +                             struct zone *zone = pgdat->node_zones + i;
> > > +
> > > +                             if (populated_zone(zone))
> > > +                                     break;
> > > +                     }
> >
> > memory less node check is here. but we can check it before.
> 
> Not sure I understand this, can you help to clarify?

Same with above N_HIGH_MEMORY comments.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
