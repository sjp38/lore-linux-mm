Date: Fri, 8 Sep 2006 11:41:14 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 5/5] linear reclaim core
Message-Id: <20060908114114.87612de3.akpm@osdl.org>
In-Reply-To: <20060908122718.GA1662@shadowen.org>
References: <exportbomb.1157718286@pinky>
	<20060908122718.GA1662@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Sep 2006 13:27:18 +0100
Andy Whitcroft <apw@shadowen.org> wrote:

> When we are out of memory of a suitable size we enter reclaim.
> The current reclaim algorithm targets pages in LRU order, which
> is great for fairness but highly unsuitable if you desire pages at
> higher orders.  To get pages of higher order we must shoot down a
> very high proportion of memory; >95% in a lot of cases.
> 
> This patch introduces an alternative algorithm used when requesting
> higher order allocations.  Here we look at memory in ranges at the
> order requested.  We make a quick pass to see if all pages in that
> area are likely to be reclaimed, only then do we apply reclaim to
> the pages in the area.
> 
> Testing in combination with fragmentation avoidance shows
> significantly improved chances of a successful allocation at
> higher order.

I bet it does.

I'm somewhat surprised at the implementation.  Would it not be sufficient
to do this within shrink_inactive_list()?  Something along the lines of:

- Pick tail page off LRU.

- For all "neighbour" pages (alignment == 1<<order, count == 1<<order)

  - If they're all PageLRU and !PageActive, add them all to page_list for
    possible reclaim

And, in shrink_active_list:

- Pick tail page off LRU

- For all "neighbour" pages (alignment == 1<<order, count == 1<<order)

  If they're all PageLRU, put all the active pages in this block onto
  l_hold for possible deactivation.


Maybe all that can be done in isolate_lru_pages().


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
