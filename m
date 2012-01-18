Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 2E2C76B004F
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 15:38:56 -0500 (EST)
Received: by qcsf14 with SMTP id f14so1879122qcs.14
        for <linux-mm@kvack.org>; Wed, 18 Jan 2012 12:38:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120118094523.GJ24386@cmpxchg.org>
References: <1326207772-16762-1-git-send-email-hannes@cmpxchg.org>
	<1326207772-16762-3-git-send-email-hannes@cmpxchg.org>
	<20120113120406.GC17060@tiehlicka.suse.cz>
	<20120113155001.GB1653@cmpxchg.org>
	<20120113163423.GG17060@tiehlicka.suse.cz>
	<CALWz4iyj4SMMyYhbuZ3HUq-jvcZUCGarceYY7vxm4b7X=yvCMg@mail.gmail.com>
	<20120118094523.GJ24386@cmpxchg.org>
Date: Wed, 18 Jan 2012 12:38:54 -0800
Message-ID: <CALWz4iw85UZ4k1T8THhq=gnm0yEFW_=+7d9xtmcSfNm4sx5CAA@mail.gmail.com>
Subject: Re: [patch 2/2] mm: memcg: hierarchical soft limit reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 18, 2012 at 1:45 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Fri, Jan 13, 2012 at 01:45:30PM -0800, Ying Han wrote:
>> On Fri, Jan 13, 2012 at 8:34 AM, Michal Hocko <mhocko@suse.cz> wrote:
>> > On Fri 13-01-12 16:50:01, Johannes Weiner wrote:
>> >> On Fri, Jan 13, 2012 at 01:04:06PM +0100, Michal Hocko wrote:
>> >> > On Tue 10-01-12 16:02:52, Johannes Weiner wrote:
>> > [...]
>> >> > > +bool mem_cgroup_over_softlimit(struct mem_cgroup *root,
>> >> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct mem_cgrou=
p *memcg)
>> >> > > +{
>> >> > > + if (mem_cgroup_disabled())
>> >> > > + =A0 =A0 =A0 =A0 return false;
>> >> > > +
>> >> > > + if (!root)
>> >> > > + =A0 =A0 =A0 =A0 root =3D root_mem_cgroup;
>> >> > > +
>> >> > > + for (; memcg; memcg =3D parent_mem_cgroup(memcg)) {
>> >> > > + =A0 =A0 =A0 =A0 /* root_mem_cgroup does not have a soft limit *=
/
>> >> > > + =A0 =A0 =A0 =A0 if (memcg =3D=3D root_mem_cgroup)
>> >> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> >> > > + =A0 =A0 =A0 =A0 if (res_counter_soft_limit_excess(&memcg->res))
>> >> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
>> >> > > + =A0 =A0 =A0 =A0 if (memcg =3D=3D root)
>> >> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> >> > > + }
>> >> > > + return false;
>> >> > > +}
>> >> >
>> >> > Well, this might be little bit tricky. We do not check whether memc=
g and
>> >> > root are in a hierarchy (in terms of use_hierarchy) relation.
>> >> >
>> >> > If we are under global reclaim then we iterate over all memcgs and =
so
>> >> > there is no guarantee that there is a hierarchical relation between=
 the
>> >> > given memcg and its parent. While, on the other hand, if we are doi=
ng
>> >> > memcg reclaim then we have this guarantee.
>> >> >
>> >> > Why should we punish a group (subtree) which is perfectly under its=
 soft
>> >> > limit just because some other subtree contributes to the common par=
ent's
>> >> > usage and makes it over its limit?
>> >> > Should we check memcg->use_hierarchy here?
>> >>
>> >> We do, actually. =A0parent_mem_cgroup() checks the res_counter parent=
,
>> >> which is only set when ->use_hierarchy is also set.
>> >
>> > Of course I am blind.. We do not setup res_counter parent for
>> > !use_hierarchy case. Sorry for noise...
>> > Now it makes much better sense. I was wondering how !use_hierarchy cou=
ld
>> > ever work, this should be a signal that I am overlooking something
>> > terribly.
>> >
>> > [...]
>> >> > > @@ -2121,8 +2121,16 @@ static void shrink_zone(int priority, stru=
ct zone *zone,
>> >> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D memcg,
>> >> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .zone =3D zone,
>> >> > > =A0 =A0 =A0 =A0 =A0 };
>> >> > > + =A0 =A0 =A0 =A0 int epriority =3D priority;
>> >> > > + =A0 =A0 =A0 =A0 /*
>> >> > > + =A0 =A0 =A0 =A0 =A0* Put more pressure on hierarchies that exce=
ed their
>> >> > > + =A0 =A0 =A0 =A0 =A0* soft limit, to push them back harder than =
their
>> >> > > + =A0 =A0 =A0 =A0 =A0* well-behaving siblings.
>> >> > > + =A0 =A0 =A0 =A0 =A0*/
>> >> > > + =A0 =A0 =A0 =A0 if (mem_cgroup_over_softlimit(root, memcg))
>> >> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 epriority =3D 0;
>> >> >
>> >> > This sounds too aggressive to me. Shouldn't we just double the pres=
sure
>> >> > or something like that?
>> >>
>> >> That's the historical value. =A0When I tried priority - 1, it was not
>> >> aggressive enough.
>> >
>> > Probably because we want to reclaim too much. Maybe we should do
>> > reduce nr_to_reclaim (ugly) or reclaim only overlimit groups until cer=
tain
>> > priority level as Ying suggested in her patchset.
>>
>> I plan to post that change on top of this, and this patch set does the
>> basic stuff to allow us doing further improvement.
>>
>> I still like the design to skip over_soft_limit cgroups until certain
>> priority. One way to set up the soft limit for each cgroup is to base
>> on its actual working set size, and we prefer to punish A first with
>> lots of page cache ( cold file pages above soft limit) than reclaiming
>> anon pages from B ( below soft limit ). Unless we can not get enough
>> pages reclaimed from A, we will start reclaiming from B.
>>
>> This might not be the ideal solution, but should be a good start. Though=
ts?
>
> I don't like this design at all because unless you add weird code to
> detect if soft limits apply to any memcgs on the reclaimed hierarchy
> you may iterate over the same bunch of memcgs doing nothing for
> several times. =A0For example in the default case of no softlimits set
> anywhere and you repeatedly walk ALL memcgs in the system doing jack
> until you reach your threshold priority level. =A0Elegant is something
> else in my book.

Agree that change isn't ready until the default soft limit is changed to "0=
".

> Once we invert soft limits to mean guarantees and make the default
> soft limit not infinity but zero, then we can ignore memcgs below
> their soft limit for a few priority levels just fine because being
> below the soft limit is the exception. =A0But I don't really want to
> make this quite invasive behavioural change a requirement for a
> refactoring patch if possible.

Sounds reasonable to me.

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
