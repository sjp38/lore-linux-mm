Message-Id: <l03130301b7419d6b39d8@[192.168.239.105]>
In-Reply-To: <20010604114516.C1955@redhat.com>
References: <l03130301b73f486b8acb@[192.168.239.105]>; from
 chromi@cyberspace.org on Sun, Jun 03, 2001 at 03:06:22AM +0100
 <l03130301b73f486b8acb@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 4 Jun 2001 22:54:27 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: Some VM tweaks (against 2.4.5)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> - Increased PAGE_AGE_MAX and PAGE_AGE_START to help newly-created and
>> frequently-accessed pages remain in physical RAM.
>
>> - Changed age_page_down() and family to use a decrement instead of divide
>> (gives frequently-accessed pages a longer lease of life).
>
>We've tried this and the main problem is that something like "grep
>foo /usr/bin/*" causes a whole pile of filesystem data to be
>maintained in cache for a long time because it is so recent.  Reducing
>the initial age of new pages is essential if you want to allow
>read-once data to get flushed out again quickly.

Noted.  But what about pages which already "exist" but are freshly swapped
in?  Maybe we should indeed have a low PAGE_AGE_START, but push page->age
to PAGE_AGE_MAX when it is swapped in by a major fault.  I assume, of
course, that the act of reading data from a file is not handled by means of
a major fault...

>> - In try_to_swap_out(), take page->age into account and age it down rather
>> than swapping it out immediately.
>
>Bad for shared pages if you have got some tasks still referencing a
>page and other tasks which are pretty much idle.  The point of
>ignoring the age is that sleeping tasks can get their working set
>paged out even if they use library pages which are still in use by
>other processes.  That way, if the only active user of a page dies, we
>can reclaim the pages without having to wade through the working set
>of every other sleeping task which might ever have used the same
>shared library.

I'm not sure I agree with your logic here, but I'll think on it, perhaps
out loud.  First of all, the working set is not calculated per se at
present.  Instead, we attempt to make the resident set roughly match the
working set by some (crude) algorithms.  With this in mind, it doesn't
matter a jot if there are multiple (active or not) users of a given page,
since the page is only resident once.  When all processes have stopped
actively using it, the age of that page will decrease and it will be paged
out if needed.

>> - In swap_out_mm(), don't allow large processes to force out processes
>> which have smaller RSS than them.  kswapd can still cause any process to be
>> paged out.  This replaces my earlier "enforce minimum RSS" hack.
>
>Good idea.  I'd be interested in seeing the effect of this measured in
>isolation.

Time for the big boys to get out their toys again.  :)  I did some testing
by compiling MySQL on my Athlon with mem=32M, which is what led me to
realise that the "enforce minimum RSS" could actually decrease overall
throughput dramatically, even if processes weren't actually using the
(artificially) reserved memory.  This test also emphasises rather nicely
the difference between "heavy paging" and "thrashing" - given just the few
extra Mb of RAM, most of the C++ compiles went to "heavy paging" mode and
made rapid progress.  The "monster" C++ file was the only one left
thrashing when the "anti-big-bully" patch was applied.  I haven't directly
compared the anti-big-bully patch to the stock kernel, though.

As a side note, let me point out that XFree86 has a large RSS, much of
which is not part of the normal memory map (it is VRAM).  Therefore XFree86
suffers unduly at the hands of the anti-big-bully patch, and has more
difficulty paging bits of itself in when it needs to.  This could
potentially be true of other classes of application, too.  It does still
seem to soldier on bravely, though, so kswapd is doing it's job.

I'd like to see the swapping-out routines schedule more often.  The
rationale for this is to allow small processes to maintain their access
pattern while the ageing process grinds on, and also to dissipate the "big
bag o' lag" as a big swap-out operation takes place.  I've seen small,
continuous processes (mpg123, dnetc, xosview) losing several seconds of
access to the CPU as another process ate up memory and caused a large
swap-out.  Can someone suggest a good place to do this, and advise on the
proper sequence of events?

I'm also still left with the decided view that a proper working-set
calculation would be the best overall solution.  On an otherwise-idle
system, I want that C++ process to take over as much as possible -
including most of the buffers+cache space - so it makes maximum progress.
At present this is partially handled as the end result of some mysterious
interactions, and IMVHO needs to be made more explicit.  If made more
explicit "hmm, in this section of code we decide how much memory we're
going to give process X", tuning could become that much easier...

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
see: http://www.linux-mm.org/
