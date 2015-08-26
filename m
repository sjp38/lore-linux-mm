Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 010926B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 03:01:31 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so35049215wic.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 00:01:30 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id j8si3451285wjn.105.2015.08.26.00.01.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 00:01:29 -0700 (PDT)
Received: by wijn1 with SMTP id n1so13992932wij.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 00:01:28 -0700 (PDT)
Date: Wed, 26 Aug 2015 09:01:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm] mm, oom: add global access to memory reserves on
 livelock
Message-ID: <20150826070127.GB25196@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1508201358490.607@chino.kir.corp.google.com>
 <20150821081745.GG23723@dhcp22.suse.cz>
 <alpine.DEB.2.10.1508241358230.32561@chino.kir.corp.google.com>
 <20150825142503.GE6285@dhcp22.suse.cz>
 <alpine.DEB.2.10.1508251635560.10653@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1508251635560.10653@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Tue 25-08-15 16:41:29, David Rientjes wrote:
> On Tue, 25 Aug 2015, Michal Hocko wrote:
> 
> > > I don't believe a solution that requires admin intervention is 
> > > maintainable.
> > 
> > Why?
> > 
> 
> Because the company I work for has far too many machines for that to be 
> possible.

OK I can see that manual intervention for hundreds of machines is not
practical. But not everybody is that large and there are users who might
want to be be able to recover.
 
> > > It would be better to reboot when memory reserves are fully depleted.
> > 
> > The question is when are the reserves depleted without any way to
> > replenish them. While playing with GFP_NOFS patch set which gives
> > __GFP_NOFAIL allocations access to memory reserves
> > (http://marc.info/?l=linux-mm&m=143876830916540&w=2) I could see the
> > warning hit while the system still resurrected from the memory pressure.
> > 
> 
> If there is a holder of a mutex that then allocates gigabytes of memory, 
> no amount of memory reserves is going to assist in resolving an oom killer 
> livelock, whether that's partial access to memory reserves or full access 
> to memory reserves.

Sure, but do we have something like that in the kernel? I would argue it
would be terribly broken and a clear bug which should be fixed.

> You're referring to two different conditions:
> 
>  (1) oom livelock as a result of an oom kill victim waiting on a lock that
>      is held by an allocator, and
> 
>  (2) depletion of memory reserves, which can also happen today without 
>      this patchset and we have fixed in the past.
> 
> This patch addresses (1) by giving it a higher probability, absent the 
> ability to determine which thread is holding the lock that the victim 
> depends on, to make forward progress.  It would be fine to do (2) as a 
> separate patch, since it is a separate problem, that I agree has a higher 
> likelihood of happening now to panic when memory reserves have been 
> depleted.
> 
> > I think an OOM reserve/watermark makes more sense. It will not solve the
> > livelock but neithere granting the full access to reserves will. But the
> > partial access has a potential to leave some others means to intervene.
> > 
> 
> Unless the oom watermark was higher than the lowest access to memory 
> reserves other than ALLOC_NO_WATERMARKS, then no forward progress would be 
> made in this scenario.  I think it would be better to give access to that 
> crucial last page that may solve the livelock to make forward progress, or 
> panic as a result of complete depletion of memory reserves.  That panic() 
> is a very trivial patch that can be checked in the allocator slowpath and 
> addresses a problem that already exists today.

The panicing the system is really trivial, no question about that. The
question is whether that panic would be premature. And that is what
I've tried to tell you. The patch I am referring to above gives the
__GFP_NOFAIL request the full access to memory reserves (throttled by
oom_lock) but it still failed temporarily. What is more important,
though, this state wasn't permanent and the system recovered after short
time so panicing at the time would be premature.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
