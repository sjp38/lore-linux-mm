From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2/4] mm/sparse: introduce alloc_usemap_and_memmap
Date: Wed, 21 Aug 2013 15:29:15 +0800
Message-ID: <28117.9361547858$1377070179@news.gmane.org>
References: <1376981696-4312-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1376981696-4312-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130820160735.b12fe1b3dd64b4dc146d2fa0@linux-foundation.org>
 <CAE9FiQVy2uqLm2XyStYmzxSmsw7TzrB0XDhCRLymnf+L3NPxrA@mail.gmail.com>
 <52142ffe.84c0440a.57e5.02acSMTPIN_ADDED_BROKEN@mx.google.com>
 <CAE9FiQW1c3-d+iMebRK6JyHCpMt8mjga-TnsfTuVsC1bQZqsYA@mail.gmail.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="mP3DRpeJDSE+ciuQ"
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1VC2rC-00018J-De
	for glkm-linux-mm-2@m.gmane.org; Wed, 21 Aug 2013 09:29:30 +0200
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 12C3D6B0032
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 03:29:26 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 21 Aug 2013 12:50:20 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id BD3703940058
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 12:59:08 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7L7UoQ334734108
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 13:00:51 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7L7TGW7023154
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 12:59:17 +0530
Content-Disposition: inline
In-Reply-To: <CAE9FiQW1c3-d+iMebRK6JyHCpMt8mjga-TnsfTuVsC1bQZqsYA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>


--mP3DRpeJDSE+ciuQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Yinghai,
On Tue, Aug 20, 2013 at 09:28:29PM -0700, Yinghai Lu wrote:
>On Tue, Aug 20, 2013 at 8:11 PM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
>> Hi Yinghai,
>> On Tue, Aug 20, 2013 at 05:02:17PM -0700, Yinghai Lu wrote:
>>>>> -     /* ok, last chunk */
>>>>> -     sparse_early_usemaps_alloc_node(usemap_map, pnum_begin, NR_MEM_SECTIONS,
>>>>> -                                      usemap_count, nodeid_begin);
>>>>> +     alloc_usemap_and_memmap(usemap_map, true);
>>>
>>>alloc_usemap_and_memmap() is somehow confusing.
>>>
>>>Please check if you can pass function pointer instead of true/false.
>>>
>>
>> sparse_early_usemaps_alloc_node and sparse_early_mem_maps_alloc_node is
>> similar, however, one has a parameter unsigned long ** and the other has
>> struct page **. function pointer can't help, isn't it? ;-)
>
>you could have one generic function pointer like
>void *alloc_func(void *data);
>
>and in the every alloc function, have own struct data to pass in/out...
>
>Yinghai

How about this?


--mP3DRpeJDSE+ciuQ
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-sparse.patch"

>From a78e12a9ff31f2a73b87145ce7ad943a0f712708 Mon Sep 17 00:00:00 2001
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Date: Wed, 21 Aug 2013 15:23:08 +0800
Subject: [PATCH] mm/sparse: introduce alloc_usemap_and_memmap fix 

Pass function pointer to alloc_usemap_and_memmap() instead of true/false. 

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/sparse.c |   54 +++++++++++++++++++++++++-----------------------------
 1 files changed, 25 insertions(+), 29 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 55e5752..06adf3c 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -339,14 +339,16 @@ static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
-static void __init sparse_early_usemaps_alloc_node(unsigned long**usemap_map,
+static void __init sparse_early_usemaps_alloc_node(void **usemap_map,
 				 unsigned long pnum_begin,
 				 unsigned long pnum_end,
 				 unsigned long usemap_count, int nodeid)
 {
 	void *usemap;
 	unsigned long pnum;
+	unsigned long **map;
 	int size = usemap_size();
+	map = (unsigned long **) usemap_map;
 
 	usemap = sparse_early_usemaps_alloc_pgdat_section(NODE_DATA(nodeid),
 							  size * usemap_count);
@@ -358,9 +360,9 @@ static void __init sparse_early_usemaps_alloc_node(unsigned long**usemap_map,
 	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
 		if (!present_section_nr(pnum))
 			continue;
-		usemap_map[pnum] = usemap;
+		map[pnum] = usemap;
 		usemap += size;
-		check_usemap_section_nr(nodeid, usemap_map[pnum]);
+		check_usemap_section_nr(nodeid, map[pnum]);
 	}
 }
 
@@ -430,23 +432,16 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 #endif /* !CONFIG_SPARSEMEM_VMEMMAP */
 
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
-static void __init sparse_early_mem_maps_alloc_node(struct page **map_map,
+static void __init sparse_early_mem_maps_alloc_node(void **map_map,
 				 unsigned long pnum_begin,
 				 unsigned long pnum_end,
 				 unsigned long map_count, int nodeid)
 {
-	sparse_mem_maps_populate_node(map_map, pnum_begin, pnum_end,
+	struct page **map = (struct page **)map_map;
+	sparse_mem_maps_populate_node(map, pnum_begin, pnum_end,
 					 map_count, nodeid);
 }
 #else
-
-static void __init sparse_early_mem_maps_alloc_node(struct page **map_map,
-				unsigned long pnum_begin,
-				unsigned long pnum_end,
-				unsigned long map_count, int nodeid)
-{
-}
-
 static struct page __init *sparse_early_mem_map_alloc(unsigned long pnum)
 {
 	struct page *map;
@@ -471,9 +466,10 @@ void __attribute__((weak)) __meminit vmemmap_populate_print_last(void)
 /**
  *  alloc_usemap_and_memmap - memory alloction for pageblock flags and vmemmap
  *  @map: usemap_map for pageblock flags or mmap_map for vmemmap
- *  @use_map: true if memory allocated for pageblock flags, otherwise false
  */
-static void alloc_usemap_and_memmap(unsigned long **map, bool use_map)
+static void alloc_usemap_and_memmap(void (*sparse_early_maps_alloc_node)
+				(void **, unsigned long, unsigned long,
+				unsigned long, int), void **map)
 {
 	unsigned long pnum;
 	unsigned long map_count;
@@ -504,24 +500,16 @@ static void alloc_usemap_and_memmap(unsigned long **map, bool use_map)
 			continue;
 		}
 		/* ok, we need to take cake of from pnum_begin to pnum - 1*/
-		if (use_map)
-			sparse_early_usemaps_alloc_node(map, pnum_begin, pnum,
-						 map_count, nodeid_begin);
-		else
-			sparse_early_mem_maps_alloc_node((struct page **)map,
-				pnum_begin, pnum, map_count, nodeid_begin);
+		(*sparse_early_maps_alloc_node)(map, pnum_begin, pnum,
+					map_count, nodeid_begin);
 		/* new start, update count etc*/
 		nodeid_begin = nodeid;
 		pnum_begin = pnum;
 		map_count = 1;
 	}
 	/* ok, last chunk */
-	if (use_map)
-		sparse_early_usemaps_alloc_node(map, pnum_begin,
-				NR_MEM_SECTIONS, map_count, nodeid_begin);
-	else
-		sparse_early_mem_maps_alloc_node((struct page **)map,
-			pnum_begin, NR_MEM_SECTIONS, map_count, nodeid_begin);
+	(*sparse_early_maps_alloc_node)(map, pnum_begin, NR_MEM_SECTIONS,
+					map_count, nodeid_begin);
 }
 
 /*
@@ -540,6 +528,10 @@ void __init sparse_init(void)
 	struct page **map_map;
 #endif
 
+	void (*sparse_early_maps_alloc_node)(void **map,
+			unsigned long pnum_begin, unsigned long pnum_end,
+				unsigned long map_count, int nodeid);
+
 	/* see include/linux/mmzone.h 'struct mem_section' definition */
 	BUILD_BUG_ON(!is_power_of_2(sizeof(struct mem_section)));
 
@@ -561,14 +553,18 @@ void __init sparse_init(void)
 	usemap_map = alloc_bootmem(size);
 	if (!usemap_map)
 		panic("can not allocate usemap_map\n");
-	alloc_usemap_and_memmap(usemap_map, true);
+	sparse_early_maps_alloc_node = sparse_early_usemaps_alloc_node;
+	alloc_usemap_and_memmap(sparse_early_maps_alloc_node,
+						(void **)usemap_map);
 
 #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
 	size2 = sizeof(struct page *) * NR_MEM_SECTIONS;
 	map_map = alloc_bootmem(size2);
 	if (!map_map)
 		panic("can not allocate map_map\n");
-	alloc_usemap_and_memmap((unsigned long **)map_map, false);
+	sparse_early_maps_alloc_node = sparse_early_mem_maps_alloc_node;
+	alloc_usemap_and_memmap(sparse_early_maps_alloc_node,
+						(void **)map_map);
 #endif
 
 	for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
-- 
1.7.7.6


--mP3DRpeJDSE+ciuQ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
