Message-ID: <444BA0A9.3080901@yahoo.com.au>
Date: Mon, 24 Apr 2006 01:43:37 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [rfc][patch] radix-tree: small data structure
Content-Type: multipart/mixed;
 boundary="------------000804080204000408010301"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Linux Kernel Mailing List <Linux-Kernel@Vger.Kernel.ORG>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------000804080204000408010301
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

With the previous patch, the radix_tree_node budget on my 64-bit
desktop is cut from 20MB to 10MB. This patch should cut it again
by nearly a factor of 4 (haven't verified, but 98ish % of files
are under 64K).

I wonder if this would be of any interest for those who enable
CONFIG_BASE_SMALL?

-- 
SUSE Labs, Novell Inc.

--------------000804080204000408010301
Content-Type: text/plain;
 name="radix-tree-tag_get-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="radix-tree-tag_get-fix.patch"

Index: rtth/radix-tree.c
===================================================================
--- rtth.orig/radix-tree.c	2006-04-22 18:40:38.000000000 +1000
+++ rtth/radix-tree.c	2006-04-23 04:46:15.000000000 +1000
@@ -458,9 +458,8 @@ EXPORT_SYMBOL(radix_tree_tag_clear);
  *
  * Return values:
  *
- *  0: tag not present
+ *  0: tag not set or not present
  *  1: tag present, set
- * -1: tag present, unset
  */
 int radix_tree_tag_get(struct radix_tree_root *root,
 			unsigned long index, unsigned int tag)
@@ -494,7 +493,7 @@ int radix_tree_tag_get(struct radix_tree
 			int ret = tag_get(slot, tag, offset);
 
 			BUG_ON(ret && saw_unset_tag);
-			return ret ? 1 : -1;
+			return ret;
 		}
 		slot = slot->slots[offset];
 		shift -= RADIX_TREE_MAP_SHIFT;

--------------000804080204000408010301--
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
