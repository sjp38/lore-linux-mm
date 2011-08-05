Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B0C15900137
	for <linux-mm@kvack.org>; Fri,  5 Aug 2011 02:39:23 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p756dLoM023334
	for <linux-mm@kvack.org>; Thu, 4 Aug 2011 23:39:21 -0700
Received: from qyk31 (qyk31.prod.google.com [10.241.83.159])
	by wpaz21.hot.corp.google.com with ESMTP id p756cT59003421
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 4 Aug 2011 23:39:20 -0700
Received: by qyk31 with SMTP id 31so1173995qyk.18
        for <linux-mm@kvack.org>; Thu, 04 Aug 2011 23:39:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1312492042-13184-1-git-send-email-walken@google.com>
References: <1312492042-13184-1-git-send-email-walken@google.com>
Date: Thu, 4 Aug 2011 23:39:19 -0700
Message-ID: <CANN689HpuQ3bAW946c4OeoLLAUXHd6nzp+NVxkrFgZo7k3k0Kg@mail.gmail.com>
Subject: Re: [RFC PATCH 0/3] page count lock for simpler put_page
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

On Thu, Aug 4, 2011 at 2:07 PM, Michel Lespinasse <walken@google.com> wrote:
> Patch 3 demonstrates my motivation for this patch series: in my pre-THP
> implementation of idle page tracking, I was able to use get_page_unless_zero
> in a way that __split_huge_page_refcount made unsafe. Building on top of
> patch 2, I can make the required operation safe again. If patch 2 was to
> be rejected, I would like to get suggestions about alternative approaches
> to implement the get_first_page_unless_zero() operation described here.

I should add that I am quite worried about the places that use
get_page_unless_zero (or the page_cache_*_speculative wrappers) today.
My worrisome scenario would be as follows:

- thread T finds a pointer to a page P (possibly from a radix tree in
find_get_page() )
- page P gets freed by another thread
- page P gets re-allocated as the tail of a THP page by another thread
- another thread gets a reference on page P
- thread T proceeds doing page_cache_get_speculative(P), intending to
then check that P is really the page it wanted
- another thread splits up P's compound page;
__split_huge_page_refcount subtracts T's refcount on P from head(P)'s
refcount
- thread T figures out that it didn't get the page it expected, calls
page_cache_release(P). But it's too late - the refcount for what used
to be head(P) has already been corrupted (incorrectly decremented).

Does anything prevent the above ?

I can see that the page_cache_get_speculative comment in
include/linux/pagemap.h maps out one way to prevent the issue. If
thread T continually held an rcu read lock from the time it finds the
pointer to P until the time it calls get_page_unless_zero on that
page, AND there was a synchronize_rcu() call somewhere between the
time a THP page gets allocated and the time __split_huge_page_refcount
might first get called on that page, then things would be safe.
However, that does not seem to be true today: I could not find a
synchronize_rcu() call before __split_huge_page_refcount(), AND there
are also places (such as deactivate_page() for example) that call
get_page_unless_zero without being within an rcu read locked section
(or holding the zone lru lock to provide exclusion against
__split_huge_page_refcount).

Is there another protection mechanism that I have not considered ?

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
