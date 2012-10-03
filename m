Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 208CF6B0070
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 17:10:45 -0400 (EDT)
Received: by padfa10 with SMTP id fa10so7894579pad.14
        for <linux-mm@kvack.org>; Wed, 03 Oct 2012 14:10:44 -0700 (PDT)
Date: Wed, 3 Oct 2012 14:10:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm, thp: fix mlock statistics fix
In-Reply-To: <20121003131012.f88b0d66.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1210031403270.4352@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1209191818490.7879@chino.kir.corp.google.com> <alpine.LSU.2.00.1209192021270.28543@eggly.anvils> <alpine.DEB.2.00.1209261821380.7745@chino.kir.corp.google.com> <alpine.DEB.2.00.1209261929270.8567@chino.kir.corp.google.com>
 <alpine.LSU.2.00.1209271814340.2107@eggly.anvils> <20121003131012.f88b0d66.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 3 Oct 2012, Andrew Morton wrote:

> The free_page_mlock() hunk gets dropped because free_page_mlock() is
> removed.  And clear_page_mlock() doesn't need this treatment.  But
> please check my handiwork.
> 

I reviewed what was merged into -mm and clear_page_mlock() does need this 
fix as well.  It's an easy fix, there's no need to pass "anon" into 
clear_page_mlock() since PageHuge() is already checked in its only caller.


mm, thp: fix mlock statistics fix

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/mlock.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -56,7 +56,8 @@ void clear_page_mlock(struct page *page)
 	if (!TestClearPageMlocked(page))
 		return;
 
-	dec_zone_page_state(page, NR_MLOCK);
+	mod_zone_page_state(page_zone(page), NR_MLOCK,
+			    -hpage_nr_pages(page));
 	count_vm_event(UNEVICTABLE_PGCLEARED);
 	if (!isolate_lru_page(page)) {
 		putback_lru_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
