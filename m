Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 94AA46B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 14:55:02 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id j6so7121597lfb.1
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 11:55:02 -0700 (PDT)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id 134si5713909wmt.50.2016.06.14.11.55.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 11:55:01 -0700 (PDT)
Received: by mail-wm0-f50.google.com with SMTP id v199so133870546wmv.0
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 11:55:01 -0700 (PDT)
Date: Tue, 14 Jun 2016 20:54:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, tree wide: replace __GFP_REPEAT by
 __GFP_RETRY_HARD with more useful semantic
Message-ID: <20160614185458.GA22336@dhcp22.suse.cz>
References: <20160607123149.GK12305@dhcp22.suse.cz>
 <201606112335.HBG09891.OLFJOFtVMOQHSF@I-love.SAKURA.ne.jp>
 <20160613113726.GE6518@dhcp22.suse.cz>
 <201606132354.AJG05292.MOFVQJOFLFSHtO@I-love.SAKURA.ne.jp>
 <20160613151726.GL6518@dhcp22.suse.cz>
 <201606142012.HEJ69240.FFLFOOtMJVOSHQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606142012.HEJ69240.FFLFOOtMJVOSHQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, hannes@cmpxchg.org, riel@redhat.com, david@fromorbit.com, linux-kernel@vger.kernel.org

On Tue 14-06-16 20:12:08, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > > > That _somebody_ might release oom_lock without invoking the OOM killer (e.g.
> > > > > doing !__GFP_FS allocation), which means that we have reached the OOM condition
> > > > > and nobody is actually handling the OOM on our behalf. __GFP_RETRY_HARD becomes
> > > > > as weak as __GFP_NORETRY. I think this is a regression.
> > > > 
> > > > I really fail to see your point. We are talking about a gfp flag which
> > > > tells the allocator to retry as much as it is feasible. Getting through
> > > > all the reclaim attempts two times without any progress sounds like a
> > > > fair criterion. Well, we could try $NUM times but that wouldn't make too
> > > > much difference to what you are writing above. The fact whether somebody
> > > > has been killed or not is not really that important IMHO.
> > > 
> > > If all the reclaim attempt first time made no progress, all the reclaim
> > > attempt second time unlikely make progress unless the OOM killer kills
> > > something. Thus, doing all the reclaim attempts two times without any progress
> > > without killing somebody sounds almost equivalent to doing all the reclaim
> > > attempt only once.
> > 
> > Yes, that is possible. You might have a GFP_NOFS only load where nothing
> > really invokes the OOM killer. Does that actually matter, though? The
> > semantic of the flag is to retry hard while the page allocator believes
> > it can make a forward progress. But not for ever. We never know whether
> > a progress is possible at all. We have certain heuristics when to give
> > up, try to invoke OOM killer and try again hoping things have changed.
> > This is not much different except we declare that no hope to getting to
> > the OOM point again without being able to succeed. Are you suggesting
> > a more precise heuristic? Or do you claim that we do not need a flag
> > which would put a middle ground between __GFP_NORETRY and __GFP_NOFAIL
> > which are on the extreme sides?
> 
> Well, maybe we can get rid of __GFP_RETRY (or make __GFP_RETRY used for only
> huge pages). Many __GFP_RETRY users are ready to fall back to vmalloc().

But some of them should try hard before they fall back to vmalloc. And
let me repeat, there valid usecases when you want to to tell the
allocator to not retry !costly requests for ever.

> We are not sure whether such __GFP_RETRY users want to retry with OOM-killing
> somebody (we don't have __GFP_MAY_OOM_KILL which explicitly asks for "retry
> with OOM-killing somebody").

And we do not want something like __GFP_MAY_OOM_KILL. We have
__GFP_NORETRY to tell to bail out early. We do not want callers to
control the OOM behavior. That is an MM internal thing IMHO.

> If __GFP_RETRY means nothing but try once more,
> 
> 	void *n = kzalloc(size, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY);
> 	if (!n)
> 		n = kzalloc(size, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY);
> 
> will emulate it.

It won't. __GFP_NORETRY is way too weak because it only invokes
optimistic compaction so the success rate would be really small even if
you retry with the same flag multiple times in a row. We definitely need
a stronger mode to tell that the allocator should really try hard before
it fails.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
