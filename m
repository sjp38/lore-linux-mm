Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 557CC5F0001
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 23:50:39 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3H3pNuY031090
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 17 Apr 2009 12:51:24 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C93445DE61
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 12:51:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3336145DE5D
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 12:51:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 104281DB805D
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 12:51:23 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EBF71DB8043
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 12:51:22 +0900 (JST)
Date: Fri, 17 Apr 2009 12:49:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Add file based RSS accounting for memory resource
 controller (v2)
Message-Id: <20090417124951.a8472c86.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090417034539.GD18558@balbir.in.ibm.com>
References: <20090415120510.GX7082@balbir.in.ibm.com>
	<20090416095303.b4106e9f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090416015955.GB7082@balbir.in.ibm.com>
	<20090416110246.c3fef293.kamezawa.hiroyu@jp.fujitsu.com>
	<20090416164036.03d7347a.kamezawa.hiroyu@jp.fujitsu.com>
	<20090416171535.cfc4ca84.kamezawa.hiroyu@jp.fujitsu.com>
	<20090416120316.GG7082@balbir.in.ibm.com>
	<20090417091459.dac2cc39.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417014042.GB18558@balbir.in.ibm.com>
	<20090417110350.3144183d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417034539.GD18558@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Apr 2009 09:15:39 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-17 11:03:50]:
> 
> > On Fri, 17 Apr 2009 07:10:42 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-17 09:14:59]:
> > > 
> > > > On Thu, 16 Apr 2009 17:33:16 +0530
> > > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > 
> > > > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-16 17:15:35]:
> > > > > 
> > > > > > 
> > > > > > > Sorry, some troubles found. Ignore above Ack. 3points now.
> > > > > > > 
> > > > > > > 1. get_cpu should be after (*)
> > > > > > > ==mem_cgroup_update_mapped_file_stat()
> > > > > > > +	int cpu = get_cpu();
> > > > > > > +
> > > > > > > +	if (!page_is_file_cache(page))
> > > > > > > +		return;
> > > > > > > +
> > > > > > > +	if (unlikely(!mm))
> > > > > > > +		mm = &init_mm;
> > > > > > > +
> > > > > > > +	mem = try_get_mem_cgroup_from_mm(mm);
> > > > > > > +	if (!mem)
> > > > > > > +		return;
> > > > > > > + ----------------------------------------(*)
> > > > > > > +	stat = &mem->stat;
> > > > > > > +	cpustat = &stat->cpustat[cpu];
> > > > > > > +
> > > > > > > +	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE, val);
> > > > > > > +	put_cpu();
> > > > > > > +}
> > > > > > > ==
> > > > > 
> > > > > Yes or I should have a goto
> > > > > 
> > > > > > > 
> > > > > > > 2. In above, "mem" shouldn't be got from "mm"....please get "mem" from page_cgroup.
> > > > > > > (Because it's file cache, pc->mem_cgroup is not NULL always.)
> > > > > 
> > > > > Hmmm.. not sure I understand this part. Are you suggesting that mm can
> > > > > be NULL?
> > > > No.
> > > > 
> > > > > I added the check for !mm as a safety check. Since this
> > > > > routine is only called from rmap context, mm is not NULL, hence mem
> > > > > should not be NULL. Did you find a race between mm->owner assignment
> > > > > and lookup via mm->owner?
> > > > > 
> > > > No.
> > > > 
> > > > page_cgroup->mem_cgroup != try_get_mem_cgroup_from_mm(mm);  in many many cases.
> > > > 
> > > > For example, libc and /bin/*** is tend to be loaded into default cgroup at boot but
> > > > used by many cgroups. But mapcount of page caches for /bin/*** is 0 if not running.
> > > > 
> > > > Then, File_Mapped can be greater than Cached easily if you use mm->owner.
> > > > 
> > > > I can't estimate RSS in *my* cgroup if File_Mapped includes pages which is under 
> > > > other cgroups. It's meaningless.
> > > > Especially, when Cached==0 but File_Mapped > 0, I think "oh, the kernel leaks somehing..hmm..."
> > > > 
> > > > By useing page_cgroup->mem_cgroup, we can avoid above mess.
> > > 
> > > Yes, I see your point. I wanted mapped_file to show up in the cgroup
> > > that mapped the page. But this works for me as well, but that means
> > > we'll nest the page cgroup lock under the PTE lock.
> > 
> > Don't worry. we do that nest at ANON's uncharge(), already.
> > 
> > About cost:
> > 
> > IIUC, the number of "mapcount 0->1/1->0" of file caches are much smaller than
> > that of o Anon. And there will be not very much cache pingpong.
> > 
> > If you use PCG_MAPPED flag in page_cgroup (as my patch), you can use
> > not-atomic version of set/clear when update is only under lock_page_cgroup().
> > If you find better way, plz use it. But we can't avoid some kind of atomic ops
> > for correct accounting, I think.
> >
> 
> Can you sign off on your patch, so that I can take it with your
> signed-off-by. I will also make some minor changes, get_cpu() is not
> needed, since we are in preempt disable context. 
> 
Hmm, 
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

But some more clean up is necesarry.

=== This part ==
+	lock_page_cgroup(pc);
+	mem = pc->mem_cgroup;
+	if (mem) {
+		cpu = get_cpu();
+		stat = &mem->stat;
+		cpustat = &stat->cpustat[cpu];
+		if (map)

=== Should be ==
+	lock_page_cgroup(pc);
	if (!PageCgroupUsed(pc)) {
		unlock_page_cgroup(pc);
		return;
	}
	mem = pc->mem_cgroup
	VM_BUG_ON(!mem);
	cpu = get_cpu();
	stat = &mem->stat;
	cpustat = &stat->cpustat[cpu];
	if (map)
.....

Maybe much cleaner.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
