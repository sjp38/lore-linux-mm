Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4361A6B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 10:05:06 -0400 (EDT)
Date: Wed, 14 Apr 2010 10:04:30 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Message-ID: <20100414140430.GB13535@redhat.com>
References: <20100317115855.GS18054@balbir.in.ibm.com> <20100318085411.834e1e46.kamezawa.hiroyu@jp.fujitsu.com> <20100318041944.GA18054@balbir.in.ibm.com> <20100318133527.420b2f25.kamezawa.hiroyu@jp.fujitsu.com> <20100318162855.GG18054@balbir.in.ibm.com> <20100319102332.f1d81c8d.kamezawa.hiroyu@jp.fujitsu.com> <20100319024039.GH18054@balbir.in.ibm.com> <20100319120049.3dbf8440.kamezawa.hiroyu@jp.fujitsu.com> <xr931veiplpr.fsf@ninji.mtv.corp.google.com> <20100414182904.2f72a63d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100414182904.2f72a63d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Greg Thelen <gthelen@google.com>, balbir@linux.vnet.ibm.com, Andrea Righi <arighi@develer.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 06:29:04PM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 13 Apr 2010 23:55:12 -0700
> Greg Thelen <gthelen@google.com> wrote:
> 
> > On Thu, Mar 18, 2010 at 8:00 PM, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > On Fri, 19 Mar 2010 08:10:39 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > >
> > >> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-19 10:23:32]:
> > >>
> > >> > On Thu, 18 Mar 2010 21:58:55 +0530
> > >> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > >> >
> > >> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-18 13:35:27]:
> > >> >
> > >> > > > Then, no probelm. It's ok to add mem_cgroup_udpate_stat() indpendent from
> > >> > > > mem_cgroup_update_file_mapped(). The look may be messy but it's not your
> > >> > > > fault. But please write "why add new function" to patch description.
> > >> > > >
> > >> > > > I'm sorry for wasting your time.
> > >> > >
> > >> > > Do we need to go down this route? We could check the stat and do the
> > >> > > correct thing. In case of FILE_MAPPED, always grab page_cgroup_lock
> > >> > > and for others potentially look at trylock. It is OK for different
> > >> > > stats to be protected via different locks.
> > >> > >
> > >> >
> > >> > I _don't_ want to see a mixture of spinlock and trylock in a function.
> > >> >
> > >>
> > >> A well documented well written function can help. The other thing is to
> > >> of-course solve this correctly by introducing different locking around
> > >> the statistics. Are you suggesting the later?
> > >>
> > >
> > > No. As I wrote.
> > >        - don't modify codes around FILE_MAPPED in this series.
> > >        - add a new functions for new statistics
> > > Then,
> > >        - think about clean up later, after we confirm all things work as expected.
> > 
> > I have ported Andrea Righi's memcg dirty page accounting patches to latest
> > mmtom-2010-04-05-16-09.  In doing so I have to address this locking issue.  Does
> > the following look good?  I will (of course) submit the entire patch for review,
> > but I wanted make sure I was aiming in the right direction.
> > 
> > void mem_cgroup_update_page_stat(struct page *page,
> > 			enum mem_cgroup_write_page_stat_item idx, bool charge)
> > {
> > 	static int seq;
> > 	struct page_cgroup *pc;
> > 
> > 	if (mem_cgroup_disabled())
> > 		return;
> > 	pc = lookup_page_cgroup(page);
> > 	if (!pc || mem_cgroup_is_root(pc->mem_cgroup))
> > 		return;
> > 
> > 	/*
> > 	 * This routine does not disable irq when updating stats.  So it is
> > 	 * possible that a stat update from within interrupt routine, could
> > 	 * deadlock.  Use trylock_page_cgroup() to avoid such deadlock.  This
> > 	 * makes the memcg counters fuzzy.  More complicated, or lower
> > 	 * performing locking solutions avoid this fuzziness, but are not
> > 	 * currently needed.
> > 	 */
> > 	if (irqs_disabled()) {
> > 		if (! trylock_page_cgroup(pc))
> > 			return;
> > 	} else
> > 		lock_page_cgroup(pc);
> > 
> 
> I prefer trylock_page_cgroup() always.
> 
> I have another idea fixing this up _later_. (But I want to start from simple one.)
> 
> My rough idea is following.  Similar to your idea which you gave me before.
> 
> ==
> DEFINE_PERCPU(account_move_ongoing);
> DEFINE_MUTEX(move_account_mutex):
> 
> void memcg_start_account_move(void)
> {
> 	mutex_lock(&move_account_mutex);
> 	for_each_online_cpu(cpu)
> 		per_cpu(cpu, account_move_ongoing) += 1;
> 	mutex_unlock(&move_account_mutex);
> 	/* Wait until there are no lockless update */
> 	synchronize_rcu();
> 	return;
> }
> 
> void memcg_end_account_move(void)
> {
> 	mutex_lock(&move_account_mutex);
> 	for_each_online_cpu(cpu)
> 		per_cpu(cpu, account_move_ongoing) -= 1;
> 	mutex_unlock(&move_account_mutex);
> }
> 
> /* return 1 when we took lock, return 0 if lockess OPs is guarantedd to be safe */
> int memcg_start_filecache_accounting(struct page_cgroup *pc)
> {
> 	rcu_read_lock();
> 	smp_rmb();
> 	if (!this_cpu_read(move_account_ongoing))
> 		return 0; /* no move account is ongoing */
> 	lock_page_cgroup(pc);
> 	return 1;
> }
> 
> void memcg_end_filecache_accounting(struct page_cgroup *pc, int unlock)
> {
> 	if (unlock)
> 		unlock_page_cgroup(pc);
> 
> 	rcu_read_unlock();
> }
> 
> and call memcg_start_account_move()/end_account_move() in the start/end of
> migrainting chunk of pages.
> 

Hi Kame-san,

May be I am missing something but how does it solve the issue of making sure
lock_page_cgroup() is not held in interrupt context? IIUC, above code will
make sure that for file cache accouting, lock_page_cgroup() is taken only
if task migration is on. But say task migration is on, and then some IO
completes and we update WRITEBACK stat (i think this is the one which can
be called from interrupt context), then we will still take the
lock_page_cgroup() and again run into the issue of deadlocks?

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
