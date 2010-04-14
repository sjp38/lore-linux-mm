Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 14A296B01F2
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 12:23:09 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id o3EGN3qh012086
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 18:23:05 +0200
Received: from qyk1 (qyk1.prod.google.com [10.241.83.129])
	by kpbe13.cbf.corp.google.com with ESMTP id o3EGMuZW017239
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 11:23:02 -0500
Received: by qyk1 with SMTP id 1so354619qyk.15
        for <linux-mm@kvack.org>; Wed, 14 Apr 2010 09:23:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100414182904.2f72a63d.kamezawa.hiroyu@jp.fujitsu.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
	<20100318085411.834e1e46.kamezawa.hiroyu@jp.fujitsu.com> <20100318041944.GA18054@balbir.in.ibm.com>
	<20100318133527.420b2f25.kamezawa.hiroyu@jp.fujitsu.com> <20100318162855.GG18054@balbir.in.ibm.com>
	<20100319102332.f1d81c8d.kamezawa.hiroyu@jp.fujitsu.com> <20100319024039.GH18054@balbir.in.ibm.com>
	<20100319120049.3dbf8440.kamezawa.hiroyu@jp.fujitsu.com> <xr931veiplpr.fsf@ninji.mtv.corp.google.com>
	<20100414182904.2f72a63d.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 14 Apr 2010 09:22:41 -0700
Message-ID: <p2k49b004811004140922v8b6c4c57j2dd435261ff2dd43@mail.gmail.com>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Andrea Righi <arighi@develer.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 2:29 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 13 Apr 2010 23:55:12 -0700
> Greg Thelen <gthelen@google.com> wrote:
>> On Thu, Mar 18, 2010 at 8:00 PM, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.f=
ujitsu.com> wrote:
>> > On Fri, 19 Mar 2010 08:10:39 +0530
>> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> >> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-19 10:2=
3:32]:
>> >>
>> >> > On Thu, 18 Mar 2010 21:58:55 +0530
>> >> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> >> >
>> >> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-18 =
13:35:27]:
>> >> >
>> >> > > > Then, no probelm. It's ok to add mem_cgroup_udpate_stat() indpe=
ndent from
>> >> > > > mem_cgroup_update_file_mapped(). The look may be messy but it's=
 not your
>> >> > > > fault. But please write "why add new function" to patch descrip=
tion.
>> >> > > >
>> >> > > > I'm sorry for wasting your time.
>> >> > >
>> >> > > Do we need to go down this route? We could check the stat and do =
the
>> >> > > correct thing. In case of FILE_MAPPED, always grab page_cgroup_lo=
ck
>> >> > > and for others potentially look at trylock. It is OK for differen=
t
>> >> > > stats to be protected via different locks.
>> >> > >
>> >> >
>> >> > I _don't_ want to see a mixture of spinlock and trylock in a functi=
on.
>> >> >
>> >>
>> >> A well documented well written function can help. The other thing is =
to
>> >> of-course solve this correctly by introducing different locking aroun=
d
>> >> the statistics. Are you suggesting the later?
>> >>
>> >
>> > No. As I wrote.
>> > =A0 =A0 =A0 =A0- don't modify codes around FILE_MAPPED in this series.
>> > =A0 =A0 =A0 =A0- add a new functions for new statistics
>> > Then,
>> > =A0 =A0 =A0 =A0- think about clean up later, after we confirm all thin=
gs work as expected.
>>
>> I have ported Andrea Righi's memcg dirty page accounting patches to late=
st
>> mmtom-2010-04-05-16-09. =A0In doing so I have to address this locking is=
sue. =A0Does
>> the following look good? =A0I will (of course) submit the entire patch f=
or review,
>> but I wanted make sure I was aiming in the right direction.
>>
>> void mem_cgroup_update_page_stat(struct page *page,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum mem_cgroup_write_page_s=
tat_item idx, bool charge)
>> {
>> =A0 =A0 =A0 static int seq;
>> =A0 =A0 =A0 struct page_cgroup *pc;
>>
>> =A0 =A0 =A0 if (mem_cgroup_disabled())
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);
>> =A0 =A0 =A0 if (!pc || mem_cgroup_is_root(pc->mem_cgroup))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>>
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* This routine does not disable irq when updating stats. =
=A0So it is
>> =A0 =A0 =A0 =A0* possible that a stat update from within interrupt routi=
ne, could
>> =A0 =A0 =A0 =A0* deadlock. =A0Use trylock_page_cgroup() to avoid such de=
adlock. =A0This
>> =A0 =A0 =A0 =A0* makes the memcg counters fuzzy. =A0More complicated, or=
 lower
>> =A0 =A0 =A0 =A0* performing locking solutions avoid this fuzziness, but =
are not
>> =A0 =A0 =A0 =A0* currently needed.
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 if (irqs_disabled()) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (! trylock_page_cgroup(pc))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> =A0 =A0 =A0 } else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_page_cgroup(pc);
>>
>
> I prefer trylock_page_cgroup() always.

What is your reason for preferring trylock_page_cgroup()?  I assume
it's for code simplicity, but I wanted to check.

I had though about using trylock_page_cgroup() always, but I think
that would make file_mapped accounting even more fuzzy that it already
it is.  I was trying to retain the current accuracy of file_mapped and
only make new counters, like writeback/dirty/etc (those obtained in
interrupt), fuzzy.

> I have another idea fixing this up _later_. (But I want to start from sim=
ple one.)
>
> My rough idea is following. =A0Similar to your idea which you gave me bef=
ore.

Hi Kame-san,

I like the general approach.  The code I previously gave you appears
to work and is faster than non-root memcgs using mmotm due to mostly
being lockless.

> =3D=3D
> DEFINE_PERCPU(account_move_ongoing);

What's the reason for having a per-cpu account_move_ongoing flag?
Would a single system-wide global be sufficient?  I assume the
majority of the time this value will not be changing because
accounting moves are rare.

Perhaps all of the per-cpu variables are packed within a per-cpu
cacheline making accessing it more likely to be local, but I'm not
sure if this is true.

--
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
