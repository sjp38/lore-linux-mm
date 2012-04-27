Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 238466B00EB
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 13:42:30 -0400 (EDT)
Received: by laah2 with SMTP id h2so51228laa.2
        for <linux-mm@kvack.org>; Fri, 27 Apr 2012 10:42:28 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 1/2] mm: Warn once when a page is freed with PG_mlocked
Date: Fri, 27 Apr 2012 10:42:26 -0700
Message-Id: <1335548546-25040-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>

I am resending this patch orginally from Mel, and the reason we spotted this
is due to the next patch where I am adding the mlock stat into per-memcg
meminfo. We found out that it is impossible to update the counter if the page
is in the freeing patch w/ mlocked bit set.

Then we started wondering if it is possible at all. It shouldn't happen that
freeing a mlocked page without going through munlock_vma_pages_all(). Looks
like it did happen few years ago, and here is the patch introduced it

commit 985737cf2ea096ea946aed82c7484d40defc71a8
Author: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date:   Sat Oct 18 20:26:53 2008 -0700

    mlock: count attempts to free mlocked page

There are two ways to persue and I would like to ask people's opinion:

1. revert the patch totally and the page will get into bad_page(). Then we
get the report as well.

2. fix up the page like the patch does but put on warn_once() to report the
problem.

People might feel more confident by doing step by step which adding the
warn_on() first and then revert it later. So I resend the patch from Mel and
here is the patch:

When a page is freed with the PG_mlocked set, it is considered an unexpected
but recoverable situation. A counter records how often this event happens
but it is easy to miss that this event has occured at all. This patch warns
once when PG_mlocked is set to prompt debuggers to check the counter to
see how often it is happening.

Signed-off-by: Ying Han <yinghan@google.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/page_alloc.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a712fb9..4f905af 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -599,6 +599,11 @@ out:
  */
 static inline void free_page_mlock(struct page *page)
 {
+	WARN_ONCE(1, KERN_WARNING
+		"Page flag mlocked set for process %s at pfn:%05lx\n"
+		"page:%p flags:%#lx\n",
+		current->comm, page_to_pfn(page),
+		page, page->flags|__PG_MLOCKED);
 	__dec_zone_page_state(page, NR_MLOCK);
 	__count_vm_event(UNEVICTABLE_MLOCKFREED);
 }
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
