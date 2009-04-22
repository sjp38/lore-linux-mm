Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 932FE6B004D
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 20:03:49 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3M03oj6026536
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 22 Apr 2009 09:03:50 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AE5A45DD76
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 09:03:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 330DE45DD75
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 09:03:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F4A91DB8013
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 09:03:50 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CCD611DB8016
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 09:03:49 +0900 (JST)
Date: Wed, 22 Apr 2009 09:02:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Add file based RSS accounting for memory resource
 controller (v3)
Message-Id: <20090422090218.6d451a08.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090421132551.38e9960a.akpm@linux-foundation.org>
References: <20090416120316.GG7082@balbir.in.ibm.com>
	<20090417091459.dac2cc39.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417014042.GB18558@balbir.in.ibm.com>
	<20090417110350.3144183d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417034539.GD18558@balbir.in.ibm.com>
	<20090417124951.a8472c86.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417045623.GA3896@balbir.in.ibm.com>
	<20090417141726.a69ebdcc.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417064726.GB3896@balbir.in.ibm.com>
	<20090417155608.eeed1f02.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417141837.GD3896@balbir.in.ibm.com>
	<20090421132551.38e9960a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Apr 2009 13:25:51 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 17 Apr 2009 19:48:38 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> >
> > ...
> >
> > We currently don't track file RSS, the RSS we report is actually anon RSS.
> > All the file mapped pages, come in through the page cache and get accounted
> > there. This patch adds support for accounting file RSS pages. It should
> > 
> > 1. Help improve the metrics reported by the memory resource controller
> > 2. Will form the basis for a future shared memory accounting heuristic
> >    that has been proposed by Kamezawa.
> > 
> > Unfortunately, we cannot rename the existing "rss" keyword used in memory.stat
> > to "anon_rss". We however, add "mapped_file" data and hope to educate the end
> > user through documentation.
> > 
> > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> >
> > ...
> >
> > @@ -1096,6 +1135,10 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
> >  	struct mem_cgroup_per_zone *from_mz, *to_mz;
> >  	int nid, zid;
> >  	int ret = -EBUSY;
> > +	struct page *page;
> > +	int cpu;
> > +	struct mem_cgroup_stat *stat;
> > +	struct mem_cgroup_stat_cpu *cpustat;
> >  
> >  	VM_BUG_ON(from == to);
> >  	VM_BUG_ON(PageLRU(pc->page));
> > @@ -1116,6 +1159,23 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
> >  
> >  	res_counter_uncharge(&from->res, PAGE_SIZE);
> >  	mem_cgroup_charge_statistics(from, pc, false);
> > +
> > +	page = pc->page;
> > +	if (page_is_file_cache(page) && page_mapped(page)) {
> > +		cpu = smp_processor_id();
> > +		/* Update mapped_file data for mem_cgroup "from" */
> > +		stat = &from->stat;
> > +		cpustat = &stat->cpustat[cpu];
> > +		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE,
> > +						-1);
> > +
> > +		/* Update mapped_file data for mem_cgroup "to" */
> > +		stat = &to->stat;
> > +		cpustat = &stat->cpustat[cpu];
> > +		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE,
> > +						1);
> > +	}
> 
> This function (mem_cgroup_move_account()) does a trylock_page_cgroup()
> and if that fails it will bale out, and the newly-added code will not
> be executed.
yes. and returns -EBUSY.

> 
> What are the implications of this?  Does the missed accounting later get
> performed somewhere, or does the error remain in place?
> 
no error just -BUSY. the caller (now, only force_empty is the caller) will do retry.

> That trylock_page_cgroup() really sucks - trylocks usually do.  Could
> someone please raise a patch which completely documents the reasons for
> its presence, and for any other uncommented/unobvious trylocks?
> 
> Where appropriate, the comment should explain why the trylock isn't
> simply a bug - why it is safe and correct to omit the operations which
> we wished to perform.
> 
> Thanks.
> 
Hmm...maybe we can replace trylock with lock, here.

IIRC, this has been trylock because the old routine uses other locks
(mem_cgroup' zone mz->lru_lock) before calling this.
   mz->lru_lock
     lock_page_cgroup()
And there was other routine which calls lock_page_cgroup()->mz->lru_lock.
   lock_page_cgroup()
        -> mz->lru_lock.

So, I used trylock here. But now, the lock(mz->lru_lock) is removed.
I should check this.

Thank you for pointing out.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
