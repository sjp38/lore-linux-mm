Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF248E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 10:15:04 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id p14-v6so19647305oip.0
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 07:15:04 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c69-v6si15900901oib.38.2018.09.24.07.15.02
        for <linux-mm@kvack.org>;
        Mon, 24 Sep 2018 07:15:03 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: [PATCH] mm/migrate: Split only transparent huge pages when allocation fails
Date: Mon, 24 Sep 2018 19:44:55 +0530
Message-Id: <1537798495-4996-1-git-send-email-anshuman.khandual@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@kernel.org, akpm@linux-foundation.org

When unmap_and_move[_huge_page] function fails due to lack of memory, the
splitting should happen only for transparent huge pages not for HugeTLB
pages. PageTransHuge() returns true for both THP and HugeTLB pages. Hence
the conditonal check should test PagesHuge() flag to make sure that given
pages is not a HugeTLB one.

Fixes: 94723aafb9 ("mm: unclutter THP migration")
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 mm/migrate.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index d6a2e89..d2297fe 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1411,7 +1411,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 				 * we encounter them after the rest of the list
 				 * is processed.
 				 */
-				if (PageTransHuge(page)) {
+				if (PageTransHuge(page) && !PageHuge(page)) {
 					lock_page(page);
 					rc = split_huge_page_to_list(page, from);
 					unlock_page(page);
-- 
2.7.4
