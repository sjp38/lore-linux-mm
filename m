Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 11F2D6B025F
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 11:17:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 4so30765819wmz.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 08:17:31 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id b199si13773251wmb.78.2016.06.13.08.17.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 08:17:28 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id r5so15686244wmr.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 08:17:28 -0700 (PDT)
Date: Mon, 13 Jun 2016 17:17:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, tree wide: replace __GFP_REPEAT by
 __GFP_RETRY_HARD with more useful semantic
Message-ID: <20160613151726.GL6518@dhcp22.suse.cz>
References: <1465212736-14637-2-git-send-email-mhocko@kernel.org>
 <7fb7e035-7795-839b-d1b0-4a68fcf8e9c9@I-love.SAKURA.ne.jp>
 <20160607123149.GK12305@dhcp22.suse.cz>
 <201606112335.HBG09891.OLFJOFtVMOQHSF@I-love.SAKURA.ne.jp>
 <20160613113726.GE6518@dhcp22.suse.cz>
 <201606132354.AJG05292.MOFVQJOFLFSHtO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606132354.AJG05292.MOFVQJOFLFSHtO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, hannes@cmpxchg.org, riel@redhat.com, david@fromorbit.com, linux-kernel@vger.kernel.org

On Mon 13-06-16 23:54:13, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sat 11-06-16 23:35:49, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Tue 07-06-16 21:11:03, Tetsuo Handa wrote:
> > > > > Remaining __GFP_REPEAT users are not always doing costly allocations.
> > > > 
> > > > Yes but...
> > > > 
> > > > > Sometimes they pass __GFP_REPEAT because the size is given from userspace.
> > > > > Thus, unconditional s/__GFP_REPEAT/__GFP_RETRY_HARD/g is not good.
> > > > 
> > > > Would that be a regression though? Strictly speaking the __GFP_REPEAT
> > > > documentation was explicit to not loop for ever. So nobody should have
> > > > expected nofail semantic pretty much by definition. The fact that our
> > > > previous implementation was not fully conforming to the documentation is
> > > > just an implementation detail.  All the remaining users of __GFP_REPEAT
> > > > _have_ to be prepared for the allocation failure. So what exactly is the
> > > > problem with them?
> > > 
> > > A !costly allocation becomes weaker than now if __GFP_RETRY_HARD is passed.
> > 
> > That is true. But it is not weaker than the __GFP_REPEAT actually ever
> > promissed. __GFP_REPEAT explicitly said to not retry _for_ever_. The
> > fact that we have ignored it is sad but that is what I am trying to
> > address here.
> 
> Whatever you rename __GFP_REPEAT to, it sounds strange to me that !costly
> __GFP_REPEAT allocations are weaker than !costly !__GFP_REPEAT allocations.
> Are you planning to make !costly !__GFP_REPEAT allocations to behave like
> __GFP_NORETRY?

The patch description tries to explain the difference:
__GFP_NORETRY doesn't retry at all
__GFP_RETRY_HARD retries as hard as feasible
__GFP_NOFAIL tells the retry for ever

all of them regardless of the order. This is the way how to tell the
allocator to change its default behavior which might be, and actually
is, different depending on the order.

[...]
> > > That _somebody_ might release oom_lock without invoking the OOM killer (e.g.
> > > doing !__GFP_FS allocation), which means that we have reached the OOM condition
> > > and nobody is actually handling the OOM on our behalf. __GFP_RETRY_HARD becomes
> > > as weak as __GFP_NORETRY. I think this is a regression.
> > 
> > I really fail to see your point. We are talking about a gfp flag which
> > tells the allocator to retry as much as it is feasible. Getting through
> > all the reclaim attempts two times without any progress sounds like a
> > fair criterion. Well, we could try $NUM times but that wouldn't make too
> > much difference to what you are writing above. The fact whether somebody
> > has been killed or not is not really that important IMHO.
> 
> If all the reclaim attempt first time made no progress, all the reclaim
> attempt second time unlikely make progress unless the OOM killer kills
> something. Thus, doing all the reclaim attempts two times without any progress
> without killing somebody sounds almost equivalent to doing all the reclaim
> attempt only once.

Yes, that is possible. You might have a GFP_NOFS only load where nothing
really invokes the OOM killer. Does that actually matter, though? The
semantic of the flag is to retry hard while the page allocator believes
it can make a forward progress. But not for ever. We never know whether
a progress is possible at all. We have certain heuristics when to give
up, try to invoke OOM killer and try again hoping things have changed.
This is not much different except we declare that no hope to getting to
the OOM point again without being able to succeed. Are you suggesting
a more precise heuristic? Or do you claim that we do not need a flag
which would put a middle ground between __GFP_NORETRY and __GFP_NOFAIL
which are on the extreme sides?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
