Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 156416B03A1
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 08:39:39 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id b78so2536745wrd.18
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 05:39:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x8si6072564wmg.92.2017.04.10.05.39.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 05:39:37 -0700 (PDT)
Date: Mon, 10 Apr 2017 14:39:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,page_alloc: Split stall warning and failure warning.
Message-ID: <20170410123934.GB4618@dhcp22.suse.cz>
References: <1491825493-8859-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1491825493-8859-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>

On Mon 10-04-17 20:58:13, Tetsuo Handa wrote:
> Patch "mm: page_alloc: __GFP_NOWARN shouldn't suppress stall warnings"
> changed to drop __GFP_NOWARN when calling warn_alloc() for stall warning.
> Although I suggested for two times to drop __GFP_NOWARN when warn_alloc()
> for stall warning was proposed, Michal Hocko does not want to print stall
> warnings when __GFP_NOWARN is given [1][2].
> 
>  "I am not going to allow defining a weird __GFP_NOWARN semantic which
>   allows warnings but only sometimes. At least not without having a proper
>   way to silence both failures _and_ stalls or just stalls. I do not
>   really thing this is worth the additional gfp flag."
> 
> I don't know whether he is aware of "mm: page_alloc: __GFP_NOWARN
> shouldn't suppress stall warnings" patch, but I assume that
> no response means he finally accepted this change.

I am certainly not happy about it but I just do not have time to
endlessly discuss this absolutely minor thing. I have raised my worries
already.

> Therefore,
> this patch splits into a function for reporting allocation stalls
> and a function for reporting allocation failures, due to below reasons.
> 
>   (1) Dropping __GFP_NOWARN when calling warn_alloc() causes
>       "mode:%#x(%pGg)" to report incorrect flags. It can confuse
>       developers when scanning the source code for corresponding
>       location.

You have the backtrace which make it clear _what_ is the allocation
context.

>   (2) Not reporting when debug_guardpage_minorder() > 0 causes failing
>       to report stall warnings. Stall warnings should not be be disabled
>       by debug_guardpage_minorder() > 0 as well as __GFP_NOWARN.

Could you remind me why this matter at all? Who is the user and why does
it matter?

>   (3) Sharing warn_alloc() for reporting stalls (which is guaranteed
>       to be schedulable context) and for reporting failures (which is
>       not guaranteed to be schedulable context) is inconvenient when
>       adding a mutex for serializing printk() messages and/or filtering
>       events which should be handled for further analysis based on
>       function name.
> 
>       # stap -F -g -e 'probe kernel.function("warn_alloc").return {
>                        if (determine_whether_reason_is_allocation_stall)
>                            panic("MemAlloc stall detected."); }'
> 
>       # stap -F -g -e 'probe kernel.function("warn_alloc_stall").return {
>                        panic("MemAlloc stall detected."); }'

This is not a sufficient reason to add more code.
> 
>       Although adding allocation watchdog [3] will do it more powerfully,
>       allocation watchdog discussion is still stalling. Thus, for now
>       I propose triggering from warn_alloc_stall().
> 
> [1] http://lkml.kernel.org/r/20160929091040.GE408@dhcp22.suse.cz
> [2] http://lkml.kernel.org/r/20170114090613.GD9962@dhcp22.suse.cz
> [3] http://lkml.kernel.org/r/1489578541-81526-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>

NAK. This just adds a pointless code and it doesn't solve any real
issue.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
