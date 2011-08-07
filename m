Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 923A2900137
	for <linux-mm@kvack.org>; Sun,  7 Aug 2011 10:25:45 -0400 (EDT)
Received: by pzk6 with SMTP id 6so1217063pzk.36
        for <linux-mm@kvack.org>; Sun, 07 Aug 2011 07:25:43 -0700 (PDT)
Date: Sun, 7 Aug 2011 23:25:32 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RFC PATCH 0/3] page count lock for simpler put_page
Message-ID: <20110807142532.GC1823@barrios-desktop>
References: <1312492042-13184-1-git-send-email-walken@google.com>
 <CANN689HpuQ3bAW946c4OeoLLAUXHd6nzp+NVxkrFgZo7k3k0Kg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689HpuQ3bAW946c4OeoLLAUXHd6nzp+NVxkrFgZo7k3k0Kg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

On Thu, Aug 04, 2011 at 11:39:19PM -0700, Michel Lespinasse wrote:
> On Thu, Aug 4, 2011 at 2:07 PM, Michel Lespinasse <walken@google.com> wrote:
> > Patch 3 demonstrates my motivation for this patch series: in my pre-THP
> > implementation of idle page tracking, I was able to use get_page_unless_zero
> > in a way that __split_huge_page_refcount made unsafe. Building on top of
> > patch 2, I can make the required operation safe again. If patch 2 was to
> > be rejected, I would like to get suggestions about alternative approaches
> > to implement the get_first_page_unless_zero() operation described here.
> 
> I should add that I am quite worried about the places that use
> get_page_unless_zero (or the page_cache_*_speculative wrappers) today.
> My worrisome scenario would be as follows:
> 
> - thread T finds a pointer to a page P (possibly from a radix tree in
> find_get_page() )
> - page P gets freed by another thread
> - page P gets re-allocated as the tail of a THP page by another thread
> - another thread gets a reference on page P
> - thread T proceeds doing page_cache_get_speculative(P), intending to
> then check that P is really the page it wanted
> - another thread splits up P's compound page;
> __split_huge_page_refcount subtracts T's refcount on P from head(P)'s
> refcount
> - thread T figures out that it didn't get the page it expected, calls
> page_cache_release(P). But it's too late - the refcount for what used
> to be head(P) has already been corrupted (incorrectly decremented).
> 
> Does anything prevent the above ?

I think it's possbile and you find a BUG.
Andrea?

> 
> I can see that the page_cache_get_speculative comment in
> include/linux/pagemap.h maps out one way to prevent the issue. If
> thread T continually held an rcu read lock from the time it finds the
> pointer to P until the time it calls get_page_unless_zero on that
> page, AND there was a synchronize_rcu() call somewhere between the
> time a THP page gets allocated and the time __split_huge_page_refcount
> might first get called on that page, then things would be safe.
> However, that does not seem to be true today: I could not find a
> synchronize_rcu() call before __split_huge_page_refcount(), AND there
> are also places (such as deactivate_page() for example) that call
> get_page_unless_zero without being within an rcu read locked section
> (or holding the zone lru lock to provide exclusion against
> __split_huge_page_refcount).

When I make deactivate_page, I didn't consider that honestly.
IMHO, It shouldn't be a problem as deactive_page hold a reference
of page by pagevec_lookup so the page shouldn't be gone under us.
And at the moment, deactive_page is used by only invalidate_mapping_pages
which handles only file pages but THP handles only anon pages.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
