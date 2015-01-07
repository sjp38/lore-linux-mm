Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id A946D6B0032
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 13:56:59 -0500 (EST)
Received: by mail-ie0-f173.google.com with SMTP id y20so5370036ier.4
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 10:56:59 -0800 (PST)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id a83si2027618ioj.91.2015.01.07.10.56.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 Jan 2015 10:56:58 -0800 (PST)
Received: by mail-ig0-f174.google.com with SMTP id hn15so6314834igb.13
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 10:56:57 -0800 (PST)
References: <20150106161435.GF20860@dhcp22.suse.cz> <xr93k30zij6o.fsf@gthelen.mtv.corp.google.com> <20150107142804.GD16553@dhcp22.suse.cz>
From: Greg Thelen <gthelen@google.com>
Subject: Re: [LSF/MM TOPIC ATTEND]
In-reply-to: <20150107142804.GD16553@dhcp22.suse.cz>
Date: Wed, 07 Jan 2015 10:54:25 -0800
Message-ID: <xr93d26q1kwu.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Wed, Jan 07 2015, Michal Hocko wrote:

> On Tue 06-01-15 15:27:27, Greg Thelen wrote:
>> On Tue, Jan 06 2015, Michal Hocko wrote:
>> 
>> > - As it turned out recently GFP_KERNEL mimicing GFP_NOFAIL for !costly
>> >   allocation is sometimes kicking us back because we are basically
>> >   creating an invisible lock dependencies which might livelock the whole
>> >   system under OOM conditions.
>> >   That leads to attempts to add more hacks into the OOM killer
>> >   which is tricky enough as is. Changing the current state is
>> >   quite risky because we do not really know how many places in the
>> >   kernel silently depend on this behavior. As per Johannes attempt
>> >   (http://marc.info/?l=linux-mm&m=141932770811346) it is clear that
>> >   we are not yet there! I do not have very good ideas how to deal with
>> >   this unfortunatelly...
>> 
>> We've internally been fighting similar deadlocks between memcg kmem
>> accounting and memcg oom killer.  I wouldn't call it a very good idea,
>> because it falls in the realm of further complicating the oom killer,
>> but what about introducing an async oom killer which runs outside of the
>> context of the current task. 
>
> I am not sure I understand you properly. We have something similar for
> memcg in upstream. It is still from the context of the task which has
> tripped over the OOM but it happens down in the page fault path where no
> locks are held. This has fixed the similar lock dependency problem in
> memcg charges, which can happen on top of any locks, but it is still not
> enough, see below.

Nod.  I'm working with an older kernel which does oom killing in the allocation
context rather than failing the allocation and expecting the end of page fault
processing to queue an oom kill.  Such older kernels thus don't fail small
GFP_KERNEL kmem allocations due to memcg oom, but they run the risk of lockups.
Newer kernels fail small GFP_KERNEL for memcg oom, but won't fail them for page
allocator shortages.  I assume we want consistency in the handling of small
GFP_KERNEL allocations for memcg and machine oom.

>> An async killer won't hold any locks so it
>> won't block the indented oom victim from terminating.  After queuing a
>> deferred oom kill the allocating thread would then be able to dip into
>> memory reserves to satisfy its too-small-to-fail allocation.
>
> What would prevent the current to consume all the memory reserves
> because the victim wouldn't die early enough (e.g. it won't be scheduled
> or spend a lot of time on an unrelated lock)? Each "current" which
> blocks the oom victim would have to get access to the reserves. There
> might be really lots of them...

Yeah, this is the weak spot.

> I think that we shouldn't give anybody but OOM victim access to
> the reserves because there is a good chance that the victim will
> not use too much of it (unless there is a bug somewhere where the
> victim allocates unbounded amount of memory without bailing out on
> fatal_signals_pending).
>
> I am pretty sure that we can extend lockdep to report when OOM victim
> is going to block on a lock which is held by a task which is allocating
> on almost-never-fail gfp (there is already GFP_FS tracking implemented
> AFAIR). But that wouldn't solve the problem, though, because it would
> turn into, as Dave pointed out, "whack a mole" game.

Close, but I think the lockdep complaint would need to be wider - it shouldn't
only catch actual oom kill victims but potential oom kill victims.  Lockdep
would need to complain whenever any thread attempts almost-never-fail allocation
while holding any lock which any user thread (possible oom kill victim) has ever
grabbed in non-interruptible fashion.  This might catch a lot of allocations.

> Instead we shouldn't pretend that GFP_KERNEL is basically GFP_NOFAIL.
> The question is how to get there without too many regressions IMHO.
> Or maybe we should simply bite a bullet and don't be cowards and simply
> deal with bugs as they come. If something really cannot deal with the
> failure it should tell that by a proper flag.

I'm not opposed to this, but we'll still have a lot of places where the
only response to small GFP_KERNEL allocation failure is to call the oom
killer.  These allocation sites would presumably add a GFP_NOFAIL, to
instruct the page allocator to caller the oom killer rather than fail.
Thus we still need to either start enforcing the above lockdep rule or
have "some sort of" async oom killer.  But I admit the async killer has
a serious reserve exhaustion issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
