Message-Id: <l03130300b704f22fc837@[192.168.239.105]>
In-Reply-To: <mibudt848g9vrhaac88qjdpnaut4hajooa@4ax.com>
References: <7370000.987704745@baldur>
 <l03130303b704a08b5dde@[192.168.239.105]> <7370000.987704745@baldur>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 19 Apr 2001 21:23:34 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "James A. Sutherland" <jas88@cam.ac.uk>, Dave McCracken <dmc@austin.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>It appears to me that the end result of all this is about the same as
>>suspending a few selected processes.  Under your algorithm the processes
>>that have no guaranteed working set make no real progress and the others
>>get to run.  It seems like a significant amount of additional overhead to
>>end up with the same result.  Additionally, those processes will be
>>generating large numbers of page faults as they fight over the scrap of
>>memory they have.  Using the suspension algorithm they'll be removed
>>entirely from running, this freeing up resources for the remaining
>>processes.
>
>That's my suspicion too: The "strangled" processes eat up system
>resources and still get nowhere (no win there: might as well suspend
>them until they can run properly!) and you are wasting resources which
>could be put to good use by other processes.
>
>More to the point, though, what about the worst case, where every
>process is thrashing? With my approach, some processes get suspended,
>others run to completion freeing up resources for others. With this
>approach, every process will still thrash indefinitely: perhaps the
>effects on other processes will be reduced, but you don't actually get
>out of the hole you're in!

My suggestion is not written in competition with the suspension idea, but
as a significant improvement to the current situation.  I also believe that
my suggestion can be implemented very cheaply and (mostly) with O(1)
complexity.

Case study: my 256Mb RAM box with arbitrary amount of swap.

Load X, a few system monitors, and XMMS.  XMMS on this configuration
consumes about 9Mb RAM and probably has a working set well below 4Mb.  Now
load 3 synthetic memory hogs with essentially infinite working sets.  XMMS
will soon begin to stutter as it is repeatedly paged in and out arbitrarily
by the rather poor NRU algorithm Linux uses.  Upon loading the fourth
memory hog, XMMS and X will stop working altogether, and it becomes
impossible to log in either locally or remotely.  Usually when this
happens, I am forced to hit the reset switch.

With the working set algorithm I proposed, the active portions of XMMS, X
and all other processes would be kept in physical memory, preventing the
stuttering and subsequent failure.  Login processes would also continue to
operate correctly, if with a little delay as the process is initially paged
in.  The memory hogs will thrash themselves and make *slow* progress (this
is NOT the same as *no* progress), but their impact on the system at large
is *much* less than at present.  Remember that processes unrelated to the
swap activity can continue to operate while the disk and swap are in use!

Now for the worst-case scenario, where no active process on the system has
a working set small enough to be given it's entire share.  For this
example, I will use an 8Mb RAM box with 1.5Mb used by the kernel and a
total of 200Kb reserved for buffers, cache and other sundry items.  There
are 10 memory hogs running on this system - each of their working sets is
far larger than the physical memory on the system.  There are no other
processes running, but are present.  Obviously the system is thrashing, but
because each memory hog gets to keep several hundred Kb of itself resident
at a time, progress is still made.

On the above system, suppose root wants to log in and kill some of the
thrashing processes.  At present, this would not be possible (as on the
256Mb box), because swapped-in pages get thrown out even before they can be
used by the login process.  With the working set algorithm, pages used by
the login processes would be forced to remain resident until they were no
longer needed, and root can log in and deal with the situation.

Now consider if 100 memory hogs are present on the 8Mb box.  Each will
effectively have 67Kb to work in - thrashing still definitely occurs, but
the system is still alive.  Root wants to log in - and login gets to keep
66K of resident pages at a time in the *worst* case, and may even be able
to keep *all* of itself resident (depending on the tunable parameter - the
number of pages reserved for each large-working-set process).  I think 66K
is enough to keep a login process happy.

I repeat my request for a precisely-defined suspension algorithm.  I would
like to consider how well it performs in the above 3 scenarios,
particularly in the last case where there are approximately 100 processes
to suspend at once before root can log in successfully.

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
