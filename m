Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 70BAB82F99
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 08:36:42 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so29168793wic.1
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 05:36:42 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id fq6si9497472wib.110.2015.10.02.05.36.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 05:36:41 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so30966407wic.1
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 05:36:41 -0700 (PDT)
Date: Fri, 2 Oct 2015 14:36:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: can't oom-kill zap the victim's memory?
Message-ID: <20151002123639.GA13914@dhcp22.suse.cz>
References: <20150922160608.GA2716@redhat.com>
 <20150923205923.GB19054@dhcp22.suse.cz>
 <alpine.DEB.2.10.1509241359100.32488@chino.kir.corp.google.com>
 <20150925093556.GF16497@dhcp22.suse.cz>
 <201509260114.ADI35946.OtHOVFOMJQFLFS@I-love.SAKURA.ne.jp>
 <201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

On Tue 29-09-15 01:18:00, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > The point I've tried to made is that oom unmapper running in a detached
> > context (e.g. kernel thread) vs. directly in the oom context doesn't
> > make any difference wrt. lock because the holders of the lock would loop
> > inside the allocator anyway because we do not fail small allocations.
> 
> We tried to allow small allocations to fail. It resulted in unstable system
> with obscure bugs.

Have they been reported/fixed? All kernel paths doing an allocation are
_supposed_ to check and handle ENOMEM. If they are not then they are
buggy and should be fixed.

> We tried to allow small !__GFP_FS allocations to fail. It failed to fail by
> effectively __GFP_NOFAIL allocations.

What do you mean by that? An opencoded __GFP_NOFAIL?
 
> We are now trying to allow zapping OOM victim's mm. Michal is already
> skeptical about this approach due to lock dependency.

I am not sure where this came from. I am all for this approach. It will
not solve the problem completely for sure but it can help in many cases
already.

> We already spent 9 months on this OOM livelock. No silver bullet yet.
> Proposed approaches are too drastic to backport for existing users.
> I think we are out of bullet.

Not at all. We have this problem since ever basically. And we have a lot
of legacy issues to care about. But nobody could reasonably expect this
will be solved in a short time period.

> Until we complete adding/testing __GFP_NORETRY (or __GFP_KILLABLE) to most
> of callsites,

This is simply not doable. There are thousand of allocation sites all
over the kernel.

> timeout based workaround will be the only bullet we can use.

Those are the last resort which only paper over real bugs which should
be fixed. I would agree with your urging if this was something that can
easily happen on a _properly_ configured system. System which can blow
into an OOM storm is far from being configured properly. If you have an
untrusted users running on your system you should better put them into a
highly restricted environment and limit as much as possible.

I can completely understand your frustration about the pace of the
progress here but this is nothing new and we should strive for long term
vision which would be much less fragile than what we have right now. No
timeout based solution is the way in that direction.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
