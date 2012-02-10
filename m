Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 53CF06B13F0
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 14:42:25 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so3584330bkt.14
        for <linux-mm@kvack.org>; Fri, 10 Feb 2012 11:42:24 -0800 (PST)
Subject: [PATCH 1/4] shmem: simlify shmem_unlock_mapping
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 10 Feb 2012 23:42:22 +0400
Message-ID: <20120210194222.6492.97744.stgit@zurg>
In-Reply-To: <20120210193249.6492.18768.stgit@zurg>
References: <20120210193249.6492.18768.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>

find_get_pages() now can skip unlimited count of exeptional entries,
so shmem_find_get_pages_and_swap() does not required there any more.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/shmem.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 269d049..4af8e85 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -397,7 +397,6 @@ static void shmem_deswap_pagevec(struct pagevec *pvec)
 void shmem_unlock_mapping(struct address_space *mapping)
 {
 	struct pagevec pvec;
-	pgoff_t indices[PAGEVEC_SIZE];
 	pgoff_t index = 0;
 
 	pagevec_init(&pvec, 0);
@@ -405,16 +404,9 @@ void shmem_unlock_mapping(struct address_space *mapping)
 	 * Minor point, but we might as well stop if someone else SHM_LOCKs it.
 	 */
 	while (!mapping_unevictable(mapping)) {
-		/*
-		 * Avoid pagevec_lookup(): find_get_pages() returns 0 as if it
-		 * has finished, if it hits a row of PAGEVEC_SIZE swap entries.
-		 */
-		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
-					PAGEVEC_SIZE, pvec.pages, indices);
-		if (!pvec.nr)
+		if (!pagevec_lookup(&pvec, mapping, index, PAGEVEC_SIZE))
 			break;
-		index = indices[pvec.nr - 1] + 1;
-		shmem_deswap_pagevec(&pvec);
+		index = pvec.pages[pvec.nr - 1]->index + 1;
 		check_move_unevictable_pages(pvec.pages, pvec.nr);
 		pagevec_release(&pvec);
 		cond_resched();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
