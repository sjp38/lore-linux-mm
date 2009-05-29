Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 777516B005A
	for <linux-mm@kvack.org>; Fri, 29 May 2009 17:35:17 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <200905291135.124267638@firstfloor.org>
In-Reply-To: <200905291135.124267638@firstfloor.org>
Subject: [PATCH] [7/16] HWPOISON: Add various poison checks in mm/memory.c
Message-Id: <20090529213532.DD6471D0293@basil.firstfloor.org>
Date: Fri, 29 May 2009 23:35:32 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
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
--- linux.orig/mm/memory.c	2009-05-29 23:32:10.000000000 +0200
+++ linux/mm/memory.c	2009-05-29 23:32:10.000000000 +0200
@@ -2659,6 +2659,9 @@
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
