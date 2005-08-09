From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC] Net vm deadlock fix, version 5
Date: Tue, 9 Aug 2005 13:37:45 +1000
References: <200508082012.55049.phillips@istop.com>
In-Reply-To: <200508082012.55049.phillips@istop.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508091337.46457.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: netdev@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

A couple of goofs.  First, the sysctl interface to min_free_kbytes could stomp
on any in-kernel adjustments.  Now there are two variables, summed in
setup_per_zone_pages_min: min_free_kbytes and var_free_kbytes.  The
adjust_memalloc_reserve operates only the latter, so the user can freely
twiddle the base reserve without interfering with in-kernel adjustments.

Second, the skb resource estimation code was grossly wrong where it attempted
to calculate ceiling(log2(size)), now fixed and tested this time.

To save bandwidth, just the relevant parts of the patch included below.

Regards,

Daniel

diff -up --recursive 2.6.12.3.clean/mm/page_alloc.c 2.6.12.3/mm/page_alloc.c
--- 2.6.12.3.clean/mm/page_alloc.c	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/mm/page_alloc.c	2005-08-08 21:20:15.000000000 -0400
@@ -73,6 +73,7 @@ EXPORT_SYMBOL(zone_table);
 
 static char *zone_names[MAX_NR_ZONES] = { "DMA", "Normal", "HighMem" };
 int min_free_kbytes = 1024;
+int var_free_kbytes;
 
 unsigned long __initdata nr_kernel_pages;
 unsigned long __initdata nr_all_pages;
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
diff -up --recursive 2.6.12.3.clean/net/core/skbuff.c 2.6.12.3/net/core/skbuff.c
--- 2.6.12.3.clean/net/core/skbuff.c	2005-07-15 17:18:57.000000000 -0400
+++ 2.6.12.3/net/core/skbuff.c	2005-08-08 23:07:12.000000000 -0400
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
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
