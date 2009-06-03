Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C5B786B00DE
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:47:02 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <20090603846.816684333@firstfloor.org>
In-Reply-To: <20090603846.816684333@firstfloor.org>
Subject: [PATCH] [6/16] HWPOISON: Add various poison checks in mm/memory.c
Message-Id: <20090603184639.1933B1D028F@basil.firstfloor.org>
Date: Wed,  3 Jun 2009 20:46:38 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>


Bail out early when hardware poisoned pages are found in page fault handling.
Since they are poisoned they should not be mapped freshly into processes,
because that would cause another (potentially deadly) machine check

This is generally handled in the same way as OOM, just a different
error code is returned to the architecture code.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/memory.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux/mm/memory.c
===================================================================
--- linux.orig/mm/memory.c	2009-06-03 19:36:23.000000000 +0200
+++ linux/mm/memory.c	2009-06-03 19:36:23.000000000 +0200
@@ -2797,6 +2797,9 @@
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
 		return ret;
 
+	if (unlikely(PageHWPoison(vmf.page)))
+		return VM_FAULT_HWPOISON;
+
 	/*
 	 * For consistency in subsequent calls, make the faulted page always
 	 * locked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
