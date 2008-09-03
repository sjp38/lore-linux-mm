From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 4/4] capture pages freed during direct reclaim for allocation by the reclaimer
Date: Wed,  3 Sep 2008 19:44:12 +0100
Message-Id: <1220467452-15794-5-git-send-email-apw@shadowen.org>
In-Reply-To: <1220467452-15794-1-git-send-email-apw@shadowen.org>
References: <1220467452-15794-1-git-send-email-apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

When a process enters direct reclaim it will expend effort identifying
and releasing pages in the hope of obtaining a page.  However as these
pages are released asynchronously there is every possibility that the
pages will have been consumed by other allocators before the reclaimer
gets a look in.  This is particularly problematic where the reclaimer is
attempting to allocate a higher order page.  It is highly likely that
a parallel allocation will consume lower order constituent pages as we
release them preventing them coelescing into the higher order page the
reclaimer desires.

This patch set attempts to address this for allocations above
ALLOC_COSTLY_ORDER by temporarily collecting the pages we are releasing
onto a local free list.  Instead of freeing them to the main buddy lists,
pages are collected and coelesced on this per direct reclaimer free list.
Pages which are freed by other processes are also considered, where they
coelesce with a page already under capture they will be moved to the
capture list.  When pressure has been applied to a zone we then consult
the capture list and if there is an appropriatly sized page available
it is taken immediatly and the remainder returned to the free pool.
Capture is only enabled when the reclaimer's allocation order exceeds
ALLOC_COSTLY_ORDER as free pages below this order should naturally occur
in large numbers following regular reclaim.

Thanks go to Mel Gorman for numerous discussions during the development
of this patch and for his repeated reviews.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
