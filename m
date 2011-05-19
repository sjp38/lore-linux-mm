Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2093F6B0011
	for <linux-mm@kvack.org>; Thu, 19 May 2011 15:52:20 -0400 (EDT)
From: james_p_freyensee@linux.intel.com
Subject: [PATCH] kernel buffer overflow kmalloc_slab() fix
Date: Thu, 19 May 2011 12:51:52 -0700
Message-Id: <1305834712-27805-2-git-send-email-james_p_freyensee@linux.intel.com>
In-Reply-To: <james_p_freyensee@linux.intel.com>
References: <james_p_freyensee@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: gregkh@suse.de, hari.k.kanigeri@intel.com, james_p_freyensee@linux.intel.com

From: J Freyensee <james_p_freyensee@linux.intel.com>

Currently, kmalloc_index() can return -1, which can be
passed right to the kmalloc_caches[] array, cause a
buffer overflow, and security bug issue (not sure how
likely this can happen, but this case does exist in the code).
This adds a check for -1 and completely prevents this from happening.

Signed-off-by: J Freyensee <james_p_freyensee@linux.intel.com>
---
 include/linux/slub_def.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 45ca123..558fa99 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -211,7 +211,7 @@ static __always_inline struct kmem_cache *kmalloc_slab(size_t size)
 {
 	int index = kmalloc_index(size);
 
-	if (index == 0)
+	if ((index == 0) || (index == -1))
 		return NULL;
 
 	return kmalloc_caches[index];
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
