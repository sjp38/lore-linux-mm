Date: Tue, 25 Apr 2000 11:36:16 -0700
From: Simon Kirby <sim@stormix.com>
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
Message-ID: <20000425113616.A7176@stormix.com>
References: <Pine.LNX.4.21.0004251757360.9768-100000@alpha.random> <Pine.LNX.4.21.0004251418520.10408-100000@duckman.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0004251418520.10408-100000@duckman.conectiva>; from riel@conectiva.com.br on Tue, Apr 25, 2000 at 02:20:19PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Ben LaHaise <bcrl@redhat.com>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Tue, Apr 25, 2000 at 02:20:19PM -0300, Rik van Riel wrote:

> On Tue, 25 Apr 2000, Andrea Arcangeli wrote:
> > On Tue, 25 Apr 2000, Rik van Riel wrote:
> > 
> > >If you look closer, you'll see that none of the swapped out
> > >stuff is swapped back in again. This shows that the VM
> > >subsystem did make the right choice here...
> > 
> > Swapping out with 50mbyte of cache isn't the right choice unless
> > all the 50mbyte of cache were mapped in memory (and I bet that
> > wasn't the case).
> 
> Funny you just state this without explaining why.
> If the memory that's swapped out isn't used again
> in the next 5 minutes, but the pages in the file
> cache _are_ used (eg. for compiling that kernel you
> just unpacked), then it definately is the right
> choice to keep the cached data in memory and swap
> out some part of netscape.

Well, from the way I look at it...

In the ideal world, everybody would have unlimited quantities of RAM and
swap would be unnecessary.  In the desktop world, this is pretty much the
opposite, but RAM is always getting cheaper and newer machines always have
more RAM.  The ideal server setup is one where it never has to use swap,
_but also_ where it never has to read in anything at all after it's been
up for a while.

For desktops with low memory, it probably is an advantage to swap out
occasionally to be able to keep more things in cache.  However, for
higher-end servers, I don't think it would be an advantage to swap simply
when the cache has used up the remaining free memory and more memory is
needed because it would slow down the response time for running programs
(although this is all a balance, I see :)).  I suppose it would make more
of a difference on desktops where people switch between windows in X and
want a speedy response from large programs, where as on a server it would
probably just be a small daemon that doesn't get used much.

Hrmm.. I guess the ideal solution would be that swappable pages would age
just like cache pages and everything else?  Then, if a particular
program's page hasn't been accessed for 60 seconds and there is nothing
older in the page cahce, it would swap out... I don't think this is
possible, though, because it would have to keep track of reads to every
page (slow, right?).

Simon-

[  Stormix Technologies Inc.  ][  NetNation Communications Inc. ]
[       sim@stormix.com       ][       sim@netnation.com        ]
[ Opinions expressed are not necessarily those of my employers. ]
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
