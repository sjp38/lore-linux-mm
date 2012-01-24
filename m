Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 1C1C06B004F
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 14:04:18 -0500 (EST)
Received: by qadc11 with SMTP id c11so422458qad.14
        for <linux-mm@kvack.org>; Tue, 24 Jan 2012 11:04:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120123090436.GA12375@tiehlicka.suse.cz>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
	<20120113173347.6231f510.kamezawa.hiroyu@jp.fujitsu.com>
	<20120117152635.GA22142@tiehlicka.suse.cz>
	<20120118090656.83268b3e.kamezawa.hiroyu@jp.fujitsu.com>
	<20120118123759.GB31112@tiehlicka.suse.cz>
	<20120119111727.6337bde4.kamezawa.hiroyu@jp.fujitsu.com>
	<CALWz4iz59=-J+cif+XickXBG3zUSy58yHhkX6j3zbJyBXGzpYw@mail.gmail.com>
	<20120123090436.GA12375@tiehlicka.suse.cz>
Date: Tue, 24 Jan 2012 11:04:16 -0800
Message-ID: <CALWz4iyaWtes=aU79DAbEfBsNUTaHKLK5HZbNfShaxgC8UX_TQ@mail.gmail.com>
Subject: Re: [RFC] [PATCH 2/7 v2] memcg: add memory barrier for checking
 account move.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Mon, Jan 23, 2012 at 1:04 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Fri 20-01-12 10:08:44, Ying Han wrote:
>> On Wed, Jan 18, 2012 at 6:17 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Wed, 18 Jan 2012 13:37:59 +0100
>> > Michal Hocko <mhocko@suse.cz> wrote:
>> >
>> >> On Wed 18-01-12 09:06:56, KAMEZAWA Hiroyuki wrote:
>> >> > On Tue, 17 Jan 2012 16:26:35 +0100
>> >> > Michal Hocko <mhocko@suse.cz> wrote:
>> >> >
>> >> > > On Fri 13-01-12 17:33:47, KAMEZAWA Hiroyuki wrote:
>> >> > > > I think this bugfix is needed before going ahead. thoughts?
>> >> > > > =3D=3D
>> >> > > > From 2cb491a41782b39aae9f6fe7255b9159ac6c1563 Mon Sep 17 00:00:=
00 2001
>> >> > > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> >> > > > Date: Fri, 13 Jan 2012 14:27:20 +0900
>> >> > > > Subject: [PATCH 2/7] memcg: add memory barrier for checking acc=
ount move.
>> >> > > >
>> >> > > > At starting move_account(), source memcg's per-cpu variable
>> >> > > > MEM_CGROUP_ON_MOVE is set. The page status update
>> >> > > > routine check it under rcu_read_lock(). But there is no memory
>> >> > > > barrier. This patch adds one.
>> >> > >
>> >> > > OK this would help to enforce that the CPU would see the current =
value
>> >> > > but what prevents us from the race with the value update without =
the
>> >> > > lock? This is as racy as it was before AFAICS.
>> >> > >
>> >> >
>> >> > Hm, do I misunderstand ?
>> >> > =3D=3D
>> >> > =A0 =A0update =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reference
>> >> >
>> >> > =A0 =A0CPU A =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0CPU B
>> >> > =A0 set value =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_read_lock()
>> >> > =A0 smp_wmb() =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0smp_rmb()
>> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0read_value
>> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_read_unl=
ock()
>> >> > =A0 synchronize_rcu().
>> >> > =3D=3D
>> >> > I expect
>> >> > If synchronize_rcu() is called before rcu_read_lock() =3D> move_loc=
k_xxx will be held.
>> >> > If synchronize_rcu() is called after rcu_read_lock() =3D> update wi=
ll be delayed.
>> >>
>> >> Ahh, OK I can see it now. Readers are not that important because it i=
s
>> >> actually the updater who is delayed until all preexisting rcu read
>> >> sections are finished.
>> >>
>> >> In that case. Why do we need both barriers? spin_unlock is a full
>> >> barrier so maybe we just need smp_rmb before we read value to make su=
re
>> >> that we do not get stalled value when we start rcu_read section after
>> >> synchronize_rcu?
>> >>
>> >
>> > I doubt .... If no barrier, this case happens
>> >
>> > =3D=3D
>> > =A0 =A0 =A0 =A0update =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reference
>> > =A0 =A0 =A0 =A0CPU A =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 CPU B
>> > =A0 =A0 =A0 =A0set value
>> > =A0 =A0 =A0 =A0synchronize_rcu() =A0 =A0 =A0 rcu_read_lock()
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0read_va=
lue <=3D find old value
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_rea=
d_unlock()
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0do no l=
ock
>> > =3D=3D
>>
>> Hi Kame,
>>
>> Can you help to clarify a bit more on the example above? Why
>> read_value got the old value after synchronize_rcu().
>
> AFAIU it is because rcu_read_unlock doesn't force any memory barrier
> and we synchronize only the updater (with synchronize_rcu), so nothing
> guarantees that the value set on CPUA is visible to CPUB.

Thanks, and i might have found similar comment on the
documentation/rcu/checklist.txt:
"
The various RCU read-side primitives do -not- necessarily contain
memory barriers.
"

So, the read barrier here is to make sure no reordering between the
reader and the rcu_read_lock. The same for the write barrier which
makes sure no reordering between the updater and synchronize_rcu. The
the rcu here is to synchronize between the updater and reader. If so,
why not the change like :

       for_each_online_cpu(cpu)
               per_cpu(memcg->stat->count[MEM_CGROUP_ON_MOVE], cpu) +=3D 1;
+      smp_wmb();

Sorry, the use of per-cpu variable MEM_CGROUP_ON_MOVE does confuse me.

--Ying
>
> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
