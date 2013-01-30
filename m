Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 4C7336B0005
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 02:55:19 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH Bug fix] acpi, movablemem_map: node0 should always be unhotpluggable when using SRAT.
Date: Wed, 30 Jan 2013 15:54:30 +0800
Message-Id: <1359532470-28874-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

When using movablemem_map=acpi, always set node0 as unhotpluggable, otherwise
if all the memory is hotpluggable, the kernel will fail to boot.

When using movablemem_map=nn[KMG]@ss[KMG], we don't stop users specifying
node0 as hotpluggable, and ignore all the info in SRAT, so that this option
can be used as a workaround of firmware bugs.

Reported-by: H. Peter Anvin <hpa@zytor.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 Documentation/kernel-parameters.txt |    6 ++++++
 arch/x86/mm/srat.c                  |   10 ++++++++--
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 7d1b6fc..81b6f15 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1645,6 +1645,8 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			in flags from SRAT from ACPI BIOS to determine which
 			memory devices could be hotplugged. The corresponding
 			memory ranges will be set as ZONE_MOVABLE.
+			NOTE: node0 should always be unhotpluggable, otherwise
+			      the kernel will fail to boot.
 
 	movablemem_map=nn[KMG]@ss[KMG]
 			[KNL,X86,IA-64,PPC] This parameter is similar to
@@ -1666,6 +1668,10 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			satisfied. So the administrator should be careful that
 			the amount of movablemem_map areas are not too large.
 			Otherwise kernel won't have enough memory to start.
+			NOTE: We don't stop users specifying node0 as
+			      hotpluggable, and ingore all the info in SRAT so
+			      that this option can be used as a workaround of
+			      firmware bugs.
 
 	MTD_Partition=	[MTD]
 			Format: <name>,<region-number>,<size>,<offset>
diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
index b20b5b7..a85d2b7 100644
--- a/arch/x86/mm/srat.c
+++ b/arch/x86/mm/srat.c
@@ -161,9 +161,13 @@ handle_movablemem(int node, u64 start, u64 end, u32 hotpluggable)
 	 *
 	 * Using movablemem_map, we can prevent memblock from allocating memory
 	 * on ZONE_MOVABLE at boot time.
+	 *
+	 * NOTE: node0 shoule always be unhotpluggable, otherwise, if all the
+	 *       memory is hotpluggable, there will be no memory kernel can use.
 	 */
 	if (hotpluggable && movablemem_map.acpi) {
-		insert_movablemem_map(start_pfn, end_pfn);
+		if (node != 0)
+			insert_movablemem_map(start_pfn, end_pfn);
 		goto out;
 	}
 
@@ -178,7 +182,9 @@ handle_movablemem(int node, u64 start, u64 end, u32 hotpluggable)
 	 * Using movablemem_map, we can prevent memblock from allocating memory
 	 * on ZONE_MOVABLE at boot time.
 	 *
-	 * NOTE: In this case, SRAT info will be ingored.
+	 * NOTE: We don't stop users specifying node0 as hotpluggable, and
+	 *       ignore all the info in SRAT, so that this option can be used
+	 *       as a workaround of firmware bugs.
 	 */
 	overlap = movablemem_map_overlap(start_pfn, end_pfn);
 	if (overlap >= 0) {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
