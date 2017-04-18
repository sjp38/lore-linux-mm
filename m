Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 300436B03A2
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 19:10:38 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s19so4417590pgn.14
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 16:10:38 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id d66si509804pfb.67.2017.04.18.16.10.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 16:10:37 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id a188so3354113pfa.0
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 16:10:37 -0700 (PDT)
Date: Tue, 18 Apr 2017 16:10:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm, page_alloc: Remove debug_guardpage_minorder()
 test in warn_alloc().
In-Reply-To: <1492525366-4929-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1704181604460.141160@chino.kir.corp.google.com>
References: <1492525366-4929-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Stanislaw Gruszka <sgruszka@redhat.com>

On Tue, 18 Apr 2017, Tetsuo Handa wrote:

> Commit c0a32fc5a2e470d0 ("mm: more intensive memory corruption debugging")
> changed to check debug_guardpage_minorder() > 0 when reporting allocation
> failures. The reasoning was
> 
>   When we use guard page to debug memory corruption, it shrinks available
>   pages to 1/2, 1/4, 1/8 and so on, depending on parameter value.
>   In such case memory allocation failures can be common and printing
>   errors can flood dmesg. If somebody debug corruption, allocation
>   failures are not the things he/she is interested about.
> 
> but is misguided.
> 

As discussed privately, I think the reasoning is worthwhile.  
debug_guardpage_minorder is effectively pulling DIMMs from your system 
from the perspective of the buddy allocator, which triggers these 
warnings.  Nobody will be deploying with this config on production 
systems, they are interesting in debugging or triaging issues.  As a 
result, I agree that low on memory or fragmentation issues as a result of 
the overhead required for this debugging is not interesting to report.  

> Allocation requests with __GFP_NOWARN flag by definition do not cause
> flooding of allocation failure messages. Allocation requests with
> __GFP_NORETRY flag likely also have __GFP_NOWARN flag. Costly allocation
> requests likely also have __GFP_NOWARN flag.
> 
> Allocation requests without __GFP_DIRECT_RECLAIM flag likely also have
> __GFP_NOWARN flag or __GFP_HIGH flag. Non-costly allocation requests with
> __GFP_DIRECT_RECLAIM flag basically retry forever due to the "too small to
> fail" memory-allocation rule.
> 
> Therefore, as a whole, shrinking available pages by
> debug_guardpage_minorder= kernel boot parameter might cause flooding of
> OOM killer messages but unlikely causes flooding of allocation failure
> messages. Let's remove debug_guardpage_minorder() > 0 check which would
> likely be pointless.
> 

Hmm, not necessarily, the oom killer can be used in situations where the 
context allows it but there is still a great possibility that we are 
getting page allocation failure warnings in softirq context, including 
high-order allocations from the networking layer.  I think the reasoning 
presented by Stanislaw in commit c0a32fc5a2e4 is correct and we ought to 
avoid allocation failure warnings spamming the log when looking for real 
debugging information.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
