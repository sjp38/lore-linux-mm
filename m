Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 5C12D6B002C
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 14:40:08 -0500 (EST)
From: Dan Smith <danms@us.ibm.com>
Subject: [PATCH] Ensure that walk_page_range()'s start and end are page-aligned
Date: Fri, 10 Feb 2012 11:39:56 -0800
Message-Id: <1328902796-30389-1-git-send-email-danms@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

The inner function walk_pte_range() increments "addr" by PAGE_SIZE after
each pte is processed, and only exits the loop if the result is equal to
"end". Current, if either (or both of) the starting or ending addresses
passed to walk_page_range() are not page-aligned, then we will never
satisfy that exit condition and begin calling the pte_entry handler with
bad data.

To be sure that we will land in the right spot, this patch checks that
both "addr" and "end" are page-aligned in walk_page_range() before starting
the traversal.

Signed-off-by: Dan Smith <danms@us.ibm.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/pagewalk.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 2f5cf10..9242bfc 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -196,6 +196,8 @@ int walk_page_range(unsigned long addr, unsigned long end,
 	if (addr >= end)
 		return err;
 
+	VM_BUG_ON((addr & ~PAGE_MASK) || (end & ~PAGE_MASK));
+
 	if (!walk->mm)
 		return -EINVAL;
 
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
