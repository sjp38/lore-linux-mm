Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E4FB96B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 11:55:16 -0400 (EDT)
Message-Id: <4A8AEB0B0200007800010570@vpn.id2.novell.com>
Date: Tue, 18 Aug 2009 16:55:23 +0100
From: "Jan Beulich" <JBeulich@novell.com>
Subject: [PATCH] also use alloc_large_system_hash() for the PID hash
	 table
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This is being done by allowing boot time allocations to specify that
they may want a sub-page sized amount of memory.

Overall this seems more consistent with the other hash table
allocations, and allows making two supposedly mm-only variables really
mm-only (nr_{kernel,all}_pages).

Signed-off-by: Jan Beulich <jbeulich@novell.com>

---
 include/linux/bootmem.h |    5 ++---
 kernel/pid.c            |   15 ++++-----------
 mm/page_alloc.c         |   13 ++++++++++---
 3 files changed, 16 insertions(+), 17 deletions(-)

--- linux-2.6.31-rc6/include/linux/bootmem.h	2009-06-10 05:05:27.0000000=
00 +0200
+++ 2.6.31-rc6-alloc-small-hash/include/linux/bootmem.h	2009-08-17 =
15:21:17.000000000 +0200
@@ -132,9 +132,6 @@ static inline void *alloc_remap(int nid,
 }
 #endif /* CONFIG_HAVE_ARCH_ALLOC_REMAP */
=20
-extern unsigned long __meminitdata nr_kernel_pages;
-extern unsigned long __meminitdata nr_all_pages;
-
 extern void *alloc_large_system_hash(const char *tablename,
 				     unsigned long bucketsize,
 				     unsigned long numentries,
@@ -145,6 +142,8 @@ extern void *alloc_large_system_hash(con
 				     unsigned long limit);
=20
 #define HASH_EARLY	0x00000001	/* Allocating during early boot? =
*/
+#define HASH_SMALL	0x00000002	/* sub-page allocation allowed, =
min
+					 * shift passed via *_hash_shift =
*/
=20
 /* Only NUMA needs hash distribution. 64bit NUMA architectures have
  * sufficient vmalloc space.
--- linux-2.6.31-rc6/kernel/pid.c	2009-08-18 15:31:56.000000000 =
+0200
+++ 2.6.31-rc6-alloc-small-hash/kernel/pid.c	2009-08-17 15:21:17.0000000=
00 +0200
@@ -40,7 +40,7 @@
 #define pid_hashfn(nr, ns)	\
 	hash_long((unsigned long)nr + (unsigned long)ns, pidhash_shift)
 static struct hlist_head *pid_hash;
-static int pidhash_shift;
+static unsigned int pidhash_shift =3D 4;
 struct pid init_struct_pid =3D INIT_STRUCT_PID;
=20
 int pid_max =3D PID_MAX_DEFAULT;
@@ -499,19 +499,12 @@ struct pid *find_ge_pid(int nr, struct p
 void __init pidhash_init(void)
 {
 	int i, pidhash_size;
-	unsigned long megabytes =3D nr_kernel_pages >> (20 - PAGE_SHIFT);
=20
-	pidhash_shift =3D max(4, fls(megabytes * 4));
-	pidhash_shift =3D min(12, pidhash_shift);
+	pid_hash =3D alloc_large_system_hash("PID", sizeof(*pid_hash), 0, =
18,
+					   HASH_EARLY | HASH_SMALL,
+					   &pidhash_shift, NULL, 4096);
 	pidhash_size =3D 1 << pidhash_shift;
=20
-	printk("PID hash table entries: %d (order: %d, %Zd bytes)\n",
-		pidhash_size, pidhash_shift,
-		pidhash_size * sizeof(struct hlist_head));
-
-	pid_hash =3D alloc_bootmem(pidhash_size *	sizeof(*(pid_hash))=
);
-	if (!pid_hash)
-		panic("Could not alloc pidhash!\n");
 	for (i =3D 0; i < pidhash_size; i++)
 		INIT_HLIST_HEAD(&pid_hash[i]);
 }
--- linux-2.6.31-rc6/mm/page_alloc.c	2009-08-18 15:31:56.000000000 =
+0200
+++ 2.6.31-rc6-alloc-small-hash/mm/page_alloc.c	2009-08-17 15:21:17.0000000=
00 +0200
@@ -123,8 +123,8 @@ static char * const zone_names[MAX_NR_ZO
=20
 int min_free_kbytes =3D 1024;
=20
-unsigned long __meminitdata nr_kernel_pages;
-unsigned long __meminitdata nr_all_pages;
+static unsigned long __meminitdata nr_kernel_pages;
+static unsigned long __meminitdata nr_all_pages;
 static unsigned long __meminitdata dma_reserve;
=20
 #ifdef CONFIG_ARCH_POPULATES_NODE_MAP
@@ -4728,7 +4728,14 @@ void *__init alloc_large_system_hash(con
 			numentries <<=3D (PAGE_SHIFT - scale);
=20
 		/* Make sure we've got at least a 0-order allocation.. */
-		if (unlikely((numentries * bucketsize) < PAGE_SIZE))
+		if (unlikely(flags & HASH_SMALL)) {
+			/* Makes no sense without HASH_EARLY */
+			WARN_ON(!(flags & HASH_EARLY));
+			if (!(numentries >> *_hash_shift)) {
+				numentries =3D 1UL << *_hash_shift;
+				BUG_ON(!numentries);
+			}
+		} else if (unlikely((numentries * bucketsize) < PAGE_SIZE))=

 			numentries =3D PAGE_SIZE / bucketsize;
 	}
 	numentries =3D roundup_pow_of_two(numentries);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
