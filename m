Date: Fri, 21 Jan 2000 03:01:45 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.2.1{3,4,5} VM fix
In-Reply-To: <Pine.LNX.4.10.10001210152350.27593-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.4.21.0001210220190.4332-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2000, Rik van Riel wrote:

>We must clean up those 32 pages because we also use them
>for swapin readaround.

During the swapout that doesn't matter much since in the mix of swapin
swapout you may need the readaround in the middle of swap_out and not when
do_try_to_free_pages completed. If there's high memory and you do a
swapin, the first swapin will be a sync operation so you'll flush the I/O
and all further swapins will take advantage of readaround so that's a
minor issue too.

Anyway your fix wouldn't be correct either, because if it would be
necessary you should trigger I/O after all swapouts not only inside
kswapd. And you should never run_task_queue if you didn't recalled
swap_out().

>Hmmm, you're right. It's even worse than I thought...
>
>Once we've reached free_pages.high, kswapd will sleep
>and not wake up again until we've reached an emergency
>situation. And when we are in an even worse emergency
>kswapd will bloody SLEEP for 10 seconds!

That's fine instead.

>We want kswapd to free memory before we reach an emergency
>situation. That is, if nr_free_pages < freepages.high,
>kswapd should free a few pages. We should check that every
>second or so...

_It's_ checking every second (not or so).

But what I just said is that the check every second is almost useless for
normal allocations. In one second you just eaten all free memory. And I
think such pool loop should be shutted down completly. I think that kind
of poll is the real source of atomic-allocation problems. I'll do a patch
against 2.2.14 to show you what I think to have seen as problematic for
atomic allocations but IIRC nothing is changed in this respect between
2.2.13 and 2.2.14. Is the atomic allocation troubles started with 2.2.14
(I guess no)?

>`Who is allocating memory' is _not_ always the memory hog.

red herring. You know that we are based on probability.

>Your idea will punish the wrong processes!

Run the trashing_mem patch I pointed out to Alan. I debugged it with
printk and it punish the right process here. Give it a try. It will only
bias a bit more the current heuristic.

>The pre-wakeup is triggered in part by the `-4' thing
>and partly disfunctional because kswapd in 2.2 is more
>braindead than I thought before :(

I remeber how you driven kswapd in the past. You let it running all the
time in RT. Then when people come up and complained about oom-deadlocks,
so you started sending sigkill to processes from inside kswapd and you
given this as a solution. NOTE: I like your selection of the "best" task
but sending sigkill from kswapd is wrong IMHO. Sorry I don't agree in your
way and I merely suggest you to not take it again.

I got lots of oom lockup reports for 2.2.x. Now 2.2.14 has all my fixes
included and a kswapd that is been finally dominated, please don't
resurrect it to the old behaviour.

I think to see the atomic allocation problem and it will get fixed with
a one liner. But the problem cames from 2.2.13, not from my changes.

>> If you are planning to change the current semantics of the GFP_*
>> variables please work on 2.3.x only.
>
>You have silently changed the semantics of various
>things in the VM subsystem in 2.2. I'd like to
>change it back to something that works.

2.2.13 definitely doesn't work. If you don't believe me I'll send you a
flood of lockup reports (I got one security-advisory about oom lockups
even _today_ that 2.2.14 just includes all the fixes and doesn't deadlock
anymore with such exploits :).

And I am not changing the semantics of anything. Please read the diff
before complaining.

_You_ are the one that proposed new semantics for high/low priority
allocations. I only said you how things works since the late 2.1.x and I
agree with the current semanitc.

I'll try to send a patch against 2.2.14 for the atomic allocation thing
that I think to see ASAP.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
