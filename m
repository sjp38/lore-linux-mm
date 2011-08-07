Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6EE6B016B
	for <linux-mm@kvack.org>; Sun,  7 Aug 2011 10:13:50 -0400 (EDT)
Received: by pzk6 with SMTP id 6so1199586pzk.36
        for <linux-mm@kvack.org>; Sun, 07 Aug 2011 07:13:48 -0700 (PDT)
Date: Sun, 7 Aug 2011 23:13:36 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RFC PATCH 3/3] mm: get_first_page_unless_zero()
Message-ID: <20110807141336.GB1823@barrios-desktop>
References: <1312492042-13184-1-git-send-email-walken@google.com>
 <1312492042-13184-4-git-send-email-walken@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312492042-13184-4-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

On Thu, Aug 04, 2011 at 02:07:22PM -0700, Michel Lespinasse wrote:
> This change introduces a new get_page_unless_zero() function, to be
> used for idle page tracking in a a future patch series. It also
> illustrates why I care about introducing the page count lock discussed
> in the previous commit.
> 
> To explain the context: for idle page tracking, I am scanning pages
> at a known rate based on their physical address. I want to find out
> if pages have been referenced since the last scan using page_referenced(),
> but before that I must acquire a reference on the page and to basic
> checks about the page type. Before THP, it was safe to acquire references
> using get_page_unless_zero(), but this won't work with in THP enabled kernel
> due to the possible race with __split_huge_page_refcount(). Thus, the new
> proposed get_first_page_unless_zero() function:
> 
> - must act like get_page_unless_zero() if the page is not a tail page;
> - returns 0 for tail pages.
> 
> Without the page count lock I'm proposing, other approaches don't work
> as well to provide mutual exclusion with __split_huge_page_refcount():
> 
> - using the zone LRU lock would work, but has a low granularity and
>   exhibits contention under some of our workloads

I thougt this but it seems your concern is LRU lock contention.

This patch doesn't include any use case(Sometime it hurts reviewers)
but I expect it's in idle tracking patch set.
But we don't conclude yet idle page tracking patchset is reasonable
or not to merge mainline. So, I think it's rather rash idea.
(But I admit [1,2/3] is enough to discuss regardless of idle page tracking)

What I suggestion is as follows,

1. Replace naked page->_count accesses with accessor functions
2. page count lock
3. idle page tracking with simple lock(ex, zone->lru_lock)
4. get_first_page_unless_zero to optimize lock overhead.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
