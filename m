From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 14 Sep 2007 16:54:57 -0400
Message-Id: <20070914205457.6536.41479.sendpatchset@localhost>
In-Reply-To: <20070914205359.6536.98017.sendpatchset@localhost>
References: <20070914205359.6536.98017.sendpatchset@localhost>
Subject: [PATCH/RFC 9/14] Reclaim Scalability: SHM_LOCKED pages are nonreclaimable
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

PATCH/RFC 09/14 Reclaim Scalability: SHM_LOCKED pages are nonreclaimable

Against:  2.6.23-rc4-mm1

While working with Nick Piggin's mlock patches, I noticed that
shmem segments locked via shmctl(SHM_LOCKED) were not being handled.
SHM_LOCKed pages work like ramdisk pages--the writeback function
just redirties the page so that it can't be reclaimed.  Deal with
these using the same approach as for ram disk pages.

Use the AS_NORECLAIM flag to mark address_space of SHM_LOCKed
shared memory regions as non-reclaimable.  Then these pages
will be culled off the normal LRU lists during vmscan.

Add new wrapper function to clear the mapping's noreclaim state
when/if shared memory segment is munlocked.

Changes depend on [CONFIG_]NORECLAIM.

TODO:  patch currently splices all zones' noreclaim lists back
onto normal LRU lists when shmem region unlocked.  Could just
putback pages from this region/file--e.g., by scanning the
address space's radix tree using find_get_pages().

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/pagemap.h |   10 ++++++++--
 mm/shmem.c              |    5 +++++
 2 files changed, 13 insertions(+), 2 deletions(-)

Index: Linux/mm/shmem.c
===================================================================
--- Linux.orig/mm/shmem.c	2007-09-14 10:22:03.000000000 -0400
+++ Linux/mm/shmem.c	2007-09-14 10:23:51.000000000 -0400
@@ -1357,10 +1357,15 @@ int shmem_lock(struct file *file, int lo
 		if (!user_shm_lock(inode->i_size, user))
 			goto out_nomem;
 		info->flags |= VM_LOCKED;
+		mapping_set_noreclaim(file->f_mapping);
 	}
 	if (!lock && (info->flags & VM_LOCKED) && user) {
 		user_shm_unlock(inode->i_size, user);
 		info->flags &= ~VM_LOCKED;
+		mapping_clear_noreclaim(file->f_mapping);
+		putback_all_noreclaim_pages();
+//TODO:  could just putback pages from this file.
+//       e.g., "munlock_file_pages()" using find_get_pages() ?
 	}
 	retval = 0;
 out_nomem:
Index: Linux/include/linux/pagemap.h
===================================================================
--- Linux.orig/include/linux/pagemap.h	2007-09-14 10:23:50.000000000 -0400
+++ Linux/include/linux/pagemap.h	2007-09-14 10:23:51.000000000 -0400
@@ -38,14 +38,20 @@ static inline void mapping_set_noreclaim
 	set_bit(AS_NORECLAIM, &mapping->flags);
 }
 
+static inline void mapping_clear_noreclaim(struct address_space *mapping)
+{
+	clear_bit(AS_NORECLAIM, &mapping->flags);
+}
+
 static inline int mapping_non_reclaimable(struct address_space *mapping)
 {
-	if (mapping && (mapping->flags & AS_NORECLAIM))
-		return 1;
+	if (mapping)
+		return test_bit(AS_NORECLAIM, &mapping->flags);
 	return 0;
 }
 #else
 static inline void mapping_set_noreclaim(struct address_space *mapping) { }
+static inline void mapping_clear_noreclaim(struct address_space *mapping) { }
 static inline int mapping_non_reclaimable(struct address_space *mapping)
 {
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
