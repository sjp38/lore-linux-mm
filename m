Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id F418E6B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 11:40:34 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id i85so44912113pfa.5
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 08:40:34 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id an6si8236865pad.167.2016.10.12.08.40.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 08:40:34 -0700 (PDT)
Date: Wed, 12 Oct 2016 08:40:33 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] Don't touch single threaded PTEs which are on the right
 node
Message-ID: <20161012154033.GH3078@tassilo.jf.intel.com>
References: <1476217738-10451-1-git-send-email-andi@firstfloor.org>
 <20161012054933.GB20573@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161012054933.GB20573@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, peterz@infradead.org, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

> You shouldn't need to check the number of mm_users and the node the task
> is running on for every PTE being scanned.

Ok.

> 
> A more important corner case is if the VMA is shared with a task running on
> another node. By avoiding the NUMA hinting faults here, the hinting faults
> trapped by the remote process will appear exclusive and allow migration of
> the page. This will happen even if the single-threade task is continually
> using the pages.
> 
> When you said "we had some problems", you didn't describe the workload or
> what the problems were (I'm assuming latency/jitter). Would restricting
> this check to private VMAs be sufficient?

The problem we ran into was that prefetches were not working, but
yes it would also cause extra latencies and jitter and in general
is unnecessary overhead.

It is super easy to reproduce. Just run main() {for(;;);}
It will eventually get some of its pages unmapped.

Yes doing it for private only would be fine. I'll add a check
for that.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
