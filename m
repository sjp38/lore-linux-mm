From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Date: Sun, 22 Apr 2001 18:06:43 +0100
Message-ID: <re36et84buhdc4mm252om30upobd8285th@4ax.com>
References: <l0313030fb70791aa88ae@[192.168.239.105]> <mibudt848g9vrhaac88qjdpnaut4hajooa@4ax.com> <Pine.LNX.4.30.0104201203280.20939-100000@fs131-224.f-secure.com> <sb72ets3sek2ncsjg08sk5tmj7v9hmt4p7@4ax.com> <3AE1DCA8.A6EF6802@earthlink.net> <l0313030fb70791aa88ae@[192.168.239.105]> <54b5et09brren07ta6kme3l28th29pven4@4ax.com> <l03130311b708b57e1923@[192.168.239.105]>
In-Reply-To: <l03130311b708b57e1923@[192.168.239.105]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: "Joseph A. Knapka" <jknapka@earthlink.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 22 Apr 2001 17:53:05 +0100, you wrote:

>>>That might possibly work for some loads, mostly where there are some
>>>processes which are already swapped-in (and have sensible working sets)
>>>alongside the "thrashing" processes.  That would at least give the
>>>well-behaved processes some chance to keep their "active" bits up to date.
>>
>>The trouble is, thrashing isn't really a process level issue: yes,
>>there are a group of processes causing it, but you don't have
>>"thrashing processes" and "non-thrashing processes". Like a car with
>>one wheel stuck in a pool of mud without a diff-lock: yes, you have
>>one or two point(s) where all your engine power is going, and the
>>other wheels are just spinning, but as a result the whole car is going
>>nowhere! In both cases, the answer is to "starve" the spinning
>>wheel(s) of power, allowing the others to pull you out...
>
>Actually, that's not quite how a diff-lock works - it distributes tractive
>effort equally across all four wheels, rather than simply locking a single
>wheel.  You don't get out of a mud puddle by (effectively) braking one
>wheel.

If it's stuck in mud, spinning freely, a diff-lock WILL actually mean
(almost) no power goes to that wheel: it just rotates at the same
speed as the others, with no power being exerted.

>>>However, it doesn't help at all for the cases where some paging-in has to
>>>be done for a well-behaved but only-just-accessed process.
>>
>>Yes it does: we've suspended the runaway process (Netscape, Acrobat
>>Reader, whatever), leaving enough RAM free for login to be paged in.
>
>No, it doesn't.  If we stick with the current page-replacement policy, then
>regardless of what we do with the size of the timeslice, there is always
>going to be the following situation:

This is not just a case of increasing the timeslice: the suspension
strategy avoids the penultimate stage of this list happening:

>- Large process(es) are thrashing.
>- Login needs paging in (is suspended while it waits).
>- Each large process gets it's page and is resumed, but immediately page
>faults again, gets suspended
>- Memory reserved for Login gets paged out before Login can do any useful work

Except suspended processes do not get scheduled for a couple of
seconds, meaning login CAN do useful work.

>- Repeat ad infinitum.

Doesn't repeat, since login has succeeded.

>IOW, even with the current timeslice (which, BTW, depends on 'nice' value -
>setting the memory hogs to nice 19 and XMMS to nice -20 doesn't help), the
>timeslice limit is often never reached for a given process when the system
>is thrashing.  Increasing the timeslice will not help, except for process
>which are already completely resident in memory.  Increasing the suspension
>time *might* help, provided pages newly swapped in get locked in for that
>time period.  Oh, wait a minute...  isn't that exactly what my working-set
>suggestion does?

Not really. Your WS suggestion doesn't evict some processes entirely,
which is necessary under some workloads.

>>>Example of a
>>>critically important process under this category: LOGIN.  :)  IMHO, the
>>>only way to sensibly cater for this case (and a few others) is to update
>>>the page-replacement algorithm.
>>
>>Updating the page replacement algorithm will help, but our core
>>problem remains: we don't have enough pages for the currently active
>>processes! Either we starve SOME processes, or we starve all of
>>them...
>
>Or we distribute the "tractive effort" (physical RAM) equally (or fairly)
>among them, just like the diff-lock you so helpfully mentioned.  :)  A 4x4
>vehicle doesn't perform optimally when the diff-lock is applied, but it's
>certainly an improvement in the case where one wheel would otherwise spin
>uselessly.

Distributing "fairly" is sub-optimal: sequential suspension and
resumption of each memory hog will yield far better performance. To
the extent some workloads fail with your approach but succeed with
mine: if a process needs more than the current working-set in RAM to
make progress, your suggestion leaves each process spinning, taking up
resources.

>Right now, the page-replacement policy simply finds a page it "can" swap
>out, and pays only cursory attention to whether it's actually in use.  I
>firmly believe it's well worth spending a little more effort there to
>reduce the amount of swapping required for a given VM load, especially if
>it means that Linux gets more stable under such loads.  Piddling around
>with the scheduler won't do that, although it might help with pathological
>loads *iff* we get a better pager.

On the contrary: tweaking page-replacement will probably help in most
cases, but won't solve any pathological case.


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
