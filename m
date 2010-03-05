Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C7E8C6B0047
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 15:28:11 -0500 (EST)
Message-ID: <4B916922.3010807@kernel.org>
Date: Fri, 05 Mar 2010 12:27:14 -0800
From: Yinghai Lu <yinghai@kernel.org>
MIME-Version: 1.0
Subject: Re: mmotm boot panic bootmem-avoid-dma32-zone-by-default.patch
References: <49b004811003041321g2567bac8yb73235be32a27e7c@mail.gmail.com> <20100305032106.GA12065@cmpxchg.org> <4B90C921.6060908@kernel.org> <4B90DC3C.1060000@gmail.com>
In-Reply-To: <4B90DC3C.1060000@gmail.com>
Content-Type: multipart/mixed;
 boundary="------------010205080801090505000906"
Sender: owner-linux-mm@kvack.org
To: Jiri Slaby <jirislaby@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------010205080801090505000906
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 03/05/2010 02:26 AM, Jiri Slaby wrote:
> On 03/05/2010 10:04 AM, Yinghai Lu wrote:
>> according to context
>> http://patchwork.kernel.org/patch/73893/
>>
>> Jiri, 
>> please check current linus tree still have problem about mem_map is using that much low mem?
> 
> Hi!
> 
> Sorry, I don't have direct access to the machine. I might try to ask the
> owners to do so.
> 
>> on my 1024g system first node has 128G ram, [2g, 4g) are mmio range.
> 
> So where gets your mem_map allocated (I suppose you're running flat model)?
> 
> Note that the failure we were seeing was with different amount of memory
> on different machines. Obviously because of different e820 reservations
> and driver requirements at boot time. So the required memory to trigger
> the error oscillated around 128G, sometimes being 130G.
> 
> It triggered when mem_map fit exactly into 0-2G (and 2-4G was reserved)
> and no more space was there. If RAM was more than 130G, mem_map was
> above 4G boundary implicitly, so that there was enough space in the
> first 4G of memory for others with specific bootmem limitations.
> 
>> with NO_BOOTMEM
>> [    0.000000]  a - 11
>> [    0.000000]  19 40 - 80 95
>> [    0.000000]  702 740 - 1000 1000
>> [    0.000000]  331f 3340 - 3400 3400
>> [    0.000000]  35dd - 3600
>> [    0.000000]  37dd - 3800
>> [    0.000000]  39dd - 3a00
>> [    0.000000]  3bdd - 3c00
>> [    0.000000]  3ddd - 3e00
>> [    0.000000]  3fdd - 4000
>> [    0.000000]  41dd - 4200
>> [    0.000000]  43dd - 4400
>> [    0.000000]  45dd - 4600
>> [    0.000000]  47dd - 4800
>> [    0.000000]  49dd - 4a00
>> [    0.000000]  4bdd - 4c00
>> [    0.000000]  4ddd - 4e00
>> [    0.000000]  4fdd - 5000
>> [    0.000000]  51dd - 5200
>> [    0.000000]  93dd 9400 - 7d500 7d53b
>> [    0.000000]  7f730 - 7f750
>> [    0.000000]  100012 100040 - 100200 100200
>> [    0.000000]  170200 170200 - 2080000 2080000
>> [    0.000000]  2080065 2080080 - 2080200 2080200
>>
>> so PFN: 9400 - 7d500 are free.
> 
> Could you explain more the dmesg output?

it will list free pfn range that will be use for slab...

attached is debug patch for print out without CONFIG_NO_BOOTMEM set.

YH

--------------010205080801090505000906
Content-Type: text/x-patch;
 name="print_free_bootmem.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="print_free_bootmem.patch"

Subject: [PATCH -v3] x86: print bootmem free before and free_all_bootmem

so we could double check if we have enough low pages later

-v2: fix errors checkpatch.pl reported
-v3: move after pci_iommu_alloc, so could compare it with NO_BOOTMEM

Signed-off-by: Yinghai Lu <yinghai@kernel.org>

---
 arch/x86/mm/init_64.c   |    2 +
 include/linux/bootmem.h |    3 +
 mm/bootmem.c            |   91 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 96 insertions(+)

Index: linux-2.6/mm/bootmem.c
===================================================================
--- linux-2.6.orig/mm/bootmem.c
+++ linux-2.6/mm/bootmem.c
@@ -335,6 +335,97 @@ static void __init __free(bootmem_data_t
 			BUG();
 }
 
+static void __init print_all_bootmem_free_core(bootmem_data_t *bdata)
+{
+	int aligned;
+	unsigned long *map;
+	unsigned long start, end, count = 0;
+	unsigned long free_start = -1UL, free_end = 0;
+
+	if (!bdata->node_bootmem_map)
+		return;
+
+	start = bdata->node_min_pfn;
+	end = bdata->node_low_pfn;
+
+	/*
+	 * If the start is aligned to the machines wordsize, we might
+	 * be able to count it in bulks of that order.
+	 */
+	aligned = !(start & (BITS_PER_LONG - 1));
+
+	printk(KERN_DEBUG "nid=%td start=0x%010lx end=0x%010lx aligned=%d\n",
+		bdata - bootmem_node_data, start, end, aligned);
+	map = bdata->node_bootmem_map;
+
+	while (start < end) {
+		unsigned long idx, vec;
+
+		idx = start - bdata->node_min_pfn;
+		vec = ~map[idx / BITS_PER_LONG];
+
+		if (aligned && vec == ~0UL && start + BITS_PER_LONG < end) {
+			if (free_start == -1UL) {
+				free_start = idx;
+				free_end = free_start + BITS_PER_LONG;
+			} else {
+				if (free_end == idx) {
+					free_end += BITS_PER_LONG;
+				} else {
+					/* there is gap, print old */
+					printk(KERN_DEBUG "  free [0x%010lx - 0x%010lx]\n",
+							free_start + bdata->node_min_pfn,
+							free_end + bdata->node_min_pfn);
+					free_start = idx;
+					free_end = idx + BITS_PER_LONG;
+				}
+			}
+			count += BITS_PER_LONG;
+		} else {
+			unsigned long off = 0;
+
+			while (vec && off < BITS_PER_LONG) {
+				if (vec & 1) {
+					if (free_start == -1UL) {
+						free_start = idx + off;
+						free_end = free_start + 1;
+					} else {
+						if (free_end == (idx + off)) {
+							free_end++;
+						} else {
+							/* there is gap, print old */
+							printk(KERN_DEBUG "  free [0x%010lx - 0x%010lx]\n",
+								free_start + bdata->node_min_pfn,
+								free_end + bdata->node_min_pfn);
+							free_start = idx + off;
+							free_end = free_start + 1;
+						}
+					}
+					count++;
+				}
+				vec >>= 1;
+				off++;
+			}
+		}
+		start += BITS_PER_LONG;
+	}
+
+	/* last one */
+	if (free_start != -1UL)
+		printk(KERN_DEBUG "  free [0x%010lx - 0x%010lx]\n",
+			free_start + bdata->node_min_pfn,
+			free_end + bdata->node_min_pfn);
+	printk(KERN_DEBUG "  total free 0x%010lx\n", count);
+}
+
+void __init print_bootmem_free(void)
+{
+	bootmem_data_t *bdata;
+
+	list_for_each_entry(bdata, &bdata_list, list)
+		print_all_bootmem_free_core(bdata);
+}
+
 static int __init __reserve(bootmem_data_t *bdata, unsigned long sidx,
 			unsigned long eidx, int flags)
 {
Index: linux-2.6/arch/x86/mm/init_64.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/init_64.c
+++ linux-2.6/arch/x86/mm/init_64.c
@@ -679,6 +679,8 @@ void __init mem_init(void)
 
 	pci_iommu_alloc();
 
+	print_bootmem_free();
+
 	/* clear_bss() already clear the empty_zero_page */
 
 	reservedpages = 0;
Index: linux-2.6/include/linux/bootmem.h
===================================================================
--- linux-2.6.orig/include/linux/bootmem.h
+++ linux-2.6/include/linux/bootmem.h
@@ -38,6 +38,9 @@ typedef struct bootmem_data {
 } bootmem_data_t;
 
 extern bootmem_data_t bootmem_node_data[];
+void print_bootmem_free(void);
+#else
+static inline void print_bootmem_free(void) {}
 #endif
 
 extern unsigned long bootmem_bootmap_pages(unsigned long);

--------------010205080801090505000906--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
