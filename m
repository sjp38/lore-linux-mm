Message-Id: <l03130313b708dedad0c4@[192.168.239.105]>
In-Reply-To: <o7a6ets1pf548v51tu6d357ng1o0iu77ub@4ax.com>
References: <l03130312b708cf8a37bf@[192.168.239.105]>
 <l0313030fb70791aa88ae@[192.168.239.105]>
 <mibudt848g9vrhaac88qjdpnaut4hajooa@4ax.com>
 <Pine.LNX.4.30.0104201203280.20939-100000@fs131-224.f-secure.com>
 <sb72ets3sek2ncsjg08sk5tmj7v9hmt4p7@4ax.com>
 <3AE1DCA8.A6EF6802@earthlink.net>
 <l0313030fb70791aa88ae@[192.168.239.105]>
 <54b5et09brren07ta6kme3l28th29pven4@4ax.com>
 <l03130311b708b57e1923@[192.168.239.105]>
 <re36et84buhdc4mm252om30upobd8285th@4ax.com>
 <l03130312b708cf8a37bf@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Sun, 22 Apr 2001 20:30:50 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "James A. Sutherland" <jas88@cam.ac.uk>
Cc: "Joseph A. Knapka" <jknapka@earthlink.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>- Login needs paging in (is suspended while it waits).

>>But login was suspended because of a page fault,
>
>No, login was NOT *suspended*. It's sleeping on I/O, not suspended.

So, the memory hogs are causing page faults (accessing memory which is not
currently resident), login is causing page faults (same definition).
What's the difference?

>>>Not really. Your WS suggestion doesn't evict some processes entirely,
>>>which is necessary under some workloads.
>>
>>Can you give an example of such a workload?
>
>Example: any process which is doing random access throughout an array
>in memory. Let's suppose it's a 100 Mb array on a machine with 128Mb
>of RAM.

>How exactly will your approach solve the two process case, yet still
>keeping the processes running properly?

It will allocate one process it's entire working set in physical RAM, and
allow the other to make progress as fast as disk I/O will allow (which I
would call "single-process thrashing").  When, after a few seconds, the
entirely-resident process completes, the other is allowed to take up as
much RAM as it likes.

If I've followed my mental dry-run correctly, the entirely-resident process
would probably be the *second* process to be started, assuming both are
identical, one is started a few scheduling cycles after the other, and the
first process establishes it's 100Mb working set within those few cycles.

If, at this point, your suspension algorithm decided to suspend the
(mostly) swapped-out process for a few brief periods of time, it would have
little effect except maybe to slightly delay the resumption of progress of
the swapped-out process and to reduce the amount of disk I/O caused while
the first process ran to completion.

>>I think we're approaching the problem from opposite viewpoints.  Don't get
>>me wrong here - I think process suspension could be a valuable "feature"
>>under extreme load, but I think that the working-set idea will perform
>>better and more consistently under "mild overloads", which the current
>>system handles extremely poorly.  Probably the only way to resolve this
>>argument is to actually try and implement each idea, and see how they
>>perform.
>
>Since the two are not mutually exclusive, why try "comparing" them?
>Returning to our car analogy, would you try "comparing" snow chains
>with diff-lock?!

I said nothing about comparison or competition.  By "each idea" I *include*
the possibility of having the suspension algorithm *and* the working-set
algorithm implemented simultaneously.  It would be instructive to see how
they performed separately, too.

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
