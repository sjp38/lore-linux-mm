From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Date: Sun, 22 Apr 2001 21:35:14 +0100
Message-ID: <ssf6etkhgrc2ejgcv22ophdj7pb5fbifbk@4ax.com>
References: <Pine.LNX.4.30.0104201203280.20939-100000@fs131-224.f-secure.com> <sb72ets3sek2ncsjg08sk5tmj7v9hmt4p7@4ax.com> <3AE1DCA8.A6EF6802@earthlink.net> <l0313030fb70791aa88ae@[192.168.239.105]> <54b5et09brren07ta6kme3l28th29pven4@4ax.com> <l03130311b708b57e1923@[192.168.239.105]> <re36et84buhdc4mm252om30upobd8285th@4ax.com> <l03130312b708cf8a37bf@[192.168.239.105]> <o7a6ets1pf548v51tu6d357ng1o0iu77ub@4ax.com> <l03130313b708dedad0c4@[192.168.239.105]>
In-Reply-To: <l03130313b708dedad0c4@[192.168.239.105]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: "Joseph A. Knapka" <jknapka@earthlink.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 22 Apr 2001 20:30:50 +0100, you wrote:

>>>>>- Login needs paging in (is suspended while it waits).
>
>>>But login was suspended because of a page fault,
>>
>>No, login was NOT *suspended*. It's sleeping on I/O, not suspended.
>
>So, the memory hogs are causing page faults (accessing memory which is not
>currently resident), login is causing page faults (same definition).
>What's the difference?

The number of page faults, the size of process. One is a huge process
generating large numbers of page faults over a period of time,
contributing a large amount to the VM load.

>>>>Not really. Your WS suggestion doesn't evict some processes entirely,
>>>>which is necessary under some workloads.
>>>
>>>Can you give an example of such a workload?
>>
>>Example: any process which is doing random access throughout an array
>>in memory. Let's suppose it's a 100 Mb array on a machine with 128Mb
>>of RAM.
>
>>How exactly will your approach solve the two process case, yet still
>>keeping the processes running properly?
>
>It will allocate one process it's entire working set in physical RAM, 

Which one?

>and
>allow the other to make progress as fast as disk I/O will allow (which I
>would call "single-process thrashing").  

So you effectively "busy-suspend" the other process - it's going
nowhere, but eating I/O capacity as it does so.

>When, after a few seconds, the
>entirely-resident process completes, the other is allowed to take up as
>much RAM as it likes.

i.e. it resumes proper execution.

>If I've followed my mental dry-run correctly, the entirely-resident process
>would probably be the *second* process to be started, assuming both are
>identical, one is started a few scheduling cycles after the other, and the
>first process establishes it's 100Mb working set within those few cycles.
>
>If, at this point, your suspension algorithm decided to suspend the
>(mostly) swapped-out process for a few brief periods of time, it would have
>little effect except maybe to slightly delay the resumption of progress of
>the swapped-out process and to reduce the amount of disk I/O caused while
>the first process ran to completion.

If you truly allow the second process to be starved entirely of
memory, yes. At which point, it's suspended, and you've just copied my
solution (and Rik's, and that used by a dozen other Unices.)

>>>I think we're approaching the problem from opposite viewpoints.  Don't get
>>>me wrong here - I think process suspension could be a valuable "feature"
>>>under extreme load, but I think that the working-set idea will perform
>>>better and more consistently under "mild overloads", which the current
>>>system handles extremely poorly.  Probably the only way to resolve this
>>>argument is to actually try and implement each idea, and see how they
>>>perform.
>>
>>Since the two are not mutually exclusive, why try "comparing" them?
>>Returning to our car analogy, would you try "comparing" snow chains
>>with diff-lock?!
>
>I said nothing about comparison or competition.  By "each idea" I *include*
>the possibility of having the suspension algorithm *and* the working-set
>algorithm implemented simultaneously.  It would be instructive to see how
>they performed separately, too.

Perhaps, but they tackle different problems.


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
