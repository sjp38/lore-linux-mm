Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA14797
	for <linux-mm@kvack.org>; Mon, 22 Dec 1997 12:11:12 -0500
Date: Mon, 22 Dec 1997 17:29:17 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: mmap-age patch, comments wanted 
In-Reply-To: <m0xjTGa-000sLKC@linux.biostat.hfh.edu>
Message-ID: <Pine.LNX.3.91.971222172043.7639P-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Noel Maddy <ncm@biostat.hfh.edu>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 20 Dec 1997, Noel Maddy wrote:

> I haven't had the time to do comprehensive testing with your mmap-age 
> patch, but I have been alternately running 2.1.71 with and without the 
> patch.  It seems like the patch really helps for steady-state 
> situations, but has problems when I start large programs when my system 
> is already overloaded.

Hmm, yes. This is a problem, it can probably be solved by
tuning some parameters in /proc/sys/vm (I have the problem too,
but not by far as severe as you have them). <see below>

> The problem comes when I run another large application, like Debian's 
> dpkg, or netscape, or gimp.  With the mmap-age patched kernel, the 
> system freezes for 5 to 10 seconds while loading one of these large 
> apps -- no mouse movement, no X updating, nothing.  When I run vmstat 
> while this is happening, I see a huge amount of page-out with no 
> page-in followed by a huge amount of page-in.
> 
> When I do the same thing without the mmap-age patch, the system slows 
> down, but does not become completely unresponsive.

At my place it doesn't become unresponsive, not even when I'm
already swapping and then I load Netscape...

> I'm not that familiar with the Linux mm system, but I'm guessing that 
> what's happening is that since all of the new pages for the starting 
> process are referenced while it loads, they all have a high priority, 
> and won't be replaced by more pages from the same new process.  Once 
> the new process starts, the  pages from the older processes that have 
> been paged out have to be paged in again.
> 
> If that's the case, might it help to start the new pages out pre-aged?  
> That way, there'd be a chance that a new page for the new process would 
> replace older pages for the new process rather than pages from older 
> processes?

They are loaded preaged. And since Linux does demand-loading,
only the pages actually required are loaded into core...

I think it's the anti-fragmentation part that's biting you,
ie. the kernel has some free pages in large chunks --> memory
gets allocated --> kswapd has to free loads of random pages until
there are some large chunks of free pages again.

But if we don't have the anti-fragmentation stuff, the kernel
wouldn't run as stable as it does now, and I'm not willing to
sacrifice stability for performance...
(and frankly, I don't think anyone is:)

> Of course, this is just speculation rather than from studying the code 
> -- if I'm all wet, just tell me...

Well, you did have a clue. Not neccesary the right clue, but
it did make me think about what to do...
I might actually have some solution^H^H^H^H^H^H^H^Hworkaround
for this by tomorrow...

Merry Cristmas,

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
