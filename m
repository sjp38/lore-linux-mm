Date: Thu, 30 Mar 2000 20:41:30 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: shrink_mmap SMP race fix
In-Reply-To: <Pine.LNX.4.21.0003301415270.1104-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.21.0003301921270.3831-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Mar 2000, Rik van Riel wrote:

>On Thu, 30 Mar 2000, Andrea Arcangeli wrote:
>> On Thu, 30 Mar 2000, Andrea Arcangeli wrote:
>> 
>> >[..] If something the higher is the priority the
>> >harder we should shrink the cache (that's the opposite that the patch
>> >achieves). Usually priority is always zero and the below check has no
>> >effect. [..]
>> 
>> thinko, I noticed I was wrong about this, apologies (prio start with 6 and
>> 0 is the most severe one).
>> 
>> anyway I keep not enjoying such path for all the other reasons. It should
>> at _least_ be done outside the loop before calculating `count`.
>
>True. The only reason this check is inside shrink_mmap() is that we
>may want to do the page aging on the LRU pages anyway because of
>page replacement reasons. It will be interesting to see if moving

I don't think there were any valid reason to clear all reference bits
while enforcing the minimal limit of the lru size.

The check is only a kind of barrier that tries to preserve some lru cache
based on an hardwired value (took from the freepages min level that have
nothing to do with the lru minimal size btw) while the system is under
swap. It tries to forbid shrink_mmap to eat too much cache pages. This may
have the effect that the `ls` binary gets not took out of the cache while
you hit swap or something like that depending how big is `ls` in your
system.

That's very similar to the pgcache_under_min() hack we just have but that
is a page-cache only thing and since it's not a global lru thing it make
sense to not break the loop in such case (since such check doesn't know
anything about the buffer cache). The main difference is that
pgcache_under_min doesn't care about the severity of the shrink_mmap (it's
not in function of `priority').

So I believe that we just have a kind of hack to try to preserve the `ls`
binary to be shrunk from the cache and we don't need a secondary one.

IMHO it's also better to replace the pgcache_under_min with a global lru
sysctl where we can set a low limit on the percentage of the lru cache.
And then we do:

	if (nr_lru_pages < lru_min)
		return;

before enterning the loop.

In practice the above sysctl will act the same as the current
pgcache_under_min but it avoid wasting CPU power and it also won't
penalize the buffer cache for no good reason.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
