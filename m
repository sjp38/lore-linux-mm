Date: Mon, 11 Jun 2007 13:35:43 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: mm: memory/cpu hotplug section mismatch.
Message-ID: <20070611043543.GA22910@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

When building with memory hotplug enabled and cpu hotplug disabled, we
end up with the following section mismatch:

WARNING: mm/built-in.o(.text+0x4e58): Section mismatch: reference to
.init.text: (between 'free_area_init_node' and '__build_all_zonelists')

This happens as a result of:

	-> free_area_init_node()
	  -> free_area_init_core()
	    -> zone_pcp_init() <-- all __meminit up to this point
	      -> zone_batchsize() <-- marked as __cpuinit

This happens because CONFIG_HOTPLUG_CPU=n sets __cpuinit to __init, but
CONFIG_MEMORY_HOTPLUG=y unsets __meminit.

Changing zone_batchsize() to __init_refok fixes this.

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

--

 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bd8e335..5c312d6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1968,7 +1968,7 @@ void zone_init_free_lists(struct pglist_data *pgdat, struct zone *zone,
 	memmap_init_zone((size), (nid), (zone), (start_pfn), MEMMAP_EARLY)
 #endif
 
-static int __cpuinit zone_batchsize(struct zone *zone)
+static int __init_refok zone_batchsize(struct zone *zone)
 {
 	int batch;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
