Date: Sun, 29 Oct 2000 20:41:46 +0000 (GMT)
From: James Sutherland <jas88@cam.ac.uk>
Subject: Re: Discussion on my OOM killer API
In-Reply-To: <20001029203046.A23822@nightmaster.csn.tu-chemnitz.de>
Message-ID: <Pine.LNX.4.10.10010292025071.20735-100000@dax.joh.cam.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 29 Oct 2000, Ingo Oeser wrote:

> On Fri, Oct 27, 2000 at 06:36:13PM +0100, James Sutherland wrote:
> > > If I do the full blown variant of my patch: 
> > EBADIDEA. The kernel's OOM killer is a last ditch "something's going to
> > die - who's first?" - adding extra bloat like this is BAD.
>  
> Ok. So it's easier for me ;-)

Also a plus point, I think :)

> > Policy should be decided user-side, and should prevent the kernel-side
> > killer EVER triggering.
>  
> So your user space OOM handler would like to be notified on
> memory *pressure* (not only about OOM)? You would like to shrink
> image caches and the like with it? Sounds sane. 

That's a bit more elaborate than my plan, but I'd like to get that at some
point (2.5?) - "Hey, X, we're getting short on RAM here. How about
ditching a few cached bitmaps?" etc.

My plan for now was simpler: my handler gets notified "only x Mb left!"
and works down a priority list of things to try at each threshold: maybe
kill netscapes if we're down to 2 Mb, send a SIGDANGER to everyone at 1
Mb, reboot if we drop below 0.5 Mb.

> But then we need information on _how_ much memory we need. I
> could pass allocation "priority" to user space, but I doubt that
> will be descriptive enough.

Memory pressure is very difficult to measure, but if the configuration is
flexible enough the daemon should be able to handle most things.

> > I was planning to implement a user-side OOM killer myself - perhaps we
> > could split the work, you do kernel-side, I'll do the userspace bits?
> 
> If you could clarify, what events you actually like to get, I
> could implement this a loadable OOM handler.

The main event I'm interested in is "free memory below <level>" (and "free
memory above <level>"; users may want things restarted once the problem
has gone). Having the same facility for short-term load average might be
nice, too, to catch fork-bombs etc. before they hurt the system too badly.

The mechanism I have in mind is something like this:

1. System boots up, init loads /sbin/resourced

2. resourced works out the nearest threshold of interest, and writes this
to /dev/resources, then performs a blocking read (i.e. sleeps until that
threshold is crossed). (Runs as root, realtime maximum priority.)

3. As a threshold is crossed, the read will return appropriate
information: which threshold was crossed, for example. This wakes
resourced, which takes appropriate action.

For a simple configuration, I'd probably just want to warn logged-in users
when we drop below, say, 5 Mb, then start killing things at 1 Mb.

> But still my patch is much more flexible, since it even allows to
> panic & reboot. I would prefer that on embedded systems, which
> boot _really_ fast, over blowing the system by adding mutally
> watching to my important processes.

I'd rather reboot cleanly from userspace if possible, avoiding the panic()
route. OK, in an embedded system you may not have big RAID arrays to fsck
etc., but I think most programmers would rather not have the system panic
unnecessarily?


James.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
