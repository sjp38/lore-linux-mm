Message-Id: <l03130311b708b57e1923@[192.168.239.105]>
In-Reply-To: <54b5et09brren07ta6kme3l28th29pven4@4ax.com>
References: <l0313030fb70791aa88ae@[192.168.239.105]>
 <mibudt848g9vrhaac88qjdpnaut4hajooa@4ax.com>
 <Pine.LNX.4.30.0104201203280.20939-100000@fs131-224.f-secure.com>
 <sb72ets3sek2ncsjg08sk5tmj7v9hmt4p7@4ax.com>
 <3AE1DCA8.A6EF6802@earthlink.net>
 <l0313030fb70791aa88ae@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Sun, 22 Apr 2001 17:53:05 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "James A. Sutherland" <jas88@cam.ac.uk>
Cc: "Joseph A. Knapka" <jknapka@earthlink.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>That might possibly work for some loads, mostly where there are some
>>processes which are already swapped-in (and have sensible working sets)
>>alongside the "thrashing" processes.  That would at least give the
>>well-behaved processes some chance to keep their "active" bits up to date.
>
>The trouble is, thrashing isn't really a process level issue: yes,
>there are a group of processes causing it, but you don't have
>"thrashing processes" and "non-thrashing processes". Like a car with
>one wheel stuck in a pool of mud without a diff-lock: yes, you have
>one or two point(s) where all your engine power is going, and the
>other wheels are just spinning, but as a result the whole car is going
>nowhere! In both cases, the answer is to "starve" the spinning
>wheel(s) of power, allowing the others to pull you out...

Actually, that's not quite how a diff-lock works - it distributes tractive
effort equally across all four wheels, rather than simply locking a single
wheel.  You don't get out of a mud puddle by (effectively) braking one
wheel.

>>However, it doesn't help at all for the cases where some paging-in has to
>>be done for a well-behaved but only-just-accessed process.
>
>Yes it does: we've suspended the runaway process (Netscape, Acrobat
>Reader, whatever), leaving enough RAM free for login to be paged in.

No, it doesn't.  If we stick with the current page-replacement policy, then
regardless of what we do with the size of the timeslice, there is always
going to be the following situation:

- Large process(es) are thrashing.
- Login needs paging in (is suspended while it waits).
- Each large process gets it's page and is resumed, but immediately page
faults again, gets suspended
- Memory reserved for Login gets paged out before Login can do any useful work
- Repeat ad infinitum.

IOW, even with the current timeslice (which, BTW, depends on 'nice' value -
setting the memory hogs to nice 19 and XMMS to nice -20 doesn't help), the
timeslice limit is often never reached for a given process when the system
is thrashing.  Increasing the timeslice will not help, except for process
which are already completely resident in memory.  Increasing the suspension
time *might* help, provided pages newly swapped in get locked in for that
time period.  Oh, wait a minute...  isn't that exactly what my working-set
suggestion does?

>>Example of a
>>critically important process under this category: LOGIN.  :)  IMHO, the
>>only way to sensibly cater for this case (and a few others) is to update
>>the page-replacement algorithm.
>
>Updating the page replacement algorithm will help, but our core
>problem remains: we don't have enough pages for the currently active
>processes! Either we starve SOME processes, or we starve all of
>them...

Or we distribute the "tractive effort" (physical RAM) equally (or fairly)
among them, just like the diff-lock you so helpfully mentioned.  :)  A 4x4
vehicle doesn't perform optimally when the diff-lock is applied, but it's
certainly an improvement in the case where one wheel would otherwise spin
uselessly.

Right now, the page-replacement policy simply finds a page it "can" swap
out, and pays only cursory attention to whether it's actually in use.  I
firmly believe it's well worth spending a little more effort there to
reduce the amount of swapping required for a given VM load, especially if
it means that Linux gets more stable under such loads.  Piddling around
with the scheduler won't do that, although it might help with pathological
loads *iff* we get a better pager.

Right now, I'm going to look at how my working-set algorithm could actually
be implemented in the kernel, starting with my detailed suggestion of the
other day.

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
