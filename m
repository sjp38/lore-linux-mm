Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9672E6B000E
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 23:31:23 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id x81so5682596pgx.21
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 20:31:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h2-v6sor3358448plr.151.2018.03.29.20.31.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 29 Mar 2018 20:31:22 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm/memblock: fix potential issue in memblock_search_pfn_nid()
Date: Fri, 30 Mar 2018 11:30:55 +0800
Message-Id: <20180330033055.22340-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, yinghai@kernel.org
Cc: linux-mm@kvack.org, hejianet@gmail.com, Wei Yang <richard.weiyang@gmail.com>, "3 . 12+" <stable@vger.kernel.org>

memblock_search_pfn_nid() returns the nid and the [start|end]_pfn of the
memory region where pfn sits in. While the calculation of start_pfn has
potential issue when the regions base is not page aligned.

For example, we assume PAGE_SHIFT is 12 and base is 0x1234. Current
implementation would return 1 while this is not correct.

This patch fixes this by using PFN_UP().

The original commit is commit e76b63f80d93 ("memblock, numa: binary search
node id") and merged in v3.12.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
Cc: 3.12+ <stable@vger.kernel.org>

---
* add He Jia in cc
* fix the mm mail list address
* Cc: 3.12+

---
 mm/memblock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index b6ba6b7adadc..de768307696d 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1673,7 +1673,7 @@ int __init_memblock memblock_search_pfn_nid(unsigned long pfn,
 	if (mid == -1)
 		return -1;
 
-	*start_pfn = PFN_DOWN(type->regions[mid].base);
+	*start_pfn = PFN_UP(type->regions[mid].base);
 	*end_pfn = PFN_DOWN(type->regions[mid].base + type->regions[mid].size);
 
 	return type->regions[mid].nid;
-- 
2.15.1
