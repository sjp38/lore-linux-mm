Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 1138F6B0009
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 19:36:17 -0500 (EST)
Date: Fri, 25 Jan 2013 16:36:15 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] acpi, memory-hotplug: Extend movablemem_map ranges
 to the end of node.
Message-Id: <20130125163615.4f82bf9d.akpm@linux-foundation.org>
In-Reply-To: <1359106929-3034-3-git-send-email-tangchen@cn.fujitsu.com>
References: <1359106929-3034-1-git-send-email-tangchen@cn.fujitsu.com>
	<1359106929-3034-3-git-send-email-tangchen@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 25 Jan 2013 17:42:08 +0800
Tang Chen <tangchen@cn.fujitsu.com> wrote:

> When implementing movablemem_map boot option, we introduced an array
> movablemem_map.map[] to store the memory ranges to be set as ZONE_MOVABLE.
> 
> Since ZONE_MOVABLE is the latst zone of a node, if user didn't specify
> the whole node memory range, we need to extend it to the node end so that
> we can use it to prevent memblock from allocating memory in the ranges
> user didn't specify.
> 
> We now implement movablemem_map boot option like this:
>         /*
>          * For movablemem_map=nn[KMG]@ss[KMG]:
>          *
>          * SRAT:                |_____| |_____| |_________| |_________| ......
>          * node id:                0       1         1           2
>          * user specified:                |__|                 |___|
>          * movablemem_map:                |___| |_________|    |______| ......
>          *
>          * Using movablemem_map, we can prevent memblock from allocating memory
>          * on ZONE_MOVABLE at boot time.
>          *
>          * NOTE: In this case, SRAT info will be ingored.
>          */
> 

The patch generates a bunch of rejects, partly due to linux-next
changes but I think I fixed everything up OK.

> index 4ddf497..f841d0e 100644
> --- a/arch/x86/mm/srat.c
> +++ b/arch/x86/mm/srat.c
> @@ -141,11 +141,16 @@ static inline int save_add_info(void) {return 1;}
>  static inline int save_add_info(void) {return 0;}
>  #endif
>  
> +#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> +extern struct movablemem_map movablemem_map;
> +#endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */

Well.

a) we shouldn't put extern declarations in C files - put them in
   headers so we can be assured that all compilation units agree on the
   type.

b) the ifdefs are unneeded - a unused extern declaration is OK (as
   long as the type itself is always defined!)

c) movablemem_map is already declared in memblock.h.

So I zapped the above three lines.

> @@ -178,9 +185,57 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
>  
>  	node_set(node, numa_nodes_parsed);
>  
> -	printk(KERN_INFO "SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx]\n",
> +	printk(KERN_INFO "SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx] %s\n",
>  	       node, pxm,
> -	       (unsigned long long) start, (unsigned long long) end - 1);
> +	       (unsigned long long) start, (unsigned long long) end - 1,
> +	       hotpluggable ? "Hot Pluggable": "");
> +
> +#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> +	int overlap;
> +	unsigned long start_pfn, end_pfn;

no, we don't put declarations of locals in the middle of C statements
like this:

arch/x86/mm/srat.c: In function 'acpi_numa_memory_affinity_init':
arch/x86/mm/srat.c:185: warning: ISO C90 forbids mixed declarations and code

Did your compiler not emit this warning?

I fixed this by moving the code into a new function
"handle_movablemem".  Feel free to suggest a more appropriate name!


From: Andrew Morton <akpm@linux-foundation.org>
Subject: acpi-memory-hotplug-extend-movablemem_map-ranges-to-the-end-of-node-fix

clean up code, fix build warning

Cc: "Brown, Len" <len.brown@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Jiang Liu <jiang.liu@huawei.com>
Cc: Jianguo Wu <wujianguo@huawei.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Len Brown <lenb@kernel.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Wu Jianguo <wujianguo@huawei.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/x86/mm/srat.c |   93 ++++++++++++++++++++++---------------------
 1 file changed, 49 insertions(+), 44 deletions(-)

diff -puN arch/x86/mm/srat.c~acpi-memory-hotplug-extend-movablemem_map-ranges-to-the-end-of-node-fix arch/x86/mm/srat.c
--- a/arch/x86/mm/srat.c~acpi-memory-hotplug-extend-movablemem_map-ranges-to-the-end-of-node-fix
+++ a/arch/x86/mm/srat.c
@@ -142,50 +142,8 @@ static inline int save_add_info(void) {r
 #endif
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
-extern struct movablemem_map movablemem_map;
-#endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
-
-/* Callback for parsing of the Proximity Domain <-> Memory Area mappings */
-int __init
-acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
+static void __init handle_movablemem(int node, u64 start, u64 end)
 {
-	u64 start, end;
-	u32 hotpluggable;
-	int node, pxm;
-
-	if (srat_disabled())
-		goto out_err;
-	if (ma->header.length != sizeof(struct acpi_srat_mem_affinity))
-		goto out_err_bad_srat;
-	if ((ma->flags & ACPI_SRAT_MEM_ENABLED) == 0)
-		goto out_err;
-	hotpluggable = ma->flags & ACPI_SRAT_MEM_HOT_PLUGGABLE;
-	if (hotpluggable && !save_add_info())
-		goto out_err;
-
-	start = ma->base_address;
-	end = start + ma->length;
-	pxm = ma->proximity_domain;
-	if (acpi_srat_revision <= 1)
-		pxm &= 0xff;
-
-	node = setup_node(pxm);
-	if (node < 0) {
-		printk(KERN_ERR "SRAT: Too many proximity domains.\n");
-		goto out_err_bad_srat;
-	}
-
-	if (numa_add_memblk(node, start, end) < 0)
-		goto out_err_bad_srat;
-
-	node_set(node, numa_nodes_parsed);
-
-	printk(KERN_INFO "SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx] %s\n",
-	       node, pxm,
-	       (unsigned long long) start, (unsigned long long) end - 1,
-	       hotpluggable ? "Hot Pluggable": "");
-
-#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 	int overlap;
 	unsigned long start_pfn, end_pfn;
 
@@ -229,7 +187,54 @@ acpi_numa_memory_affinity_init(struct ac
 			 */
 			insert_movablemem_map(start_pfn, end_pfn);
 	}
-#endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
+}
+#else		/* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
+static inline void handle_movablemem(int node, u64 start, u64 end)
+{
+}
+#endif		/* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
+
+/* Callback for parsing of the Proximity Domain <-> Memory Area mappings */
+int __init
+acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
+{
+	u64 start, end;
+	u32 hotpluggable;
+	int node, pxm;
+
+	if (srat_disabled())
+		goto out_err;
+	if (ma->header.length != sizeof(struct acpi_srat_mem_affinity))
+		goto out_err_bad_srat;
+	if ((ma->flags & ACPI_SRAT_MEM_ENABLED) == 0)
+		goto out_err;
+	hotpluggable = ma->flags & ACPI_SRAT_MEM_HOT_PLUGGABLE;
+	if (hotpluggable && !save_add_info())
+		goto out_err;
+
+	start = ma->base_address;
+	end = start + ma->length;
+	pxm = ma->proximity_domain;
+	if (acpi_srat_revision <= 1)
+		pxm &= 0xff;
+
+	node = setup_node(pxm);
+	if (node < 0) {
+		printk(KERN_ERR "SRAT: Too many proximity domains.\n");
+		goto out_err_bad_srat;
+	}
+
+	if (numa_add_memblk(node, start, end) < 0)
+		goto out_err_bad_srat;
+
+	node_set(node, numa_nodes_parsed);
+
+	printk(KERN_INFO "SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx] %s\n",
+	       node, pxm,
+	       (unsigned long long) start, (unsigned long long) end - 1,
+	       hotpluggable ? "Hot Pluggable": "");
+
+	handle_movablemem(node, start, end);
 
 	return 0;
 out_err_bad_srat:
diff -puN include/linux/mm.h~acpi-memory-hotplug-extend-movablemem_map-ranges-to-the-end-of-node-fix include/linux/mm.h
diff -puN mm/page_alloc.c~acpi-memory-hotplug-extend-movablemem_map-ranges-to-the-end-of-node-fix mm/page_alloc.c
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
