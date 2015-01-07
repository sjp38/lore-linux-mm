Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 385BE6B0032
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 09:28:08 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id a1so1265595wgh.23
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 06:28:07 -0800 (PST)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com. [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id bp10si4294489wjb.157.2015.01.07.06.28.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 Jan 2015 06:28:07 -0800 (PST)
Received: by mail-wi0-f171.google.com with SMTP id bs8so7585183wib.10
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 06:28:07 -0800 (PST)
Date: Wed, 7 Jan 2015 15:28:04 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [LSF/MM TOPIC ATTEND]
Message-ID: <20150107142804.GD16553@dhcp22.suse.cz>
References: <20150106161435.GF20860@dhcp22.suse.cz>
 <xr93k30zij6o.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr93k30zij6o.fsf@gthelen.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Tue 06-01-15 15:27:27, Greg Thelen wrote:
> On Tue, Jan 06 2015, Michal Hocko wrote:
> 
> > - As it turned out recently GFP_KERNEL mimicing GFP_NOFAIL for !costly
> >   allocation is sometimes kicking us back because we are basically
> >   creating an invisible lock dependencies which might livelock the whole
> >   system under OOM conditions.
> >   That leads to attempts to add more hacks into the OOM killer
> >   which is tricky enough as is. Changing the current state is
> >   quite risky because we do not really know how many places in the
> >   kernel silently depend on this behavior. As per Johannes attempt
> >   (http://marc.info/?l=linux-mm&m=141932770811346) it is clear that
> >   we are not yet there! I do not have very good ideas how to deal with
> >   this unfortunatelly...
> 
> We've internally been fighting similar deadlocks between memcg kmem
> accounting and memcg oom killer.  I wouldn't call it a very good idea,
> because it falls in the realm of further complicating the oom killer,
> but what about introducing an async oom killer which runs outside of the
> context of the current task. 

I am not sure I understand you properly. We have something similar for
memcg in upstream. It is still from the context of the task which has
tripped over the OOM but it happens down in the page fault path where no
locks are held. This has fixed the similar lock dependency problem in
memcg charges, which can happen on top of any locks, but it is still not
enough, see below.

> An async killer won't hold any locks so it
> won't block the indented oom victim from terminating.  After queuing a
> deferred oom kill the allocating thread would then be able to dip into
> memory reserves to satisfy its too-small-to-fail allocation.

What would prevent the current to consume all the memory reserves
because the victim wouldn't die early enough (e.g. it won't be scheduled
or spend a lot of time on an unrelated lock)? Each "current" which
blocks the oom victim would have to get access to the reserves. There
might be really lots of them...

I think that we shouldn't give anybody but OOM victim access to
the reserves because there is a good chance that the victim will
not use too much of it (unless there is a bug somewhere where the
victim allocates unbounded amount of memory without bailing out on
fatal_signals_pending).

I am pretty sure that we can extend lockdep to report when OOM victim
is going to block on a lock which is held by a task which is allocating
on almost-never-fail gfp (there is already GFP_FS tracking implemented
AFAIR). But that wouldn't solve the problem, though, because it would
turn into, as Dave pointed out, "whack a mole" game.

Instead we shouldn't pretend that GFP_KERNEL is basically GFP_NOFAIL.
The question is how to get there without too many regressions IMHO.
Or maybe we should simply bite a bullet and don't be cowards and simply
deal with bugs as they come. If something really cannot deal with the
failure it should tell that by a proper flag.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
