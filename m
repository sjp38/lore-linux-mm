Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2046E900163
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 22:29:28 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3C41F3EE0AE
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 11:29:24 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BFC0E45DE57
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 11:29:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A07E45DE54
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 11:29:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 886411DB8041
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 11:29:22 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DB3B1DB803E
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 11:29:22 +0900 (JST)
Date: Tue, 2 Aug 2011 11:21:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 2/5] memcg : pass scan nodemask
Message-Id: <20110802112143.814e3720.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110801135953.GE25251@tiehlicka.suse.cz>
References: <20110727144438.a9fdfd5b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110727144742.420cf69c.kamezawa.hiroyu@jp.fujitsu.com>
	<20110801135953.GE25251@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Mon, 1 Aug 2011 15:59:53 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Wed 27-07-11 14:47:42, KAMEZAWA Hiroyuki wrote:
> > 
> > pass memcg's nodemask to try_to_free_pages().
> > 
> > try_to_free_pages can take nodemask as its argument but memcg
> > doesn't pass it. Considering memcg can be used with cpuset on
> > big NUMA, memcg should pass nodemask if available.
> > 
> > Now, memcg maintain nodemask with periodic updates. pass it.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/memcontrol.h |    2 +-
> >  mm/memcontrol.c            |    8 ++++++--
> >  mm/vmscan.c                |    3 ++-
> >  3 files changed, 9 insertions(+), 4 deletions(-)
> > 
> [...]
> > Index: mmotm-0710/mm/vmscan.c
> > ===================================================================
> > --- mmotm-0710.orig/mm/vmscan.c
> > +++ mmotm-0710/mm/vmscan.c
> > @@ -2280,6 +2280,7 @@ unsigned long try_to_free_mem_cgroup_pag
> >  	unsigned long nr_reclaimed;
> >  	unsigned long start, end;
> >  	int nid;
> > +	nodemask_t *mask;
> >  	struct scan_control sc = {
> >  		.may_writepage = !laptop_mode,
> >  		.may_unmap = 1,
> > @@ -2302,7 +2303,7 @@ unsigned long try_to_free_mem_cgroup_pag
> >  	 * take care of from where we get pages. So the node where we start the
> >  	 * scan does not need to be the current node.
> >  	 */
> > -	nid = mem_cgroup_select_victim_node(mem_cont);
> > +	nid = mem_cgroup_select_victim_node(mem_cont, &mask);
> 
> The mask is not used anywhere AFAICS and using it is a point of the
> patch AFAIU. I guess you wanted to use &sc.nodemask, right?
> 
> Other than that, looks good to me.
> 
> Reviewed-by: Michal Hocko <mhocko@suse.cz>

Ah, sorry. I'll fix.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
