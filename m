Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0E16B006E
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 10:51:49 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id bz8so5494491wib.16
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 07:51:48 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id u49si14846482eep.211.2013.12.10.07.51.48
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 07:51:48 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 16/18] mm: numa: Do not automatically migrate KSM pages
Date: Tue, 10 Dec 2013 15:51:34 +0000
Message-Id: <1386690695-27380-17-git-send-email-mgorman@suse.de>
In-Reply-To: <1386690695-27380-1-git-send-email-mgorman@suse.de>
References: <1386690695-27380-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

KSM pages can be shared between tasks that are not necessarily related
to each other from a NUMA perspective. This patch causes those pages to
be ignored by automatic NUMA balancing so they do not migrate and do not
cause unrelated tasks to be grouped together.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/mprotect.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 9b1be30..c258137 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -23,6 +23,7 @@
 #include <linux/mmu_notifier.h>
 #include <linux/migrate.h>
 #include <linux/perf_event.h>
+#include <linux/ksm.h>
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
@@ -63,7 +64,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 
 				ptent = *pte;
 				page = vm_normal_page(vma, addr, oldpte);
-				if (page) {
+				if (page && !PageKsm(page)) {
 					if (!pte_numa(oldpte)) {
 						ptent = pte_mknuma(ptent);
 						updated = true;
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
