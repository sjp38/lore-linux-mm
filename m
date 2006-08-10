Date: Wed, 9 Aug 2006 19:38:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-ID: <Pine.LNX.4.64.0608091934180.5464@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I see some strange vmalloc_node constructs in the netfilter code. Looks as 
if they were trying to bypass memory policies with vmalloc_node().
That works but they have not considered that cpusets can also
influence the allocation. With GFP_THISNODE we can give them now
what they wanted: A node local allocation regardless of what settings
the currently executing process has.

However, vmalloc() currently does not pass a gfp flag. Define a macro
that uses __vmalloc() to pass GFP_THISNODE.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc3-mm2/net/ipv4/netfilter/arp_tables.c
===================================================================
--- linux-2.6.18-rc3-mm2.orig/net/ipv4/netfilter/arp_tables.c	2006-07-29 23:15:36.000000000 -0700
+++ linux-2.6.18-rc3-mm2/net/ipv4/netfilter/arp_tables.c	2006-08-09 19:26:37.776299432 -0700
@@ -723,7 +723,7 @@ static int copy_entries_to_user(unsigned
 	 * about).
 	 */
 	countersize = sizeof(struct xt_counters) * private->number;
-	counters = vmalloc_node(countersize, numa_node_id());
+	counters = vmalloc_flags(countersize, GFP_THISNODE);
 
 	if (counters == NULL)
 		return -ENOMEM;
Index: linux-2.6.18-rc3-mm2/net/ipv4/netfilter/ip_tables.c
===================================================================
--- linux-2.6.18-rc3-mm2.orig/net/ipv4/netfilter/ip_tables.c	2006-07-29 23:15:36.000000000 -0700
+++ linux-2.6.18-rc3-mm2/net/ipv4/netfilter/ip_tables.c	2006-08-09 19:26:18.463039994 -0700
@@ -809,8 +809,7 @@ static inline struct xt_counters * alloc
 	   (other than comefrom, which userspace doesn't care
 	   about). */
 	countersize = sizeof(struct xt_counters) * private->number;
-	counters = vmalloc_node(countersize, numa_node_id());
-
+	counters = vmalloc_flags(countersize, GFP_THISNODE);
 	if (counters == NULL)
 		return ERR_PTR(-ENOMEM);
 
@@ -1365,7 +1364,7 @@ do_add_counters(void __user *user, unsig
 	if (len != size + num_counters * sizeof(struct xt_counters))
 		return -EINVAL;
 
-	paddc = vmalloc_node(len - size, numa_node_id());
+	paddc = vmalloc_flags(len - size, GFP_THISNODE);
 	if (!paddc)
 		return -ENOMEM;
 
Index: linux-2.6.18-rc3-mm2/include/linux/vmalloc.h
===================================================================
--- linux-2.6.18-rc3-mm2.orig/include/linux/vmalloc.h	2006-08-07 20:21:00.586376498 -0700
+++ linux-2.6.18-rc3-mm2/include/linux/vmalloc.h	2006-08-09 19:25:24.544497518 -0700
@@ -52,7 +52,10 @@ extern void vunmap(void *addr);
 
 extern int remap_vmalloc_range(struct vm_area_struct *vma, void *addr,
 							unsigned long pgoff);
- 
+
+#define vmalloc_flags(__s, __f) \
+	__vmalloc((__s), (__f)|__GFP_HIGHMEM|GFP_KERNEL, PAGE_KERNEL)
+
 /*
  *	Lowlevel-APIs (not for driver use!)
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
