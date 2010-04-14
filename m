Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 14A126B01EF
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 10:44:35 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp09.au.ibm.com (8.14.3/8.13.1) with ESMTP id o3EEiTJu016258
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 00:44:29 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3EEiTe91855546
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 00:44:29 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3EEiSR4022981
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 00:44:29 +1000
Date: Wed, 14 Apr 2010 20:14:24 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Message-ID: <20100414144424.GN3994@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1268609202-15581-2-git-send-email-arighi@develer.com>
 <20100317115855.GS18054@balbir.in.ibm.com>
 <20100318085411.834e1e46.kamezawa.hiroyu@jp.fujitsu.com>
 <20100318041944.GA18054@balbir.in.ibm.com>
 <20100318133527.420b2f25.kamezawa.hiroyu@jp.fujitsu.com>
 <20100318162855.GG18054@balbir.in.ibm.com>
 <20100319102332.f1d81c8d.kamezawa.hiroyu@jp.fujitsu.com>
 <20100319024039.GH18054@balbir.in.ibm.com>
 <20100319120049.3dbf8440.kamezawa.hiroyu@jp.fujitsu.com>
 <xr931veiplpr.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <xr931veiplpr.fsf@ninji.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Righi <arighi@develer.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Greg Thelen <gthelen@google.com> [2010-04-13 23:55:12]:

> On Thu, Mar 18, 2010 at 8:00 PM, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Fri, 19 Mar 2010 08:10:39 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >
> >> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-19 10:23:32]:
> >>
> >> > On Thu, 18 Mar 2010 21:58:55 +0530
> >> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >> >
> >> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-18 13:35:27]:
> >> >
> >> > > > Then, no probelm. It's ok to add mem_cgroup_udpate_stat() indpendent from
> >> > > > mem_cgroup_update_file_mapped(). The look may be messy but it's not your
> >> > > > fault. But please write "why add new function" to patch description.
> >> > > >
> >> > > > I'm sorry for wasting your time.
> >> > >
> >> > > Do we need to go down this route? We could check the stat and do the
> >> > > correct thing. In case of FILE_MAPPED, always grab page_cgroup_lock
> >> > > and for others potentially look at trylock. It is OK for different
> >> > > stats to be protected via different locks.
> >> > >
> >> >
> >> > I _don't_ want to see a mixture of spinlock and trylock in a function.
> >> >
> >>
> >> A well documented well written function can help. The other thing is to
> >> of-course solve this correctly by introducing different locking around
> >> the statistics. Are you suggesting the later?
> >>
> >
> > No. As I wrote.
> >        - don't modify codes around FILE_MAPPED in this series.
> >        - add a new functions for new statistics
> > Then,
> >        - think about clean up later, after we confirm all things work as expected.
> 
> I have ported Andrea Righi's memcg dirty page accounting patches to latest
> mmtom-2010-04-05-16-09.  In doing so I have to address this locking issue.  Does
> the following look good?  I will (of course) submit the entire patch for review,
> but I wanted make sure I was aiming in the right direction.
> 
> void mem_cgroup_update_page_stat(struct page *page,
> 			enum mem_cgroup_write_page_stat_item idx, bool charge)
> {
> 	static int seq;
> 	struct page_cgroup *pc;
> 
> 	if (mem_cgroup_disabled())
> 		return;
> 	pc = lookup_page_cgroup(page);
> 	if (!pc || mem_cgroup_is_root(pc->mem_cgroup))
> 		return;
> 
> 	/*
> 	 * This routine does not disable irq when updating stats.  So it is
> 	 * possible that a stat update from within interrupt routine, could
> 	 * deadlock.  Use trylock_page_cgroup() to avoid such deadlock.  This
> 	 * makes the memcg counters fuzzy.  More complicated, or lower
> 	 * performing locking solutions avoid this fuzziness, but are not
> 	 * currently needed.
> 	 */
> 	if (irqs_disabled()) {
> 		if (! trylock_page_cgroup(pc))
> 			return;

Since this is just stats can we used deferred updates?
        else
                update a deferred structure

> 	} else
> 		lock_page_cgroup(pc);
> 
> 	__mem_cgroup_update_page_stat(pc, idx, charge);

Do charging + any deferred charges pending in
__mem_cgroup_update_page_stat().

> 	unlock_page_cgroup(pc);
> }
> 
> __mem_cgroup_update_page_stat() has a switch statement that updates all of the
> MEMCG_NR_FILE_{MAPPED,DIRTY,WRITEBACK,WRITEBACK_TEMP,UNSTABLE_NFS} counters
> using the following form:
> 	switch (idx) {
> 	case MEMCG_NR_FILE_MAPPED:
> 		if (charge) {
> 			if (!PageCgroupFileMapped(pc))
> 				SetPageCgroupFileMapped(pc);
> 			else
> 				val = 0;
> 		} else {
> 			if (PageCgroupFileMapped(pc))
> 				ClearPageCgroupFileMapped(pc);
> 			else
> 				val = 0;
> 		}
> 		idx = MEM_CGROUP_STAT_FILE_MAPPED;
> 		break;
> 
> 		...
> 	}
> 
> 	/*
> 	 * Preemption is already disabled. We can use __this_cpu_xxx
> 	 */
> 	if (val > 0) {
> 		__this_cpu_inc(mem->stat->count[idx]);
> 	} else if (val < 0) {
> 		__this_cpu_dec(mem->stat->count[idx]);
> 	}
> 
> In my current tree, irq is never saved/restored by cgroup locking code.  To
> protect against interrupt reentrancy, trylock_page_cgroup() is used.  As the
> comment indicates, this makes the new counters fuzzy.
> 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
