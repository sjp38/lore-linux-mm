Message-Id: <l03130301b701fc801a61@[192.168.239.105]>
In-Reply-To: <3ormdto78qla1qir8c62i2tuope82bt1u0@4ax.com>
References: <l03130300b701154d843c@[192.168.239.105]>
 <20010414022048.B10405@redhat.com> <m1wv8pti0o.fsf@frodo.biederman.org>
 <Pine.LNX.4.21.0104131317110.12164-100000@imladris.rielhome.conectiva>
 <20010414022048.B10405@redhat.com>
 <ehnmdtcljeb1bttp3r6o6o85b6agda0mdt@4ax.com>
 <l03130300b701154d843c@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 17 Apr 2001 15:26:12 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: [PATCH] a simple OOM killer to save me from Netscape
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "James A. Sutherland" <jas88@cam.ac.uk>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, Slats Grobnik <kannzas@excite.com>, linux-mm@kvack.org, Andrew Morton <andrewm@uow.edu.au>
List-ID: <linux-mm.kvack.org>

>It's a very black art, this; "clever" page replacement algorithms will
>probably go some way towards helping, but there will always be a point
>when you really are thrashing - at which point, I think the best
>solution is to suspend processes alternately until the problem is
>resolved.

I've got an even better idea.  Monitor each process's "working set" - ie.
the set of unique pages it regularly "uses" or pages in over some period of
(real) time.  In the event of thrashing, processes should be reserved an
amount of physical RAM equal to their working set, except for processes
which have "unreasonably large" working sets.  These last should be given
some arbitrarily small and fixed working set - they will perform just the
same as if nothing was done, but everything else runs *far* better.

The parameters for the above algorithm would be threefold:

- The time over which the working set is calculated (a decaying weight
would probably work)
- Determining "unreasonably large" (probably can be done by taking the
largest working set(s) on the system and penalising those until the total
working set is within the physical limit of the machine)
- How small the "fixed working set" should be for penalised processes (such
as a fair proportion of the un-reserved physical memory)

If this is done properly, well-behaved processes like XMMS, shells and
system monitors can continue working normally even if a ton of "memory
hogs" attempt to thrash the system to it's knees.  I suspect even a runaway
Netscape would be handled sensibly by this technique.  Best of all, this
technique doesn't involve arbitrarily killing or suspending processes.

It is still possible, mostly on small systems, to have *every* active
process thrashing in this manner.  However, I would submit that if it gets
this far, the system can safely be considered overloaded.  :)  It has
certainly got to be an improvement over the current situation, where just 3
or 4 runaway processes can bring down my well-endowed machine, and Netscape
can crunch a typical desktop.

The disadvantage, of course, is that some record has to be kept of the
working set of each process over time.  This could be some overhead in
terms of storage, but probably won't be much of a CPU burden.

Interestingly, the "working set" calculation yielded by this method, if
made available to userland, could possibly aid optimisation by application
programmers.  It is well known to systems programmers that if the working
set exceeds the size of the largest CPU cache on the system, performance is
limited to the speed and latency of DRAM (both of which are exceptionally
poor) - but it is considerably less well known to applications programmers.

As for how to actually implement this...  don't ask me.  I'm still a kernel
newbie, really!

--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)
big-mail: chromatix@penguinpowered.com
uni-mail: j.d.morton@lancaster.ac.uk

The key to knowledge is not to rely on people to teach you it.

Get VNC Server for Macintosh from http://www.chromatix.uklinux.net/vnc/

-----BEGIN GEEK CODE BLOCK-----
Version 3.12
GCS$/E/S dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$ V? PS
PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)
-----END GEEK CODE BLOCK-----


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
