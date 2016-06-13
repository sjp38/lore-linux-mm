Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9180D6B0005
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 10:54:30 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id f6so78981726ith.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 07:54:30 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f45si5653481otc.8.2016.06.13.07.54.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Jun 2016 07:54:29 -0700 (PDT)
Subject: Re: [RFC PATCH 1/2] mm, tree wide: replace __GFP_REPEAT by __GFP_RETRY_HARD with more useful semantic
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1465212736-14637-2-git-send-email-mhocko@kernel.org>
	<7fb7e035-7795-839b-d1b0-4a68fcf8e9c9@I-love.SAKURA.ne.jp>
	<20160607123149.GK12305@dhcp22.suse.cz>
	<201606112335.HBG09891.OLFJOFtVMOQHSF@I-love.SAKURA.ne.jp>
	<20160613113726.GE6518@dhcp22.suse.cz>
In-Reply-To: <20160613113726.GE6518@dhcp22.suse.cz>
Message-Id: <201606132354.AJG05292.MOFVQJOFLFSHtO@I-love.SAKURA.ne.jp>
Date: Mon, 13 Jun 2016 23:54:13 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, hannes@cmpxchg.org, riel@redhat.com, david@fromorbit.com, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Sat 11-06-16 23:35:49, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Tue 07-06-16 21:11:03, Tetsuo Handa wrote:
> > > > Remaining __GFP_REPEAT users are not always doing costly allocations.
> > > 
> > > Yes but...
> > > 
> > > > Sometimes they pass __GFP_REPEAT because the size is given from userspace.
> > > > Thus, unconditional s/__GFP_REPEAT/__GFP_RETRY_HARD/g is not good.
> > > 
> > > Would that be a regression though? Strictly speaking the __GFP_REPEAT
> > > documentation was explicit to not loop for ever. So nobody should have
> > > expected nofail semantic pretty much by definition. The fact that our
> > > previous implementation was not fully conforming to the documentation is
> > > just an implementation detail.  All the remaining users of __GFP_REPEAT
> > > _have_ to be prepared for the allocation failure. So what exactly is the
> > > problem with them?
> > 
> > A !costly allocation becomes weaker than now if __GFP_RETRY_HARD is passed.
> 
> That is true. But it is not weaker than the __GFP_REPEAT actually ever
> promissed. __GFP_REPEAT explicitly said to not retry _for_ever_. The
> fact that we have ignored it is sad but that is what I am trying to
> address here.

Whatever you rename __GFP_REPEAT to, it sounds strange to me that !costly
__GFP_REPEAT allocations are weaker than !costly !__GFP_REPEAT allocations.
Are you planning to make !costly !__GFP_REPEAT allocations to behave like
__GFP_NORETRY?

> 
> > > > >  	/* Reclaim has failed us, start killing things */
> > > > >  	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
> > > > >  	if (page)
> > > > > @@ -3719,6 +3731,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> > > > >  	/* Retry as long as the OOM killer is making progress */
> > > > >  	if (did_some_progress) {
> > > > >  		no_progress_loops = 0;
> > > > > +		passed_oom = true;
> > > > 
> > > > This is too premature. did_some_progress != 0 after returning from
> > > > __alloc_pages_may_oom() does not mean the OOM killer was invoked. It only means
> > > > that mutex_trylock(&oom_lock) was attempted.
> > > 
> > > which means that we have reached the OOM condition and _somebody_ is
> > > actaully handling the OOM on our behalf.
> > 
> > That _somebody_ might release oom_lock without invoking the OOM killer (e.g.
> > doing !__GFP_FS allocation), which means that we have reached the OOM condition
> > and nobody is actually handling the OOM on our behalf. __GFP_RETRY_HARD becomes
> > as weak as __GFP_NORETRY. I think this is a regression.
> 
> I really fail to see your point. We are talking about a gfp flag which
> tells the allocator to retry as much as it is feasible. Getting through
> all the reclaim attempts two times without any progress sounds like a
> fair criterion. Well, we could try $NUM times but that wouldn't make too
> much difference to what you are writing above. The fact whether somebody
> has been killed or not is not really that important IMHO.

If all the reclaim attempt first time made no progress, all the reclaim
attempt second time unlikely make progress unless the OOM killer kills
something. Thus, doing all the reclaim attempts two times without any progress
without killing somebody sounds almost equivalent to doing all the reclaim
attempt only once.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
