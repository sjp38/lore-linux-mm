Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f49.google.com (mail-bk0-f49.google.com [209.85.214.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6E98D6B0035
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 22:13:23 -0500 (EST)
Received: by mail-bk0-f49.google.com with SMTP id my13so3492712bkb.8
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 19:13:22 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id b2si13112292bko.253.2013.11.27.19.13.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Nov 2013 19:13:22 -0800 (PST)
Date: Wed, 27 Nov 2013 22:13:13 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [merged]
 mm-memcg-handle-non-error-oom-situations-more-gracefully.patch removed from
 -mm tree
Message-ID: <20131128031313.GK3556@cmpxchg.org>
References: <526028bd.k5qPj2+MDOK1o6ii%akpm@linux-foundation.org>
 <alpine.DEB.2.02.1311271453270.13682@chino.kir.corp.google.com>
 <20131127233353.GH3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271622330.10617@chino.kir.corp.google.com>
 <20131128021809.GI3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271826001.5120@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311271826001.5120@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, Michal Hocko <mhocko@suse.cz>, azurit@pobox.sk, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 27, 2013 at 06:38:31PM -0800, David Rientjes wrote:
> On Wed, 27 Nov 2013, Johannes Weiner wrote:
> 
> > > The task that is bypassing the memcg charge to the root memcg may not be 
> > > the process that is chosen by the oom killer, and it's possible the amount 
> > > of memory freed by killing the victim is less than the amount of memory 
> > > bypassed.
> > 
> > That's true, though unlikely.
> > 
> 
> Well, the "goto bypass" allows it and it's trivial to cause by 
> manipulating /proc/pid/oom_score_adj values to prefer processes with very 
> little rss.  It will just continue looping and killing processes as they 
> are forked and never cause the memcg to free memory below its limit.  At 
> least the "goto nomem" allows us to free some memory instead of leaking to 
> the root memcg.

Yes, that's the better way of doing it, I'll send the patch.  Thanks.

> > > Were you targeting these to 3.13 instead?  If so, it would have already 
> > > appeared in 3.13-rc1 anyway.  Is it still a work in progress?
> > 
> > I don't know how to answer this question.
> > 
> 
> It appears as though this work is being developed in Linus's tree rather 
> than -mm, so I'm asking if we should consider backing some of it out for 
> 3.14 instead.

The changes fix a deadlock problem.  Are they creating problems that
are worse than deadlocks, that would justify their revert?

> > > Should we be checking mem_cgroup_margin() here to ensure 
> > > task_in_memcg_oom() is still accurate and we haven't raced by freeing 
> > > memory?
> > 
> > We would have invoked the OOM killer long before this point prior to
> > my patches.  There is a line we draw and from that point on we start
> > killing things.  I tried to explain multiple times now that there is
> > no race-free OOM killing and I'm tired of it.  Convince me otherwise
> > or stop repeating this non-sense.
> > 
> 
> In our internal kernel we call mem_cgroup_margin() with the order of the 
> charge immediately prior to sending the SIGKILL to see if it's still 
> needed even after selecting the victim.  It makes the race smaller.
> 
> It's obvious that after the SIGKILL is sent, either from the kernel or 
> from userspace, that memory might subsequently be freed or another process 
> might exit before the process killed could even wake up.  There's nothing 
> we can do about that since we don't have psychic abilities.  I think we 
> should try to reduce the chance for unnecessary oom killing as much as 
> possible, however.

Since we can't physically draw a perfect line, we should strive for a
reasonable and intuitive line.  After that it's rapidly diminishing
returns.  Killing something after that much reclaim effort without
success is a completely reasonable and intuitive line to draw.  It's
also the line that has been drawn a long time ago and we're not
breaking this because of a micro optmimization.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
