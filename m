Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DEFB78D0047
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 01:32:45 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p2U5WgOq012740
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 22:32:43 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by hpaq14.eem.corp.google.com with ESMTP id p2U5WeYm008645
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 22:32:41 -0700
Received: by qyk7 with SMTP id 7so631447qyk.10
        for <linux-mm@kvack.org>; Tue, 29 Mar 2011 22:32:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110329184119.219f7d7b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110328093957.089007035@suse.cz>
	<20110328200332.17fb4b78.kamezawa.hiroyu@jp.fujitsu.com>
	<20110328114430.GE5693@tiehlicka.suse.cz>
	<20110329090924.6a565ef3.kamezawa.hiroyu@jp.fujitsu.com>
	<20110329073232.GB30671@tiehlicka.suse.cz>
	<20110329165117.179d87f9.kamezawa.hiroyu@jp.fujitsu.com>
	<20110329085942.GD30671@tiehlicka.suse.cz>
	<20110329184119.219f7d7b.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 29 Mar 2011 22:32:38 -0700
Message-ID: <BANLkTi=rVBXt0iZPQrbQaG8YtLPA9mJpkQ@mail.gmail.com>
Subject: Re: [RFC 0/3] Implementation of cgroup isolation
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 29, 2011 at 2:41 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 29 Mar 2011 10:59:43 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
>
>> On Tue 29-03-11 16:51:17, KAMEZAWA Hiroyuki wrote:
>> > On Tue, 29 Mar 2011 09:32:32 +0200
>> > Michal Hocko <mhocko@suse.cz> wrote:
>> >
>> > > On Tue 29-03-11 09:09:24, KAMEZAWA Hiroyuki wrote:
>> > > > On Mon, 28 Mar 2011 13:44:30 +0200
>> > > > Michal Hocko <mhocko@suse.cz> wrote:
>> > > >
>> > > > > On Mon 28-03-11 20:03:32, KAMEZAWA Hiroyuki wrote:
>> > > > > > On Mon, 28 Mar 2011 11:39:57 +0200
>> > > > > > Michal Hocko <mhocko@suse.cz> wrote:
>> > > > > [...]
>> > > > > >
>> > > > > > Isn't it the same result with the case where no cgroup is used=
 ?
>> > > > >
>> > > > > Yes and that is the point of the patchset. Memory cgroups will n=
ot give
>> > > > > you anything else but the top limit wrt. to the global memory ac=
tivity.
>> > > > >
>> > > > > > What is the problem ?
>> > > > >
>> > > > > That we cannot prevent from paging out memory of process(es), ev=
en though
>> > > > > we have intentionaly isolated them in a group (read as we do not=
 have
>> > > > > any other possibility for the isolation), because of unrelated m=
emory
>> > > > > activity.
>> > > > >
>> > > > Because the design of memory cgroup is not for "defending" but for
>> > > > "never attack some other guys".
>> > >
>> > > Yes, I am aware of the current state of implementation. But as the
>> > > patchset show there is not quite trivial to implement also the other
>> > > (defending) part.
>> > >
>> >
>> > My opinions is to enhance softlimit is better.
>>
>> I will look how softlimit can be enhanced to match the expectations but
>> I'm kind of suspicious it can handle workloads where heuristics simply
>> cannot guess that the resident memory is important even though it wasn't
>> touched for a long time.
>>
>
> I think we recommend mlock() or hugepagefs to pin application's work area
> in usual. And mm guyes have did hardwork to work mm better even without
> memory cgroup under realisitic workloads.
>
> If your worload is realistic but _important_ anonymous memory is swapped =
out,
> it's problem of global VM rather than memcg.
>
> If you add 'isolate' per process, okay, I'll agree to add isolate per mem=
cg.
>
>
>
>> > > > > > Why it's not a problem of configuration ?
>> > > > > > IIUC, you can put all logins to some cgroup by using cgroupd/l=
ibgcgroup.
>> > > > >
>> > > > > Yes, but this still doesn't bring the isolation.
>> > > > >
>> > > >
>> > > > Please explain this more.
>> > > > Why don't you move all tasks under /root/default <- this has some =
limit ?
>> > >
>> > > OK, I have tried to explain that in one of the (2nd) patch descripti=
on.
>> > > If I move all task from the root group to other group(s) and keep th=
e
>> > > primary application in the root group I would achieve some isolation=
 as
>> > > well. That is very much true.
>> >
>> > Okay, then, current works well.
>> >
>> > > But then there is only one such a group.
>> >
>> > I can't catch what you mean. you can create limitless cgroup, anywhere=
.
>> > Can't you ?
>>
>> This is not about limits. This is about global vs. per-cgroup reclaim
>> and how much they interact together.
>>
>> The everything-in-groups approach with the "primary" service in the root
>> group (or call it unlimited) works just because all the memory activity
>> (but the primary service) is caped with the limits so the rest of the
>> memory can be used by the service. Moreover, in order this to work the
>> limit for other groups would be smaller then the working set of the
>> primary service.
>>
>> Even if you created a limitless group for other important service they
>> would still interact together and if one goes wild the other would
>> suffer from that.
>>
>
> .........I can't understad what is the problem when global reclaim
> runs just because an application wasn't limited ...or memory are
> overcomitted.

I guess the problem here is not triggering global reclaim, but more of
what is the expected output of it. We can not prevent global memory
pressure from happening in over-commit environment, however we should
do targeting reclaim only when that happens.

Hopefully an example helps explaining the problem we are trying to solve he=
re.

Here is the current supported mechanism on memcg limits:
1. limit_in_bytes:
If the usage_in_bytes goes over the limit, the memcg get throttled or
OOM killed.

2. soft_limit_in_bytes:
If the usage_in_bytes goes over the limit, the memory are
best_efforts. Otherwise, no memory pressure is expected in the memcg.
This serves as "guarantee" in some sense.

Here is the configuration memcg users might consider:
On a host with 32G ram, we would like to over-committing the machine
but also provide guarantees to individual memcg.

memcg-A/ -- limit_in_bytes =3D 20G, soft_limit_in_bytes =3D  15G
memcg-B/ -- limit_in_bytes =3D 20G, soft_limit_in_bytes =3D 15G

The expectation of this configuration is:
a) Either memcg-A or memcg-B can grow usage_in_bytes up to 20G as long
as there is no system memory contention.
b) Both memcg-A and memcg-B have memory guarantee of 15G, and there
shouldn't be memory pressure applied if usage_in_bytes below the
value.
c) If there is a global memory pressure, whoever allocate memory above
the guarantee (soft_limit) need to push pages out.
d) Either memcg-A or memcg-B will be throttled or OOM killed if the
usage_in_bytes goes above the limit_in_bytes.

In order to achieve that, we need the following:
a) Improve the current soft_limit reclaim mechanism. Right now it is
designed to be best-effort working with global background reclaim. I
can easily generate scenario where it is not picking the "right"
cgroup to reclaim from each time. ("right" here stands for the
efficiency of the reclaim)

b) When the global reclaim happens (both background and ttfp), we need
to rely on soft_limit targeting reclaim instead of picking page on
global lru. The later one just blindly throw pages away regardless of
the configuration of cgroup. In this case, the configuration means
"guarantee".

c) Of course, we will have per-memcg background reclaim patch. It will
do more targeting reclaim proactively before the global memory
contention.

Overall, I don't see why we should scan the global LRU, especially
after the things above being improved and supported.

--Ying

>
>
>
>
>> [...]
>> > > > Yes, then, almost all mm guys answer has been "please use mlock".
>> > >
>> > > Yes. As I already tried to explain, mlock is not the remedy all the
>> > > time. It gets very tricky when you balance on the edge of the limit =
of
>> > > the available memory resp. cgroup limit. Sometimes you rather want t=
o
>> > > have something swapped out than being killed (or fail due to ENOMEM)=
.
>> > > The important thing about swapped out above is that with the isolati=
on
>> > > it is only per-cgroup.
>> > >
>> >
>> > IMHO, doing isolation by hiding is not good idea.
>>
>> It depends on what you want to guarantee.
>>
>> > Because we're kernel engineer, we should do isolation by
>> > scheduling. The kernel is art of shceduling, not separation.
>>
>> Well, I would disagree with this statement (to some extend of course).
>> Cgroups are quite often used for separation (e.g. cpusets basically
>> hide tasks from CPUs that are not configured for them).
>>
>> You are certainly right that the memory management is about proper
>> scheduling and balancing needs vs. demands. And it turned out to be
>> working fine in many (maybe even most of) workloads (modulo bugs
>> which are fixed over time). But if an application has more specific
>> requirements for its memory usage then it is quite limited in ways how
>> it can achieve them (mlock is one way how to pin the memory but there
>> are cases where it is not appropriate).
>> Kernel will simply never know the complete picture and have to rely on
>> heuristics which will never fit in with everybody.
>>
>
> That's what MM guys are tring.
>
> IIUC, there has been many papers on 'hinting LRU' in OS study,
> but none has been added to Linux successfully. I'm not sure there has
> been no trial or they were rejected.
>
>
>
>>
>> > I think we should start from some scheduling as softlimit. Then,
>> > as an extreme case of scheduling, 'complete isolation' should be
>> > archived. If it seems impossible after trial of making softlimit
>> > better, okay, we should consider some.
>>
>> As I already tried to point out what-ever will scheduling do it has no
>> way to guess that somebody needs to be isolated unless he says that to
>> kernel.
>> Anyway, I will have a look whether softlimit can be used and how helpful
>> it would be.
>>
>
> If softlimit (after some improvement) isn't enough, please add some other=
.
>
> What I think of is
>
> 1. need to "guarantee" memory usages in future.
> =A0 "first come, first served" is not good for admins.
>
> 2. need to handle zone memory shortage. Using memory migration
> =A0 between zones will be necessary to avoid pageout.
>
> 3. need a knob to say "please reclaim from my own cgroup rather than
> =A0 affecting others (if usage > some(soft)limit)."
>
>
>> [...]
>> > > > I think you should put tasks in root cgroup to somewhere. It works=
 perfect
>> > > > against OOM. And if memory are hidden by isolation, OOM will happe=
n easier.
>> > >
>> > > Why do you think that it would happen easier? Isn't it similar (from=
 OOM
>> > > POV) as if somebody mlocked that memory?
>> > >
>> >
>> > if global lru scan cannot find victim memory, oom happens.
>>
>> Yes, but this will happen with mlocked memory as well, right?
>>
> Yes, of course.
>
> Anyway, I'll Nack to simple "first come, first served" isolation.
> Please implement garantee, which is reliable and admin can use safely.
>
> mlock() has similar problem, So, I recommend hugetlbfs to customers,
> admin can schedule it at boot time.
> (the number of users of hugetlbfs is tend to be one app. (oracle))
>
> I'll be absent, tomorrow.
>
> I think you'll come LSF/MM summit and from the schedule, you'll have
> a joint session with Ying as "Memcg LRU management and isolation".
>
> IIUC, "LRU management" is a google's performance improvement topic.
>
> It's ok for me to talk only about 'isolation' =A01st in earlier session.
> If you want, please ask James to move session and overlay 1st memory
> cgroup session. (I think you saw e-mail from James.)
>
> Thanks,
> -Kame
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
