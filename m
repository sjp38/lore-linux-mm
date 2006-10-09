Date: Mon, 9 Oct 2006 15:02:59 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] memory page_alloc zonelist caching speedup
Message-Id: <20061009150259.d5b87469.pj@sgi.com>
In-Reply-To: <20061009111203.5dba9cbe.akpm@osdl.org>
References: <20061009105451.14408.28481.sendpatchset@jackhammer.engr.sgi.com>
	<20061009105457.14408.859.sendpatchset@jackhammer.engr.sgi.com>
	<20061009111203.5dba9cbe.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, nickpiggin@yahoo.com.au, rientjes@google.com, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Andrew wrote:
> I worry about the one-second-expiry thing.  Wall time is a pretty
> meaningless thing in the context of the page allocator and it doesn't seem
> appropriate to use it.  A more appropriate measure of "time" in this
> context would be number-of-pages-allocated.

Yeah, maybe ...

Let's take a couple of extreme examples.

1) Let's say a compute intensive app is growing slowly, one page
   every few seconds.  Do we really care whether or not we take the
   fast path or the slow path through the page allocator in this case?
   I doubt it.

   Though, if it's been a while, I'd sooner take the slow path code and
   get the page placed exactly on the first zone that can provide it.
   Just because a cache hasn't been used in several seconds doesn't
   make it still useful.  Maybe something we didn't count changed.

   For this reason, I still think a time based expiration is useful.

2) Let's say you just got a sample petahertz processor from your
   favorite CPU vendor, with 64 cores and 4 TBytes of 10 picosecond
   RAM, all in one package.  You can built, boot and test your entire
   distro in 4.2 seconds.  The average teenager can do it in 2.7
   seconds, because they have faster fingers.  Life is good.

   Yeah - well - in that case only resetting this cache 4 times in
   that entire build, boot and test cycle is retarded.

So that suggests we need two triggers on the cache expiration:

 * the current time trigger, and
 * a counter trigger - say every 1000 allocations.

Once either the count or the time trigger is hit, reset the cache.

I guess this means we add a counter to the zonelist_cache struct.
Increment it each time we try to allocate a page from that zonelist.
Trigger a zap (cache expiration) if the counter hits 1000, and clear
the counter when we do the zap.

If we have many CPUs banging on one poor zonelist, this counter risks
creating a warm cache line.  Though since this is per zone (tends to be
per node) and since the rest of this line of memory is stone cold, this
is not likely to be a serious problem.

Normally, if I'm not sure I need a line of code, I don't code it.
But if it makes others happier to have the extra code, and it seems
harmless enough, then what the heck - add it.

Guess I should code up such a counter, so we can see how it looks.

I still doubt it matters ...

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
