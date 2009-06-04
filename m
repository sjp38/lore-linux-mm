Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2BE796B0085
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 17:28:35 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <200906041128.112757038@firstfloor.org>
In-Reply-To: <200906041128.112757038@firstfloor.org>
Subject: [PATCH] [6/15] HWPOISON: Add various poison checks in mm/memory.c v2
Message-Id: <20090604212817.8E1F11D0290@basil.firstfloor.org>
Date: Thu,  4 Jun 2009 23:28:17 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>


Bail out early when hardware poisoned pages are found in page fault handling.
Since they are poisoned they should not be mapped freshly into processes,
because that would cause another (potentially deadly) machine check

This is generally handled in the same way as OOM, just a different
error code is returned to the architecture code.

v2: Do a page unlock if needed (Fengguang Wu)

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/memory.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: linux/mm/memory.c
===================================================================
--- linux.orig/mm/memory.c
+++ linux/mm/memory.c
@@ -2797,6 +2797,12 @@ static int __do_fault(struct mm_struct *
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
 		return ret;
 
+	if (unlikely(PageHWPoison(vmf.page))) {
+		if (ret & VM_FAULT_LOCKED)
+			unlock_page(vmf.page);
+		return VM_FAULT_HWPOISON;
+	}
+
 	/*
 	 * For consistency in subsequent calls, make the faulted page always
 	 * locked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
