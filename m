Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA23713
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 16:43:24 -0500
Date: Sun, 10 Jan 1999 13:41:38 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Reply-To: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Results: pre6 vs pre6+zlatko's_patch  vs pre5 vs arcavm13
In-Reply-To: <36990DB5.DA6AE432@netplus.net>
Message-ID: <Pine.LNX.3.95.990110130307.7668N-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steve Bergman <steve@netplus.net>
Cc: Andrea Arcangeli <andrea@e-mind.com>, "Garst R. Reese" <reese@isn.net>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>



On Sun, 10 Jan 1999, Steve Bergman wrote:
> 
> I tried the patch in the 'image test' and it helped little if any.  Still a lot
> of swapping in and the numbers are close enough that I'm not sure it helped at
> all.  This was a comparison between vanilla pre6 and vanilla
> pre6+page_alloc_patch with no other patches applied.

Ok, I think I now know why pre-6 looks so unbalanced. It's two issues. 

Basically, trying to swap out a large number of pages from one process
context is just doomed. It bascially sucks, because

 - it has bad latency. This is further excerberated by the per-process
   "thrashing_memory" flag, which means that if we were unlucky enough to
   be selected to be the process that frees up memory, we'll probably be
   stuck with it for a long time. That can make it extremely unfair under
   some circumstances - other processes may allocate the pages we free'd
   up, so that we keep on being counted as a memory trasher even if we
   really aren't. 

   Note that this shows most under "moderate" load - the problem doesn't
   tend to show itself if you have some process that is _really_
   allocating a lot of pages, because then that process will be correctly
   found by the trashing logic. But if you have lots of "normal load"
   processes, some of those can get really badly hurt by this.

   In particular, the worst case you have a number of processes that all
   allocate memory, but not very quickly - certainly not more quickly than
   we can page things out. What happens is that under these circumstances
   one of them gets marked as a "scapegoat", and once that happens all the
   others will just live off the pages that the scapegoat frees up, while
   the scapegoat itself doesn't make much progress at all because it is
   always just freeing memory for others. 

   The really bad behaviour tends to go away reasonably quickly, but while
   it happens it's _really_ unfair.

 - try_to_free_pages() just goes overboard, and starts paging stuff out
   without getting back to the nice balanced behaviour. This is what
   Andrea noticed.

   Essentially, once it starts failing the shrink_mmap() tests, it will
   just page things out crazily. Normally this is avoided by just always
   starting from shrink_mmap(), but if you ask try_to_free_pages() to try
   to free up a ton of pages, the balancing that it does is basically
   bypassed.

So basically pre-6 works _really_ well for the kind of stress-me stuff
that it was designed for: a few processes that are extremely memory
hungry. It gets close to perfect swap-out behaviour, simply because it is
optimized for getting into a paging rut. 

That makes for nice benchmarks, but it also explains why (a) sometimes
it's just not very nice for interactive behaviour and (b) why it under
normal load can easily swap much too eagerly.

Anyway, the first problem is fixed by making "trashing" be a global flag
rather than a per-process flag. Being per-process is really nice when it
finds the right process, but it's really unfair under a lot of other
circumstances. I'd rather be fair than get the best possible page-out
speed. 

Note that even a global flag helps: it still clusters the write-outs, and
means that processes that allocate more pages tend to be more likely to be
hit by it, so it still does a large part of what the per-process flag did
- without the unfairness (but admittedly being unfair sometimes gets you
better performance - you just have to be _very_ careful whom you target
with the unfairness, and that's the hard part). 

The second problem actually goes away by simply just not asking
try_to_free_pages() to free too many pages - and having the global
trashing flag makes it unnecessary to do so anyway because the flag will
essentially cluster the page-outs even without asking for them to be all
done in one large chunk (and now it's not just one process that gets hit
any more).

There's a "pre-7.gz" on ftp.kernel.org in testing, anybody interested? 
It's not the real thing, as I haven't done the write semaphore deadlock
thing yet, but that one will not affect normal users anyway so for
performance testing this should be equivalent. 

			Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
