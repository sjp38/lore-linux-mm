Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6BEBD6B0047
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 02:45:33 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1C7jUFj016889
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Feb 2010 16:45:31 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D07F45DE60
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 16:45:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F8BA45DE6E
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 16:45:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F7D21DB8037
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 16:45:30 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AEA52E18007
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 16:45:26 +0900 (JST)
Date: Fri, 12 Feb 2010 16:42:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] memcg : update softlimit and threshold at commit.
Message-Id: <20100212164201.2ec8f0ff.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100212163311.7fe3d879.nishimura@mxp.nes.nec.co.jp>
References: <20100212154422.58bfdc4d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100212154713.d8a9374d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100212163311.7fe3d879.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Feb 2010 16:33:11 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Fri, 12 Feb 2010 15:47:13 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Now, move_task introduced "batched" precharge. Because res_counter or css's refcnt
> > are not-scalable jobs for memcg, charge()s should be done in batched manner
> > if allowed.
> > 
> > Now, softlimit and threshold check their event counter in try_charge, but
> > this charge() is not per-page event. And event counter is not updated at charge().
> > Moreover, precharge doesn't pass "page" to try_charge() and softlimit tree
> > will be never updated until uncharge() causes an event.
> > 
> > So, the best place to check the event counter is commit_charge(). This is 
> > per-page event by its nature. This patch move checks to there.
> > 
> I agree to this direction.
> 
> > Cc: Kirill A. Shutemov <kirill@shutemov.name>
> > Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> > Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |   23 ++++++++++++-----------
> >  1 file changed, 12 insertions(+), 11 deletions(-)
> > 
> > Index: mmotm-2.6.33-Feb10/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.33-Feb10.orig/mm/memcontrol.c
> > +++ mmotm-2.6.33-Feb10/mm/memcontrol.c
> > @@ -1463,7 +1463,7 @@ static int __mem_cgroup_try_charge(struc
> >  		unsigned long flags = 0;
> >  
> >  		if (consume_stock(mem))
> > -			goto charged;
> > +			goto done;
> >  
> >  		ret = res_counter_charge(&mem->res, csize, &fail_res);
> >  		if (likely(!ret)) {
> > @@ -1558,16 +1558,7 @@ static int __mem_cgroup_try_charge(struc
> >  	}
> >  	if (csize > PAGE_SIZE)
> >  		refill_stock(mem, csize - PAGE_SIZE);
> > -charged:
> > -	/*
> > -	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
> > -	 * if they exceeds softlimit.
> > -	 */
> > -	if (page && mem_cgroup_soft_limit_check(mem))
> > -		mem_cgroup_update_tree(mem, page);
> >  done:
> > -	if (mem_cgroup_threshold_check(mem))
> > -		mem_cgroup_threshold(mem);
> >  	return 0;
> >  nomem:
> >  	css_put(&mem->css);
> After this change, @page can be removed from the arg of try_charge().
> 
Ah, hmm. good point. Will update.

Thanks,
-Kame


> 
> Thanks,
> Daisuke Nishimura.
> 
> > @@ -1691,6 +1682,16 @@ static void __mem_cgroup_commit_charge(s
> >  	mem_cgroup_charge_statistics(mem, pc, true);
> >  
> >  	unlock_page_cgroup(pc);
> > +	/*
> > +	 * "charge_statistics" updated event counter. Then, check it.
> > +	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
> > +	 * if they exceeds softlimit.
> > +	 */
> > +	if (mem_cgroup_soft_limit_check(mem))
> > +		mem_cgroup_update_tree(mem, pc->page);
> > +	if (mem_cgroup_threshold_check(mem))
> > +		mem_cgroup_threshold(mem);
> > +
> >  }
> >  
> >  /**
> > 
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
