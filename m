Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id B7C7D6B0255
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 18:21:41 -0400 (EDT)
Received: by pacwi10 with SMTP id wi10so9153360pac.3
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 15:21:41 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id lg2si11568330pbc.60.2015.09.01.15.21.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 15:21:41 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so9248930pac.2
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 15:21:40 -0700 (PDT)
Date: Tue, 1 Sep 2015 15:21:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [REPOST] [PATCH 2/2] mm: Fix potentially scheduling in GFP_ATOMIC
 allocations.
In-Reply-To: <201508231623.DED13020.tFOHFVFQOSOLMJ@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1509011519170.11913@chino.kir.corp.google.com>
References: <201508231623.DED13020.tFOHFVFQOSOLMJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On Sun, 23 Aug 2015, Tetsuo Handa wrote:

> >From 08a638e04351386ab03cd1223988ac7940d4d3aa Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sat, 1 Aug 2015 22:46:12 +0900
> Subject: [PATCH 2/2] mm: Fix potentially scheduling in GFP_ATOMIC
>  allocations.
> 
> Currently, if somebody does GFP_ATOMIC | __GFP_NOFAIL allocation,
> wait_iff_congested() might be called via __alloc_pages_high_priority()
> before reaching
> 
>   if (!wait) {
>     WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL);
>     goto nopage;
>   }
> 
> because gfp_to_alloc_flags() includes ALLOC_NO_WATERMARKS if TIF_MEMDIE
> was set.
> 
> We need to check for __GFP_WAIT flag at __alloc_pages_high_priority()
> in order to make sure that we won't schedule.
> 

I've brought the GFP_ATOMIC | __GFP_NOFAIL combination up before, which 
resulted in the WARN_ON_ONCE() that you cited.  We don't support such a 
combination.  Fixing up the documentation in any places you feel it is 
deficient would be the best.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
