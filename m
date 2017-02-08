Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3588C6B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 00:42:50 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id ez4so30660751wjd.2
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 21:42:50 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 74si1149274wmi.91.2017.02.07.21.42.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 21:42:49 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v185ZJTd036496
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 00:42:47 -0500
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28fphqxd4g-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 Feb 2017 00:42:47 -0500
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gwshan@linux.vnet.ibm.com>;
	Wed, 8 Feb 2017 15:42:44 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 27C49357805A
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 16:42:43 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v185gZ1h24576006
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 16:42:43 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v185gBUd024537
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 16:42:11 +1100
From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH] mm/page_alloc: Fix nodes for reclaim in fast path
Date: Wed,  8 Feb 2017 16:40:55 +1100
Message-Id: <1486532455-29613-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mgorman@suse.de, akpm@linux-foundation.org, anton@samba.org, mpe@ellerman.id.au, Gavin Shan <gwshan@linux.vnet.ibm.com>, "# v3 . 16+" <stable@vger.kernel.org>

When @node_reclaim_node isn't 0, the page allocator tries to reclaim
pages if the amount of free memory in the zones are below the low
watermark. On Power platform, none of NUMA nodes are scanned for page
reclaim because no nodes match the condition in zone_allows_reclaim().
On Power platform, RECLAIM_DISTANCE is set to 10 which is the distance
of Node-A to Node-A. So the preferred node even won't be scanned for
page reclaim.

   __alloc_pages_nodemask()
   get_page_from_freelist()
      zone_allows_reclaim()

Anton proposed the test code as below:

   # cat alloc.c
      :
   int main(int argc, char *argv[])
   {
	void *p;
	unsigned long size;
	unsigned long start, end;

	start = time(NULL);
	size = strtoul(argv[1], NULL, 0);
	printf("To allocate %ldGB memory\n", size);

	size <<= 30;
	p = malloc(size);
	assert(p);
	memset(p, 0, size);

	end = time(NULL);
	printf("Used time: %ld seconds\n", end - start);
	sleep(3600);
	return 0;
   }

The system I use for testing has two NUMA nodes. Both have 128GB
memory. In below scnario, the page caches on node#0 should be reclaimed
when it encounters pressure to accommodate request of allocation.

   # echo 2 > /proc/sys/vm/zone_reclaim_mode; \
     sync; \
     echo 3 > /proc/sys/vm/drop_caches; \
   # taskset -c 0 cat file.32G > /dev/null; \
     grep FilePages /sys/devices/system/node/node0/meminfo
     Node 0 FilePages:       33619712 kB
   # taskset -c 0 ./alloc 128
   # grep FilePages /sys/devices/system/node/node0/meminfo
     Node 0 FilePages:       33619840 kB
   # grep MemFree /sys/devices/system/node/node0/meminfo
     Node 0 MemFree:          186816 kB

With the patch applied, the pagecache on node-0 is reclaimed when
its free memory is running out. It's the expected behaviour.

   # echo 2 > /proc/sys/vm/zone_reclaim_mode; \
     sync; \
     echo 3 > /proc/sys/vm/drop_caches
   # taskset -c 0 cat file.32G > /dev/null; \
     grep FilePages /sys/devices/system/node/node0/meminfo
     Node 0 FilePages:       33605568 kB
   # taskset -c 0 ./alloc 128
   # grep FilePages /sys/devices/system/node/node0/meminfo
     Node 0 FilePages:        1379520 kB
   # grep MemFree /sys/devices/system/node/node0/meminfo
     Node 0 MemFree:           317120 kB

Fixes: 5f7a75acdb24 ("mm: page_alloc: do not cache reclaim distances")
Cc: <stable@vger.kernel.org> # v3.16+
Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f3e0c69..1a5f665 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2877,7 +2877,7 @@ bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
 #ifdef CONFIG_NUMA
 static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 {
-	return node_distance(zone_to_nid(local_zone), zone_to_nid(zone)) <
+	return node_distance(zone_to_nid(local_zone), zone_to_nid(zone)) <=
 				RECLAIM_DISTANCE;
 }
 #else	/* CONFIG_NUMA */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
