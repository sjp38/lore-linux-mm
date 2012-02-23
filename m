Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 09F0C6B004D
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 08:50:55 -0500 (EST)
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/3] NOMMU: Merge __put_nommu_region() into put_nommu_region()
Date: Thu, 23 Feb 2012 13:50:49 +0000
Message-ID: <20120223135049.24278.76524.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120223135035.24278.96099.stgit@warthog.procyon.org.uk>
References: <20120223135035.24278.96099.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, uclinux-dev@uclinux.org, gerg@uclinux.org, lethal@linux-sh.org, David Howells <dhowells@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>

Merge __put_nommu_region() into put_nommu_region() in the NOMMU mmap code as
that's the only remaining user.

Reported-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Al Viro <viro@zeniv.linux.org.uk>
---

 mm/nommu.c |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)


diff --git a/mm/nommu.c b/mm/nommu.c
index ee7e57e..d02ee35 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -615,15 +615,15 @@ static void free_page_series(unsigned long from, unsigned long to)
 
 /*
  * release a reference to a region
- * - the caller must hold the region semaphore for writing, which this releases
  * - the region may not have been added to the tree yet, in which case vm_top
  *   will equal vm_start
  */
-static void __put_nommu_region(struct vm_region *region)
-	__releases(nommu_region_sem)
+static void put_nommu_region(struct vm_region *region)
 {
 	kenter("%p{%d}", region, region->vm_usage);
 
+	down_write(&nommu_region_sem);
+
 	BUG_ON(!nommu_region_tree.rb_node);
 
 	if (--region->vm_usage == 0) {
@@ -647,15 +647,6 @@ static void __put_nommu_region(struct vm_region *region)
 }
 
 /*
- * release a reference to a region
- */
-static void put_nommu_region(struct vm_region *region)
-{
-	down_write(&nommu_region_sem);
-	__put_nommu_region(region);
-}
-
-/*
  * update protection on a vma
  */
 static void protect_vma(struct vm_area_struct *vma, unsigned long flags)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
