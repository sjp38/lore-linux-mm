Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 4F6FF6B0044
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 22:30:01 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so3155933pbb.14
        for <linux-mm@kvack.org>; Wed, 26 Sep 2012 19:30:00 -0700 (PDT)
Date: Wed, 26 Sep 2012 19:29:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, thp: fix mlock statistics
In-Reply-To: <alpine.DEB.2.00.1209261821380.7745@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1209261929270.8567@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1209191818490.7879@chino.kir.corp.google.com> <alpine.LSU.2.00.1209192021270.28543@eggly.anvils> <alpine.DEB.2.00.1209261821380.7745@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

NR_MLOCK is only accounted in single page units: there's no logic to
handle transparent hugepages.  This patch checks the appropriate number
of pages to adjust the statistics by so that the correct amount of memory
is reflected.

Currently:

		$ grep Mlocked /proc/meminfo
		Mlocked:           19636 kB

	#define MAP_SIZE	(4 << 30)	/* 4GB */

	void *ptr = mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE,
			 MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);
	mlock(ptr, MAP_SIZE);

		$ grep Mlocked /proc/meminfo
		Mlocked:           29844 kB

	munlock(ptr, MAP_SIZE);

		$ grep Mlocked /proc/meminfo
		Mlocked:           19636 kB

And with this patch:

		$ grep Mlock /proc/meminfo
		Mlocked:           19636 kB

	mlock(ptr, MAP_SIZE);

		$ grep Mlock /proc/meminfo
		Mlocked:         4213664 kB

	munlock(ptr, MAP_SIZE);

		$ grep Mlock /proc/meminfo
		Mlocked:           19636 kB

Reported-by: Hugh Dickens <hughd@google.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/internal.h   |    3 ++-
 mm/mlock.c      |    6 ++++--
 mm/page_alloc.c |    2 +-
 3 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -180,7 +180,8 @@ static inline int mlocked_vma_newpage(struct vm_area_struct *vma,
 		return 0;
 
 	if (!TestSetPageMlocked(page)) {
-		inc_zone_page_state(page, NR_MLOCK);
+		mod_zone_page_state(page_zone(page), NR_MLOCK,
+				    hpage_nr_pages(page));
 		count_vm_event(UNEVICTABLE_PGMLOCKED);
 	}
 	return 1;
diff --git a/mm/mlock.c b/mm/mlock.c
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -81,7 +81,8 @@ void mlock_vma_page(struct page *page)
 	BUG_ON(!PageLocked(page));
 
 	if (!TestSetPageMlocked(page)) {
-		inc_zone_page_state(page, NR_MLOCK);
+		mod_zone_page_state(page_zone(page), NR_MLOCK,
+				    hpage_nr_pages(page));
 		count_vm_event(UNEVICTABLE_PGMLOCKED);
 		if (!isolate_lru_page(page))
 			putback_lru_page(page);
@@ -108,7 +109,8 @@ void munlock_vma_page(struct page *page)
 	BUG_ON(!PageLocked(page));
 
 	if (TestClearPageMlocked(page)) {
-		dec_zone_page_state(page, NR_MLOCK);
+		mod_zone_page_state(page_zone(page), NR_MLOCK,
+				    -hpage_nr_pages(page));
 		if (!isolate_lru_page(page)) {
 			int ret = SWAP_AGAIN;
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -604,7 +604,7 @@ out:
  */
 static inline void free_page_mlock(struct page *page)
 {
-	__dec_zone_page_state(page, NR_MLOCK);
+	__mod_zone_page_state(page_zone(page), NR_MLOCK, -hpage_nr_pages(page));
 	__count_vm_event(UNEVICTABLE_MLOCKFREED);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
