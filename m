Date: Mon, 2 Aug 2004 21:20:54 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] token based thrashing control
In-Reply-To: <Pine.LNX.4.44.0408022018080.8702-100000@va.cs.wm.edu>
Message-ID: <Pine.LNX.4.44.0408022106560.5948-100000@dhcp83-102.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Song Jiang <sjiang@CS.WM.EDU>
Cc: Con Kolivas <kernel@kolivas.org>, Andrew Morton <akpm@osdl.org>, fchen@CS.WM.EDU, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2 Aug 2004, Song Jiang wrote:

> When there is memory competition among multiple processes,
> Which process grabs the token first is important.
> A process with its memory demand exceeding the total
> ram gets the token first and finally has to give it up 
> due to a time-out would have little performance gain from token,
> It could also hurt others. Ideally we could make small processes
> more easily grab the token first and enjoy the benifis from
> token. That is, we want to protect those that are deserved to be
> protected. Can we take the rss or other available memory demand
> information for each process into the consideration of whether 
> a token should be taken, or given up and how long a token is held.  

I like this idea.  I'm trying to think of a way to skew
the "lottery" so small processes get an advantage, but
the only thing I can come up with is as follows:

1) when a process tries to grab the token, it "registers"
   itself

2) a subsequent process can "register" itself to get the
   token, but only if it has a better score than the
   process that already has it

3) the score can be calculated based on a few factors,
   like (a) size of the process (b) time since it last
   had the token

4) a simple formula could be (time / size), giving big
   processes the token every once in a blue moon and
   letting small processes have the token all the time

5) the token would be grabbed in pretty much the same way
   we do currently, except the token can be handed to
   another process instead of the current process, if there
   is a better candidate registered - all the locking is there

6) since there is only one candidate, we won't have any
   queueing complexities and the algorithm should be just
   as cheap as it is currently

What do you think ?

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
