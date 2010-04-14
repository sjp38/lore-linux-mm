Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B9015600374
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 02:55:53 -0400 (EDT)
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
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
From: Greg Thelen <gthelen@google.com>
Date: Tue, 13 Apr 2010 23:55:12 -0700
In-Reply-To: <xr93hbnepmj6.fsf@ninji.mtv.corp.google.com> (Greg Thelen's message of "Tue\, 13 Apr 2010 23\:37\:33 -0700")
Message-ID: <xr931veiplpr.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Andrea Righi <arighi@develer.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 18, 2010 at 8:00 PM, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fuji=
tsu.com> wrote:
> On Fri, 19 Mar 2010 08:10:39 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-19 10:23:3=
2]:
>>
>> > On Thu, 18 Mar 2010 21:58:55 +0530
>> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> >
>> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-18 13:=
35:27]:
>> >
>> > > > Then, no probelm. It's ok to add mem_cgroup_udpate_stat() indpende=
nt from
>> > > > mem_cgroup_update_file_mapped(). The look may be messy but it's no=
t your
>> > > > fault. But please write "why add new function" to patch descriptio=
n.
>> > > >
>> > > > I'm sorry for wasting your time.
>> > >
>> > > Do we need to go down this route? We could check the stat and do the
>> > > correct thing. In case of FILE_MAPPED, always grab page_cgroup_lock
>> > > and for others potentially look at trylock. It is OK for different
>> > > stats to be protected via different locks.
>> > >
>> >
>> > I _don't_ want to see a mixture of spinlock and trylock in a function.
>> >
>>
>> A well documented well written function can help. The other thing is to
>> of-course solve this correctly by introducing different locking around
>> the statistics. Are you suggesting the later?
>>
>
> No. As I wrote.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0- don't modify codes around FILE_MAPPED in thi=
s series.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0- add a new functions for new statistics
> Then,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0- think about clean up later, after we confirm=
 all things work as expected.

I have ported Andrea Righi's memcg dirty page accounting patches to latest
mmtom-2010-04-05-16-09.  In doing so I have to address this locking issue. =
 Does
the following look good?  I will (of course) submit the entire patch for re=
view,
but I wanted make sure I was aiming in the right direction.

void mem_cgroup_update_page_stat(struct page *page,
			enum mem_cgroup_write_page_stat_item idx, bool charge)
{
	static int seq;
	struct page_cgroup *pc;

	if (mem_cgroup_disabled())
		return;
	pc =3D lookup_page_cgroup(page);
	if (!pc || mem_cgroup_is_root(pc->mem_cgroup))
		return;

	/*
	 * This routine does not disable irq when updating stats.  So it is
	 * possible that a stat update from within interrupt routine, could
	 * deadlock.  Use trylock_page_cgroup() to avoid such deadlock.  This
	 * makes the memcg counters fuzzy.  More complicated, or lower
	 * performing locking solutions avoid this fuzziness, but are not
	 * currently needed.
	 */
	if (irqs_disabled()) {
		if (! trylock_page_cgroup(pc))
			return;
	} else
		lock_page_cgroup(pc);

	__mem_cgroup_update_page_stat(pc, idx, charge);
	unlock_page_cgroup(pc);
}

__mem_cgroup_update_page_stat() has a switch statement that updates all of =
the
MEMCG_NR_FILE_{MAPPED,DIRTY,WRITEBACK,WRITEBACK_TEMP,UNSTABLE_NFS} counters
using the following form:
	switch (idx) {
	case MEMCG_NR_FILE_MAPPED:
		if (charge) {
			if (!PageCgroupFileMapped(pc))
				SetPageCgroupFileMapped(pc);
			else
				val =3D 0;
		} else {
			if (PageCgroupFileMapped(pc))
				ClearPageCgroupFileMapped(pc);
			else
				val =3D 0;
		}
		idx =3D MEM_CGROUP_STAT_FILE_MAPPED;
		break;

		...
	}

	/*
	 * Preemption is already disabled. We can use __this_cpu_xxx
	 */
	if (val > 0) {
		__this_cpu_inc(mem->stat->count[idx]);
	} else if (val < 0) {
		__this_cpu_dec(mem->stat->count[idx]);
	}

In my current tree, irq is never saved/restored by cgroup locking code.  To
protect against interrupt reentrancy, trylock_page_cgroup() is used.  As the
comment indicates, this makes the new counters fuzzy.

--
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
