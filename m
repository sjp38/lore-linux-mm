Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 854EE6B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 04:32:41 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id e12so92543001ioj.0
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 01:32:41 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id 141si1780477itu.33.2017.03.03.01.32.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 01:32:40 -0800 (PST)
Date: Fri, 3 Mar 2017 10:32:38 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170303093238.GI6536@twins.programming.kicks-ass.net>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228134018.GK5680@worktop>
 <20170301054323.GE11663@X58A-UD3R>
 <20170301122843.GF6515@twins.programming.kicks-ass.net>
 <20170302134031.GG6536@twins.programming.kicks-ass.net>
 <20170303001737.GF28562@X58A-UD3R>
 <20170303081416.GT6515@twins.programming.kicks-ass.net>
 <20170303091338.GH6536@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170303091338.GH6536@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com, kernel-team@lge.com, Michal Hocko <mhocko@kernel.org>, Nikolay Borisov <nborisov@suse.com>, Mel Gorman <mgorman@suse.de>

On Fri, Mar 03, 2017 at 10:13:38AM +0100, Peter Zijlstra wrote:
> On Fri, Mar 03, 2017 at 09:14:16AM +0100, Peter Zijlstra wrote:
> 
> > That said; I'd be fairly interested in numbers on how many links this
> > avoids, I'll go make a check_redundant() version of the above and put a
> > proper counter in so I can see what it does for a regular boot etc..
> 
> Two boots + a make defconfig, the first didn't have the redundant bit
> in, the second did (full diff below still includes the reclaim rework,
> because that was still in that kernel and I forgot to reset the tree).
> 
> 
>  lock-classes:                         1168       1169 [max: 8191]
>  direct dependencies:                  7688       5812 [max: 32768]
>  indirect dependencies:               25492      25937
>  all direct dependencies:            220113     217512
>  dependency chains:                    9005       9008 [max: 65536]
>  dependency chain hlocks:             34450      34366 [max: 327680]
>  in-hardirq chains:                      55         51
>  in-softirq chains:                     371        378
>  in-process chains:                    8579       8579
>  stack-trace entries:                108073      88474 [max: 524288]
>  combined max dependencies:       178738560  169094640
> 
>  max locking depth:                      15         15
>  max bfs queue depth:                   320        329
> 
>  cyclic checks:                        9123       9190
> 
>  redundant checks:                                5046
>  redundant links:                                 1828
> 
>  find-mask forwards checks:            2564       2599
>  find-mask backwards checks:          39521      39789
> 

OK, last email, I promise, then I'll go bury myself in futexes.

 find-mask forwards checks:            2999
 find-mask backwards checks:          56134

Is with a clean kernel, which shows how many __bfs() calls we save by
doing away with that RECLAIM state. OTOH:

 lock-classes:                         1167 [max: 8191]
 direct dependencies:                  7254 [max: 32768]
 indirect dependencies:               23763
 all direct dependencies:            219093

Shows that the added reclaim class isn't entirely free either ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
