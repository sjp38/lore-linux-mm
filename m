Date: Tue, 11 Apr 2006 20:30:09 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch:001/005] wait_table and zonelist initializing for memory hotadd (change name of wait_table_size())
In-Reply-To: <20060411202031.5643.Y-GOTO@jp.fujitsu.com>
References: <20060411202031.5643.Y-GOTO@jp.fujitsu.com>
Message-Id: <20060411202534.5645.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is just to rename from wait_table_size() to wait_table_hash_nr_entries().

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

 include/linux/mmzone.h |    4 ++--
 mm/page_alloc.c        |   12 +++++++-----
 2 files changed, 9 insertions(+), 7 deletions(-)

Index: pgdat10/mm/page_alloc.c
===================================================================
--- pgdat10.orig/mm/page_alloc.c	2006-04-10 18:30:42.000000000 +0900
+++ pgdat10/mm/page_alloc.c	2006-04-10 20:20:09.000000000 +0900
@@ -1786,7 +1786,7 @@ void __init build_all_zonelists(void)
  */
 #define PAGES_PER_WAITQUEUE	256
 
-static inline unsigned long wait_table_size(unsigned long pages)
+static inline unsigned long wait_table_hash_nr_entries(unsigned long pages)
 {
 	unsigned long size = 1;
 
@@ -2081,13 +2081,15 @@ void zone_wait_table_init(struct zone *z
 	 * The per-page waitqueue mechanism uses hashed waitqueues
 	 * per zone.
 	 */
-	zone->wait_table_size = wait_table_size(zone_size_pages);
-	zone->wait_table_bits =	wait_table_bits(zone->wait_table_size);
+	zone->wait_table_hash_nr_entries =
+		 wait_table_hash_nr_entries(zone_size_pages);
+	zone->wait_table_bits =
+		wait_table_bits(zone->wait_table_hash_nr_entries);
 	zone->wait_table = (wait_queue_head_t *)
-		alloc_bootmem_node(pgdat, zone->wait_table_size
+		alloc_bootmem_node(pgdat, zone->wait_table_hash_nr_entries
 					* sizeof(wait_queue_head_t));
 
-	for(i = 0; i < zone->wait_table_size; ++i)
+	for(i = 0; i < zone->wait_table_hash_nr_entries; ++i)
 		init_waitqueue_head(zone->wait_table + i);
 }
 
Index: pgdat10/include/linux/mmzone.h
===================================================================
--- pgdat10.orig/include/linux/mmzone.h	2006-04-10 18:30:40.000000000 +0900
+++ pgdat10/include/linux/mmzone.h	2006-04-10 20:19:33.000000000 +0900
@@ -196,7 +196,7 @@ struct zone {
 
 	/*
 	 * wait_table		-- the array holding the hash table
-	 * wait_table_size	-- the size of the hash table array
+	 * wait_table_hash_nr_entries	-- the size of the hash table array
 	 * wait_table_bits	-- wait_table_size == (1 << wait_table_bits)
 	 *
 	 * The purpose of all these is to keep track of the people
@@ -219,7 +219,7 @@ struct zone {
 	 * free_area_init_core() performs the initialization of them.
 	 */
 	wait_queue_head_t	* wait_table;
-	unsigned long		wait_table_size;
+	unsigned long		wait_table_hash_nr_entries;
 	unsigned long		wait_table_bits;
 
 	/*

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
