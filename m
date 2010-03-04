Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 81D756B0047
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 22:48:47 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o243mj9q007933
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 4 Mar 2010 12:48:45 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 31CDC45DE51
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 12:48:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1532045DE4C
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 12:48:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F02961DB8015
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 12:48:44 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A010C1DB8012
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 12:48:44 +0900 (JST)
Date: Thu, 4 Mar 2010 12:45:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Message-Id: <20100304124505.394a058e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100303220319.GA2706@linux>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	<1267478620-5276-4-git-send-email-arighi@develer.com>
	<20100303111238.7133f8af.nishimura@mxp.nes.nec.co.jp>
	<20100303122906.9c613ab2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100303150137.f56d7084.nishimura@mxp.nes.nec.co.jp>
	<20100303151549.5d3d686a.kamezawa.hiroyu@jp.fujitsu.com>
	<20100303172132.fc6d9387.kamezawa.hiroyu@jp.fujitsu.com>
	<20100303220319.GA2706@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg@smtp1.linux-foundation.org, Suleiman Souhlal <suleiman@google.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Mar 2010 23:03:19 +0100
Andrea Righi <arighi@develer.com> wrote:

> On Wed, Mar 03, 2010 at 05:21:32PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Wed, 3 Mar 2010 15:15:49 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
 
> > +	preempt_disable();
> > +	lock_page_cgroup_migrate(pc);
> >  	page = pc->page;
> >  	if (page_mapped(page) && !PageAnon(page)) {
> >  		/* Update mapped_file data for mem_cgroup */
> > -		preempt_disable();
> >  		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> >  		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> > -		preempt_enable();
> >  	}
> >  	mem_cgroup_charge_statistics(from, pc, false);
> > +	move_acct_information(from, to, pc);
> 
> Kame-san, a question. According to is_target_pte_for_mc() it seems we
> don't move file pages across cgroups for now. 

yes. It's just in plan.

> If !PageAnon(page) we just return 0 and the page won't be selected for migration in
> mem_cgroup_move_charge_pte_range().
> 
> So, if I've understood well the code is correct in perspective, but
> right now it's unnecessary. File pages are not moved on task migration
> across cgroups and, at the moment, there's no way for file page
> accounted statistics to go negative.
> 
> Or am I missing something?
> 

At rmdir(), remainging file caches in a cgroup is moved to
its parent. Then, all file caches are moved to its parent at rmdir().

This behavior is for avoiding to lose too much file caches at removing cgroup.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
