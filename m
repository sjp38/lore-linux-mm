Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AAEA26B03A5
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 18:48:35 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j16so93169089pfk.4
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 15:48:35 -0700 (PDT)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id v21si12523012pfl.286.2017.04.17.15.48.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Apr 2017 15:48:35 -0700 (PDT)
Received: by mail-pf0-x22c.google.com with SMTP id 194so32430805pfv.3
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 15:48:35 -0700 (PDT)
Date: Mon, 17 Apr 2017 15:48:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm,page_alloc: Split stall warning and failure
 warning.
In-Reply-To: <20170410150308.c6e1a0213c32e6d587b33816@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1704171539190.46404@chino.kir.corp.google.com>
References: <1491825493-8859-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <20170410150308.c6e1a0213c32e6d587b33816@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Mon, 10 Apr 2017, Andrew Morton wrote:

> I interpret __GFP_NOWARN to mean "don't warn about this allocation
> attempt failing", not "don't warn about anything at all".  It's a very
> minor issue but yes, methinks that stall warning should still come out.
> 

Agreed, and we have found this to be helpful in automated memory stress 
tests.

I agree that masking off __GFP_NOWARN and then reporting the gfp_mask to 
the user is only harmful.  If the allocation stalls vs allocation failure 
warnings are separated such as you have done, it is easily preventable.

I have a couple of suggestions for Tetsuo about this patch, though:

 - We now have show_mem_rs, stall_rs, and nopage_rs.  Ugh.  I think it's
   better to get rid of show_mem_rs and let warn_alloc_common() not 
   enforce any ratelimiting at all and leave it to the callers.

 - warn_alloc() is probably better off renamed to warn_alloc_failed()
   since it enforces __GFP_NOWARN and uses an allocation failure ratelimit 
   regardless of what the passed text is.

It may also be slightly off-topic, but I think it would be useful to print 
current's pid.  I find printing its parent's pid and comm helpful when 
using shared libraries, but you may not agree.

Otherwise, I think this is a good direction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
