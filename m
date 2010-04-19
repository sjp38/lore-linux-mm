Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7B87D6B01EF
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 11:20:57 -0400 (EDT)
Date: Mon, 19 Apr 2010 16:20:34 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100419152034.GW19264@csn.ul.ie>
References: <20100413202021.GZ13327@think> <20100414014041.GD2493@dastard> <20100414155233.D153.A69D9226@jp.fujitsu.com> <20100414072830.GK2493@dastard> <20100414085132.GJ25756@csn.ul.ie> <20100415013436.GO2493@dastard> <20100415102837.GB10966@csn.ul.ie> <20100416041412.GY2493@dastard> <20100416151403.GM19264@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100416151403.GM19264@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 16, 2010 at 04:14:03PM +0100, Mel Gorman wrote:
> > > Your patch fixes 2, avoids 1, breaks 3 and haven't thought about 4 but I
> > > guess dirty pages can cycle around more so it'd need to be cared for.
> > 
> > Well, you keep saying that they break #3, but I haven't seen any
> > test cases or results showing that. I've been unable to confirm that
> > lumpy reclaim is broken by disallowing writeback in my testing, so
> > I'm interested to know what tests you are running that show it is
> > broken...
> > 
> 
> Ok, I haven't actually tested this. The machines I use are tied up
> retesting the compaction patches at the moment. The reason why I reckon
> it'll be a problem is that when these sync-writeback changes were
> introduced, it significantly helped lumpy reclaim for huge pages. I am
> making an assumption that backing out those changes will hurt it.
> 
> I'll test for real on Monday and see what falls out.
> 

One machine has completed the test and the results are as expected. When
allocating huge pages under stress, your patch drops the success rates
significantly. On X86-64, it showed

STRESS-HIGHALLOC
              stress-highalloc   stress-highalloc
            enable-directreclaim disable-directreclaim
Under Load 1    89.00 ( 0.00)    73.00 (-16.00)
Under Load 2    90.00 ( 0.00)    85.00 (-5.00)
At Rest         90.00 ( 0.00)    90.00 ( 0.00)

So with direct reclaim, it gets 89% of memory as huge pages at the first
attempt but 73% with your patch applied. The "Under Load 2" test happens
immediately after. With the start kernel, the first and second attempts
are usually the same or very close together. With your patch applied,
there are big differences as it was no longer trying to clean pages.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
