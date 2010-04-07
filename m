Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C56106B01E3
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 12:12:15 -0400 (EDT)
Date: Wed, 7 Apr 2010 17:11:43 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 12/14] Add a tunable that decides when memory should be
	compacted and when it should be reclaimed
Message-ID: <20100407161143.GU17882@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie> <1270224168-14775-13-git-send-email-mel@csn.ul.ie> <20100406170613.9b80c7ea.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100406170613.9b80c7ea.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 05:06:13PM -0700, Andrew Morton wrote:
> On Fri,  2 Apr 2010 17:02:46 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > The kernel applies some heuristics when deciding if memory should be
> > compacted or reclaimed to satisfy a high-order allocation. One of these
> > is based on the fragmentation. If the index is below 500, memory will
> > not be compacted. This choice is arbitrary and not based on data. To
> > help optimise the system and set a sensible default for this value, this
> > patch adds a sysctl extfrag_threshold. The kernel will only compact
> > memory if the fragmentation index is above the extfrag_threshold.
> 
> Was this the most robust, reliable, no-2am-phone-calls thing we could
> have done?
> 
> What about, say, just doing a bit of both until something worked? 

I guess you could but that is not a million miles away from what
currently happens.

This heuristic is basically "based on free memory layout, how likely is
compaction to succeed?". It makes a decision based on that. A later
patch then checks if the guess was right. If not, just try direct
reclaim for a bit before trying compaction again.

> For
> extra smarts we could remember what worked best last time, and make
> ourselves more likely to try that next time.
> 

With the later patch, this is essentially what we do. Granted we
remember the opposite "If the kernel guesses wrong, then don't compact
for a short while before trying again".

> Or whatever, but extfrag_threshold must die!  And replacing it with a
> hardwired constant doesn't count ;)
> 

I think what you have in mind is "just try compaction every time" but my
concern about that is we'll hit a corner case where a lot of CPU time is
taken scanning zones uselessly. That is what this heuristic and the
back-off logic in a later patch was meant to avoid. I haven't thought of
a better alternative :/

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
