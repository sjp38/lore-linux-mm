Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E7E316B008C
	for <linux-mm@kvack.org>; Wed, 27 May 2009 16:12:25 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <200905271012.668777061@firstfloor.org>
In-Reply-To: <200905271012.668777061@firstfloor.org>
Subject: [PATCH] [2/16] HWPOISON: Export poison flag in /proc/kpageflags
Message-Id: <20090527201227.EAEC41D0286@basil.firstfloor.org>
Date: Wed, 27 May 2009 22:12:27 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.orgfengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>


From: Fengguang Wu <fengguang.wu@intel.com>

Export the new poison flag in /proc/kpageflags. Poisoned pages are moderately
interesting even for administrators, so export them here. Also useful
for debugging.

AK: I extracted this out of a larger patch from Fengguang Wu.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 fs/proc/page.c |    4 ++++
 1 file changed, 4 insertions(+)

Index: linux/fs/proc/page.c
===================================================================
--- linux.orig/fs/proc/page.c	2009-05-27 21:13:54.000000000 +0200
+++ linux/fs/proc/page.c	2009-05-27 21:14:21.000000000 +0200
@@ -79,6 +79,7 @@
 #define KPF_WRITEBACK  8
 #define KPF_RECLAIM    9
 #define KPF_BUDDY     10
+#define KPF_HWPOISON  11
 
 #define kpf_copy_bit(flags, dstpos, srcpos) (((flags >> srcpos) & 1) << dstpos)
 
@@ -118,6 +119,9 @@
 			kpf_copy_bit(kflags, KPF_WRITEBACK, PG_writeback) |
 			kpf_copy_bit(kflags, KPF_RECLAIM, PG_reclaim) |
 			kpf_copy_bit(kflags, KPF_BUDDY, PG_buddy);
+#ifdef CONFIG_MEMORY_FAILURE
+		uflags |= kpf_copy_bit(kflags, KPF_HWPOISON, PG_hwpoison);
+#endif
 
 		if (put_user(uflags, out++)) {
 			ret = -EFAULT;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
