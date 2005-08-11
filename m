From: Daniel Phillips <phillips@istop.com>
Subject: [RFC] Net vm deadlock fix, version 6
Date: Fri, 12 Aug 2005 08:31:57 +1000
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <200508120831.57884.phillips@istop.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

This version corrects a couple of bugs previously noted and ties up some loose
ends in the e1000 driver.  Some versions of this driver support packet
splitting into multiple pages, with just the protocol header in the skb
itself.  This is a very good thing because it avoids the high order page
fragmentation problem.  Though this is something that probably needs to be
pushed down into generic skb allocation, for now the driver handles it
explicitly with the help of a new memalloc_page function that just gets a page
from the memalloc reserve if normal allocation fails.  This does not need
separate reserve accounting because such pages are allocated per-skb.

While I was in there, I could not resist cleaning up some non-orthogonality in
the 64K overlap handling (e1000 people, please check my work).  The result is
that with the new memalloc handling, the source stayed the same size.  Code
size is another question.  I have added a number of new inlines.  I suspect
that inlining the skb allocation functions in general doesn't buy anything, 
but this needs to be checked.  Anyway, we now have a pretty good picture of 
the full per-driver damage of closing this hole, and it is not much.

I still haven't looked at the various hooks in the packet delivery path, but 
it's coming up pretty soon.  There are other wrinkles too, like the fact that 
there can actually be many block devices mapped over the same network 
interface.  I have to ponder what is best to do so they can't wedge each
other, and so that the SOCK_MEMALLOC bit doesn't get cleared prematurely.

Anyway, progress marches on.

diff -up --recursive 2.6.12.3.clean/drivers/net/e1000/e1000_main.c 2.6.12.3/drivers/net/e1000/e1000_main.c
--- 2.6.12.3.clean/drivers/net/e1000/e1000_main.c	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/drivers/net/e1000/e1000_main.c	2005-08-11 17:42:12.000000000 -0400
@@ -309,6 +309,16 @@ e1000_up(struct e1000_adapter *adapter)
 			e1000_phy_reset(&adapter->hw);
 	}
 
+	netdev->memalloc_pages = estimate_skb_pages(netdev->rx_reserve,
+		adapter->rx_buffer_len + NET_IP_ALIGN);
+	if (adapter->rx_ps)
+		netdev->memalloc_pages += PS_PAGE_BUFFERS * netdev->rx_reserve;
+	if ((err = adjust_memalloc_reserve(netdev->memalloc_pages))) {
+		DPRINTK(PROBE, ERR,
+		    "Unable to allocate rx reserve Error: %d\n", err);
+		return err;
+	}
+
 	e1000_set_multi(netdev);
 
 	e1000_restore_vlan(adapter);
@@ -386,6 +396,7 @@ e1000_down(struct e1000_adapter *adapter
 		mii_reg |= MII_CR_POWER_DOWN;
 		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, mii_reg);
 		mdelay(1);
+	adjust_memalloc_reserve(-netdev->memalloc_pages);
 	}
 }
 
@@ -3116,34 +3127,29 @@ e1000_alloc_rx_buffers(struct e1000_adap
 	buffer_info = &rx_ring->buffer_info[i];
 
 	while(!buffer_info->skb) {
-		skb = dev_alloc_skb(bufsz);
+		skb = dev_memalloc_skb(netdev, bufsz);
 
-		if(unlikely(!skb)) {
+		if(unlikely(!skb))
 			/* Better luck next round */
 			break;
-		}
 
 		/* Fix for errata 23, can't cross 64kB boundary */
 		if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
 			struct sk_buff *oldskb = skb;
 			DPRINTK(RX_ERR, ERR, "skb align check failed: %u bytes "
 					     "at %p\n", bufsz, skb->data);
-			/* Try again, without freeing the previous */
-			skb = dev_alloc_skb(bufsz);
+			/* Try again, then free previous */
+			skb = dev_memalloc_skb(netdev, bufsz);
+			dev_memfree_skb(oldskb);
+
 			/* Failed allocation, critical failure */
-			if (!skb) {
-				dev_kfree_skb(oldskb);
+			if (!skb)
 				break;
-			}
 
+			/* give up */
 			if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
-				/* give up */
-				dev_kfree_skb(skb);
-				dev_kfree_skb(oldskb);
+				dev_memfree_skb(skb);
 				break; /* while !buffer_info->skb */
-			} else {
-				/* Use new allocation */
-				dev_kfree_skb(oldskb);
 			}
 		}
 		/* Make buffer alignment 2 beyond a 16 byte boundary
@@ -3152,8 +3158,6 @@ e1000_alloc_rx_buffers(struct e1000_adap
 		 */
 		skb_reserve(skb, NET_IP_ALIGN);
 
-		skb->dev = netdev;
-
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_buffer_len;
 		buffer_info->dma = pci_map_single(pdev,
@@ -3169,8 +3173,8 @@ e1000_alloc_rx_buffers(struct e1000_adap
 				"dma align check failed: %u bytes at %p\n",
 				adapter->rx_buffer_len,
 				(void *)(unsigned long)buffer_info->dma);
-			dev_kfree_skb(skb);
 			buffer_info->skb = NULL;
+			dev_memfree_skb(skb);
 
 			pci_unmap_single(pdev, buffer_info->dma,
 					 adapter->rx_buffer_len,
@@ -3225,8 +3229,7 @@ e1000_alloc_rx_buffers_ps(struct e1000_a
 
 		for(j = 0; j < PS_PAGE_BUFFERS; j++) {
 			if(unlikely(!ps_page->ps_page[j])) {
-				ps_page->ps_page[j] =
-					alloc_page(GFP_ATOMIC);
+				ps_page->ps_page[j] = memalloc_page();
 				if(unlikely(!ps_page->ps_page[j]))
 					goto no_buffers;
 				ps_page_dma->ps_page_dma[j] =
@@ -3242,7 +3245,7 @@ e1000_alloc_rx_buffers_ps(struct e1000_a
 				cpu_to_le64(ps_page_dma->ps_page_dma[j]);
 		}
 
-		skb = dev_alloc_skb(adapter->rx_ps_bsize0 + NET_IP_ALIGN);
+		skb = dev_memalloc_skb(netdev, adapter->rx_ps_bsize0 + NET_IP_ALIGN);
 
 		if(unlikely(!skb))
 			break;
@@ -3253,8 +3256,6 @@ e1000_alloc_rx_buffers_ps(struct e1000_a
 		 */
 		skb_reserve(skb, NET_IP_ALIGN);
 
-		skb->dev = netdev;
-
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_ps_bsize0;
 		buffer_info->dma = pci_map_single(pdev, skb->data,
diff -up --recursive 2.6.12.3.clean/include/linux/gfp.h 2.6.12.3/include/linux/gfp.h
--- 2.6.12.3.clean/include/linux/gfp.h	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/include/linux/gfp.h	2005-08-05 21:53:09.000000000 -0400
@@ -39,6 +39,7 @@ struct vm_area_struct;
 #define __GFP_COMP	0x4000u	/* Add compound page metadata */
 #define __GFP_ZERO	0x8000u	/* Return zeroed page on success */
 #define __GFP_NOMEMALLOC 0x10000u /* Don't use emergency reserves */
+#define __GFP_MEMALLOC  0x20000u /* Use emergency reserves */
 
 #define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((1 << __GFP_BITS_SHIFT) - 1)
diff -up --recursive 2.6.12.3.clean/include/linux/mmzone.h 2.6.12.3/include/linux/mmzone.h
--- 2.6.12.3.clean/include/linux/mmzone.h	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/include/linux/mmzone.h	2005-08-08 04:32:21.000000000 -0400
@@ -378,6 +378,7 @@ int min_free_kbytes_sysctl_handler(struc
 extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
 int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int, struct file *,
 					void __user *, size_t *, loff_t *);
+int adjust_memalloc_reserve(int bytes);
 
 #include <linux/topology.h>
 /* Returns the number of the current Node. */
diff -up --recursive 2.6.12.3.clean/include/linux/netdevice.h 2.6.12.3/include/linux/netdevice.h
--- 2.6.12.3.clean/include/linux/netdevice.h	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/include/linux/netdevice.h	2005-08-11 17:40:41.000000000 -0400
@@ -371,6 +371,9 @@ struct net_device
 	struct Qdisc		*qdisc_ingress;
 	struct list_head	qdisc_list;
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
+	int			rx_reserve;
+	atomic_t		rx_reserve_used;
+	int			memalloc_pages;
 
 	/* ingress path synchronizer */
 	spinlock_t		ingress_lock;
@@ -662,6 +665,60 @@ static inline void dev_kfree_skb_any(str
 		dev_kfree_skb(skb);
 }
 
+/*
+ * Support for critical network IO under low memory conditions
+ */
+static inline int dev_reserve_used(struct net_device *dev)
+{
+	return atomic_read(&dev->rx_reserve_used);
+}
+
+static inline struct sk_buff *__dev_memalloc_skb(struct net_device *dev,
+	unsigned length, int gfp_mask)
+{
+	struct sk_buff *skb = __dev_alloc_skb(length, gfp_mask);
+	if (skb)
+		goto done;
+	if (dev_reserve_used(dev) >= dev->rx_reserve)
+		return NULL;
+	if (!(skb = __dev_alloc_skb(length, gfp_mask|__GFP_MEMALLOC)))
+		return NULL;
+	atomic_inc(&dev->rx_reserve_used);
+done:
+	skb->dev = dev;
+	return skb;
+}
+
+static inline struct sk_buff *dev_memalloc_skb(struct net_device *dev,
+	unsigned length)
+{
+	return __dev_memalloc_skb(dev, length, GFP_ATOMIC);
+}
+
+/*
+ * This is a stopgap to be used only until reserve accounting is changed to
+ * from page to skb granularity.  It depends on no more than a fixed maximum
+ * number of pages being allocated each time an skb is allocated.
+ */
+static inline struct page *memalloc_page(void)
+{
+	struct page *page = alloc_page(GFP_ATOMIC);
+	return page ? : alloc_page(GFP_ATOMIC|__GFP_MEMALLOC);
+}
+
+static inline void dev_unreserve_skb(struct net_device *dev)
+{
+	if (atomic_dec_return(&dev->rx_reserve_used) < 0)
+		atomic_inc(&dev->rx_reserve_used);
+}
+
+static inline void dev_memfree_skb(struct sk_buff *skb)
+{
+	struct net_device *dev = skb->dev;
+	__kfree_skb(skb);
+	dev_unreserve_skb(dev);
+}
+
 #define HAVE_NETIF_RX 1
 extern int		netif_rx(struct sk_buff *skb);
 extern int		netif_rx_ni(struct sk_buff *skb);
diff -up --recursive 2.6.12.3.clean/include/linux/skbuff.h 2.6.12.3/include/linux/skbuff.h
--- 2.6.12.3.clean/include/linux/skbuff.h	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/include/linux/skbuff.h	2005-08-08 04:25:31.000000000 -0400
@@ -994,6 +994,8 @@ static inline struct sk_buff *__dev_allo
 extern struct sk_buff *__dev_alloc_skb(unsigned int length, int gfp_mask);
 #endif
 
+unsigned estimate_skb_pages(unsigned howmany, unsigned size);
+
 /**
  *	dev_alloc_skb - allocate an skbuff for sending
  *	@length: length to allocate
diff -up --recursive 2.6.12.3.clean/include/linux/slab.h 2.6.12.3/include/linux/slab.h
--- 2.6.12.3.clean/include/linux/slab.h	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/include/linux/slab.h	2005-08-08 05:02:07.000000000 -0400
@@ -65,6 +65,7 @@ extern void *kmem_cache_alloc(kmem_cache
 extern void kmem_cache_free(kmem_cache_t *, void *);
 extern unsigned int kmem_cache_size(kmem_cache_t *);
 extern kmem_cache_t *kmem_find_general_cachep(size_t size, int gfpflags);
+unsigned kmem_estimate_pages(kmem_cache_t *cache, unsigned num);
 
 /* Size description struct for general caches. */
 struct cache_sizes {
diff -up --recursive 2.6.12.3.clean/include/net/sock.h 2.6.12.3/include/net/sock.h
--- 2.6.12.3.clean/include/net/sock.h	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/include/net/sock.h	2005-08-05 21:53:09.000000000 -0400
@@ -382,6 +382,7 @@ enum sock_flags {
 	SOCK_NO_LARGESEND, /* whether to sent large segments or not */
 	SOCK_LOCALROUTE, /* route locally only, %SO_DONTROUTE setting */
 	SOCK_QUEUE_SHRUNK, /* write queue has been shrunk recently */
+	SOCK_MEMALLOC, /* protocol can use memalloc reserve */
 };
 
 static inline void sock_set_flag(struct sock *sk, enum sock_flags flag)
@@ -399,6 +400,11 @@ static inline int sock_flag(struct sock 
 	return test_bit(flag, &sk->sk_flags);
 }
 
+static inline int is_memalloc_sock(struct sock *sk)
+{
+	return sock_flag(sk, SOCK_MEMALLOC);
+}
+
 static inline void sk_acceptq_removed(struct sock *sk)
 {
 	sk->sk_ack_backlog--;
diff -up --recursive 2.6.12.3.clean/mm/page_alloc.c 2.6.12.3/mm/page_alloc.c
--- 2.6.12.3.clean/mm/page_alloc.c	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/mm/page_alloc.c	2005-08-08 21:20:15.000000000 -0400
@@ -73,6 +73,7 @@ EXPORT_SYMBOL(zone_table);
 
 static char *zone_names[MAX_NR_ZONES] = { "DMA", "Normal", "HighMem" };
 int min_free_kbytes = 1024;
+int var_free_kbytes;
 
 unsigned long __initdata nr_kernel_pages;
 unsigned long __initdata nr_all_pages;
@@ -802,8 +803,8 @@ __alloc_pages(unsigned int __nocast gfp_
 
 	/* This allocation should allow future memory freeing. */
 
-	if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
-			&& !in_interrupt()) {
+	if ((((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
+			&& !in_interrupt()) || (gfp_mask & __GFP_MEMALLOC)) {
 		if (!(gfp_mask & __GFP_NOMEMALLOC)) {
 			/* go through the zonelist yet again, ignoring mins */
 			for (i = 0; (z = zones[i]) != NULL; i++) {
@@ -2029,7 +2030,8 @@ static void setup_per_zone_lowmem_reserv
  */
 static void setup_per_zone_pages_min(void)
 {
-	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
+	unsigned pages_min = (min_free_kbytes + var_free_kbytes)
+		>> (PAGE_SHIFT - 10);
 	unsigned long lowmem_pages = 0;
 	struct zone *zone;
 	unsigned long flags;
@@ -2075,6 +2077,18 @@ static void setup_per_zone_pages_min(voi
 	}
 }
 
+int adjust_memalloc_reserve(int pages)
+{
+	int kbytes = var_free_kbytes + (pages << (PAGE_SHIFT - 10));
+	if (kbytes < 0)
+		return -EINVAL;
+	var_free_kbytes = kbytes;
+	setup_per_zone_pages_min();
+	return 0;
+}
+
+EXPORT_SYMBOL_GPL(adjust_memalloc_reserve);
+
 /*
  * Initialise min_free_kbytes.
  *
diff -up --recursive 2.6.12.3.clean/mm/slab.c 2.6.12.3/mm/slab.c
--- 2.6.12.3.clean/mm/slab.c	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/mm/slab.c	2005-08-08 05:00:38.000000000 -0400
@@ -2353,6 +2353,11 @@ out:
 	return 0;
 }
 
+unsigned kmem_estimate_pages(kmem_cache_t *cache, unsigned num)
+{
+	return ((num + cache->num - 1) / cache->num) << cache->gfporder;
+}
+
 #ifdef CONFIG_NUMA
 /**
  * kmem_cache_alloc_node - Allocate an object on the specified node
diff -up --recursive 2.6.12.3.clean/net/core/skbuff.c 2.6.12.3/net/core/skbuff.c
--- 2.6.12.3.clean/net/core/skbuff.c	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/net/core/skbuff.c	2005-08-08 23:16:23.000000000 -0400
@@ -44,6 +44,7 @@
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/mm.h>
+#include <linux/pagemap.h>
 #include <linux/interrupt.h>
 #include <linux/in.h>
 #include <linux/inet.h>
@@ -167,6 +168,15 @@ nodata:
 	goto out;
 }
 
+#define ceiling_log2(x) fls(x - 1)
+unsigned estimate_skb_pages(unsigned num, unsigned size)
+{
+	int slab_pages = kmem_estimate_pages(skbuff_head_cache, num);
+	int data_space = num * (1 << ceiling_log2(size + 16));
+	int data_pages = (data_space + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	return slab_pages + data_pages;
+}
+
 /**
  *	alloc_skb_from_cache	-	allocate a network buffer
  *	@cp: kmem_cache from which to allocate the data area
diff -up --recursive 2.6.12.3.clean/net/ethernet/eth.c 2.6.12.3/net/ethernet/eth.c
--- 2.6.12.3.clean/net/ethernet/eth.c	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/net/ethernet/eth.c	2005-08-06 02:32:02.000000000 -0400
@@ -281,6 +281,7 @@ void ether_setup(struct net_device *dev)
 	dev->mtu		= 1500; /* eth_mtu */
 	dev->addr_len		= ETH_ALEN;
 	dev->tx_queue_len	= 1000;	/* Ethernet wants good queues */	
+	dev->rx_reserve		= 50;
 	dev->flags		= IFF_BROADCAST|IFF_MULTICAST;
 	
 	memset(dev->broadcast,0xFF, ETH_ALEN);
diff -up --recursive 2.6.12.3.clean/net/ipv4/icmp.c 2.6.12.3/net/ipv4/icmp.c
--- 2.6.12.3.clean/net/ipv4/icmp.c	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/net/ipv4/icmp.c	2005-08-11 16:28:46.000000000 -0400
@@ -944,6 +944,11 @@ int icmp_rcv(struct sk_buff *skb)
 	default:;
 	}
 
+	if (unlikely(dev_reserve_used(skb->dev))) {
+		dev_unreserve_skb(skb->dev);
+		goto drop;
+	}
+
 	if (!pskb_pull(skb, sizeof(struct icmphdr)))
 		goto error;
 
diff -up --recursive 2.6.12.3.clean/net/ipv4/tcp_ipv4.c 2.6.12.3/net/ipv4/tcp_ipv4.c
--- 2.6.12.3.clean/net/ipv4/tcp_ipv4.c	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/net/ipv4/tcp_ipv4.c	2005-08-11 16:29:14.000000000 -0400
@@ -1766,6 +1766,12 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	if (!sk)
 		goto no_tcp_socket;
 
+	if (unlikely(dev_reserve_used(skb->dev))) {
+		dev_unreserve_skb(skb->dev);
+		if (!is_memalloc_sock(sk))
+			goto discard_and_relse;
+	}
+
 process:
 	if (sk->sk_state == TCP_TIME_WAIT)
 		goto do_time_wait;
diff -up --recursive 2.6.12.3.clean/net/ipv4/udp.c 2.6.12.3/net/ipv4/udp.c
--- 2.6.12.3.clean/net/ipv4/udp.c	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/net/ipv4/udp.c	2005-08-11 16:28:56.000000000 -0400
@@ -1152,6 +1152,12 @@ int udp_rcv(struct sk_buff *skb)
 	sk = udp_v4_lookup(saddr, uh->source, daddr, uh->dest, skb->dev->ifindex);
 
 	if (sk != NULL) {
+		if (unlikely(dev_reserve_used(skb->dev))) {
+			dev_unreserve_skb(skb->dev);
+			if (!is_memalloc_sock(sk))
+				goto drop_noncritical;
+		}
+
 		int ret = udp_queue_rcv_skb(sk, skb);
 		sock_put(sk);
 
@@ -1163,6 +1169,7 @@ int udp_rcv(struct sk_buff *skb)
 		return 0;
 	}
 
+drop_noncritical:
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto drop;
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
