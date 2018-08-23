Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3136B2A31
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 09:08:06 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d22-v6so3198543pfn.3
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 06:08:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g12-v6sor250853pgr.8.2018.08.23.06.08.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Aug 2018 06:08:05 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 1/3] mm/sparse: add likely to mem_section[root] check in sparse_index_init()
Date: Thu, 23 Aug 2018 21:07:30 +0800
Message-Id: <20180823130732.9489-2-richard.weiyang@gmail.com>
In-Reply-To: <20180823130732.9489-1-richard.weiyang@gmail.com>
References: <20180823130732.9489-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, bob.picco@hp.com, Wei Yang <richard.weiyang@gmail.com>

Each time SECTIONS_PER_ROOT number of mem_section is allocated when
mem_section[root] is null. This means only (1 / SECTIONS_PER_ROOT) chance
of the mem_section[root] check is false.

This patch adds likely to the if check to optimize this a little.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/sparse.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 10b07eea9a6e..90bab7f03757 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -78,7 +78,7 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
 	unsigned long root = SECTION_NR_TO_ROOT(section_nr);
 	struct mem_section *section;
 
-	if (mem_section[root])
+	if (likely(mem_section[root]))
 		return -EEXIST;
 
 	section = sparse_index_alloc(nid);
-- 
2.15.1
