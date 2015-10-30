Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4670F82F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 10:55:42 -0400 (EDT)
Received: by wijp11 with SMTP id p11so12839914wij.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 07:55:41 -0700 (PDT)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id wz6si9492733wjc.9.2015.10.30.07.55.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Oct 2015 07:55:41 -0700 (PDT)
Received: by wmll128 with SMTP id l128so14255844wml.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 07:55:41 -0700 (PDT)
Date: Fri, 30 Oct 2015 15:55:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/3] mm, oom: refactor oom detection
Message-ID: <20151030145539.GF23627@dhcp22.suse.cz>
References: <1446131835-3263-1-git-send-email-mhocko@kernel.org>
 <1446131835-3263-2-git-send-email-mhocko@kernel.org>
 <00f201d112c8$e2377720$a6a66560$@alibaba-inc.com>
 <20151030083626.GC18429@dhcp22.suse.cz>
 <20151030101436.GH18429@dhcp22.suse.cz>
 <201510302232.FCH52626.OQJOFHSVFFOtLM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201510302232.FCH52626.OQJOFHSVFFOtLM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hillf.zj@alibaba-inc.com, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com, rientjes@google.com, linux-kernel@vger.kernel.org

On Fri 30-10-15 22:32:27, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > +		target -= (stall_backoff * target + MAX_STALL_BACKOFF - 1) / MAX_STALL_BACKOFF;
> target -= DIV_ROUND_UP(stall_backoff * target, MAX_STALL_BACKOFF);

Ohh, we have a macro for that. Good to know. Thanks. It sure looks much
easier to follow.
 
> Michal Hocko wrote:
> > This alone wouldn't be sufficient, though, because the writeback might
> > get stuck and reclaimable pages might be pinned for a really long time
> > or even depend on the current allocation context.
> 
> Is this a dependency which I worried at
> http://lkml.kernel.org/r/201510262044.BAI43236.FOMSFFOtOVLJQH@I-love.SAKURA.ne.jp ?

Yes, I had restricted allocation contexts in mind here.

> >                                                   Therefore there is a
> > feedback mechanism implemented which reduces the reclaim target after
> > each reclaim round without any progress.
> 
> If yes, this feedback mechanism will help avoiding infinite wait loop.
> 
> >                                          This means that we should
> > eventually converge to only NR_FREE_PAGES as the target and fail on the
> > wmark check and proceed to OOM.
> 
> What if all in-flight allocation requests are !__GFP_NOFAIL && !__GFP_FS ?

Then we will loop like crazy hoping that _something_ will reclaim memory
for us. Same as we do now.

> (In other words, either "no __GFP_FS allocations are in-flight" or "all
> __GFP_FS allocations are in-flight but are either waiting for completion
> of operations which depend on !__GFP_FS allocations with a lock held or
> waiting for that lock to be released".)
> 
> Don't we need to call out_of_memory() even though !__GFP_FS allocations?

I do not think this is in scope of this patch series. I am trying to
normalize the OOM detection and GFP_FS is a separate beast and we do not
have enough counters to decide the whether OOM killer would be
premature or not (e.g. we do not know how much memory is unreclaimable
just because of NOFS context). I am convinced that GFP_FS simply has to
fail the allocation as I've suggested quite some time ago and plan to
revisit it soon(ish). I consider the two orthogonal.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
