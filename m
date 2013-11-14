Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 003836B003C
	for <linux-mm@kvack.org>; Wed, 13 Nov 2013 19:48:37 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id mc17so1192168pbc.7
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 16:48:37 -0800 (PST)
Received: from psmtp.com ([74.125.245.120])
        by mx.google.com with SMTP id bc2si25811923pad.129.2013.11.13.16.48.35
        for <linux-mm@kvack.org>;
        Wed, 13 Nov 2013 16:48:36 -0800 (PST)
Received: by mail-pd0-f169.google.com with SMTP id y13so1204639pdi.28
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 16:48:34 -0800 (PST)
Date: Wed, 13 Nov 2013 16:48:32 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, vmscan: abort futile reclaim if we've been oom
 killed
In-Reply-To: <20131114000043.GK707@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1311131639010.6735@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1311121801200.18803@chino.kir.corp.google.com> <20131113152412.GH707@cmpxchg.org> <alpine.DEB.2.02.1311131400300.23211@chino.kir.corp.google.com> <20131114000043.GK707@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 13 Nov 2013, Johannes Weiner wrote:

> > The reclaim will fail, the only reason current has TIF_MEMDIE set is 
> > because reclaim has completely failed.
> 
> ...for somebody else.
> 

That process is in the same allocating context as current, otherwise 
current would not have been selected as a victim.  The oom killer tries to 
only kill processes that will lead to future memory freeing where reclaim 
has failed.

> > I don't know of any other "random places" other than when the oom killed 
> > process is sitting in reclaim before it is selected as the victim.  Once 
> > it returns to the page allocator, it will immediately allocate and then be 
> > able to handle its pending SIGKILL.  The one spot identified where it is 
> > absolutely pointless to spin is in reclaim since it is virtually 
> > guaranteed to fail.  This patch fixes that issue.
> 
> No, this applies to every other operation that does not immediately
> lead to the task exiting or which creates more system load.  Readahead
> would be another example.  They're all pointless and you could do
> without all of them at this point, but I'm not okay with putting these
> checks in random places that happen to bother you right now.  It's not
> a proper solution to the problem.
> 

If you have an alternative solution, please feel free to propose it and 
I'll try it out.

This isn't only about the cond_resched() in shrink_slab(), the reclaim is 
going to fail.  There should be no instances where an oom killed process 
can go and start magically reclaiming memory that would have prevented it 
from becoming oom in the first place.  I have seen the oom killer trigger 
and the victim stall for several seconds before actually allocating memory 
and that stall is pointless, especially when we're not touching a hotpath 
here, we're in direct reclaim already.

> Is it a good idea to let ~700 processes simultaneously go into direct
> global reclaim?
> 
> The victim aborting reclaim still leaves you with ~699 processes
> spinning in reclaim that should instead just retry the allocation as
> well.  What about them?
> 

Um, no, those processes are going through a repeated loop of direct 
reclaim, calling the oom killer, iterating the tasklist, finding an 
existing oom killed process that has yet to exit, and looping.  They 
wouldn't loop for too long if we can reduce the amount of time that it 
takes for that oom killed process to exit.

> The situation your setups seem to get in frequently is bananas, don't
> micro optimize this.
> 

Unless you propose an alternative solution, this is the patch that fixes 
the problem when an oom killed process gets killed and then stalls for 
seconds before it actually retries allocating memory.

Thanks for your thoughts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
