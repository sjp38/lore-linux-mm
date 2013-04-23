Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id D78C06B0033
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 05:58:20 -0400 (EDT)
Received: by mail-qe0-f46.google.com with SMTP id x7so78595qeu.5
        for <linux-mm@kvack.org>; Tue, 23 Apr 2013 02:58:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130422155454.GH18286@dhcp22.suse.cz>
References: <20130420002620.GA17179@mtj.dyndns.org>
	<20130420031611.GA4695@dhcp22.suse.cz>
	<20130421022321.GE19097@mtj.dyndns.org>
	<CANN689GuN_5QdgPBjr7h6paVmPeCvLHYfLWNLsJMWib9V9G_Fw@mail.gmail.com>
	<20130422042445.GA25089@mtj.dyndns.org>
	<20130422153730.GG18286@dhcp22.suse.cz>
	<20130422154620.GB12543@htj.dyndns.org>
	<20130422155454.GH18286@dhcp22.suse.cz>
Date: Tue, 23 Apr 2013 02:58:19 -0700
Message-ID: <CANN689Hz5A+iMM3T76-8RCh8YDnoGrYBvtjL_+cXaYRR0OkGRQ@mail.gmail.com>
Subject: Re: memcg: softlimit on internal nodes
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Greg Thelen <gthelen@google.com>

On Mon, Apr 22, 2013 at 8:54 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Mon 22-04-13 08:46:20, Tejun Heo wrote:
>> Oh, if so, I'm happy.  Sorry about being brash on the thread; however,
>> please talk with google memcg people.  They have very different
>> interpretation of what "softlimit" is and are using it according to
>> that interpretation.  If it *is* an actual soft limit, there is no
>> inherent isolation coming from it and that should be clear to
>> everyone.
>
> We have discussed that for a long time. I will not speak for Greg & Ying
> but from my POV we have agreed that the current implementation will work
> for them with some (minor) changes in their layout.
> As I have said already with a careful configuration (e.i. setting the
> soft limit only where it matters - where it protects an important
> memory which is usually in the leaf nodes)

I don't like your argument that soft limits work if you only set them
on leaves. To me this is just a fancy way of saying that hierarchical
soft limits don't work.

Also it is somewhat problematic to assume that important memory can
easily be placed in leaves. This is difficult to ensure when
subcontainer destruction, for example, moves the memory back into the
parent.

> you can actually achieve
> _high_ probability for not being reclaimed after the rework which was not
> possible before because of the implementation which was ugly and
> smelled.

So, to be clear, what we (google MM people) want from soft limits is
some form of protection against being reclaimed from when your cgroup
(or its parent) is below the soft limit.

I don't like to call it a guarantee either, because we understand that
it comes with some limitations - for example, if all user pages on a
given node are yours then allocations from that node might cause some
of your pages to be reclaimed, even when you're under your soft limit.
But we want some form of (weak) guarantee that can be made to work
good enough in practice.

Before your change, soft limits didn't actually provide any such form
of guarantee, weak or not, since global reclaim would ignore soft
limits.

With your proposal, soft limits at least do provide the weak guarantee
that we want, when not using hierarchies. We see this as a very clear
improvement over the previous situation, so we're very happy about
your patchset !

However, your proposal takes that weak guarantee away as soon as one
tries to use cgroup hierarchies with it, because it reclaims from
every child cgroup as soon as the parent hits its soft limit. This is
disappointing and also, I have not heard of why you want things to
work that way ? Is this an ease of implementation issue or do you
consider that requirement as a bad idea ? And if it's the later,
what's your counterpoint, is it related to delegation or is it
something else that I haven't heard of ?

I don't think referring to the existing memcg documentation makes a
strong point - the documentation never said that soft limits were not
obeyed by global reclaim and yet we both agree that it'd be preferable
if they were. So I would like to hear of your reasons (apart from
referring to the existing documentation) for not allowing a parent
cgroup to protect its children from reclaim when the total charge from
that parent is under the parent's soft limit.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
