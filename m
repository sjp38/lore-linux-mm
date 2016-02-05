Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 02A7E4403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 22:40:57 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id ho8so26628065pac.2
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 19:40:56 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id fk1si20890288pad.35.2016.02.04.19.40.56
        for <linux-mm@kvack.org>;
        Thu, 04 Feb 2016 19:40:56 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 2/2] radix-tree: fix oops after radix_tree_iter_retry
Date: Thu,  4 Feb 2016 22:40:48 -0500
Message-Id: <1454643648-10002-3-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1454643648-10002-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1454643648-10002-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

After calling radix_tree_iter_retry(), 'slot' will be set to NULL.
This can cause radix_tree_next_slot() to dereference the NULL pointer.
Check for a NULL pointer on entry to radix_tree_next_slot().

Reported-by: Konstantin Khlebnikov <koct9i@gmail.com>
Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 include/linux/radix-tree.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 3e488e2..9aa3afe 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -447,6 +447,9 @@ radix_tree_chunk_size(struct radix_tree_iter *iter)
 static __always_inline void **
 radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
 {
+	if (!slot)
+		return NULL;
+
 	if (flags & RADIX_TREE_ITER_TAGGED) {
 		iter->tags >>= 1;
 		if (likely(iter->tags & 1ul)) {
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
