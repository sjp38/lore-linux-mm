Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0800B5F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 11:10:09 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <20090407509.382219156@firstfloor.org>
In-Reply-To: <20090407509.382219156@firstfloor.org>
Subject: [PATCH] [8/16] POISON: Add various poison checks in mm/memory.c
Message-Id: <20090407151005.4E24B1D046D@basil.firstfloor.org>
Date: Tue,  7 Apr 2009 17:10:05 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>


Bail out early when poisoned pages are found in page fault handling.
Since they are poisoned they should not be mapped freshly
into processes.

This is generally handled in the same way as OOM, just a different
error code is returned to the architecture code.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/memory.c |    7 +++++++
 1 file changed, 7 insertions(+)

Index: linux/mm/memory.c
===================================================================
--- linux.orig/mm/memory.c	2009-04-07 16:39:39.000000000 +0200
+++ linux/mm/memory.c	2009-04-07 16:39:39.000000000 +0200
@@ -2560,6 +2560,10 @@
 		goto oom;
 	__SetPageUptodate(page);
 
+	/* Kludge for now until we take poisoned pages out of the free lists */
+	if (unlikely(PagePoison(page)))
+		return VM_FAULT_POISON;
+
 	if (mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))
 		goto oom_free_page;
 
@@ -2625,6 +2629,9 @@
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
 		return ret;
 
+	if (unlikely(PagePoison(vmf.page)))
+		return VM_FAULT_POISON;
+
 	/*
 	 * For consistency in subsequent calls, make the faulted page always
 	 * locked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
