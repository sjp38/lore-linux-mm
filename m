Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 778FE5F0001
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 00:56:25 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id n3H4v9W1021441
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 14:57:09 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3H4v5sc503948
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 14:57:10 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3H4v5xf020557
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 14:57:05 +1000
Date: Fri, 17 Apr 2009 10:26:23 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] Add file based RSS accounting for memory resource
	controller (v2)
Message-ID: <20090417045623.GA3896@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090416015955.GB7082@balbir.in.ibm.com> <20090416110246.c3fef293.kamezawa.hiroyu@jp.fujitsu.com> <20090416164036.03d7347a.kamezawa.hiroyu@jp.fujitsu.com> <20090416171535.cfc4ca84.kamezawa.hiroyu@jp.fujitsu.com> <20090416120316.GG7082@balbir.in.ibm.com> <20090417091459.dac2cc39.kamezawa.hiroyu@jp.fujitsu.com> <20090417014042.GB18558@balbir.in.ibm.com> <20090417110350.3144183d.kamezawa.hiroyu@jp.fujitsu.com> <20090417034539.GD18558@balbir.in.ibm.com> <20090417124951.a8472c86.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090417124951.a8472c86.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-17 12:49:51]:

> On Fri, 17 Apr 2009 09:15:39 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-17 11:03:50]:
> > 
> > > On Fri, 17 Apr 2009 07:10:42 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > 
> > > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-17 09:14:59]:
> > > > 
> > > > > On Thu, 16 Apr 2009 17:33:16 +0530
> > > > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > > 
> > > > > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-16 17:15:35]:
> > > > > > 
> > > > > > > 
> > > > > > > > Sorry, some troubles found. Ignore above Ack. 3points now.
> > > > > > > > 
> > > > > > > > 1. get_cpu should be after (*)
> > > > > > > > ==mem_cgroup_update_mapped_file_stat()
> > > > > > > > +	int cpu = get_cpu();
> > > > > > > > +
> > > > > > > > +	if (!page_is_file_cache(page))
> > > > > > > > +		return;
> > > > > > > > +
> > > > > > > > +	if (unlikely(!mm))
> > > > > > > > +		mm = &init_mm;
> > > > > > > > +
> > > > > > > > +	mem = try_get_mem_cgroup_from_mm(mm);
> > > > > > > > +	if (!mem)
> > > > > > > > +		return;
> > > > > > > > + ----------------------------------------(*)
> > > > > > > > +	stat = &mem->stat;
> > > > > > > > +	cpustat = &stat->cpustat[cpu];
> > > > > > > > +
> > > > > > > > +	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE, val);
> > > > > > > > +	put_cpu();
> > > > > > > > +}
> > > > > > > > ==
> > > > > > 
> > > > > > Yes or I should have a goto
> > > > > > 
> > > > > > > > 
> > > > > > > > 2. In above, "mem" shouldn't be got from "mm"....please get "mem" from page_cgroup.
> > > > > > > > (Because it's file cache, pc->mem_cgroup is not NULL always.)
> > > > > > 
> > > > > > Hmmm.. not sure I understand this part. Are you suggesting that mm can
> > > > > > be NULL?
> > > > > No.
> > > > > 
> > > > > > I added the check for !mm as a safety check. Since this
> > > > > > routine is only called from rmap context, mm is not NULL, hence mem
> > > > > > should not be NULL. Did you find a race between mm->owner assignment
> > > > > > and lookup via mm->owner?
> > > > > > 
> > > > > No.
> > > > > 
> > > > > page_cgroup->mem_cgroup != try_get_mem_cgroup_from_mm(mm);  in many many cases.
> > > > > 
> > > > > For example, libc and /bin/*** is tend to be loaded into default cgroup at boot but
> > > > > used by many cgroups. But mapcount of page caches for /bin/*** is 0 if not running.
> > > > > 
> > > > > Then, File_Mapped can be greater than Cached easily if you use mm->owner.
> > > > > 
> > > > > I can't estimate RSS in *my* cgroup if File_Mapped includes pages which is under 
> > > > > other cgroups. It's meaningless.
> > > > > Especially, when Cached==0 but File_Mapped > 0, I think "oh, the kernel leaks somehing..hmm..."
> > > > > 
> > > > > By useing page_cgroup->mem_cgroup, we can avoid above mess.
> > > > 
> > > > Yes, I see your point. I wanted mapped_file to show up in the cgroup
> > > > that mapped the page. But this works for me as well, but that means
> > > > we'll nest the page cgroup lock under the PTE lock.
> > > 
> > > Don't worry. we do that nest at ANON's uncharge(), already.
> > > 
> > > About cost:
> > > 
> > > IIUC, the number of "mapcount 0->1/1->0" of file caches are much smaller than
> > > that of o Anon. And there will be not very much cache pingpong.
> > > 
> > > If you use PCG_MAPPED flag in page_cgroup (as my patch), you can use
> > > not-atomic version of set/clear when update is only under lock_page_cgroup().
> > > If you find better way, plz use it. But we can't avoid some kind of atomic ops
> > > for correct accounting, I think.
> > >
> > 
> > Can you sign off on your patch, so that I can take it with your
> > signed-off-by. I will also make some minor changes, get_cpu() is not
> > needed, since we are in preempt disable context. 
> > 
> Hmm, 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> But some more clean up is necesarry.
> 
> === This part ==
> +	lock_page_cgroup(pc);
> +	mem = pc->mem_cgroup;
> +	if (mem) {
> +		cpu = get_cpu();
> +		stat = &mem->stat;
> +		cpustat = &stat->cpustat[cpu];
> +		if (map)
> 
> === Should be ==
> +	lock_page_cgroup(pc);
> 	if (!PageCgroupUsed(pc)) {
> 		unlock_page_cgroup(pc);
> 		return;
> 	}

Do we need this? If the page is mapped, pc should be used right?

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
