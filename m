Date: Fri, 7 Jul 2000 18:58:41 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [linux-audio-dev] Re: [PATCH really] latency improvements, one
  reschedule moved
In-Reply-To: <396653EC.5D146D55@norran.net>
Message-ID: <Pine.LNX.4.10.10007071846510.3444-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: zlatko@iskon.hr, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Sat, 8 Jul 2000, Roger Larsson wrote:
> 
> I examined the patches again and the fact that it runs
> do_try_to_free_pages
> periodically may improve performance due to its page cleaning effect -
> all pages won't be dirty at the same time...

One potential problem with this, though, is that it keeps shrinking the
dcache etc: even though various parts of the system refuse to touch pages
once the machine has "enough" memory, the periodic wake-up will cause
those caches that don't have the "I don't need to do this" logic to
potentially be starved.

The keep_kswapd_awake() logic protects from the worst case (it won't go on
forever), but I wonder if it might still not cause bad behaviour when one
zone is getting balanced and the other zones shouldn't be touched, but the
continual trickle will cause the dcache etc stuff to be free'd with very
little good reason.

The "one zone gets rebalanced" is normal behaviour, so this is why I worry
about the dcache.

> But it has a downside too - it will destroy the LRU order of pages...
> PG_referenced loses some of its meaning...

That part doesn't bother me in the least - it can be seen as a simple
aging of the referenced bit. Especially if we're going to re-introduce the
multi-bit page "age" code, aging the reference bits actually only improves
stuff. 

The fact that shrink_mmap() gets called regularly also makes bdflush
potentially less important, because shrink_mmap() actually does a better
job of flushing dirty data anyway these days, and in many ways it makes
sense to have this kind of background LRU list activity.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
