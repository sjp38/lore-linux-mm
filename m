Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8860A6B004A
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 19:12:38 -0400 (EDT)
Date: Tue, 14 Sep 2010 16:12:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] use total_highpages when calculating lowmem-only
 allocation sizes
Message-Id: <20100914161205.47f4fcb3.akpm@linux-foundation.org>
In-Reply-To: <4C7FB4A40200007800013F30@vpn.id2.novell.com>
References: <4C7FB4A40200007800013F30@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jan Beulich <JBeulich@novell.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 02 Sep 2010 13:28:52 +0100
"Jan Beulich" <JBeulich@novell.com> wrote:

> For those (large) table allocations that come only from lowmem, the
> total amount of memory shouldn't really matter.
> 
> vfs_caches_init() should really also be called with a lowmem-only
> value, but since it does arithmetic involving nr_free_pages() and there
> is no nr_free_high_pages(), it's not clear how to make this work.
> 

We normally use the hopelessly-badly-named nr_free_buffer_pages() for this.
Renaming that to nr_lowmem_pages() would advance the state of humanity.

Yes, the sites you've identified do look wrong.  And they're almost all in
networking, so let's add the cc for that.  Probably this should be done
in four or fives patches.


For reference purposes:

 init/main.c                       |    3 ++-
 net/dccp/proto.c                  |    8 +++++---
 net/decnet/dn_route.c             |    3 ++-
 net/netfilter/nf_conntrack_core.c |    7 +++++--
 net/netlink/af_netlink.c          |    8 +++++---
 net/sctp/protocol.c               |    6 +++---
 6 files changed, 22 insertions(+), 13 deletions(-)

--- linux-2.6.36-rc3/init/main.c
+++ 2.6.36-rc3-use-totalhigh_pages/init/main.c
@@ -23,6 +23,7 @@
 #include <linux/smp_lock.h>
 #include <linux/initrd.h>
 #include <linux/bootmem.h>
+#include <linux/highmem.h>
 #include <linux/acpi.h>
 #include <linux/tty.h>
 #include <linux/percpu.h>
@@ -676,7 +677,7 @@ asmlinkage void __init start_kernel(void
 #endif
 	thread_info_cache_init();
 	cred_init();
-	fork_init(totalram_pages);
+	fork_init(totalram_pages - totalhigh_pages);
 	proc_caches_init();
 	buffer_init();
 	key_init();
--- linux-2.6.36-rc3/net/dccp/proto.c
+++ 2.6.36-rc3-use-totalhigh_pages/net/dccp/proto.c
@@ -14,6 +14,7 @@
 #include <linux/types.h>
 #include <linux/sched.h>
 #include <linux/kernel.h>
+#include <linux/highmem.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/in.h>
@@ -1049,10 +1050,11 @@ static int __init dccp_init(void)
 	 *
 	 * The methodology is similar to that of the buffer cache.
 	 */
-	if (totalram_pages >= (128 * 1024))
-		goal = totalram_pages >> (21 - PAGE_SHIFT);
+	goal = totalram_pages - totalhigh_pages;
+	if (goal >= (128 * 1024))
+		goal >>= 21 - PAGE_SHIFT;
 	else
-		goal = totalram_pages >> (23 - PAGE_SHIFT);
+		goal >>= 23 - PAGE_SHIFT;
 
 	if (thash_entries)
 		goal = (thash_entries *
--- linux-2.6.36-rc3/net/decnet/dn_route.c
+++ 2.6.36-rc3-use-totalhigh_pages/net/decnet/dn_route.c
@@ -69,6 +69,7 @@
 #include <linux/slab.h>
 #include <net/sock.h>
 #include <linux/mm.h>
+#include <linux/highmem.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/init.h>
@@ -1762,7 +1763,7 @@ void __init dn_route_init(void)
 	dn_route_timer.expires = jiffies + decnet_dst_gc_interval * HZ;
 	add_timer(&dn_route_timer);
 
-	goal = totalram_pages >> (26 - PAGE_SHIFT);
+	goal = (totalram_pages - totalhigh_pages) >> (26 - PAGE_SHIFT);
 
 	for(order = 0; (1UL << order) < goal; order++)
 		/* NOTHING */;
--- linux-2.6.36-rc3/net/netfilter/nf_conntrack_core.c
+++ 2.6.36-rc3-use-totalhigh_pages/net/netfilter/nf_conntrack_core.c
@@ -17,6 +17,7 @@
 #include <linux/sched.h>
 #include <linux/skbuff.h>
 #include <linux/proc_fs.h>
+#include <linux/highmem.h>
 #include <linux/vmalloc.h>
 #include <linux/stddef.h>
 #include <linux/slab.h>
@@ -1346,10 +1347,12 @@ static int nf_conntrack_init_init_net(vo
 	/* Idea from tcp.c: use 1/16384 of memory.  On i386: 32MB
 	 * machine has 512 buckets. >= 1GB machines have 16384 buckets. */
 	if (!nf_conntrack_htable_size) {
+		unsigned long nr_pages = totalram_pages - totalhigh_pages;
+
 		nf_conntrack_htable_size
-			= (((totalram_pages << PAGE_SHIFT) / 16384)
+			= (((nr_pages << PAGE_SHIFT) / 16384)
 			   / sizeof(struct hlist_head));
-		if (totalram_pages > (1024 * 1024 * 1024 / PAGE_SIZE))
+		if (nr_pages > (1024 * 1024 * 1024 / PAGE_SIZE))
 			nf_conntrack_htable_size = 16384;
 		if (nf_conntrack_htable_size < 32)
 			nf_conntrack_htable_size = 32;
--- linux-2.6.36-rc3/net/netlink/af_netlink.c
+++ 2.6.36-rc3-use-totalhigh_pages/net/netlink/af_netlink.c
@@ -30,6 +30,7 @@
 #include <linux/sched.h>
 #include <linux/errno.h>
 #include <linux/string.h>
+#include <linux/highmem.h>
 #include <linux/stat.h>
 #include <linux/socket.h>
 #include <linux/un.h>
@@ -2124,10 +2125,11 @@ static int __init netlink_proto_init(voi
 	if (!nl_table)
 		goto panic;
 
-	if (totalram_pages >= (128 * 1024))
-		limit = totalram_pages >> (21 - PAGE_SHIFT);
+	limit = totalram_pages - totalhigh_pages;
+	if (limit >= (128 * 1024))
+		limit >>= 21 - PAGE_SHIFT;
 	else
-		limit = totalram_pages >> (23 - PAGE_SHIFT);
+		limit >>= 23 - PAGE_SHIFT;
 
 	order = get_bitmask_order(limit) - 1 + PAGE_SHIFT;
 	limit = (1UL << order) / sizeof(struct hlist_head);
--- linux-2.6.36-rc3/net/sctp/protocol.c
+++ 2.6.36-rc3-use-totalhigh_pages/net/sctp/protocol.c
@@ -1189,10 +1189,10 @@ SCTP_STATIC __init int sctp_init(void)
 	/* Size and allocate the association hash table.
 	 * The methodology is similar to that of the tcp hash tables.
 	 */
-	if (totalram_pages >= (128 * 1024))
-		goal = totalram_pages >> (22 - PAGE_SHIFT);
+	if (nr_pages >= (128 * 1024))
+		goal = nr_pages >> (22 - PAGE_SHIFT);
 	else
-		goal = totalram_pages >> (24 - PAGE_SHIFT);
+		goal = nr_pages >> (24 - PAGE_SHIFT);
 
 	for (order = 0; (1UL << order) < goal; order++)
 		;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
