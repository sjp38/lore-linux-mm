Received: from fujitsu2.fujitsu.com (localhost [127.0.0.1])
	by fujitsu2.fujitsu.com (8.12.10/8.12.9) with ESMTP id i8NN4ufM003607
	for <linux-mm@kvack.org>; Thu, 23 Sep 2004 16:04:56 -0700 (PDT)
Date: Thu, 23 Sep 2004 16:04:41 -0700
From: Yasunori Goto <ygoto@us.fujitsu.com>
Subject: [Patch/RFC]Reduce second level zone_table[3/3]
In-Reply-To: <20040923135108.D8CC.YGOTO@us.fujitsu.com>
References: <20040923135108.D8CC.YGOTO@us.fujitsu.com>
Message-Id: <20040923160226.D8D2.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>
Cc: Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

This patch make reduce array of second level zone_table.

If all of second level zone_table points same zone, 
the table is not necessary.

     zone_table_directory.
     +------------+             zone_table
     |            |------------>+-----------+
     |------------|             |           |-> zone DMA
     |            |             |-----------|
     |------------|             |           |-> zone Normal
     |            |             +-----------+
     |------------|
     |            |------------>+-----------+
     +------------+             |           |-> zone Normal
                                |-----------|
                                |           |-> zone Normal
                                +-----------+

So, in this case, first level zone_table points the zone 
directly.

     zone_table_directory.
     +------------+             zone_table
     |      Bit on|------------>+-----------+
     |------------|             |           |-> zone DMA
     |            |             |-----------|
     |------------|             |           |-> zone Normal
     |            |             +-----------+
     |------------|
     |     Bit off|-> zone Normal
     +------------+             


-- 
Yasunori Goto <ygoto at us.fujitsu.com>

---

 erase_zoneid-goto/include/linux/mm.h |   26 ++++++++++++++++++++++++--
 erase_zoneid-goto/mm/page_alloc.c    |   14 +++++++++++---
 2 files changed, 35 insertions(+), 5 deletions(-)

diff -puN include/linux/mm.h~reduce_zone_table include/linux/mm.h
--- erase_zoneid/include/linux/mm.h~reduce_zone_table	Thu Sep 23 11:20:15 2004
+++ erase_zoneid-goto/include/linux/mm.h	Thu Sep 23 11:20:15 2004
@@ -415,15 +415,37 @@ struct zone_tbl{
 	};
 };
 
+#define ZONE_TABLE_BIT 0x1
+#define ZONE_TABLE_BITMASK ~(ZONE_TABLE_BIT)
+
 extern struct zone_tbl pri_zone_table[];
 
+static inline struct zone_tbl *get_zone_table(struct zone_tbl *entry)
+{
+	return (struct zone_tbl *)((unsigned long)entry->sec_zone_table
+				   & ZONE_TABLE_BITMASK);
+}
+
+static inline unsigned long is_second_zone_table(struct zone_tbl *entry)
+{
+	return (unsigned long)entry->sec_zone_table & ZONE_TABLE_BIT;
+}
+
+static inline void set_zone_table(struct zone_tbl *entry, struct zone_tbl *val)
+{
+	entry->sec_zone_table =
+		(struct zone_tbl *)((unsigned long)val | ZONE_TABLE_BIT);
+}
+
 static inline struct zone *page_zone(struct page *page)
 {
 	struct zone_tbl *entry;
 
 	entry = pri_zone_table + page_to_primary_index(page);
-	entry = entry->sec_zone_table;
-	entry += page_to_secondary_index(page);
+	if (is_second_zone_table(entry)){
+		entry = get_zone_table(entry);
+		entry += page_to_secondary_index(page);
+	}
 	return entry->zone;
 }
 
diff -puN mm/page_alloc.c~reduce_zone_table mm/page_alloc.c
--- erase_zoneid/mm/page_alloc.c~reduce_zone_table	Thu Sep 23 11:20:15 2004
+++ erase_zoneid-goto/mm/page_alloc.c	Thu Sep 23 11:20:15 2004
@@ -1499,7 +1499,6 @@ static void __init calculate_zone_totalp
 	printk(KERN_DEBUG "On node %d totalpages: %lu\n", pgdat->node_id, realtotalpages);
 }
 
-
 /*
  * Initially all pages are reserved - free ones are freed
  * up by free_all_bootmem() once the early boot process is
@@ -1590,7 +1589,16 @@ void set_page_zone(struct page *lmem_map
  		struct zone_tbl *sec_entry, *sec_start_entry;
  		unsigned int sec_index, sec_count;
 
- 		sec_start_entry = pri_entry->sec_zone_table;
+ 		if (size / PAGEZONE_DIR_SIZE > 0 &&
+ 		    (PAGEZONE_DIR_MASK & size) == 0){ /* All of second level entry will be same zone.
+ 						    So, Second level isn't necessary. */
+ 			pri_entry->zone = zone;
+ 			size -= PAGEZONE_DIR_SIZE;
+ 			page += PZDIR_SIZE;
+ 			continue;
+ 		}
+
+ 		sec_start_entry = get_zone_table(pri_entry);
  		if (!sec_start_entry){
  			unsigned int entry_size;
  			entry_size = sizeof(struct zone_tbl) <<	PAGEZONE_DIR_SHIFT;
@@ -1611,7 +1619,7 @@ void set_page_zone(struct page *lmem_map
  				break;
  		}
 
-  		pri_entry->sec_zone_table = sec_start_entry;
+ 		set_zone_table(pri_entry, sec_start_entry);
   	}
 }
 
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
