Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA11621
	for <linux-mm@kvack.org>; Tue, 9 Dec 1997 12:55:51 -0500
Date: Tue, 9 Dec 1997 18:43:13 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: vhand design flaw :((, new patch instead
Message-ID: <Pine.LNX.3.91.971209183412.8252A@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: linux-kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

I found (much to my dissapointment) a fundamental design flaw
in my vhand patch that explains very well the different results
people have had with my patch. It doesn't affect stability,
just performance, so when vhand works for you, there's no
reason not to use it anymore, except for the fact that something
better's around...

The new patch consists of two parts:
- the anti-fragmentation patch from Zlatko Calusic (really useful)
- kswapd now also ages mmap'ed pages. for this part I have just
  copied some code from vmscan.c into mmap.c, so it should all
  be rock-solid...

The results of this patch are:
- kswapd is more careful about kicking out mmap'ed pages and
  buffers and as a result of this:
	- kswapd takes more CPU time to swap out a page
	- kswapd has to swap out less pages
	- there are (far) less pagefaults
	- now there's no vhand daemon that constantly uses CPU

I hope that the total CPU usage of kswapd hasn't increased
much, if it has increased at all. I for one know that system
performance was boosted quite a bit (more than with the vhand
patch).

If this runs for a lot of people, I'll even send it to Linus 
(there's no new code in it, so we can consider this a bug-fix)

grtz,

Rik.

ps: making it a config option is also possible... We could
even consider adding another (simpler) aging algorithm to
kswapd for (huge) systems that have more I/O bandwith to spare
than they have CPU time.
--
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
