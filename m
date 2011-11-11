Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id AD4276B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 09:21:06 -0500 (EST)
Date: Fri, 11 Nov 2011 15:21:00 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: Do not stall in synchronous compaction for THP
 allocations
Message-ID: <20111111142100.GB3512@redhat.com>
References: <20111110100616.GD3083@suse.de>
 <20111110142202.GE3083@suse.de>
 <CAEwNFnCRCxrru5rBk7FpypqeL8nD=SY5W3-TaA7Ap5o4CgDSbg@mail.gmail.com>
 <20111110161331.GG3083@suse.de>
 <20111110151211.523fa185.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1111101536330.2194@chino.kir.corp.google.com>
 <20111111101414.GJ3083@suse.de>
 <alpine.DEB.2.00.1111110224500.7419@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1111110224500.7419@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Nov 11, 2011 at 02:39:10AM -0800, David Rientjes wrote:
> The history of this boolean is somewhat disturbing: it's introduced in 
> 77f1fe6b back on January 13 to be true after the first attempt at 
> compaction, then changed to be !(gfp_mask & __GFP_NO_KSWAPD) in 11bc82d6 
> on March 22, then changed to be true again in c6a140bf on May 24, then 
> proposed to be changed right back to !(gfp_mask & __GFP_NO_KSWAPD) in this 
> patch again.  When are we going to understand that the admin needs to tell 
> the kernel when we'd really like to try to allocate a transparent hugepage 
> and when it's ok to fail?

Sorry for the confusion but it was reverted by mistake. Mel fixed a
compaction bug that caused stalls of several minutes to
people. compaction was overflowing into the next zone by mistake
without adjusting its tracking parameters. So it wasn't clear anymore
if sync compaction was really a problem or not. So I reverted it to be
sure. And well now we're sure :). Without USB or pathologically slow
I/O apparently it's not a noticeable issue.

So having sync compaction off by default sounds good to me.

We can still add a tunable to force sync compaction in case anybody
needs.

Another topic is if slub and stuff also wants sync compaction off by
default when they allocate with large order so triggering compaction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
