Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA23627
	for <linux-mm@kvack.org>; Mon, 30 Mar 1998 11:04:29 -0500
Date: Mon, 30 Mar 1998 17:07:47 +0200 (MET DST)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: new allocation algorithm
In-Reply-To: <Pine.LNX.3.95.980327092811.6613C-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.91.980330170431.242H-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 27 Mar 1998, Linus Torvalds wrote:
> On Fri, 27 Mar 1998, Rik van Riel wrote:
> > 
> > I just came up with the idea of using an ext2 like algorithm
> > for memory allocation, in which we:
> > - group memory in 128 PAGE groups
> > - have one unsigned char counter per group, counting the number
> >   of used pages
> 
> Let's wait with how well the current setup works. It seems to perform
> reasonably well even on smaller machines (modulo your patch), and I think
> we'd better more-or-less freeze it waiting for further info on what people
> actually think. 

At the moment, all that's freezing are the small-memory
machines :-(

> The current scheme is fairly efficient and extremely stable, and gives
> good behaviour for the cases we _really_ care about (pageorders 0, 1 and
> to some degree 2). It comes reasonably close to working for the higher
> orders too, but they really aren't as critical..

However, when we:
- allocate one page out of a 128 area
- we continue allocating pages out of that area, even when
- several 16k area's are freed and
- we are not able to free another large area again, so:
- the system swaps to death

This is not hypothetical, I've seen it happen :-(

Another way to do it, is to have machines exit with different
kswapd tests, as in:

if (num_physpages < arbitrary_limit && free_memory_available(2))
	break;

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
