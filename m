Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7EFE36B0093
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 23:20:18 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp09.au.ibm.com (8.13.1/8.13.1) with ESMTP id n3M2wGLN012441
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 22:58:16 -0400
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3M3KSmT405790
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 13:20:31 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3M3KS12029191
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 13:20:28 +1000
Date: Wed, 22 Apr 2009 08:49:39 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] Add file based RSS accounting for memory resource
	controller (v3)
Message-ID: <20090422031939.GQ19637@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090417110350.3144183d.kamezawa.hiroyu@jp.fujitsu.com> <20090417034539.GD18558@balbir.in.ibm.com> <20090417124951.a8472c86.kamezawa.hiroyu@jp.fujitsu.com> <20090417045623.GA3896@balbir.in.ibm.com> <20090417141726.a69ebdcc.kamezawa.hiroyu@jp.fujitsu.com> <20090417064726.GB3896@balbir.in.ibm.com> <20090417155608.eeed1f02.kamezawa.hiroyu@jp.fujitsu.com> <20090417141837.GD3896@balbir.in.ibm.com> <20090421132551.38e9960a.akpm@linux-foundation.org> <20090422090218.6d451a08.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090422090218.6d451a08.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-22 09:02:18]:

> On Tue, 21 Apr 2009 13:25:51 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Fri, 17 Apr 2009 19:48:38 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > >
> > > ...
> > >
> > > We currently don't track file RSS, the RSS we report is actually anon RSS.
> > > All the file mapped pages, come in through the page cache and get accounted
> > > there. This patch adds support for accounting file RSS pages. It should
> > > 
> > > 1. Help improve the metrics reported by the memory resource controller
> > > 2. Will form the basis for a future shared memory accounting heuristic
> > >    that has been proposed by Kamezawa.
> > > 
> > > Unfortunately, we cannot rename the existing "rss" keyword used in memory.stat
> > > to "anon_rss". We however, add "mapped_file" data and hope to educate the end
> > > user through documentation.
> > > 
> > > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> > >
> > > ...
> > >
> > > @@ -1096,6 +1135,10 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
> > >  	struct mem_cgroup_per_zone *from_mz, *to_mz;
> > >  	int nid, zid;
> > >  	int ret = -EBUSY;
> > > +	struct page *page;
> > > +	int cpu;
> > > +	struct mem_cgroup_stat *stat;
> > > +	struct mem_cgroup_stat_cpu *cpustat;
> > >  
> > >  	VM_BUG_ON(from == to);
> > >  	VM_BUG_ON(PageLRU(pc->page));
> > > @@ -1116,6 +1159,23 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
> > >  
> > >  	res_counter_uncharge(&from->res, PAGE_SIZE);
> > >  	mem_cgroup_charge_statistics(from, pc, false);
> > > +
> > > +	page = pc->page;
> > > +	if (page_is_file_cache(page) && page_mapped(page)) {
> > > +		cpu = smp_processor_id();
> > > +		/* Update mapped_file data for mem_cgroup "from" */
> > > +		stat = &from->stat;
> > > +		cpustat = &stat->cpustat[cpu];
> > > +		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE,
> > > +						-1);
> > > +
> > > +		/* Update mapped_file data for mem_cgroup "to" */
> > > +		stat = &to->stat;
> > > +		cpustat = &stat->cpustat[cpu];
> > > +		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE,
> > > +						1);
> > > +	}
> > 
> > This function (mem_cgroup_move_account()) does a trylock_page_cgroup()
> > and if that fails it will bale out, and the newly-added code will not
> > be executed.
> yes. and returns -EBUSY.
> 
> > 
> > What are the implications of this?  Does the missed accounting later get
> > performed somewhere, or does the error remain in place?
> > 
> no error just -BUSY. the caller (now, only force_empty is the caller) will do retry.
> 
> > That trylock_page_cgroup() really sucks - trylocks usually do.  Could
> > someone please raise a patch which completely documents the reasons for
> > its presence, and for any other uncommented/unobvious trylocks?
> > 
> > Where appropriate, the comment should explain why the trylock isn't
> > simply a bug - why it is safe and correct to omit the operations which
> > we wished to perform.
> > 
> > Thanks.
> > 
> Hmm...maybe we can replace trylock with lock, here.
> 
> IIRC, this has been trylock because the old routine uses other locks
> (mem_cgroup' zone mz->lru_lock) before calling this.
>    mz->lru_lock
>      lock_page_cgroup()
> And there was other routine which calls lock_page_cgroup()->mz->lru_lock.
>    lock_page_cgroup()
>         -> mz->lru_lock.
> 
> So, I used trylock here. But now, the lock(mz->lru_lock) is removed.
> I should check this.
> 
> Thank you for pointing out.
>

This is definitely worth looking into. Since we run force_empty() in a
while loop with some margin, we've probably avoided the problem. I
think this code needs a second look and refactoring.

 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
