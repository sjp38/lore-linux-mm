Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A7E7A6B0397
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 17:47:34 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id r129so3266247pgr.18
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:47:34 -0700 (PDT)
Received: from mail-pg0-x234.google.com (mail-pg0-x234.google.com. [2607:f8b0:400e:c05::234])
        by mx.google.com with ESMTPS id 66si336212pgh.214.2017.04.18.14.47.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 14:47:33 -0700 (PDT)
Received: by mail-pg0-x234.google.com with SMTP id 72so2726722pge.2
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:47:33 -0700 (PDT)
Date: Tue, 18 Apr 2017 14:47:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm,page_alloc: Split stall warning and failure
 warning.
In-Reply-To: <201704182049.BIE34837.FJOFOMFOQSLHVt@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1704181435560.112481@chino.kir.corp.google.com>
References: <1491825493-8859-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <20170410150308.c6e1a0213c32e6d587b33816@linux-foundation.org> <alpine.DEB.2.10.1704171539190.46404@chino.kir.corp.google.com>
 <201704182049.BIE34837.FJOFOMFOQSLHVt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org, mhocko@kernel.org, sgruszka@redhat.com

On Tue, 18 Apr 2017, Tetsuo Handa wrote:

> > I have a couple of suggestions for Tetsuo about this patch, though:
> > 
> >  - We now have show_mem_rs, stall_rs, and nopage_rs.  Ugh.  I think it's
> >    better to get rid of show_mem_rs and let warn_alloc_common() not 
> >    enforce any ratelimiting at all and leave it to the callers.
> 
> Commit aa187507ef8bb317 ("mm: throttle show_mem() from warn_alloc()") says
> that show_mem_rs was added because a big part of the output is show_mem()
> which can generate a lot of output even on a small machines. Thus, I think
> ratelimiting at warn_alloc_common() makes sense for users who want to use
> warn_alloc_stall() for reporting stalls.
> 

The suggestion is to eliminate show_mem_rs, it has an interval of HZ and 
burst of 1 when the calling function(s), warn_alloc() and 
warn_alloc_stall(), will have intervals of 5 * HZ and burst of 10.  We 
don't need show_mem_rs :)

> >  - warn_alloc() is probably better off renamed to warn_alloc_failed()
> >    since it enforces __GFP_NOWARN and uses an allocation failure ratelimit 
> >    regardless of what the passed text is.
> 
> I'm OK to rename warn_alloc() back to warn_alloc_failed() for reporting
> allocation failures. Maybe we can remove debug_guardpage_minorder() > 0
> check from warn_alloc_failed() anyway.
> 

s/warn_alloc/warn_alloc_failed/ makes sense because the function is 
warning of allocation failures, not warning of allocations lol.

I think the debug_guardpage_minorder() check makes sense for failed 
allocations because we are essentially removing memory from the system for 
debug, failed allocations as a result of low on memory or fragmentation 
aren't concerning if we are removing memory from the system.  It isn't 
needed for allocation stalls, though, if the guard pages were actually 
mapped memory in use we would still be concerned about lengthy allocation 
stalls.  So I think we should have a debug_guardpage_minorder() check for 
warn_alloc_failed() and not for warn_alloc_stall().

If you choose to follow-up with this, I'd happily ack it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
