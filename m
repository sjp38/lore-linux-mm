From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Date: Sun, 22 Apr 2001 20:01:18 +0100
Message-ID: <o7a6ets1pf548v51tu6d357ng1o0iu77ub@4ax.com>
References: <l0313030fb70791aa88ae@[192.168.239.105]> <mibudt848g9vrhaac88qjdpnaut4hajooa@4ax.com> <Pine.LNX.4.30.0104201203280.20939-100000@fs131-224.f-secure.com> <sb72ets3sek2ncsjg08sk5tmj7v9hmt4p7@4ax.com> <3AE1DCA8.A6EF6802@earthlink.net> <l0313030fb70791aa88ae@[192.168.239.105]> <54b5et09brren07ta6kme3l28th29pven4@4ax.com> <l03130311b708b57e1923@[192.168.239.105]> <re36et84buhdc4mm252om30upobd8285th@4ax.com> <l03130312b708cf8a37bf@[192.168.239.105]>
In-Reply-To: <l03130312b708cf8a37bf@[192.168.239.105]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: "Joseph A. Knapka" <jknapka@earthlink.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 22 Apr 2001 19:18:19 +0100, you wrote:

>>>No, it doesn't.  If we stick with the current page-replacement policy, then
>>>regardless of what we do with the size of the timeslice, there is always
>>>going to be the following situation:
>>
>>This is not just a case of increasing the timeslice: the suspension
>>strategy avoids the penultimate stage of this list happening:
>>
>>>- Large process(es) are thrashing.
>>>- Login needs paging in (is suspended while it waits).
>>>- Each large process gets it's page and is resumed, but immediately page
>>>faults again, gets suspended
>>>- Memory reserved for Login gets paged out before Login can do any useful
>>>work
>>
>>Except suspended processes do not get scheduled for a couple of
>>seconds, meaning login CAN do useful work.
>
>But login was suspended because of a page fault,

No, login was NOT *suspended*. It's sleeping on I/O, not suspended.

> so potentially it will
>*also* get suspended for just as long as the hogs.  

No, it will get CPU time a small fraction of a second later, once the
I/O completes.

>Unless, of course, the
>suspension time is increased with page fault count per process.

The suspension time is irrelevant to login.

>>Not really. Your WS suggestion doesn't evict some processes entirely,
>>which is necessary under some workloads.
>
>Can you give an example of such a workload?

Example: any process which is doing random access throughout an array
in memory. Let's suppose it's a 100 Mb array on a machine with 128Mb
of RAM.

One process running: array in RAM, completes in seconds.

Two processes, no suspension: half the array on disk, both complete in
days.

Two processes, suspension: complete in a little more than twice the
time for one.

How exactly will your approach solve the two process case, yet still
keeping the processes running properly?

>>Distributing "fairly" is sub-optimal: sequential suspension and
>>resumption of each memory hog will yield far better performance. To
>>the extent some workloads fail with your approach but succeed with
>>mine: if a process needs more than the current working-set in RAM to
>>make progress, your suggestion leaves each process spinning, taking up
>>resources.
>
>I think we're approaching the problem from opposite viewpoints.  Don't get
>me wrong here - I think process suspension could be a valuable "feature"
>under extreme load, but I think that the working-set idea will perform
>better and more consistently under "mild overloads", which the current
>system handles extremely poorly.  Probably the only way to resolve this
>argument is to actually try and implement each idea, and see how they
>perform.

Since the two are not mutually exclusive, why try "comparing" them?
Returning to our car analogy, would you try "comparing" snow chains
with diff-lock?!


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
