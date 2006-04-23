Message-ID: <444BA150.7040907@yahoo.com.au>
Date: Mon, 24 Apr 2006 01:46:24 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [rfc][patch] radix-tree: small data structure
References: <444BA0A9.3080901@yahoo.com.au>
In-Reply-To: <444BA0A9.3080901@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------090004090206030103030004"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Linux Kernel Mailing List <Linux-Kernel@Vger.Kernel.ORG>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090004090206030103030004
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Nick Piggin wrote:
> With the previous patch, the radix_tree_node budget on my 64-bit
> desktop is cut from 20MB to 10MB. This patch should cut it again
> by nearly a factor of 4 (haven't verified, but 98ish % of files
> are under 64K).
> 
> I wonder if this would be of any interest for those who enable
> CONFIG_BASE_SMALL?

Bah, wrong patch.

-- 
SUSE Labs, Novell Inc.

--------------090004090206030103030004
Content-Type: text/plain;
 name="radix-small.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="radix-small.patch"

This patch reduces radix tree node memory usage by about a factor of 4
on many small files (< 64K) scenarios, and results in perfect packing of
the index range into 32 and 64 bits. There are pointer traversal and
memory usage costs for large files with dense pagecache.

Index: linux-2.6/lib/radix-tree.c
===================================================================
--- linux-2.6.orig/lib/radix-tree.c
+++ linux-2.6/lib/radix-tree.c
@@ -33,7 +33,7 @@
 
 
 #ifdef __KERNEL__
-#define RADIX_TREE_MAP_SHIFT	6
+#define RADIX_TREE_MAP_SHIFT	(CONFIG_BASE_SMALL ? 4 : 6)
 #else
 #define RADIX_TREE_MAP_SHIFT	3	/* For more stressful testing */
 #endif

--------------090004090206030103030004--
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
