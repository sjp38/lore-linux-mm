Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA15903
	for <linux-mm@kvack.org>; Wed, 18 Nov 1998 05:25:48 -0500
Date: Wed, 18 Nov 1998 09:58:58 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: useless report -- perhaps memory allocation problems in 2.1.12[678]
In-Reply-To: <Pine.LNX.3.95.981117174031.23128A-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.981118095143.21442C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Jeffrey Hundstad <jeffrey.hundstad@mankato.msus.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Nov 1998, Linus Torvalds wrote:
> On Tue, 17 Nov 1998, Linus Torvalds wrote:
> > 
> > But whether kswapd should go page-synchronous at some point? Maybe. I can
> > see arguments both for and against (the "for" argument is that we prefer
> > to have more intense bouts of IO followed by a nice clean wait, while the
> > "against" argument is that maybe we want to spread out the thing). 
> 
> Oh, well, I'm currently leaning for "for", which means your patch to
> page_io.c is what I have now.. I don't like "trickling" pages by
> running out of requests or something like that, so having the
> occasional nice wait is probably best. 

It seems like you decided for my point of view before I
woke up again, so I'll just let you know that this is
one of the reasons why I submitted the original (2.1.90?)
patch to you. The other reason was that async, clustered
swapouts have a much higher bandwidth than synchronous
swapouts. This means we can do more swap I/O without
getting into trouble.

The only request I have to make is that you use the
sysctl tuneable limit pager_daemon.swap_cluster as
the limit.  Doing this will enable people to optimize
their kswapd configuration for multiple swap partitions
or disks with loads of tagged queues (or a shortage 
thereoff).

I have found that setting that limit to SWAP_CLUSTER_MAX
* number_of_highest_priority_swap_areas doubled swapout
performance, leaving 50% extra I/O bandwidth for swapins.

cheers,

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
