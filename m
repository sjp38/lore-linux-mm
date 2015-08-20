Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id B24B26B0038
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 12:20:08 -0400 (EDT)
Received: by lbcbn3 with SMTP id bn3so27087580lbc.2
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 09:20:07 -0700 (PDT)
Received: from forward-corp1g.mail.yandex.net (forward-corp1g.mail.yandex.net. [95.108.253.251])
        by mx.google.com with ESMTPS id t18si3977399laz.137.2015.08.20.09.20.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 09:20:06 -0700 (PDT)
From: Roman Gushchin <klamm@yandex-team.ru>
Subject: [PATCH] mm/readahead.c: fix regression caused by small readahead limit
Date: Thu, 20 Aug 2015 19:19:58 +0300
Message-Id: <1440087598-27185-1-git-send-email-klamm@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Roman Gushchin <klamm@yandex-team.ru>, Linus Torvalds <torvalds@linux-foundation.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

Effectively reverts: 6d2be915e589b58cb11418cbe1f22ff90732b6ac
("mm/readahead.c: fix readahead failure for memoryless NUMA nodes and
limit readahead pages").

This commit causes significant i/o performance regression on large
RAID disks. Limiting maximal readahead size by 2Mb is not suitable for
this case, alghough previous logic (based on free memory size
on current NUMA node) is much better.

To avoid regression in case of memoryless NUMA we can still use
MAX_READAHEAD constant, if current node has no (or less) free memory.

before:

$ dd if=/dev/md2 of=/dev/null bs=100M count=100
100+0 records in
100+0 records out
10485760000 bytes (10 GB) copied, 12.6441 s, 829 MB/s

$ dd if=/dev/md2 of=/dev/null bs=100M count=100 iflag=direct
100+0 records in
100+0 records out
10485760000 bytes (10 GB) copied, 9.49377 s, 1.1 GB/s

after:

$ dd if=/dev/md2 of=/dev/null bs=100M count=100
100+0 records in
100+0 records out
10485760000 bytes (10 GB) copied, 9.18119 s, 1.1 GB/s

$ dd if=/dev/md2 of=/dev/null bs=100M count=100 iflag=direct
100+0 records in
100+0 records out
10485760000 bytes (10 GB) copied, 9.34751 s, 1.1 GB/s

(It's 8 disks RAID 5 with 1024k chunk.)

Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/readahead.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index 60cd846..93a00b3 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -239,7 +239,12 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
  */
 unsigned long max_sane_readahead(unsigned long nr)
 {
-	return min(nr, MAX_READAHEAD);
+	unsigned long max_sane;
+
+	max_sane = max(MAX_READAHEAD,
+		       (node_page_state(numa_node_id(), NR_INACTIVE_FILE) +
+			node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
+	return min(nr, max_sane);
 }
 
 /*
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
