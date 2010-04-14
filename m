Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 759006B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 15:32:59 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
References: <20100317115855.GS18054@balbir.in.ibm.com>
	<20100318085411.834e1e46.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318041944.GA18054@balbir.in.ibm.com>
	<20100318133527.420b2f25.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318162855.GG18054@balbir.in.ibm.com>
	<20100319102332.f1d81c8d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100319024039.GH18054@balbir.in.ibm.com>
	<20100319120049.3dbf8440.kamezawa.hiroyu@jp.fujitsu.com>
	<xr931veiplpr.fsf@ninji.mtv.corp.google.com>
	<20100414182904.2f72a63d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100414140430.GB13535@redhat.com>
Date: Wed, 14 Apr 2010 12:31:59 -0700
In-Reply-To: <20100414140430.GB13535@redhat.com> (Vivek Goyal's message of
	"Wed, 14 Apr 2010 10:04:30 -0400")
Message-ID: <xr93k4s9ygnk.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Vivek Goyal <vgoyal@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Andrea Righi <arighi@develer.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Vivek Goyal <vgoyal@redhat.com> writes:

> On Wed, Apr 14, 2010 at 06:29:04PM +0900, KAMEZAWA Hiroyuki wrote:
>> On Tue, 13 Apr 2010 23:55:12 -0700
>> Greg Thelen <gthelen@google.com> wrote:
>>=20
>> > On Thu, Mar 18, 2010 at 8:00 PM, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp=
.fujitsu.com> wrote:
>> > > On Fri, 19 Mar 2010 08:10:39 +0530
>> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> > >
>> > >> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-19 10=
:23:32]:
>> > >>
>> > >> > On Thu, 18 Mar 2010 21:58:55 +0530
>> > >> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> > >> >
>> > >> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-1=
8 13:35:27]:
>> > >> >
>> > >> > > > Then, no probelm. It's ok to add mem_cgroup_udpate_stat() ind=
pendent from
>> > >> > > > mem_cgroup_update_file_mapped(). The look may be messy but it=
's not your
>> > >> > > > fault. But please write "why add new function" to patch descr=
iption.
>> > >> > > >
>> > >> > > > I'm sorry for wasting your time.
>> > >> > >
>> > >> > > Do we need to go down this route? We could check the stat and d=
o the
>> > >> > > correct thing. In case of FILE_MAPPED, always grab page_cgroup_=
lock
>> > >> > > and for others potentially look at trylock. It is OK for differ=
ent
>> > >> > > stats to be protected via different locks.
>> > >> > >
>> > >> >
>> > >> > I _don't_ want to see a mixture of spinlock and trylock in a func=
tion.
>> > >> >
>> > >>
>> > >> A well documented well written function can help. The other thing i=
s to
>> > >> of-course solve this correctly by introducing different locking aro=
und
>> > >> the statistics. Are you suggesting the later?
>> > >>
>> > >
>> > > No. As I wrote.
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0- don't modify codes around FILE_MAPPED i=
n this series.
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0- add a new functions for new statistics
>> > > Then,
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0- think about clean up later, after we co=
nfirm all things work as expected.
>> >=20
>> > I have ported Andrea Righi's memcg dirty page accounting patches to la=
test
>> > mmtom-2010-04-05-16-09.  In doing so I have to address this locking is=
sue.  Does
>> > the following look good?  I will (of course) submit the entire patch f=
or review,
>> > but I wanted make sure I was aiming in the right direction.
>> >=20
>> > void mem_cgroup_update_page_stat(struct page *page,
>> > 			enum mem_cgroup_write_page_stat_item idx, bool charge)
>> > {
>> > 	static int seq;
>> > 	struct page_cgroup *pc;
>> >=20
>> > 	if (mem_cgroup_disabled())
>> > 		return;
>> > 	pc =3D lookup_page_cgroup(page);
>> > 	if (!pc || mem_cgroup_is_root(pc->mem_cgroup))
>> > 		return;
>> >=20
>> > 	/*
>> > 	 * This routine does not disable irq when updating stats.  So it is
>> > 	 * possible that a stat update from within interrupt routine, could
>> > 	 * deadlock.  Use trylock_page_cgroup() to avoid such deadlock.  This
>> > 	 * makes the memcg counters fuzzy.  More complicated, or lower
>> > 	 * performing locking solutions avoid this fuzziness, but are not
>> > 	 * currently needed.
>> > 	 */
>> > 	if (irqs_disabled()) {
>> > 		if (! trylock_page_cgroup(pc))
>> > 			return;
>> > 	} else
>> > 		lock_page_cgroup(pc);
>> >=20
>>=20
>> I prefer trylock_page_cgroup() always.
>>=20
>> I have another idea fixing this up _later_. (But I want to start from si=
mple one.)
>>=20
>> My rough idea is following.  Similar to your idea which you gave me befo=
re.
>>=20
>> =3D=3D
>> DEFINE_PERCPU(account_move_ongoing);
>> DEFINE_MUTEX(move_account_mutex):
>>=20
>> void memcg_start_account_move(void)
>> {
>> 	mutex_lock(&move_account_mutex);
>> 	for_each_online_cpu(cpu)
>> 		per_cpu(cpu, account_move_ongoing) +=3D 1;
>> 	mutex_unlock(&move_account_mutex);
>> 	/* Wait until there are no lockless update */
>> 	synchronize_rcu();
>> 	return;
>> }
>>=20
>> void memcg_end_account_move(void)
>> {
>> 	mutex_lock(&move_account_mutex);
>> 	for_each_online_cpu(cpu)
>> 		per_cpu(cpu, account_move_ongoing) -=3D 1;
>> 	mutex_unlock(&move_account_mutex);
>> }
>>=20
>> /* return 1 when we took lock, return 0 if lockess OPs is guarantedd to =
be safe */
>> int memcg_start_filecache_accounting(struct page_cgroup *pc)
>> {
>> 	rcu_read_lock();
>> 	smp_rmb();
>> 	if (!this_cpu_read(move_account_ongoing))
>> 		return 0; /* no move account is ongoing */
>> 	lock_page_cgroup(pc);
>> 	return 1;
>> }
>>=20
>> void memcg_end_filecache_accounting(struct page_cgroup *pc, int unlock)
>> {
>> 	if (unlock)
>> 		unlock_page_cgroup(pc);
>>=20
>> 	rcu_read_unlock();
>> }
>>=20
>> and call memcg_start_account_move()/end_account_move() in the start/end =
of
>> migrainting chunk of pages.
>
> Hi Kame-san,
>
> May be I am missing something but how does it solve the issue of making s=
ure
> lock_page_cgroup() is not held in interrupt context? IIUC, above code will
> make sure that for file cache accouting, lock_page_cgroup() is taken only
> if task migration is on. But say task migration is on, and then some IO
> completes and we update WRITEBACK stat (i think this is the one which can
> be called from interrupt context), then we will still take the
> lock_page_cgroup() and again run into the issue of deadlocks?
>
> Thanks
> Vivek

I agree. I think the lock/unlock_page_cgrpoup() calls suggested by
Kame-san should also include local_irq_save/restore() calls to prevent
the interrupt context deadlock Vivek describes.  These new
local_irq_save/restore() calls would only be used if
move_account_ongoing is set.  They behave just like the optional calls
to lock/unlock_page_cgroup().

--
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
