Date: Mon, 29 Jan 2007 17:31:16 +0000
Subject: Re: [PATCH 2/8] Create the ZONE_MOVABLE zone
Message-ID: <20070129173116.GA19568@skynet.ie>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie> <20070125234538.28809.24662.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0701260915390.7209@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0701260915390.7209@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (26/01/07 09:16), Christoph Lameter didst pronounce:
> I do not see any updates of vmstat.c and vmstat.h. This 
> means that VM statistics are not kept / considered for ZONE_MOVABLE.

Based on searching around for ZONE_DMA32, the following patch appears to be
all that is required;

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-rc4-mm1-009_backout_zonecount/include/linux/vmstat.h linux-2.6.20-rc4-mm1-010_update_zonecounters/include/linux/vmstat.h
--- linux-2.6.20-rc4-mm1-009_backout_zonecount/include/linux/vmstat.h	2007-01-17 17:08:36.000000000 +0000
+++ linux-2.6.20-rc4-mm1-010_update_zonecounters/include/linux/vmstat.h	2007-01-29 16:52:42.000000000 +0000
@@ -24,7 +24,7 @@
 #define HIGHMEM_ZONE(xx)
 #endif
 
-#define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL HIGHMEM_ZONE(xx)
+#define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL HIGHMEM_ZONE(xx) , xx##_MOVABLE
 
 enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
@@ -171,7 +171,8 @@ static inline unsigned long node_page_st
 #ifdef CONFIG_HIGHMEM
 		zone_page_state(&zones[ZONE_HIGHMEM], item) +
 #endif
-		zone_page_state(&zones[ZONE_NORMAL], item);
+		zone_page_state(&zones[ZONE_NORMAL], item) +
+		zone_page_state(&zones[ZONE_MOVABLE], item);
 }
 
 extern void zone_statistics(struct zonelist *, struct zone *);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-rc4-mm1-009_backout_zonecount/mm/vmstat.c linux-2.6.20-rc4-mm1-010_update_zonecounters/mm/vmstat.c
--- linux-2.6.20-rc4-mm1-009_backout_zonecount/mm/vmstat.c	2007-01-17 17:08:39.000000000 +0000
+++ linux-2.6.20-rc4-mm1-010_update_zonecounters/mm/vmstat.c	2007-01-29 16:52:42.000000000 +0000
@@ -456,7 +456,7 @@ const struct seq_operations fragmentatio
 #endif
 
 #define TEXTS_FOR_ZONES(xx) TEXT_FOR_DMA(xx) TEXT_FOR_DMA32(xx) xx "_normal", \
-					TEXT_FOR_HIGHMEM(xx)
+					TEXT_FOR_HIGHMEM(xx) xx "_movable",
 
 static const char * const vmstat_text[] = {
 	/* Zoned VM counters */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
