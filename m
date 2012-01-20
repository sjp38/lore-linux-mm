Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 42F356B004D
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 13:08:46 -0500 (EST)
Received: by qadc11 with SMTP id c11so617881qad.14
        for <linux-mm@kvack.org>; Fri, 20 Jan 2012 10:08:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120119111727.6337bde4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
	<20120113173347.6231f510.kamezawa.hiroyu@jp.fujitsu.com>
	<20120117152635.GA22142@tiehlicka.suse.cz>
	<20120118090656.83268b3e.kamezawa.hiroyu@jp.fujitsu.com>
	<20120118123759.GB31112@tiehlicka.suse.cz>
	<20120119111727.6337bde4.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 20 Jan 2012 10:08:44 -0800
Message-ID: <CALWz4iz59=-J+cif+XickXBG3zUSy58yHhkX6j3zbJyBXGzpYw@mail.gmail.com>
Subject: Re: [RFC] [PATCH 2/7 v2] memcg: add memory barrier for checking
 account move.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Wed, Jan 18, 2012 at 6:17 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 18 Jan 2012 13:37:59 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
>
>> On Wed 18-01-12 09:06:56, KAMEZAWA Hiroyuki wrote:
>> > On Tue, 17 Jan 2012 16:26:35 +0100
>> > Michal Hocko <mhocko@suse.cz> wrote:
>> >
>> > > On Fri 13-01-12 17:33:47, KAMEZAWA Hiroyuki wrote:
>> > > > I think this bugfix is needed before going ahead. thoughts?
>> > > > =3D=3D
>> > > > From 2cb491a41782b39aae9f6fe7255b9159ac6c1563 Mon Sep 17 00:00:00 =
2001
>> > > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> > > > Date: Fri, 13 Jan 2012 14:27:20 +0900
>> > > > Subject: [PATCH 2/7] memcg: add memory barrier for checking accoun=
t move.
>> > > >
>> > > > At starting move_account(), source memcg's per-cpu variable
>> > > > MEM_CGROUP_ON_MOVE is set. The page status update
>> > > > routine check it under rcu_read_lock(). But there is no memory
>> > > > barrier. This patch adds one.
>> > >
>> > > OK this would help to enforce that the CPU would see the current val=
ue
>> > > but what prevents us from the race with the value update without the
>> > > lock? This is as racy as it was before AFAICS.
>> > >
>> >
>> > Hm, do I misunderstand ?
>> > =3D=3D
>> > =A0 =A0update =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reference
>> >
>> > =A0 =A0CPU A =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0CPU B
>> > =A0 set value =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_read_lock()
>> > =A0 smp_wmb() =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0smp_rmb()
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0read_value
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_read_unlock=
()
>> > =A0 synchronize_rcu().
>> > =3D=3D
>> > I expect
>> > If synchronize_rcu() is called before rcu_read_lock() =3D> move_lock_x=
xx will be held.
>> > If synchronize_rcu() is called after rcu_read_lock() =3D> update will =
be delayed.
>>
>> Ahh, OK I can see it now. Readers are not that important because it is
>> actually the updater who is delayed until all preexisting rcu read
>> sections are finished.
>>
>> In that case. Why do we need both barriers? spin_unlock is a full
>> barrier so maybe we just need smp_rmb before we read value to make sure
>> that we do not get stalled value when we start rcu_read section after
>> synchronize_rcu?
>>
>
> I doubt .... If no barrier, this case happens
>
> =3D=3D
> =A0 =A0 =A0 =A0update =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reference
> =A0 =A0 =A0 =A0CPU A =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 CPU B
> =A0 =A0 =A0 =A0set value
> =A0 =A0 =A0 =A0synchronize_rcu() =A0 =A0 =A0 rcu_read_lock()
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0read_value=
 <=3D find old value
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_read_u=
nlock()
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0do no lock
> =3D=3D

Hi Kame,

Can you help to clarify a bit more on the example above? Why
read_value got the old value after synchronize_rcu().

Sorry for getting into this late.

--Ying

Sorry for getting into this late.
>
>> > Here, cpu B needs to read most recently updated value.
>>
>> If it reads the old value then it would think that we are not moving and
>> so we would account to the old group and move it later on, right?
>>
> Right. without move_lock, we're not sure which old/new pc->mem_cgroup wil=
l be.
> This will cause mis accounting.
>
>
> Thanks,
> -Kame
>
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
