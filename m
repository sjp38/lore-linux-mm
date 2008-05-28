Date: Wed, 28 May 2008 10:40:39 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Subject: Slab allocators: Remove kmem_cache_name() to fix invalid
 frees
Message-ID: <Pine.LNX.4.64.0805281032290.22637@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>, mpm@selenic.com
Cc: linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

kmem_cache_name() is used only by the networking subsystem in order to retrieve
a char * pointer that was passed to kmem_cache_create(). The name of the 
slab was created dynamically by the network subsystem and therefore there 
is a need to free the name when the slab is no longer in use.

This use creates a dependency on the internal workings of the slab 
allocator. It assumes that the slab allocator stores a pointer to the 
string passed in at kmem_cache_create and that the pointer can be 
retrieved later until the slab is destroyed.

SLUB does not follow that expectation for merged slabs. In that case the
slab name passed to kmem_cache_create() may only be used to create a 
symlink in /sys/kernel/slab. The "name" of the slab that will be returned 
on kmem_cache_name() is the name of the first kmem_cache_create() that 
caused a slab of a certain size to be created.

This can lead to double frees or the freeing of a string constant when
a slab is destroyed by the network subsystem by the following action in 
ccid_kmem_cache_destroy() (DCCP protocol) and in proto_unregister().

1. Retrieving the slab name via kmem_cache_name()
2. Destroying the slab cache by calling kmem_cache_destroy().
3. Freeing the slab name via kfree().

It seems that it is rare to trigger invalid kfrees because the slabs 
with the dynamic names are rarely created (at least on my systems) and 
then destroyed. In many cases it seems that the first name is the actual 
name of slab because of the uniqueness of the slab characteristics. I only 
found these while testing with cpu_alloc patches that influenced the 
sizes of these structures. But I am sure this can also be triggered under 
other conditions.

Fix:

Create special fields in the networking structs to store a pointer to
names of slab generated. The pointer is then used to free the name of
the slab after the slab was destroyed.

Drop the support for kmem_cache_name from all slab allocators.

Signed-off-by: Christoph Lameter <clameter@sgi.com>


---
 include/linux/slab.h        |    1 -
 include/net/request_sock.h  |    1 +
 include/net/timewait_sock.h |    1 +
 mm/slab.c                   |    6 ------
 mm/slob.c                   |    6 ------
 mm/slub.c                   |    6 ------
 net/core/sock.c             |   37 ++++++++++++++++++-------------------
 net/dccp/ccid.c             |   39 +++++++++++++++++++++++++--------------
 net/dccp/ccid.h             |    2 ++
 9 files changed, 47 insertions(+), 52 deletions(-)

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2008-05-27 22:55:22.878988551 -0700
+++ linux-2.6/include/linux/slab.h	2008-05-27 22:55:35.167739564 -0700
@@ -63,7 +63,6 @@ void kmem_cache_destroy(struct kmem_cach
 int kmem_cache_shrink(struct kmem_cache *);
 void kmem_cache_free(struct kmem_cache *, void *);
 unsigned int kmem_cache_size(struct kmem_cache *);
-const char *kmem_cache_name(struct kmem_cache *);
 int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
 
 /*
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2008-05-27 22:55:22.878988551 -0700
+++ linux-2.6/mm/slab.c	2008-05-27 22:55:35.167739564 -0700
@@ -3802,12 +3802,6 @@ unsigned int kmem_cache_size(struct kmem
 }
 EXPORT_SYMBOL(kmem_cache_size);
 
-const char *kmem_cache_name(struct kmem_cache *cachep)
-{
-	return cachep->name;
-}
-EXPORT_SYMBOL_GPL(kmem_cache_name);
-
 /*
  * This initializes kmem_list3 or resizes various caches for all nodes.
  */
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2008-05-27 22:55:22.898987823 -0700
+++ linux-2.6/mm/slob.c	2008-05-27 22:55:35.187738215 -0700
@@ -617,12 +617,6 @@ unsigned int kmem_cache_size(struct kmem
 }
 EXPORT_SYMBOL(kmem_cache_size);
 
-const char *kmem_cache_name(struct kmem_cache *c)
-{
-	return c->name;
-}
-EXPORT_SYMBOL(kmem_cache_name);
-
 int kmem_cache_shrink(struct kmem_cache *d)
 {
 	return 0;
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-05-27 22:55:22.888987704 -0700
+++ linux-2.6/mm/slub.c	2008-05-27 22:55:35.197736279 -0700
@@ -2390,12 +2390,6 @@ unsigned int kmem_cache_size(struct kmem
 }
 EXPORT_SYMBOL(kmem_cache_size);
 
-const char *kmem_cache_name(struct kmem_cache *s)
-{
-	return s->name;
-}
-EXPORT_SYMBOL(kmem_cache_name);
-
 static void list_slab_objects(struct kmem_cache *s, struct page *page,
 							const char *text)
 {
Index: linux-2.6/net/core/sock.c
===================================================================
--- linux-2.6.orig/net/core/sock.c	2008-05-27 22:55:22.928988094 -0700
+++ linux-2.6/net/core/sock.c	2008-05-27 23:25:14.124850559 -0700
@@ -2036,9 +2036,6 @@ static inline void release_proto_idx(str
 
 int proto_register(struct proto *prot, int alloc_slab)
 {
-	char *request_sock_slab_name = NULL;
-	char *timewait_sock_slab_name;
-
 	if (alloc_slab) {
 		prot->slab = kmem_cache_create(prot->name, prot->obj_size, 0,
 					       SLAB_HWCACHE_ALIGN, NULL);
@@ -2052,12 +2049,13 @@ int proto_register(struct proto *prot, i
 		if (prot->rsk_prot != NULL) {
 			static const char mask[] = "request_sock_%s";
 
-			request_sock_slab_name = kmalloc(strlen(prot->name) + sizeof(mask) - 1, GFP_KERNEL);
-			if (request_sock_slab_name == NULL)
+			prot->rsk_prot->name =
+				kmalloc(strlen(prot->name) + sizeof(mask) - 1, GFP_KERNEL);
+			if (prot->rsk_prot->name == NULL)
 				goto out_free_sock_slab;
 
-			sprintf(request_sock_slab_name, mask, prot->name);
-			prot->rsk_prot->slab = kmem_cache_create(request_sock_slab_name,
+			sprintf(prot->rsk_prot->name, mask, prot->name);
+			prot->rsk_prot->slab = kmem_cache_create(prot->rsk_prot->name,
 								 prot->rsk_prot->obj_size, 0,
 								 SLAB_HWCACHE_ALIGN, NULL);
 
@@ -2071,14 +2069,15 @@ int proto_register(struct proto *prot, i
 		if (prot->twsk_prot != NULL) {
 			static const char mask[] = "tw_sock_%s";
 
-			timewait_sock_slab_name = kmalloc(strlen(prot->name) + sizeof(mask) - 1, GFP_KERNEL);
+			prot->twsk_prot->twsk_name =
+				kmalloc(strlen(prot->name) + sizeof(mask) - 1, GFP_KERNEL);
 
-			if (timewait_sock_slab_name == NULL)
+			if (prot->twsk_prot->twsk_name == NULL)
 				goto out_free_request_sock_slab;
 
-			sprintf(timewait_sock_slab_name, mask, prot->name);
+			sprintf(prot->twsk_prot->twsk_name, mask, prot->name);
 			prot->twsk_prot->twsk_slab =
-				kmem_cache_create(timewait_sock_slab_name,
+				kmem_cache_create(prot->twsk_prot->twsk_name,
 						  prot->twsk_prot->twsk_obj_size,
 						  0, SLAB_HWCACHE_ALIGN,
 						  NULL);
@@ -2094,14 +2093,16 @@ int proto_register(struct proto *prot, i
 	return 0;
 
 out_free_timewait_sock_slab_name:
-	kfree(timewait_sock_slab_name);
+	kfree(prot->twsk_prot->twsk_name);
+	prot->twsk_prot->twsk_name = NULL;
 out_free_request_sock_slab:
 	if (prot->rsk_prot && prot->rsk_prot->slab) {
 		kmem_cache_destroy(prot->rsk_prot->slab);
 		prot->rsk_prot->slab = NULL;
 	}
 out_free_request_sock_slab_name:
-	kfree(request_sock_slab_name);
+	kfree(prot->rsk_prot->name);
+	prot->rsk_prot->name = NULL;
 out_free_sock_slab:
 	kmem_cache_destroy(prot->slab);
 	prot->slab = NULL;
@@ -2124,19 +2125,17 @@ void proto_unregister(struct proto *prot
 	}
 
 	if (prot->rsk_prot != NULL && prot->rsk_prot->slab != NULL) {
-		const char *name = kmem_cache_name(prot->rsk_prot->slab);
-
 		kmem_cache_destroy(prot->rsk_prot->slab);
-		kfree(name);
 		prot->rsk_prot->slab = NULL;
+		kfree(prot->rsk_prot->name);
+		prot->rsk_prot->name = NULL;
 	}
 
 	if (prot->twsk_prot != NULL && prot->twsk_prot->twsk_slab != NULL) {
-		const char *name = kmem_cache_name(prot->twsk_prot->twsk_slab);
-
 		kmem_cache_destroy(prot->twsk_prot->twsk_slab);
-		kfree(name);
 		prot->twsk_prot->twsk_slab = NULL;
+		kfree(prot->twsk_prot->twsk_name);
+		prot->twsk_prot->twsk_name = NULL;
 	}
 }
 
Index: linux-2.6/include/net/request_sock.h
===================================================================
--- linux-2.6.orig/include/net/request_sock.h	2008-05-27 22:55:33.516487474 -0700
+++ linux-2.6/include/net/request_sock.h	2008-05-27 22:55:36.738987441 -0700
@@ -30,6 +30,7 @@ struct request_sock_ops {
 	int		family;
 	int		obj_size;
 	struct kmem_cache	*slab;
+	char		*name;
 	int		(*rtx_syn_ack)(struct sock *sk,
 				       struct request_sock *req);
 	void		(*send_ack)(struct sk_buff *skb,
Index: linux-2.6/include/net/timewait_sock.h
===================================================================
--- linux-2.6.orig/include/net/timewait_sock.h	2008-05-27 22:55:33.516487474 -0700
+++ linux-2.6/include/net/timewait_sock.h	2008-05-27 22:55:36.738987441 -0700
@@ -17,6 +17,7 @@
 struct timewait_sock_ops {
 	struct kmem_cache	*twsk_slab;
 	unsigned int	twsk_obj_size;
+	char		*twsk_name;
 	int		(*twsk_unique)(struct sock *sk,
 				       struct sock *sktw, void *twp);
 	void		(*twsk_destructor)(struct sock *sk);
Index: linux-2.6/net/dccp/ccid.c
===================================================================
--- linux-2.6.orig/net/dccp/ccid.c	2008-05-27 23:00:39.466488223 -0700
+++ linux-2.6/net/dccp/ccid.c	2008-05-27 23:19:38.559419815 -0700
@@ -56,31 +56,32 @@ static inline void ccids_read_unlock(voi
 #define ccids_read_unlock() do { } while(0)
 #endif
 
-static struct kmem_cache *ccid_kmem_cache_create(int obj_size, const char *fmt,...)
+static struct kmem_cache *ccid_kmem_cache_create(int obj_size, char **name,
+							const char *fmt,...)
 {
 	struct kmem_cache *slab;
-	char slab_name_fmt[32], *slab_name;
+	char slab_name_fmt[32];
 	va_list args;
 
 	va_start(args, fmt);
 	vsnprintf(slab_name_fmt, sizeof(slab_name_fmt), fmt, args);
 	va_end(args);
 
-	slab_name = kstrdup(slab_name_fmt, GFP_KERNEL);
-	if (slab_name == NULL)
+	*name = kstrdup(slab_name_fmt, GFP_KERNEL);
+	if (*name == NULL)
 		return NULL;
-	slab = kmem_cache_create(slab_name, sizeof(struct ccid) + obj_size, 0,
+	slab = kmem_cache_create(*name, sizeof(struct ccid) + obj_size, 0,
 				 SLAB_HWCACHE_ALIGN, NULL);
-	if (slab == NULL)
-		kfree(slab_name);
+	if (slab == NULL) {
+		kfree(*name);
+		*name = NULL;
+	}
 	return slab;
 }
 
-static void ccid_kmem_cache_destroy(struct kmem_cache *slab)
+static void ccid_kmem_cache_destroy(struct kmem_cache *slab, char *name)
 {
 	if (slab != NULL) {
-		const char *name = kmem_cache_name(slab);
-
 		kmem_cache_destroy(slab);
 		kfree(name);
 	}
@@ -92,6 +93,7 @@ int ccid_register(struct ccid_operations
 
 	ccid_ops->ccid_hc_rx_slab =
 			ccid_kmem_cache_create(ccid_ops->ccid_hc_rx_obj_size,
+						&ccid_ops->ccid_hc_rx_name,
 					       "ccid%u_hc_rx_sock",
 					       ccid_ops->ccid_id);
 	if (ccid_ops->ccid_hc_rx_slab == NULL)
@@ -99,6 +101,7 @@ int ccid_register(struct ccid_operations
 
 	ccid_ops->ccid_hc_tx_slab =
 			ccid_kmem_cache_create(ccid_ops->ccid_hc_tx_obj_size,
+						&ccid_ops->ccid_hc_tx_name,
 					       "ccid%u_hc_tx_sock",
 					       ccid_ops->ccid_id);
 	if (ccid_ops->ccid_hc_tx_slab == NULL)
@@ -119,12 +122,16 @@ int ccid_register(struct ccid_operations
 out:
 	return err;
 out_free_tx_slab:
-	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_tx_slab);
+	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_tx_slab,
+					ccid_ops->ccid_hc_tx_name);
 	ccid_ops->ccid_hc_tx_slab = NULL;
+	ccid_ops->ccid_hc_tx_name = NULL;
 	goto out;
 out_free_rx_slab:
-	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_rx_slab);
+	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_rx_slab,
+					ccid_ops->ccid_hc_rx_name);
 	ccid_ops->ccid_hc_rx_slab = NULL;
+	ccid_ops->ccid_hc_rx_name = NULL;
 	goto out;
 }
 
@@ -136,10 +143,14 @@ int ccid_unregister(struct ccid_operatio
 	ccids[ccid_ops->ccid_id] = NULL;
 	ccids_write_unlock();
 
-	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_tx_slab);
+	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_tx_slab,
+						ccid_ops->ccid_hc_tx_name);
 	ccid_ops->ccid_hc_tx_slab = NULL;
-	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_rx_slab);
+	ccid_ops->ccid_hc_tx_name = NULL;
+	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_rx_slab,
+						ccid_ops->ccid_hc_rx_name);
 	ccid_ops->ccid_hc_rx_slab = NULL;
+	ccid_ops->ccid_hc_rx_name = NULL;
 
 	pr_info("CCID: Unregistered CCID %d (%s)\n",
 		ccid_ops->ccid_id, ccid_ops->ccid_name);
Index: linux-2.6/net/dccp/ccid.h
===================================================================
--- linux-2.6.orig/net/dccp/ccid.h	2008-05-27 23:05:18.836487436 -0700
+++ linux-2.6/net/dccp/ccid.h	2008-05-27 23:11:02.787525807 -0700
@@ -51,6 +51,8 @@ struct ccid_operations {
 	struct module		*ccid_owner;
 	struct kmem_cache	*ccid_hc_rx_slab,
 				*ccid_hc_tx_slab;
+	char			*ccid_hc_rx_name,
+				*ccid_hc_tx_name;
 	__u32			ccid_hc_rx_obj_size,
 				ccid_hc_tx_obj_size;
 	/* Interface Routines */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
