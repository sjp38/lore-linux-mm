Received: from fujitsu2.fujitsu.com (localhost [127.0.0.1])
	by fujitsu2.fujitsu.com (8.12.10/8.12.9) with ESMTP id i9Q2ciNo008128
	for <linux-mm@kvack.org>; Mon, 25 Oct 2004 19:38:44 -0700 (PDT)
Date: Mon, 25 Oct 2004 19:38:25 -0700
From: Yasunori Goto <ygoto@us.fujitsu.com>
Subject: [RFC/Patch]Making Removable zone[4/4]
In-Reply-To: <20041025160642.690F.YGOTO@us.fujitsu.com>
References: <20041025160642.690F.YGOTO@us.fujitsu.com>
Message-Id: <20041025193707.6919.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is just for test to make removable zones.

--

 hotremovable-goto/arch/i386/mm/init.c |   22 +++++++++++++++++++---
 1 files changed, 19 insertions(+), 3 deletions(-)

diff -puN arch/i386/mm/init.c~removable arch/i386/mm/init.c
--- hotremovable/arch/i386/mm/init.c~removable	Fri Aug 27 21:07:12 2004
+++ hotremovable-goto/arch/i386/mm/init.c	Fri Aug 27 21:07:12 2004
@@ -512,22 +512,38 @@ void zap_low_mappings (void)
 }
 
 #ifndef CONFIG_DISCONTIGMEM
+
+unsigned int __init check_max_unremovable(void)
+{
+	/* XXX : Hardware information might be necessary.
+	         Now is just for test */
+	return (highend_pfn + max_low_pfn) / 2;
+}
+
 void __init zone_sizes_init(void)
 {
-	unsigned long zones_size[MAX_NR_ZONES] = {0, 0, 0};
-	unsigned int max_dma, high, low;
+	unsigned long zones_size[MAX_NR_ZONES] = {0, 0, 0, 0, 0, 0};
+	unsigned int max_dma, high, low, max_unremovable;
 	
 	max_dma = virt_to_phys((char *)MAX_DMA_ADDRESS) >> PAGE_SHIFT;
 	low = max_low_pfn;
 	high = highend_pfn;
 	
+	max_unremovable = check_max_unremovable();
+
 	if (low < max_dma)
 		zones_size[ZONE_DMA] = low;
 	else {
 		zones_size[ZONE_DMA] = max_dma;
 		zones_size[ZONE_NORMAL] = low - max_dma;
 #ifdef CONFIG_HIGHMEM
-		zones_size[ZONE_HIGHMEM] = high - low;
+		if( low >= max_unremovable )
+			zones_size[ZONE_HIGHMEM_RMV] = high - low;
+		else if( high > max_unremovable ){
+			zones_size[ZONE_HIGHMEM_RMV] = high - max_unremovable;
+			zones_size[ZONE_HIGHMEM] = max_unremovable - low;
+		}else
+			zones_size[ZONE_HIGHMEM] = high - low;
 #endif
 	}
 	free_area_init(zones_size);	
_

-- 
Yasunori Goto <ygoto at us.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
