Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 136DE6B01EF
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 00:49:22 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o3F4nFrQ014390
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 06:49:15 +0200
Received: from qyk42 (qyk42.prod.google.com [10.241.83.170])
	by wpaz17.hot.corp.google.com with ESMTP id o3F4nDRV004761
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 21:49:14 -0700
Received: by qyk42 with SMTP id 42so1028534qyk.7
        for <linux-mm@kvack.org>; Wed, 14 Apr 2010 21:49:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100415114022.ef01b704.nishimura@mxp.nes.nec.co.jp>
References: <1268609202-15581-2-git-send-email-arighi@develer.com>
	<20100318133527.420b2f25.kamezawa.hiroyu@jp.fujitsu.com> <20100318162855.GG18054@balbir.in.ibm.com>
	<20100319102332.f1d81c8d.kamezawa.hiroyu@jp.fujitsu.com> <20100319024039.GH18054@balbir.in.ibm.com>
	<20100319120049.3dbf8440.kamezawa.hiroyu@jp.fujitsu.com> <xr931veiplpr.fsf@ninji.mtv.corp.google.com>
	<20100414140523.GC13535@redhat.com> <xr9339yxyepc.fsf@ninji.mtv.corp.google.com>
	<20100415114022.ef01b704.nishimura@mxp.nes.nec.co.jp>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 14 Apr 2010 21:48:25 -0700
Message-ID: <g2u49b004811004142148i3db9fefaje1f20760426e0c7e@mail.gmail.com>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Vivek Goyal <vgoyal@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Andrea Righi <arighi@develer.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 7:40 PM, Daisuke Nishimura
<nishimura@mxp.nes.nec.co.jp> wrote:
> On Wed, 14 Apr 2010 13:14:07 -0700, Greg Thelen <gthelen@google.com> wrot=
e:
>> Vivek Goyal <vgoyal@redhat.com> writes:
>>
>> > On Tue, Apr 13, 2010 at 11:55:12PM -0700, Greg Thelen wrote:
>> >> On Thu, Mar 18, 2010 at 8:00 PM, KAMEZAWA Hiroyuki <kamezawa.hiroyu@j=
p.fujitsu.com> wrote:
>> >> > On Fri, 19 Mar 2010 08:10:39 +0530
>> >> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> >> >
>> >> >> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-19 1=
0:23:32]:
>> >> >>
>> >> >> > On Thu, 18 Mar 2010 21:58:55 +0530
>> >> >> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> >> >> >
>> >> >> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-=
18 13:35:27]:
>> >> >> >
>> >> >> > > > Then, no probelm. It's ok to add mem_cgroup_udpate_stat() in=
dpendent from
>> >> >> > > > mem_cgroup_update_file_mapped(). The look may be messy but i=
t's not your
>> >> >> > > > fault. But please write "why add new function" to patch desc=
ription.
>> >> >> > > >
>> >> >> > > > I'm sorry for wasting your time.
>> >> >> > >
>> >> >> > > Do we need to go down this route? We could check the stat and =
do the
>> >> >> > > correct thing. In case of FILE_MAPPED, always grab page_cgroup=
_lock
>> >> >> > > and for others potentially look at trylock. It is OK for diffe=
rent
>> >> >> > > stats to be protected via different locks.
>> >> >> > >
>> >> >> >
>> >> >> > I _don't_ want to see a mixture of spinlock and trylock in a fun=
ction.
>> >> >> >
>> >> >>
>> >> >> A well documented well written function can help. The other thing =
is to
>> >> >> of-course solve this correctly by introducing different locking ar=
ound
>> >> >> the statistics. Are you suggesting the later?
>> >> >>
>> >> >
>> >> > No. As I wrote.
>> >> > =A0 =A0 =A0 =A0- don't modify codes around FILE_MAPPED in this seri=
es.
>> >> > =A0 =A0 =A0 =A0- add a new functions for new statistics
>> >> > Then,
>> >> > =A0 =A0 =A0 =A0- think about clean up later, after we confirm all t=
hings work as expected.
>> >>
>> >> I have ported Andrea Righi's memcg dirty page accounting patches to l=
atest
>> >> mmtom-2010-04-05-16-09. =A0In doing so I have to address this locking=
 issue. =A0Does
>> >> the following look good? =A0I will (of course) submit the entire patc=
h for review,
>> >> but I wanted make sure I was aiming in the right direction.
>> >>
>> >> void mem_cgroup_update_page_stat(struct page *page,
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum mem_cgroup_write_page_sta=
t_item idx, bool charge)
>> >> {
>> >> =A0 =A0static int seq;
>> >> =A0 =A0struct page_cgroup *pc;
>> >>
>> >> =A0 =A0if (mem_cgroup_disabled())
>> >> =A0 =A0 =A0 =A0 =A0 =A0return;
>> >> =A0 =A0pc =3D lookup_page_cgroup(page);
>> >> =A0 =A0if (!pc || mem_cgroup_is_root(pc->mem_cgroup))
>> >> =A0 =A0 =A0 =A0 =A0 =A0return;
>> >>
>> >> =A0 =A0/*
>> >> =A0 =A0 * This routine does not disable irq when updating stats. =A0S=
o it is
>> >> =A0 =A0 * possible that a stat update from within interrupt routine, =
could
>> >> =A0 =A0 * deadlock. =A0Use trylock_page_cgroup() to avoid such deadlo=
ck. =A0This
>> >> =A0 =A0 * makes the memcg counters fuzzy. =A0More complicated, or low=
er
>> >> =A0 =A0 * performing locking solutions avoid this fuzziness, but are =
not
>> >> =A0 =A0 * currently needed.
>> >> =A0 =A0 */
>> >> =A0 =A0if (irqs_disabled()) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 ^^^^^^^^^
>> > Or may be in_interrupt()?
>>
>> Good catch. =A0I will replace irqs_disabled() with in_interrupt().
>>
> I think you should check both. __remove_from_page_cache(), which will upd=
ate
> DIRTY, is called with irq disabled(iow, under mapping->tree_lock) but not=
 in
> interrupt context.

The only reason to use trylock in this case is to prevent deadlock
when running in a context that may have preempted or interrupted a
routine that already holds the bit locked.  In the
__remove_from_page_cache() irqs are disabled, but that does not imply
that a routine holding the spinlock has been preempted.  When the bit
is locked, preemption is disabled.  The only way to interrupt a holder
of the bit for an interrupt to occur (I/O, timer, etc).  So I think
that in_interrupt() is sufficient.  Am I missing something?

> Anyway, I tend to agree with KAMEZAWA-san: use trylock always(except for =
FILE_MAPPED),
> or add some new interfaces(e.g. mem_cgroup_update_stat_locked/safe...).

Thank you for the input.  I'm thinking more on this.

--
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
