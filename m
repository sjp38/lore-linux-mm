Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 475B16B019F
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 23:42:54 -0400 (EDT)
Received: by iec9 with SMTP id 9so7677081iec.14
        for <linux-mm@kvack.org>; Thu, 13 Sep 2012 20:42:53 -0700 (PDT)
Message-ID: <5052A7DF.4050301@gmail.com>
Date: Fri, 14 Sep 2012 11:43:27 +0800
From: qiuxishi <qiuxishi@gmail.com>
MIME-Version: 1.0
Subject: [PATCH RESEND] memory hotplug: fix a double register section info
 bug
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, tony.luck@intel.com, Jiang Liu <jiang.liu@huawei.com>
Cc: qiuxishi@huawei.com, bessel.wang@huawei.com, wujianguo@huawei.com, paul.gortmaker@windriver.com, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, rientjes@google.com, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wen Congyang <wency@cn.fujitsu.com>

There may be a bug when registering section info. For example, on
my Itanium platform, the pfn range of node0 includes the other nodes,
so other nodes' section info will be double registered, and memmap's
page count will equal to 3.

node0: start_pfn=0x100,    spanned_pfn=0x20fb00, present_pfn=0x7f8a3, => 0x000100-0x20fc00
node1: start_pfn=0x80000,  spanned_pfn=0x80000,  present_pfn=0x80000, => 0x080000-0x100000
node2: start_pfn=0x100000, spanned_pfn=0x80000,  present_pfn=0x80000, => 0x100000-0x180000
node3: start_pfn=0x180000, spanned_pfn=0x80000,  present_pfn=0x80000, => 0x180000-0x200000

free_all_bootmem_node()
	register_page_bootmem_info_node()
		register_page_bootmem_info_section()

When hot remove memory, we can't free the memmap's page because
page_count() is 2 after put_page_bootmem().

sparse_remove_one_section()
	free_section_usemap()
		free_map_bootmem()
			put_page_bootmem()

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 mm/memory_hotplug.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 2adbcac..cf493c7 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -126,9 +126,6 @@ static void register_page_bootmem_info_section(unsigned long start_pfn)
 	struct mem_section *ms;
 	struct page *page, *memmap;

-	if (!pfn_valid(start_pfn))
-		return;
-
 	section_nr = pfn_to_section_nr(start_pfn);
 	ms = __nr_to_section(section_nr);

@@ -187,9 +184,10 @@ void register_page_bootmem_info_node(struct pglist_data *pgdat)
 	end_pfn = pfn + pgdat->node_spanned_pages;

 	/* register_section info */
-	for (; pfn < end_pfn; pfn += PAGES_PER_SECTION)
-		register_page_bootmem_info_section(pfn);
-
+	for (; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
+		if (pfn_valid(pfn) && (pfn_to_nid(pfn) == node))
+			register_page_bootmem_info_section(pfn);
+	}
 }
 #endif /* !CONFIG_SPARSEMEM_VMEMMAP */

-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
