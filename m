Date: Fri, 21 Jan 2000 03:37:23 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: [PATCH] 2.2.1{3,4,5} VM fix
In-Reply-To: <Pine.LNX.4.21.0001210220190.4332-100000@alpha.random>
Message-ID: <Pine.LNX.4.10.10001210329300.27593-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2000, Andrea Arcangeli wrote:
> On Fri, 21 Jan 2000, Rik van Riel wrote:
> 
> >We must clean up those 32 pages because we also use them
> >for swapin readaround.
> 
> Anyway your fix wouldn't be correct either, because if it would be
> necessary you should trigger I/O after all swapouts not only
> inside kswapd. And you should never run_task_queue if you didn't
> recalled swap_out().

Fixed in the second version of the patch.

> >Once we've reached free_pages.high, kswapd will sleep
> >and not wake up again until we've reached an emergency
> >situation. And when we are in an even worse emergency
> >kswapd will bloody SLEEP for 10 seconds!
> 
> That's fine instead.

Why is this a good thing? I really don't see why it
helps us any bit...

> >We want kswapd to free memory before we reach an emergency
> >situation. That is, if nr_free_pages < freepages.high,
> >kswapd should free a few pages. We should check that every
> >second or so...
> 
> _It's_ checking every second (not or so).

True, my fault.

> But what I just said is that the check every second is almost
> useless for normal allocations. In one second you just eaten all
> free memory.

Not on a quiet machine. Or on a somewhat larger machine.
Think a webserver, or a desktop machine that's streaming
mp3s from disk or reading email.

In those loads there is enough idle time that kswapd can
free up memory in the background and memory consumption
is so slow that normal processes never stall or even leave
the fast path. That is definately a good thing.

> >`Who is allocating memory' is _not_ always the memory hog.
> 
> red herring. You know that we are based on probability.

Indeed. And the probability is that the most unused
process will be continuously swapping while the hog
is using up most of system memory. We've all seen
it happen.

> >Your idea will punish the wrong processes!
> 
> Run the trashing_mem patch I pointed out to Alan. I debugged it
> with printk and it punish the right process here. Give it a try.
> It will only bias a bit more the current heuristic.

Sounds like a good idea, but for 2.3. I'll check it out.

> >The pre-wakeup is triggered in part by the `-4' thing
> >and partly disfunctional because kswapd in 2.2 is more
> >braindead than I thought before :(
> 
> I remeber how you driven kswapd in the past. You let it running
> all the time in RT. Then when people come up and complained about
> oom-deadlocks, so you started sending sigkill to processes from
> inside kswapd and you given this as a solution. NOTE: I like your
> selection of the "best" task but sending sigkill from kswapd is
> wrong IMHO. Sorry I don't agree in your way and I merely suggest
> you to not take it again.

You're completely right about this one. We've both made our
mistakes and we should definately fight this argument.
May the best code win!

> I got lots of oom lockup reports for 2.2.x. Now 2.2.14 has all my
> fixes included and a kswapd that is been finally dominated, please
> don't resurrect it to the old behaviour.
>
> I think to see the atomic allocation problem and it will get fixed with
> a one liner. But the problem cames from 2.2.13, not from my changes.

Both 2.2.13, .14 and the pre-15s have the atomic allocation
problem. I hope to have it fixed with my patch.

> And I am not changing the semantics of anything. Please read the
> diff before complaining.

What diff? I haven't seen you post anything.
And if it's too big to post, it's definately
too big to go into the stable kernel...

> I'll try to send a patch against 2.2.14 for the atomic allocation
> thing that I think to see ASAP.

OK, great. Let's try to use each other's ideas and
make the code as good as possible.

kind regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
