Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6BBB96B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 22:48:32 -0400 (EDT)
Date: Thu, 15 Apr 2010 11:40:22 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Message-Id: <20100415114022.ef01b704.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <xr9339yxyepc.fsf@ninji.mtv.corp.google.com>
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
	<20100414140523.GC13535@redhat.com>
	<xr9339yxyepc.fsf@ninji.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Andrea Righi <arighi@develer.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Apr 2010 13:14:07 -0700, Greg Thelen <gthelen@google.com> wrote:
> Vivek Goyal <vgoyal@redhat.com> writes:
> 
> > On Tue, Apr 13, 2010 at 11:55:12PM -0700, Greg Thelen wrote:
> >> On Thu, Mar 18, 2010 at 8:00 PM, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> > On Fri, 19 Mar 2010 08:10:39 +0530
> >> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >> >
> >> >> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-19 10:23:32]:
> >> >>
> >> >> > On Thu, 18 Mar 2010 21:58:55 +0530
> >> >> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >> >> >
> >> >> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-18 13:35:27]:
> >> >> >
> >> >> > > > Then, no probelm. It's ok to add mem_cgroup_udpate_stat() indpendent from
> >> >> > > > mem_cgroup_update_file_mapped(). The look may be messy but it's not your
> >> >> > > > fault. But please write "why add new function" to patch description.
> >> >> > > >
> >> >> > > > I'm sorry for wasting your time.
> >> >> > >
> >> >> > > Do we need to go down this route? We could check the stat and do the
> >> >> > > correct thing. In case of FILE_MAPPED, always grab page_cgroup_lock
> >> >> > > and for others potentially look at trylock. It is OK for different
> >> >> > > stats to be protected via different locks.
> >> >> > >
> >> >> >
> >> >> > I _don't_ want to see a mixture of spinlock and trylock in a function.
> >> >> >
> >> >>
> >> >> A well documented well written function can help. The other thing is to
> >> >> of-course solve this correctly by introducing different locking around
> >> >> the statistics. Are you suggesting the later?
> >> >>
> >> >
> >> > No. As I wrote.
> >> > A  A  A  A - don't modify codes around FILE_MAPPED in this series.
> >> > A  A  A  A - add a new functions for new statistics
> >> > Then,
> >> > A  A  A  A - think about clean up later, after we confirm all things work as expected.
> >> 
> >> I have ported Andrea Righi's memcg dirty page accounting patches to latest
> >> mmtom-2010-04-05-16-09.  In doing so I have to address this locking issue.  Does
> >> the following look good?  I will (of course) submit the entire patch for review,
> >> but I wanted make sure I was aiming in the right direction.
> >> 
> >> void mem_cgroup_update_page_stat(struct page *page,
> >> 			enum mem_cgroup_write_page_stat_item idx, bool charge)
> >> {
> >> 	static int seq;
> >> 	struct page_cgroup *pc;
> >> 
> >> 	if (mem_cgroup_disabled())
> >> 		return;
> >> 	pc = lookup_page_cgroup(page);
> >> 	if (!pc || mem_cgroup_is_root(pc->mem_cgroup))
> >> 		return;
> >> 
> >> 	/*
> >> 	 * This routine does not disable irq when updating stats.  So it is
> >> 	 * possible that a stat update from within interrupt routine, could
> >> 	 * deadlock.  Use trylock_page_cgroup() to avoid such deadlock.  This
> >> 	 * makes the memcg counters fuzzy.  More complicated, or lower
> >> 	 * performing locking solutions avoid this fuzziness, but are not
> >> 	 * currently needed.
> >> 	 */
> >> 	if (irqs_disabled()) {
> >             ^^^^^^^^^
> > Or may be in_interrupt()?
> 
> Good catch.  I will replace irqs_disabled() with in_interrupt().
> 
I think you should check both. __remove_from_page_cache(), which will update
DIRTY, is called with irq disabled(iow, under mapping->tree_lock) but not in
interrupt context.

Anyway, I tend to agree with KAMEZAWA-san: use trylock always(except for FILE_MAPPED),
or add some new interfaces(e.g. mem_cgroup_update_stat_locked/safe...).

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
