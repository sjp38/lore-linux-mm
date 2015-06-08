Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0368A6B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 02:45:56 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so96707050pdb.1
        for <linux-mm@kvack.org>; Sun, 07 Jun 2015 23:45:55 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id gg2si2629160pbc.85.2015.06.07.23.45.53
        for <linux-mm@kvack.org>;
        Sun, 07 Jun 2015 23:45:54 -0700 (PDT)
From: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
Subject: [PATCH] mm/memory hotplug: print the last vmemmap region at the end of hot add memory
Date: Mon, 8 Jun 2015 14:44:41 +0800
Message-ID: <1433745881-7179-1-git-send-email-zhugh.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, n-horiguchi@ah.jp.nec.com, zhenzhang.zhang@huawei.com, wangnan0@huawei.com, fabf@skynet.be, Zhu Guihua <zhugh.fnst@cn.fujitsu.com>

When hot add two nodes continuously, we found the vmemmap region info is a
bit messed. The last region of node 2 is printed when node 3 hot added,
like the following:
Initmem setup node 2 [mem 0x0000000000000000-0xffffffffffffffff]
 On node 2 totalpages: 0
 Built 2 zonelists in Node order, mobility grouping on.  Total pages: 16090539
 Policy zone: Normal
 init_memory_mapping: [mem 0x40000000000-0x407ffffffff]
  [mem 0x40000000000-0x407ffffffff] page 1G
  [ffffea1000000000-ffffea10001fffff] PMD -> [ffff8a077d800000-ffff8a077d9fffff] on node 2
  [ffffea1000200000-ffffea10003fffff] PMD -> [ffff8a077de00000-ffff8a077dffffff] on node 2
...
  [ffffea101f600000-ffffea101f9fffff] PMD -> [ffff8a074ac00000-ffff8a074affffff] on node 2
  [ffffea101fa00000-ffffea101fdfffff] PMD -> [ffff8a074a800000-ffff8a074abfffff] on node 2
Initmem setup node 3 [mem 0x0000000000000000-0xffffffffffffffff]
 On node 3 totalpages: 0
 Built 3 zonelists in Node order, mobility grouping on.  Total pages: 16090539
 Policy zone: Normal
 init_memory_mapping: [mem 0x60000000000-0x607ffffffff]
  [mem 0x60000000000-0x607ffffffff] page 1G
  [ffffea101fe00000-ffffea101fffffff] PMD -> [ffff8a074a400000-ffff8a074a5fffff] on node 2 <=== node 2 ???
  [ffffea1800000000-ffffea18001fffff] PMD -> [ffff8a074a600000-ffff8a074a7fffff] on node 3
  [ffffea1800200000-ffffea18005fffff] PMD -> [ffff8a074a000000-ffff8a074a3fffff] on node 3
  [ffffea1800600000-ffffea18009fffff] PMD -> [ffff8a0749c00000-ffff8a0749ffffff] on node 3
...

The cause is the last region was missed at the and of hot add memory, and
p_start, p_end, node_start were not reset, so when hot add memory to a new
node, it will consider they are not contiguous blocks and print the
previous one. So we print the last vmemmap region at the end of hot add
memory to avoid the confusion.

Signed-off-by: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
---
 mm/memory_hotplug.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 457bde5..58fb223 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -513,6 +513,7 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
 			break;
 		err = 0;
 	}
+	vmemmap_populate_print_last();
 
 	return err;
 }
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
