Date: Fri, 20 Apr 2001 14:25:36 +0200 (MET DST)
From: Szabolcs Szakacsits <szaka@f-secure.com>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
In-Reply-To: <cfcudto0dln5tvehbgt4pecqf7i6nfuirf@4ax.com>
Message-ID: <Pine.LNX.4.30.0104201253500.20939-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "James A. Sutherland" <jas88@cam.ac.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Apr 2001, James A. Sutherland wrote:

> Rik and I are both proposing that, AFAICS; however it's implemented

Is it implemented? So why wasting words? Why don't you send the patch
for tests?

> since I think it could be done more neatly) you just suspend the
> process for a couple of seconds,

Processes are already suspended in __alloc_pages() for potentially
infinitely. This could explain why you see no progress and perhaps also
other people's problems who reported lockups on lkml. I run with a patch
that prevents this infinite looping in __alloc_pages().

So suspend at page level didn't help, now comes process level. What
next? Because it will not help either.

What would help from kernel level?

o reserved root vm, class/fair share scheduling (I run with the former
  and helps a lot to take control back [well to be honest, your
  statements about reboots are completely false even without too strict
  resource limits])

o non-overcommit [per process granularity and/or virtual swap spaces
  would be nice as well]

o better system monitoring: more info, more efficiently, smaller
  latencies [I mean 1 sec is ok but not the occasional 10+ sec
  accumulated stats that just hide a problem. This seems inrelevant but
  would help users and kernel developers to understand better a particular
  workload and tune or fix things (possibly not with the currently
  popular hard coded values).

As Stephen mentioned there are many [other] ways to improve things and I
think process suspension is just the wrong one.

> Indeed. It would certainly help with the usual test-case for such
> things ("make -j 50" or similar): you'll end up with 40 gcc processes
> being frozen at once, allowing the other 10 to complete first.

Can I recommend a real life test-case? Constant/increasing rate hit
to a dynamic web server.

	Szaka


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
