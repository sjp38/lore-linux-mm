Subject: Re: [PATCH] low-latency zap_page_range
From: Robert Love <rml@tech9.net>
In-Reply-To: <3D3B94AF.27A254EA@zip.com.au>
References: <1027196427.1116.753.camel@sinai>
	<3D3B94AF.27A254EA@zip.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 22 Jul 2002 10:58:04 -0700
Message-Id: <1027360686.932.33.camel@sinai>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: torvalds@transmeta.com, riel@conectiva.com.br, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2002-07-21 at 22:14, Andrew Morton wrote:

> This adds probably-unneeded extra work - we shouldn't go
> dropping the lock unless that is actually required.  ie:
> poll ->need_resched first.    Possible?

Sure.  What do you think of this?

	spin_lock(&mm->page_table_lock);

	while (size) {
		block = (size > ZAP_BLOCK_SIZE) ? ZAP_BLOCK_SIZE : size;
		end = address + block;

		flush_cache_range(vma, address, end);
		tlb = tlb_gather_mmu(mm, 0);
		unmap_page_range(tlb, vma, address, end);
		tlb_finish_mmu(tlb, address, end);

		if (need_resched()) {
			/*
			 * If we need to reschedule we will do so
			 * here if we do not hold any other locks.
			 */
			spin_unlock(&mm->page_table_lock);
			spin_lock(&mm->page_table_lock);
		}

		address += block;
		size -= block;
	}

	spin_unlock(&mm->page_table_lock);

My only issue with the above is it is _ugly_ compared to the more
natural loop.  I.e., this looks much more like explicit lock breaking /
conditional rescheduling whereas the original loop just happens to
acquire and release the lock on each iteration.  Sure, same effect, but
I think its says something toward the maintainability and cleanliness of
the function.

One thing about the "overhead" here - the main overhead would be the
lock bouncing in between cachelines on SMP afaict.  However, either (a)
there is no SMP contention or (b) there is and dropping the lock
regardless may be a good idea.  Thoughts?

Hm, the above also ends up checking need_resched twice (the explicit
need_resched() and again on the final unlock)... we can fix that by
manually calling _raw_spin_unlock and then preempt_schedule, but that
could also result in a (much longer) needless call to preempt_schedule
if an intervening interrupt serviced the request first. 

But maybe that is just me... like this better?  I can redo the patch as
the above.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
