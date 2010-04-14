Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B46296B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 05:33:10 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3E9X5bI027526
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 14 Apr 2010 18:33:05 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BA2D45DE60
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 18:33:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EC6F845DE4D
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 18:33:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D87251DB803F
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 18:33:04 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C5BA1DB8037
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 18:33:04 +0900 (JST)
Date: Wed, 14 Apr 2010 18:29:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Message-Id: <20100414182904.2f72a63d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <xr931veiplpr.fsf@ninji.mtv.corp.google.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
	<1268609202-15581-2-git-send-email-arighi@develer.com>
	<20100317115855.GS18054@balbir.in.ibm.com>
	<20100318085411.834e1e46.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318041944.GA18054@balbir.in.ibm.com>
	<20100318133527.420b2f25.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318162855.GG18054@balbir.in.ibm.com>
	<20100319102332.f1d81c8d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100319024039.GH18054@balbir.in.ibm.com>
	<20100319120049.3dbf8440.kamezawa.hiroyu@jp.fujitsu.com>
	<xr931veiplpr.fsf@ninji.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: balbir@linux.vnet.ibm.com, Andrea Righi <arighi@develer.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Apr 2010 23:55:12 -0700
Greg Thelen <gthelen@google.com> wrote:

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
> > A  A  A  A - don't modify codes around FILE_MAPPED in this series.
> > A  A  A  A - add a new functions for new statistics
> > Then,
> > A  A  A  A - think about clean up later, after we confirm all things work as expected.
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
> 	} else
> 		lock_page_cgroup(pc);
> 

I prefer trylock_page_cgroup() always.

I have another idea fixing this up _later_. (But I want to start from simple one.)

My rough idea is following.  Similar to your idea which you gave me before.

==
DEFINE_PERCPU(account_move_ongoing);
DEFINE_MUTEX(move_account_mutex):

void memcg_start_account_move(void)
{
	mutex_lock(&move_account_mutex);
	for_each_online_cpu(cpu)
		per_cpu(cpu, account_move_ongoing) += 1;
	mutex_unlock(&move_account_mutex);
	/* Wait until there are no lockless update */
	synchronize_rcu();
	return;
}

void memcg_end_account_move(void)
{
	mutex_lock(&move_account_mutex);
	for_each_online_cpu(cpu)
		per_cpu(cpu, account_move_ongoing) -= 1;
	mutex_unlock(&move_account_mutex);
}

/* return 1 when we took lock, return 0 if lockess OPs is guarantedd to be safe */
int memcg_start_filecache_accounting(struct page_cgroup *pc)
{
	rcu_read_lock();
	smp_rmb();
	if (!this_cpu_read(move_account_ongoing))
		return 0; /* no move account is ongoing */
	lock_page_cgroup(pc);
	return 1;
}

void memcg_end_filecache_accounting(struct page_cgroup *pc, int unlock)
{
	if (unlock)
		unlock_page_cgroup(pc);

	rcu_read_unlock();
}

and call memcg_start_account_move()/end_account_move() in the start/end of
migrainting chunk of pages.

Bye.
-Kame




















--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
