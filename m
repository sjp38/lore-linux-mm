Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 63AA36B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 08:41:27 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so76752577wid.1
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 05:41:27 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id o20si3804815wjr.199.2015.08.27.05.41.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 05:41:25 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so73678402wic.0
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 05:41:24 -0700 (PDT)
Date: Thu, 27 Aug 2015 14:41:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm] mm, oom: add global access to memory reserves on
 livelock
Message-ID: <20150827124122.GD27052@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1508201358490.607@chino.kir.corp.google.com>
 <20150821081745.GG23723@dhcp22.suse.cz>
 <alpine.DEB.2.10.1508241358230.32561@chino.kir.corp.google.com>
 <20150825142503.GE6285@dhcp22.suse.cz>
 <alpine.DEB.2.10.1508251635560.10653@chino.kir.corp.google.com>
 <20150826070127.GB25196@dhcp22.suse.cz>
 <alpine.DEB.2.10.1508261507270.2973@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1508261507270.2973@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Wed 26-08-15 15:23:07, David Rientjes wrote:
> On Wed, 26 Aug 2015, Michal Hocko wrote:
> 
> > > Because the company I work for has far too many machines for that to be 
> > > possible.
> > 
> > OK I can see that manual intervention for hundreds of machines is not
> > practical. But not everybody is that large and there are users who might
> > want to be be able to recover.
> >  
> 
> If Andrew would prefer moving in a direction where all Linux users are 
> required to have their admin use sysrq+f to manually trigger an oom kill, 
> which may or may not resolve the livelock since there's no way to 
> determine which process is holding the common mutex (or even which 
> processes are currently allocating), in such situations, then we can carry 
> this patch internally.  I disagree with that solution for upstream Linux.

There are other possibilities than the manual sysrq intervention. E.g.
the already mentioned oom_{panic,reboot}_timeout which has a little
advantage that it allows admin to opt in into the policy rather than
having it hard coded into the kernel.
 
> > > If there is a holder of a mutex that then allocates gigabytes of memory, 
> > > no amount of memory reserves is going to assist in resolving an oom killer 
> > > livelock, whether that's partial access to memory reserves or full access 
> > > to memory reserves.
> > 
> > Sure, but do we have something like that in the kernel? I would argue it
> > would be terribly broken and a clear bug which should be fixed.
> > 
> 
> This is also why my patch dumps the stack trace of both threads: so we can 
> evaluate the memory allocation of threads holding shared mutexes.  If it 
> is excessive, we can report that and show that it is a common offender and 
> see if we can mitigate that.
> 
> The scenario described, the full or partial depletion of memory reserves, 
> does not need to be induced by a single user.  We don't control the order 
> in which the mutex is grabbed so it's multipled by the number of threads 
> that grab it, allocate memory, and drop it before the victim has a chance 
> to grab it.  In the past, the oom killer would also increase the 
> scheduling priority of a victim so it tried to resolve issues like this 
> faster.

> > > Unless the oom watermark was higher than the lowest access to memory 
> > > reserves other than ALLOC_NO_WATERMARKS, then no forward progress would be 
> > > made in this scenario.  I think it would be better to give access to that 
> > > crucial last page that may solve the livelock to make forward progress, or 
> > > panic as a result of complete depletion of memory reserves.  That panic() 
> > > is a very trivial patch that can be checked in the allocator slowpath and 
> > > addresses a problem that already exists today.
> > 
> > The panicing the system is really trivial, no question about that. The
> > question is whether that panic would be premature. And that is what
> > I've tried to tell you.
> 
> My patch has defined that by OOM_EXPIRE_MSECS.  The premise is that an oom 
> victim with full access to memory reserves should never take more than 5s 
> to exit, which I consider a very long time.  If it's increased, we see 
> userspace responsiveness issues with our processes that monitor system 
> health which timeout.

Yes but it sounds very much like a policy which should better be defined
from the userspace because different users might have different
preferences.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
