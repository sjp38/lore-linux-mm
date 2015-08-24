Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1AB3E6B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 09:20:11 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so72095681wic.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 06:20:10 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id l18si21424047wie.104.2015.08.24.06.20.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 06:20:09 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so72094807wic.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 06:20:08 -0700 (PDT)
Date: Mon, 24 Aug 2015 15:20:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [REPOST] [PATCH 1/2] mm: Fix race between setting TIF_MEMDIE and
 __alloc_pages_high_priority().
Message-ID: <20150824132006.GN17078@dhcp22.suse.cz>
References: <201508231621.EGJ17658.FFQJtFSLVOOHMO@I-love.SAKURA.ne.jp>
 <20150824100319.GG17078@dhcp22.suse.cz>
 <201508242152.HHB69241.OFJLFVtFHQOMSO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201508242152.HHB69241.OFJLFVtFHQOMSO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

On Mon 24-08-15 21:52:08, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > The comment above the check is misleading but now you are allowing to
> > fail all ALLOC_NO_WATERMARKS (without __GFP_NOFAIL) allocations before
> > entering the direct reclaim and compaction. This seems incorrect. What
> > about __GFP_MEMALLOC requests?
> 
> So, you want __GPP_MEMALLOC to retry forever unless TIF_MEMDIE is set, don't
> you?

I am not saying that. I was just pointing out that you have changed the
behavior of this gfp flag.

> > I think the check for TIF_MEMDIE makes more sense here.
> 
> Since we already failed to allocate from memory reserves, I don't know if
> direct reclaim and compaction can work as expected under such situation.

Yes the allocation has failed and the reclaim might not do any
progress. Withtout trying to the reclaim we simply do not know that,
though.
The TIF_MEMDIE check was explicit for a good reason IMO. The race is not
really that important AFAICS because we would only fail the allocation
sooner for the OOM victim and that one might fail already. I might be
missing something of course but your change has a higher risk of
undesired behavior than the original code.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
