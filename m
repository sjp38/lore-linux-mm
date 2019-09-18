Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D1CFC4CED3
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 04:23:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDDE9214AF
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 04:23:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDDE9214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38AE26B0277; Wed, 18 Sep 2019 00:23:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33BAD6B0278; Wed, 18 Sep 2019 00:23:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 251756B0279; Wed, 18 Sep 2019 00:23:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0062.hostedemail.com [216.40.44.62])
	by kanga.kvack.org (Postfix) with ESMTP id F2A376B0277
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 00:23:03 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id A924D180AD805
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 04:23:03 +0000 (UTC)
X-FDA: 75946746246.30.ducks36_5458b0ff41908
X-HE-Tag: ducks36_5458b0ff41908
X-Filterd-Recvd-Size: 4233
Received: from huawei.com (szxga06-in.huawei.com [45.249.212.32])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 04:22:59 +0000 (UTC)
Received: from DGGEMS408-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id C9E0C158DB4B75F7F103;
	Wed, 18 Sep 2019 12:22:41 +0800 (CST)
Received: from [127.0.0.1] (10.177.251.225) by DGGEMS408-HUB.china.huawei.com
 (10.3.19.208) with Microsoft SMTP Server id 14.3.439.0; Wed, 18 Sep 2019
 12:22:36 +0800
To: <rppt@linux.ibm.com>, <akpm@linux-foundation.org>, <osalvador@suse.de>,
	<mhocko@suse.co>, <dan.j.williams@intel.com>, <rppt@linux.ibm.com>,
	<david@redhat.com>, <richardw.yang@linux.intel.com>, <cai@lca.pw>
From: Yunfeng Ye <yeyunfeng@huawei.com>
Subject: [PATCH] mm: Support memblock alloc on the exact node for
 sparse_buffer_init()
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
Message-ID: <af88d8ab-4088-e857-575f-9be57542e130@huawei.com>
Date: Wed, 18 Sep 2019 12:22:29 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.251.225]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, when memblock_find_in_range_node() fail on the exact node, it
will use %NUMA_NO_NODE to find memblock from other nodes. At present,
the work is good, but when the large memory is insufficient and the
small memory is enough, we want to allocate the small memory of this
node first, and do not need to allocate large memory from other nodes.

In sparse_buffer_init(), it will prepare large chunks of memory for page
structure. The page management structure requires a lot of memory, but
if the node does not have enough memory, it can be converted to a small
memory allocation without having to allocate it from other nodes.

Add %MEMBLOCK_ALLOC_EXACT_NODE flag for this situation. Normally, the
behavior is the same with %MEMBLOCK_ALLOC_ACCESSIBLE, only that it will
not allocate from other nodes when a single node fails to allocate.

If large contiguous block memory allocated fail in sparse_buffer_init(),
it will allocates small block memmory section by section later.

Signed-off-by: Yunfeng Ye <yeyunfeng@huawei.com>
---
 include/linux/memblock.h | 1 +
 mm/memblock.c            | 3 ++-
 mm/sparse.c              | 2 +-
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index f491690..9a81d9c 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -339,6 +339,7 @@ static inline int memblock_get_region_node(const struct memblock_region *r)
 #define MEMBLOCK_ALLOC_ANYWHERE	(~(phys_addr_t)0)
 #define MEMBLOCK_ALLOC_ACCESSIBLE	0
 #define MEMBLOCK_ALLOC_KASAN		1
+#define MEMBLOCK_ALLOC_EXACT_NODE	2

 /* We are using top down, so it is safe to use 0 here */
 #define MEMBLOCK_LOW_LIMIT 0
diff --git a/mm/memblock.c b/mm/memblock.c
index 7d4f61a..dbd52c3c 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -277,6 +277,7 @@ static phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,

 	/* pump up @end */
 	if (end == MEMBLOCK_ALLOC_ACCESSIBLE ||
+	    end == MEMBLOCK_ALLOC_EXACT_NODE ||
 	    end == MEMBLOCK_ALLOC_KASAN)
 		end = memblock.current_limit;

@@ -1365,7 +1366,7 @@ static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
 	if (found && !memblock_reserve(found, size))
 		goto done;

-	if (nid != NUMA_NO_NODE) {
+	if (end != MEMBLOCK_ALLOC_EXACT_NODE && nid != NUMA_NO_NODE) {
 		found = memblock_find_in_range_node(size, align, start,
 						    end, NUMA_NO_NODE,
 						    flags);
diff --git a/mm/sparse.c b/mm/sparse.c
index 72f010d..828db46 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -477,7 +477,7 @@ static void __init sparse_buffer_init(unsigned long size, int nid)
 	sparsemap_buf =
 		memblock_alloc_try_nid_raw(size, PAGE_SIZE,
 						addr,
-						MEMBLOCK_ALLOC_ACCESSIBLE, nid);
+						MEMBLOCK_ALLOC_EXACT_NODE, nid);
 	sparsemap_buf_end = sparsemap_buf + size;
 }

-- 
2.7.4.huawei.3



