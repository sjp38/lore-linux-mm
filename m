Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id E63946B0038
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 13:09:37 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so326410pac.1
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 10:09:37 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id hb9si23093577pbd.230.2015.08.23.10.09.36
        for <linux-mm@kvack.org>;
        Sun, 23 Aug 2015 10:09:37 -0700 (PDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 1/1] memhp: Add hot-added memory ranges to memblock before allocate node_data for a node.
Date: Mon, 24 Aug 2015 01:06:13 +0800
Message-ID: <1440349573-24260-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qiuxishi@huawei.com, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, n-horiguchi@ah.jp.nec.com, tangchen@cn.fujitsu.com, vbabka@suse.cz, mgorman@techsingularity.net, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, yasu.isimatu@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

The commit below adds hot-added memory range to memblock, after
creating pgdat for new node.

commit f9126ab9241f66562debf69c2c9d8fee32ddcc53
Author: Xishi Qiu <qiuxishi@huawei.com>
Date:   Fri Aug 14 15:35:16 2015 -0700

    memory-hotplug: fix wrong edge when hot add a new node

But there is a problem:

add_memory()
|--> hotadd_new_pgdat()
     |--> free_area_init_node()
          |--> get_pfn_range_for_nid()
               |--> find start_pfn and end_pfn in memblock
|--> ......
|--> memblock_add_node(start, size, nid)    --------    Here, just too late.

get_pfn_range_for_nid() will find that start_pfn and end_pfn are both 0.
As a result, when adding memory, dmesg will give the following wrong message.

[ 2007.577000] Initmem setup node 5 [mem 0x0000000000000000-0xffffffffffffffff]
[ 2007.584000] On node 5 totalpages: 0
[ 2007.585000] Built 5 zonelists in Node order, mobility grouping on.  Total pages: 32588823
[ 2007.594000] Policy zone: Normal
[ 2007.598000] init_memory_mapping: [mem 0x60000000000-0x607ffffffff]

The solution is simple, just add the memory range to memblock a little earlier,
before hotadd_new_pgdat().

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 mm/memory_hotplug.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6da82bc..9b78aff 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1248,6 +1248,14 @@ int __ref add_memory(int nid, u64 start, u64 size)
 
 	mem_hotplug_begin();
 
+	/*
+	 * Add new range to memblock so that when hotadd_new_pgdat() is called to
+	 * allocate new pgdat, get_pfn_range_for_nid() will be able to find this
+	 * new range and calculate total pages correctly. The range will be remove
+	 * at hot-remove time.
+	 */
+	memblock_add_node(start, size, nid);
+
 	new_node = !node_online(nid);
 	if (new_node) {
 		pgdat = hotadd_new_pgdat(nid, start);
@@ -1277,7 +1285,6 @@ int __ref add_memory(int nid, u64 start, u64 size)
 
 	/* create new memmap entry */
 	firmware_map_add_hotplug(start, start + size, "System RAM");
-	memblock_add_node(start, size, nid);
 
 	goto out;
 
@@ -1286,6 +1293,7 @@ error:
 	if (new_pgdat)
 		rollback_node_hotadd(nid, pgdat);
 	release_memory_resource(res);
+	memblock_remove(start, size);
 
 out:
 	mem_hotplug_done();
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
