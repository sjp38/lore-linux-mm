From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 1/3] page-flags: record page flag overlays explicitly
References: <exportbomb.1211560342@pinky>
Date: Fri, 23 May 2008 17:33:12 +0100
Message-Id: <1211560392.0@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Some page flags are used for more than one purpose, for example
PG_owner_priv_1.  Currently there are individual accessors for each user,
each built using the common flag name far away from the bit definitions.
This makes it hard to see all possible uses of these bits.

Now that we have a single enum to generate the bit orders it makes sense
to express overlays in the same place.  So create per use aliases for
this bit in the main page-flags enum and use those in the accessors.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 include/linux/page-flags.h |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 590cff3..2cc1fb1 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -96,7 +96,13 @@ enum pageflags {
 #ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
 	PG_uncached,		/* Page has been mapped as uncached */
 #endif
-	__NR_PAGEFLAGS
+	__NR_PAGEFLAGS,
+
+	/* Filesystems */
+	PG_checked = PG_owner_priv_1,
+
+	/* XEN */
+	PG_pinned = PG_owner_priv_1,
 };
 
 #ifndef __GENERATING_BOUNDS_H
@@ -155,8 +161,8 @@ PAGEFLAG(Dirty, dirty) TESTSCFLAG(Dirty, dirty) __CLEARPAGEFLAG(Dirty, dirty)
 PAGEFLAG(LRU, lru) __CLEARPAGEFLAG(LRU, lru)
 PAGEFLAG(Active, active) __CLEARPAGEFLAG(Active, active)
 __PAGEFLAG(Slab, slab)
-PAGEFLAG(Checked, owner_priv_1)		/* Used by some filesystems */
-PAGEFLAG(Pinned, owner_priv_1) TESTSCFLAG(Pinned, owner_priv_1) /* Xen */
+PAGEFLAG(Checked, checked)		/* Used by some filesystems */
+PAGEFLAG(Pinned, pinned) TESTSCFLAG(Pinned, pinned) /* Xen */
 PAGEFLAG(Reserved, reserved) __CLEARPAGEFLAG(Reserved, reserved)
 PAGEFLAG(Private, private) __CLEARPAGEFLAG(Private, private)
 	__SETPAGEFLAG(Private, private)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
