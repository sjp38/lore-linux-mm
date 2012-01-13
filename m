Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 88C636B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 16:45:31 -0500 (EST)
Received: by qcsg13 with SMTP id g13so643386qcs.14
        for <linux-mm@kvack.org>; Fri, 13 Jan 2012 13:45:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120113163423.GG17060@tiehlicka.suse.cz>
References: <1326207772-16762-1-git-send-email-hannes@cmpxchg.org>
	<1326207772-16762-3-git-send-email-hannes@cmpxchg.org>
	<20120113120406.GC17060@tiehlicka.suse.cz>
	<20120113155001.GB1653@cmpxchg.org>
	<20120113163423.GG17060@tiehlicka.suse.cz>
Date: Fri, 13 Jan 2012 13:45:30 -0800
Message-ID: <CALWz4iyj4SMMyYhbuZ3HUq-jvcZUCGarceYY7vxm4b7X=yvCMg@mail.gmail.com>
Subject: Re: [patch 2/2] mm: memcg: hierarchical soft limit reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 13, 2012 at 8:34 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Fri 13-01-12 16:50:01, Johannes Weiner wrote:
>> On Fri, Jan 13, 2012 at 01:04:06PM +0100, Michal Hocko wrote:
>> > On Tue 10-01-12 16:02:52, Johannes Weiner wrote:
> [...]
>> > > +bool mem_cgroup_over_softlimit(struct mem_cgroup *root,
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct mem_cgroup *=
memcg)
>> > > +{
>> > > + if (mem_cgroup_disabled())
>> > > + =A0 =A0 =A0 =A0 return false;
>> > > +
>> > > + if (!root)
>> > > + =A0 =A0 =A0 =A0 root =3D root_mem_cgroup;
>> > > +
>> > > + for (; memcg; memcg =3D parent_mem_cgroup(memcg)) {
>> > > + =A0 =A0 =A0 =A0 /* root_mem_cgroup does not have a soft limit */
>> > > + =A0 =A0 =A0 =A0 if (memcg =3D=3D root_mem_cgroup)
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> > > + =A0 =A0 =A0 =A0 if (res_counter_soft_limit_excess(&memcg->res))
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
>> > > + =A0 =A0 =A0 =A0 if (memcg =3D=3D root)
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> > > + }
>> > > + return false;
>> > > +}
>> >
>> > Well, this might be little bit tricky. We do not check whether memcg a=
nd
>> > root are in a hierarchy (in terms of use_hierarchy) relation.
>> >
>> > If we are under global reclaim then we iterate over all memcgs and so
>> > there is no guarantee that there is a hierarchical relation between th=
e
>> > given memcg and its parent. While, on the other hand, if we are doing
>> > memcg reclaim then we have this guarantee.
>> >
>> > Why should we punish a group (subtree) which is perfectly under its so=
ft
>> > limit just because some other subtree contributes to the common parent=
's
>> > usage and makes it over its limit?
>> > Should we check memcg->use_hierarchy here?
>>
>> We do, actually. =A0parent_mem_cgroup() checks the res_counter parent,
>> which is only set when ->use_hierarchy is also set.
>
> Of course I am blind.. We do not setup res_counter parent for
> !use_hierarchy case. Sorry for noise...
> Now it makes much better sense. I was wondering how !use_hierarchy could
> ever work, this should be a signal that I am overlooking something
> terribly.
>
> [...]
>> > > @@ -2121,8 +2121,16 @@ static void shrink_zone(int priority, struct =
zone *zone,
>> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D memcg,
>> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .zone =3D zone,
>> > > =A0 =A0 =A0 =A0 =A0 };
>> > > + =A0 =A0 =A0 =A0 int epriority =3D priority;
>> > > + =A0 =A0 =A0 =A0 /*
>> > > + =A0 =A0 =A0 =A0 =A0* Put more pressure on hierarchies that exceed =
their
>> > > + =A0 =A0 =A0 =A0 =A0* soft limit, to push them back harder than the=
ir
>> > > + =A0 =A0 =A0 =A0 =A0* well-behaving siblings.
>> > > + =A0 =A0 =A0 =A0 =A0*/
>> > > + =A0 =A0 =A0 =A0 if (mem_cgroup_over_softlimit(root, memcg))
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 epriority =3D 0;
>> >
>> > This sounds too aggressive to me. Shouldn't we just double the pressur=
e
>> > or something like that?
>>
>> That's the historical value. =A0When I tried priority - 1, it was not
>> aggressive enough.
>
> Probably because we want to reclaim too much. Maybe we should do
> reduce nr_to_reclaim (ugly) or reclaim only overlimit groups until certai=
n
> priority level as Ying suggested in her patchset.

I plan to post that change on top of this, and this patch set does the
basic stuff to allow us doing further improvement.

I still like the design to skip over_soft_limit cgroups until certain
priority. One way to set up the soft limit for each cgroup is to base
on its actual working set size, and we prefer to punish A first with
lots of page cache ( cold file pages above soft limit) than reclaiming
anon pages from B ( below soft limit ). Unless we can not get enough
pages reclaimed from A, we will start reclaiming from B.

This might not be the ideal solution, but should be a good start. Thoughts?

--Ying

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
