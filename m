From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
Date: Sat, 21 Apr 2001 07:08:29 +0100
Message-ID: <6u72et8hqnb32nd6da881frgpulnve8rj7@4ax.com>
References: <cfcudto0dln5tvehbgt4pecqf7i6nfuirf@4ax.com> <Pine.LNX.4.30.0104201253500.20939-100000@fs131-224.f-secure.com>
In-Reply-To: <Pine.LNX.4.30.0104201253500.20939-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 20 Apr 2001 14:25:36 +0200 (MET DST), you wrote:
>On Thu, 19 Apr 2001, James A. Sutherland wrote:
>
>> Rik and I are both proposing that, AFAICS; however it's implemented
>
>Is it implemented? So why wasting words? Why don't you send the patch
>for tests?

It isn't. You've mangled my sentence, changing the meaning...

>> since I think it could be done more neatly) you just suspend the
>> process for a couple of seconds,
>
>Processes are already suspended in __alloc_pages() for potentially
>infinitely. This could explain why you see no progress and perhaps also
>other people's problems who reported lockups on lkml. I run with a patch
>that prevents this infinite looping in __alloc_pages().

Yep, that's the whole problem. One process starts running, page
faults, so another starts running and faults - if you have enough
faults before you get back to the first process, it will fault again
straight away because you've swapped the page it was waiting for back
out!

>So suspend at page level didn't help, now comes process level. What
>next? Because it will not help either.

It will... "suspend at page level" is part of the problem: you need to
make sure the process gets a chance to USE the memory it just faulted
in.

>What would help from kernel level?
>
>o reserved root vm, 

Not much; OK, it would allow you to log in and kill the runaway
processes, but that's it. An Alt+SysRq key could do the same...

>class/fair share scheduling (I run with the former
>  and helps a lot to take control back [well to be honest, your
>  statements about reboots are completely false even without too strict
>  resource limits])

I was speaking from personal experience there...

>o non-overcommit [per process granularity and/or virtual swap spaces
>  would be nice as well]

Non-overcommit would just make matters worse: you would get the same
results but with a big chunk of swap space wasted "just in case". How
exactly would that help?

>o better system monitoring: more info, more efficiently, smaller
>  latencies [I mean 1 sec is ok but not the occasional 10+ sec
>  accumulated stats that just hide a problem. This seems inrelevant but
>  would help users and kernel developers to understand better a particular
>  workload and tune or fix things (possibly not with the currently
>  popular hard coded values).

You don't need system monitoring to detect thrashing: this would be
like fitting a warning light to your car to indicate "You've hit
something!": other subtle hints like the loud noise, the impact and
the change in car shape should convey this information already.

>As Stephen mentioned there are many [other] ways to improve things and I
>think process suspension is just the wrong one.

It's the best approach in the pathological cases where we NEED to do
something drastic or we lose the box.

>> Indeed. It would certainly help with the usual test-case for such
>> things ("make -j 50" or similar): you'll end up with 40 gcc processes
>> being frozen at once, allowing the other 10 to complete first.
>
>Can I recommend a real life test-case? Constant/increasing rate hit
>to a dynamic web server.

Yep, OK; let's assume it's a prefork server like Apache 1.3, so you
have lots of independent processes, each serving one client. Right
now, each request will hit a thrashing process. On non-thrashing
systems (running in RAM) the request takes 1 seconds to process. If
you're very lucky, thrashing, the request will be handled within two
hours. By which time, any real-world browser has given up, and you
wasted a lot of resources feeding data to /dev/null.

Now we try with process suspension. Again, we'll have Apache's
MaxProcesses number of processes running accepting requests, but this
time all the active processes are being periodically suspended to
allow others to complete. Suppose we can support 10 simultaneous
processes, and MaxProcesses is 100; the worst case is then that a 1
second response time goes to 10, instead of every single request
timing out.

Summary: with process suspension, clients get handled slowly. Without
it, requests go to /dev/null and eat CPU on the way. I know which I
prefer!


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
