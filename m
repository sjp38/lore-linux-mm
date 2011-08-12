Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1AE246B016A
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 12:58:42 -0400 (EDT)
Date: Fri, 12 Aug 2011 18:58:37 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH 0/3] page count lock for simpler put_page
Message-ID: <20110812165837.GL7959@redhat.com>
References: <1312492042-13184-1-git-send-email-walken@google.com>
 <CANN689HpuQ3bAW946c4OeoLLAUXHd6nzp+NVxkrFgZo7k3k0Kg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689HpuQ3bAW946c4OeoLLAUXHd6nzp+NVxkrFgZo7k3k0Kg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

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

BTW, this isn't just a regular reference, it can only be
get_user_pages* on a tail page, so this further reduces the chance of
some order of magnitude. If was just any reference it'd be more
probable, but the time it takes to allocate the page and then some
other user to get_user_page it, sounds always slower than the
rcu_read_lock section. If irq were disabled it'd be mostly guaranteed
(but even if irqs were disabled I would totally agree in fixing this,
I would never like to depend on timings to be 100% safe).  But in this
case irq are enabled so a long irq may allow it to happen, we never
know.

> - thread T proceeds doing page_cache_get_speculative(P), intending to
> then check that P is really the page it wanted
> - another thread splits up P's compound page;
> __split_huge_page_refcount subtracts T's refcount on P from head(P)'s
> refcount
> - thread T figures out that it didn't get the page it expected, calls
> page_cache_release(P). But it's too late - the refcount for what used
> to be head(P) has already been corrupted (incorrectly decremented).

And great spotting indeed :)

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
