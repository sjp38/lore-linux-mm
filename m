Date: Wed, 18 Sep 2002 22:07:42 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: free_more_memory() calls try_to_free_pages() with a NULL classzone
Message-ID: <383929461.1032386861@[10.10.2.3]>
In-Reply-To: <376979708.1032379912@[10.10.2.3]>
References: <376979708.1032379912@[10.10.2.3]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> mbligh:
>> wli:
>> I'm not convinced contig_page_data is supposed to even be defined.
> 
> It's not. Thus this:
> 
> zone = contig_page_data.node_zonelists[GFP_NOFS&GFP_ZONEMASK].zones[0];
> 
> should have been caught at compile time.

OK, here's more or less your fix as a patch (one typo fixed)
plus the undef of contig_page_data for discontigmem.
You don't need to check the zone size, that gets done when the
zonelist is built.

Can you put it through the wli snot-kicking test?
Compiles and boots (well, if you apply the other patch I sent
earlier first).

Thanks,

M.

diff -urN -X /home/mbligh/.diff.exclude numafixes/fs/buffer.c numafixes2/fs/buffer.c
--- numafixes/fs/buffer.c	Wed Sep 18 20:41:12 2002
+++ numafixes2/fs/buffer.c	Wed Sep 18 21:41:05 2002
@@ -468,12 +468,17 @@
 static void free_more_memory(void)
 {
 	struct zone *zone;
+	pg_data_t *pgdat;
 
-	zone = contig_page_data.node_zonelists[GFP_NOFS&GFP_ZONEMASK].zones[0];
 	wakeup_bdflush(1024);
 	blk_run_queues();
 	yield();
-	try_to_free_pages(zone, GFP_NOFS, 0);
+
+	for_each_pgdat(pgdat) {
+		zone = pgdat->node_zonelists[GFP_NOFS&GFP_ZONEMASK].zones[0];
+		if (zone)
+			try_to_free_pages(zone, GFP_NOFS, 0);
+	}
 }
 
 /*
diff -urN -X /home/mbligh/.diff.exclude numafixes/mm/bootmem.c numafixes2/mm/bootmem.c
--- numafixes/mm/bootmem.c	Tue Sep 17 17:58:50
2002
+++ numafixes2/mm/bootmem.c	Wed Sep 18 21:44:16 2002
@@ -311,6 +311,7 @@
 	return(free_all_bootmem_core(pgdat));
 }
 
+#ifndef CONFIG_DISCONTIGMEM
 unsigned long __init init_bootmem (unsigned long start, unsigned long pages)
 {
 	max_low_pfn = pages;
@@ -334,6 +335,7 @@
 {
 	return(free_all_bootmem_core(&contig_page_data));
 }
+#endif /* !CONFIG_DISCONTIGMEM */
 
 void * __init __alloc_bootmem (unsigned long size, unsigned long align, unsigned long goal)
 {
diff -urN -X /home/mbligh/.diff.exclude numafixes/mm/numa.c numafixes2/mm/numa.c
--- numafixes/mm/numa.c	Wed Sep 18 20:41:12 2002
+++ numafixes2/mm/numa.c	Wed Sep 18 21:41:05 2002
@@ -11,10 +11,10 @@
 
 int numnodes = 1;	/* Initialized for UMA platforms */
 
+#ifndef CONFIG_DISCONTIGMEM
+

static bootmem_data_t contig_bootmem_data;
 pg_data_t contig_page_data = { .bdata = &contig_bootmem_data };
-
-#ifndef CONFIG_DISCONTIGMEM
 
 /*
  * This is meant to be invoked by platforms whose physical memory starts

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
