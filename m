Date: Wed, 24 Jul 2002 20:08:34 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: page_add/remove_rmap costs
Message-ID: <20020725030834.GC2907@holomorphy.com>
References: <3D3E4A30.8A108B45@zip.com.au> <Pine.LNX.4.44L.0207241319550.3086-100000@imladris.surriel.com> <3D3F0ACE.D4195BF@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D3F0ACE.D4195BF@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2002 at 01:15:10PM -0700, Andrew Morton wrote:
> So.. who's going to do it?
> It's early days yet - although this looks bad on benchmarks we really
> need a better understanding of _why_ it's so bad, and of whether it
> really matters for real workloads.
> For example: given that copy_page_range performs atomic ops against
> page->count, how come page_add_rmap()'s atomic op against page->flags
> is more of a problem?

Hmm. It probably isn't harming more than benchmarks, but the loop is
pure bloat on UP. #ifdef that out someday. (Heck, don't even touch the
bit for UP except for debugging.)

Hypothesis:
There are too many cachelines to gain exclusive ownership of. It's not
the aggregate arrival rate, it's the aggregate cacheline-claiming
bandwidth needed to get exclusive ownership of all the pages' ->flags.

Experiment 1:
Group pages into blocks of say 2 or 4 for locality, and then hash each
pageblock to a lock. The worst case wrt. claiming cachelines is then
the size of the hash table divided by the size of the lock, but the
potential for cacheline contention exists.

Experiment 2:
Move ->flags to be adjacent to ->count and align struct page to a
divisor of the cacheline size or play tricks to get it down to 32B. =)

Experiment 3:
Compare magic oprofile perfcounter stuff between 2.5.26 and 2.5.27
and do divination based on whatever the cache counters say.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
