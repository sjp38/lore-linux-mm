Date: Tue, 14 Dec 2004 11:53:39 -0600
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: [PATCH 3/3] TCP hashes: NUMA interleaving
Message-ID: <Pine.SGI.4.61.0412141151340.22462@kzerza.americas.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

The following patch against 2.6.10-rc3 modifies the TCP ehash and TCP
bhash to enable the use of vmalloc to alleviate boottime memory allocation
imbalances on NUMA systems, utilizing flags to the alloc_large_system_hash
routine in order to centralize the enabling of this behavior.

This patch (3/3) depends on patch 1/3 in this patch series.  It
does not depend on, nor is depended upon by, patch 2/3 in the
series.

Signed-off-by: Brent Casavant <bcasavan@sgi.com>

Index: linux/net/ipv4/tcp.c
===================================================================
--- linux.orig/net/ipv4/tcp.c	2004-12-10 18:09:49.011272637 -0600
+++ linux/net/ipv4/tcp.c	2004-12-10 18:10:52.285839780 -0600
@@ -256,6 +256,7 @@
 #include <linux/smp_lock.h>
 #include <linux/fs.h>
 #include <linux/random.h>
+#include <linux/bootmem.h>
 
 #include <net/icmp.h>
 #include <net/tcp.h>
@@ -2254,7 +2255,6 @@
 void __init tcp_init(void)
 {
 	struct sk_buff *skb = NULL;
-	unsigned long goal;
 	int order, i;
 
 	if (sizeof(struct tcp_skb_cb) > sizeof(skb->cb))
@@ -2287,43 +2287,35 @@
 	 *
 	 * The methodology is similar to that of the buffer cache.
 	 */
-	if (num_physpages >= (128 * 1024))
-		goal = num_physpages >> (21 - PAGE_SHIFT);
-	else
-		goal = num_physpages >> (23 - PAGE_SHIFT);
-
-	if (thash_entries)
-		goal = (thash_entries * sizeof(struct tcp_ehash_bucket)) >> PAGE_SHIFT;
-	for (order = 0; (1UL << order) < goal; order++)
-		;
-	do {
-		tcp_ehash_size = (1UL << order) * PAGE_SIZE /
-			sizeof(struct tcp_ehash_bucket);
-		tcp_ehash_size >>= 1;
-		while (tcp_ehash_size & (tcp_ehash_size - 1))
-			tcp_ehash_size--;
-		tcp_ehash = (struct tcp_ehash_bucket *)
-			__get_free_pages(GFP_ATOMIC, order);
-	} while (!tcp_ehash && --order > 0);
-
-	if (!tcp_ehash)
-		panic("Failed to allocate TCP established hash table\n");
+	tcp_ehash = (struct tcp_ehash_bucket *)
+		alloc_large_system_hash("TCP established",
+					sizeof(struct tcp_ehash_bucket),
+					thash_entries,
+					(num_physpages >= 128 * 1024) ?
+						(25 - PAGE_SHIFT) :
+						(27 - PAGE_SHIFT),
+					HASH_HIGHMEM,
+					&tcp_ehash_size,
+					NULL,
+					0);
+	tcp_ehash_size = (1 << tcp_ehash_size) >> 1;
 	for (i = 0; i < (tcp_ehash_size << 1); i++) {
 		rwlock_init(&tcp_ehash[i].lock);
 		INIT_HLIST_HEAD(&tcp_ehash[i].chain);
 	}
 
-	do {
-		tcp_bhash_size = (1UL << order) * PAGE_SIZE /
-			sizeof(struct tcp_bind_hashbucket);
-		if ((tcp_bhash_size > (64 * 1024)) && order > 0)
-			continue;
-		tcp_bhash = (struct tcp_bind_hashbucket *)
-			__get_free_pages(GFP_ATOMIC, order);
-	} while (!tcp_bhash && --order >= 0);
-
-	if (!tcp_bhash)
-		panic("Failed to allocate TCP bind hash table\n");
+	tcp_bhash = (struct tcp_bind_hashbucket *)
+		alloc_large_system_hash("TCP bind",
+					sizeof(struct tcp_bind_hashbucket),
+					tcp_ehash_size,
+					(num_physpages >= 128 * 1024) ?
+						(25 - PAGE_SHIFT) :
+						(27 - PAGE_SHIFT),
+					HASH_HIGHMEM,
+					&tcp_bhash_size,
+					NULL,
+					64 * 1024);
+	tcp_bhash_size = 1 << tcp_bhash_size;
 	for (i = 0; i < tcp_bhash_size; i++) {
 		spin_lock_init(&tcp_bhash[i].lock);
 		INIT_HLIST_HEAD(&tcp_bhash[i].chain);
@@ -2332,6 +2324,10 @@
 	/* Try to be a bit smarter and adjust defaults depending
 	 * on available memory.
 	 */
+	for (order = 0; ((1 << order) << PAGE_SHIFT) <
+			(tcp_bhash_size * sizeof(struct tcp_bind_hashbucket));
+			order++)
+		;
 	if (order > 4) {
 		sysctl_local_port_range[0] = 32768;
 		sysctl_local_port_range[1] = 61000;

-- 
Brent Casavant                          If you had nothing to fear,
bcasavan@sgi.com                        how then could you be brave?
Silicon Graphics, Inc.                    -- Queen Dama, Source Wars
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
