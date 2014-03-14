Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1BDF26B0035
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 02:37:29 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so2131415pdi.16
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 23:37:28 -0700 (PDT)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id my2si3015002pab.281.2014.03.13.23.37.26
        for <linux-mm@kvack.org>;
        Thu, 13 Mar 2014 23:37:27 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 1/6] mm: clean up PAGE_MAPPING_FLAGS
Date: Fri, 14 Mar 2014 15:37:45 +0900
Message-Id: <1394779070-8545-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1394779070-8545-1-git-send-email-minchan@kernel.org>
References: <1394779070-8545-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.org>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

It's preparation to squeeze a new flag PAGE_MAPPING_LZFREE so
functions to get a anon_vma from mapping shouldn't assume that
+/- PAGE_MAPPING_ANON is enough.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/rmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index d9d42316a99a..76069afa6b81 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -412,7 +412,7 @@ struct anon_vma *page_get_anon_vma(struct page *page)
 	if (!page_mapped(page))
 		goto out;
 
-	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
+	anon_vma = page_rmapping(page);
 	if (!atomic_inc_not_zero(&anon_vma->refcount)) {
 		anon_vma = NULL;
 		goto out;
@@ -455,7 +455,7 @@ struct anon_vma *page_lock_anon_vma_read(struct page *page)
 	if (!page_mapped(page))
 		goto out;
 
-	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
+	anon_vma = page_rmapping(page);
 	root_anon_vma = ACCESS_ONCE(anon_vma->root);
 	if (down_read_trylock(&root_anon_vma->rwsem)) {
 		/*
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
