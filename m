Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
Date: Sun, 29 Jul 2001 16:39:17 +0200
References: <Pine.LNX.4.21.0107281035380.5720-100000@freak.distro.conectiva> <01072822131300.00315@starship> <3B6369DE.F9085405@zip.com.au>
In-Reply-To: <3B6369DE.F9085405@zip.com.au>
MIME-Version: 1.0
Message-Id: <01072916391702.00341@starship>
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Mike Galbraith <mikeg@wen-online.de>, Steven Cole <elenstev@mesatop.com>, Roger Larsson <roger.larsson@skelleftea.mail.telia.com>
List-ID: <linux-mm.kvack.org>

On Sunday 29 July 2001 03:41, Andrew Morton wrote:
> Daniel Phillips wrote:
> > Oh, by the way, my suspicions about the flakiness of dbench as a
> > benchmark were confirmed: under X, having been running various
> > memory hungry applications for a while, dbench on vanilla 2.4.7
> > turned in a 7% better performance (with a distinctly different
> > process termination pattern) than in text mode after a clean
> > reboot.
>
> Be very wary of optimising for dbench.

Agreed, but I still prefer to try to find that "never worse, usually 
better" performance sweet spot.

> It's a good stress tester, but I don't think it's a good indicator of
> how well an fs or the VM is performing.  It does much more writing
> than a normal workload mix.  It generates oceans of metadata.

I read the code and straced it.  I now understand *partially* what it 
does.  I'll take another look with your metadata comment in mind.  I 
have specifically not done anything about balancing with buffer pages 
yet, hoping that the current behaviour would work well for now.

One thing I noticed about dbench: it actually consists of a number of 
different loads, which you will see immediately if you do "tree" on its 
working directory or read the client.txt file.  One of those loads most 
probably is the worst for use-once, so what I should do is select loads 
one by one until I find the worst one.  Then it should be a short step 
to knowing why.

I did find and fix one genuine oversight, improving things
considerably, see my previous post.

> It would be very useful to have a standardised and very carefully
> chosen set of tests which we could use for evaluating fs and kernel
> performance.  I'm not aware of anything suitable, really.  It would
> have to be a whole bunch of datapoints sprinkled throughout a
> multidimesional space.  That's what we do at present, but it's
> ad-hoc.

Yes, now who will be the hero to come up with such a suite?

> > Maybe somebody can explain to me why there is sometimes a long wait
> > between the "+" a process prints when it exits and the "*" printed
> > in the parent's loop on waitpid(0, &status, 0).  And similarly, why
> > all the "*"'s are always printed together.
>
> Heaven knows.  Seems that sometimes one client makes much more
> progress than others.  When that happens, other clients coast
> along on its coattails and they start exitting waaay earlier
> than they normally do.  The overall runtime can vary by a factor
> of two between identical invokations.

That's what I've seen, though I haven't seen 2x variations since the 
days of 2.4.0-test.  I'd like to have a deeper understanding of this 
behaviour.  My guess is that somebody (Tridge) carefully tuned the 
dbench mix until its behaviour became "interesting".  Thanks ;-)

The butterfly effect here seems to be caused by the scheduler more than 
anything.  It seems that higher performance in dbench is nearly always 
associated with "bursty" scheduling.  Why the bursty scheduling 
sometimes happens and sometimes doesn't is not clear at all.  If we 
could understand and control the effect maybe we'd be able to eke out a 
system-wide performance boost under load.

I *think* it has to do with working sets, i.e., staying within 
non-thrashing limits by preferentially continuing to schedule a subset 
of processes that are currently active.  But I have not noticed yet 
exactly which resource might be being thrashed.

> The fact that a kernel change causes a decrease in dbench throughput
> is by no means a reliable indication that is was a bad change.  More
> information needed.

Yep, still digging, and making progress I think.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
