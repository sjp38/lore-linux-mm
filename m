Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 10EF06B0112
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 18:16:14 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id a13so5716402igq.3
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 15:16:13 -0700 (PDT)
Received: from mail-ie0-x24a.google.com (mail-ie0-x24a.google.com [2607:f8b0:4001:c03::24a])
        by mx.google.com with ESMTPS id rv8si70439219igb.32.2014.06.10.15.16.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Jun 2014 15:16:13 -0700 (PDT)
Received: by mail-ie0-f202.google.com with SMTP id tr6so532690ieb.5
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 15:16:13 -0700 (PDT)
References: <20140606144421.GE26253@dhcp22.suse.cz> <1402066010-25901-1-git-send-email-mhocko@suse.cz> <1402066010-25901-2-git-send-email-mhocko@suse.cz> <xr934mzt4rwc.fsf@gthelen.mtv.corp.google.com> <20140610165756.GG2878@cmpxchg.org>
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH 2/2] memcg: Allow hard guarantee mode for low limit reclaim
In-reply-to: <20140610165756.GG2878@cmpxchg.org>
Date: Tue, 10 Jun 2014 15:16:12 -0700
Message-ID: <xr93zjhk2yxf.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org


On Tue, Jun 10 2014, Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Mon, Jun 09, 2014 at 03:52:51PM -0700, Greg Thelen wrote:
>> 
>> On Fri, Jun 06 2014, Michal Hocko <mhocko@suse.cz> wrote:
>> 
>> > Some users (e.g. Google) would like to have stronger semantic than low
>> > limit offers currently. The fallback mode is not desirable and they
>> > prefer hitting OOM killer rather than ignoring low limit for protected
>> > groups. There are other possible usecases which can benefit from hard
>> > guarantees. I can imagine workloads where setting low_limit to the same
>> > value as hard_limit to prevent from any reclaim at all makes a lot of
>> > sense because reclaim is much more disrupting than restart of the load.
>> >
>> > This patch adds a new per memcg memory.reclaim_strategy knob which
>> > tells what to do in a situation when memory reclaim cannot do any
>> > progress because all groups in the reclaimed hierarchy are within their
>> > low_limit. There are two options available:
>> > 	- low_limit_best_effort - the current mode when reclaim falls
>> > 	  back to the even reclaim of all groups in the reclaimed
>> > 	  hierarchy
>> > 	- low_limit_guarantee - groups within low_limit are never
>> > 	  reclaimed and OOM killer is triggered instead. OOM message
>> > 	  will mention the fact that the OOM was triggered due to
>> > 	  low_limit reclaim protection.
>> 
>> To (a) be consistent with existing hard and soft limits APIs and (b)
>> allow use of both best effort and guarantee memory limits, I wonder if
>> it's best to offer three per memcg limits, rather than two limits (hard,
>> low_limit) and a related reclaim_strategy knob.  The three limits I'm
>> thinking about are:
>> 
>> 1) hard_limit (aka the existing limit_in_bytes cgroupfs file).  No
>>    change needed here.  This is an upper bound on a memcg hierarchy's
>>    memory consumption (assuming use_hierarchy=1).
>
> This creates internal pressure.  Outside reclaim is not affected by
> it, but internal charges can not exceed this limit.  This is set to
> hard limit the maximum memory consumption of a group (max).
>
>> 2) best_effort_limit (aka desired working set).  This allow an
>>    application or administrator to provide a hint to the kernel about
>>    desired working set size.  Before oom'ing the kernel is allowed to
>>    reclaim below this limit.  I think the current soft_limit_in_bytes
>>    claims to provide this.  If we prefer to deprecate
>>    soft_limit_in_bytes, then a new desired_working_set_in_bytes (or a
>>    hopefully better named) API seems reasonable.
>
> This controls how external pressure applies to the group.
>
> But it's conceivable that we'd like to have the equivalent of such a
> soft limit for *internal* pressure.  Set below the hard limit, this
> internal soft limit would have charges trigger direct reclaim in the
> memcg but allow them to continue to the hard limit.  This would create
> a situation wherein the allocating tasks are not killed, but throttled
> under reclaim, which gives the administrator a window to detect the
> situation with vmpressure and possibly intervene.  Because as it
> stands, once the current hard limit is hit things can go down pretty
> fast and the window for reacting to vmpressure readings is often too
> small.  This would offer a more gradual deterioration.  It would be
> set to the upper end of the working set size range (high).
>
> I think for many users such an internal soft limit would actually be
> preferred over the current hard limit, as they'd rather have some
> reclaim throttling than an OOM kill when the group reaches its upper
> bound.  The current hard limit would be reserved for more advanced or
> paid cases, where the admin would rather see a memcg get OOM killed
> than exceed a certain size.
>
> Then, as you proposed, we'd have the soft limit for external pressure,
> where the kernel only reclaims groups within that limit in order to
> avoid OOM kills.  It would be set to the estimated lower end of the
> working set size range (low).
>
>> 3) low_limit_guarantee which is a lower bound of memory usage.  A memcg
>>    would prefer to be oom killed rather than operate below this
>>    threshold.  Default value is zero to preserve compatibility with
>>    existing apps.
>
> And this would be the external pressure hard limit, which would be set
> to the absolute minimum requirement of the group (min).
>
> Either because it would be hopelessly thrashing without it, or because
> this guaranteed memory is actually paid for.  Again, I would expect
> many users to not even set this minimum guarantee but solely use the
> external soft limit (low) instead.
>
>> Logically hard_limit >= best_effort_limit >= low_limit_guarantee.
>
> max >= high >= low >= min
>
> I think we should be able to express all desired usecases with these
> four limits, including the advanced configurations, while making it
> easy for many users to set up groups without being a) dead certain
> about their memory consumption or b) prepared for frequent OOM kills,
> while still allowing them to properly utilize their machines.
>
> What do you think?

Sounds good to me.

Recapping so I understand:
- max and high apply to internal pressure.
- low and min apply to external pressure.

The {max, high, low, min} names are better than mine.  Given that they
mimic global watermarks I keep wondering if a per memcg kswapd would
someday use these new memcg watermarks.  But merely waking up some
futuristic per memcg kswapd when usage crosses high would sacrifice the
throttling for vmpressure to respond.  So I think what you've proposed
is good for most use cases I have in mind.  Though I'm not sure that I
have immediate use for the high wmark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
