Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id C6F82900016
	for <linux-mm@kvack.org>; Fri,  5 Jun 2015 10:29:34 -0400 (EDT)
Received: by wgme6 with SMTP id e6so58250473wgm.2
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 07:29:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gg1si4338612wib.111.2015.06.05.07.29.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Jun 2015 07:29:32 -0700 (PDT)
Date: Fri, 5 Jun 2015 16:29:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RFC] memcg: close the race window between OOM detection
 and killing
Message-ID: <20150605142930.GC26113@dhcp22.suse.cz>
References: <20150603031544.GC7579@mtj.duckdns.org>
 <20150603144414.GG16201@dhcp22.suse.cz>
 <20150603193639.GH20091@mtj.duckdns.org>
 <20150604093031.GB4806@dhcp22.suse.cz>
 <20150604190649.GA5867@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150604190649.GA5867@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu 04-06-15 15:06:49, Johannes Weiner wrote:
> On Thu, Jun 04, 2015 at 11:30:31AM +0200, Michal Hocko wrote:
> > There have been suggestions to add an OOM timeout and ignore the
> > previous OOM victim after the timeout expires and select a new
> > victim. This sounds attractive but this approach has its own problems
> > (http://marc.info/?l=linux-mm&m=141686814824684&w=2).
> 
> Since this list of concerns have been brought up but never really
> addressed, let me give it a shot.  From David's email:
[...]
> : (3) you can easily turn the oom killer into a serial oom killer
> : since there's no guarantee the next process that is chosen won't be
> : affected by the same problem,

This is the primary argument I had in mind when nacking the previous
attempt. If we go after another task after the timeout and that happens
to be just another blocked task we will not move any further, yet we
have killed another task pointlessly.  Tetsuo had a load which generates
hundreds of such tasks all blocked on the same i_mutex. So you would end
up in a basically time unbounded unresponsive system. If you put timeout
too low you risk pointless killing and the large timeout will not help
in the pathological case as well for which it is proposed for.

I can imagine we can enhance panic_on_oom policy to consider also a
timeout (panic_on_oom_timeout). This would be a much better solution
IMO and much cleaner policy because it would be bounded in time. So the
administrator knows what the timeout actually means. It also sounds like
a more appropriate very last resort because the current panic_on_oom
is just too restricted.
 
[...]

> > I am convinced that a more appropriate solution for this is to not
> > pretend that small allocation never fail and start failing them after
> > OOM killer is not able to make any progress (GFP_NOFS allocations would
> > be the first candidate and the easiest one to trigger deadlocks via
> > i_mutex). Johannes was also suggesting an OOM memory reserve which would
> > be used for OOM contexts.
> 
> I am no longer convinced we can ever go back to failing smaller
> allocations and NOFS allocations.  The filesystem people involved in
> that discussion have proven completely uncooperative on that subject.

Yeah, this is sad but I fail to see why this should be a reason to stop
trying to make NOFS behavior more sensible. Those allocations are
clearly restricted and retrying endlessly is simply wrong conceptually.
Maybe this alone will turn out being sufficient to prevent from the dead
lock issues in 99% of cases. panic_on_oom_timeout might be the last
resort for those who want to be really sure that the system will not be
unresponsive for an unbounded amount of time.
 
> So I think we should make the OOM killer as robust as possible. 

I do agree. I just think there are other steps we can do which would be
less disruptive like giving oom context access to memory reserves. Page
table reclaim would be more complicated but maybe we even do not need
that. 

> It's just unnecessary to deadlock on a single process when there are
> more candidates out there that we could try instead.  We are already
> in a worst-case state, killing more tasks is not going to make it
> worse.
> 
> > Also OOM killer can be improved and shrink some of the victims memory
> > before killing it (e.g. drop private clean pages and their page tables).
> 
> That might work too.  It's just a bit more complex and I don't really
> see the downside of moving on to other victims after a timeout.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
