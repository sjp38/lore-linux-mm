Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2523A6B000A
	for <linux-mm@kvack.org>; Mon,  7 May 2018 22:33:08 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id x2-v6so23004021qto.10
        for <linux-mm@kvack.org>; Mon, 07 May 2018 19:33:08 -0700 (PDT)
Received: from mail1.bemta8.messagelabs.com (mail1.bemta8.messagelabs.com. [216.82.243.201])
        by mx.google.com with ESMTPS id o14-v6si3167070qto.293.2018.05.07.19.33.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 May 2018 19:33:07 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: [External]  [RFC PATCH v1 2/6] mm/page_alloc.c: get pfn range with
 flags of memblock
Date: Tue, 8 May 2018 02:32:47 +0000
Message-ID: <HK2PR03MB1684A17E526A6E93444D871E929A0@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1525746628-114136-1-git-send-email-yehs1@lenovo.com>
 <1525746628-114136-3-git-send-email-yehs1@lenovo.com>
In-Reply-To: <1525746628-114136-3-git-send-email-yehs1@lenovo.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "willy@infradead.org" <willy@infradead.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "penguin-kernel@I-love.SAKURA.ne.jp" <penguin-kernel@I-love.SAKURA.ne.jp>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, Ocean HY1 He <hehy1@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

This is used to expand the interface of get_pfn_range_for_nid with
flags of memblock, so mm can get pfn range with special flags.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Signed-off-by: Ocean He <hehy1@lenovo.com>
---
 include/linux/mm.h |  4 ++++
 mm/page_alloc.c    | 17 ++++++++++++++++-
 2 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad06d42..8abf9c9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2046,6 +2046,10 @@ extern unsigned long absent_pages_in_range(unsigned =
long start_pfn,
 						unsigned long end_pfn);
 extern void get_pfn_range_for_nid(unsigned int nid,
 			unsigned long *start_pfn, unsigned long *end_pfn);
+extern void get_pfn_range_for_nid_with_flags(unsigned int nid,
+					     unsigned long *start_pfn,
+					     unsigned long *end_pfn,
+					     unsigned long flags);
 extern unsigned long find_min_pfn_with_active_regions(void);
 extern void free_bootmem_with_active_regions(int nid,
 						unsigned long max_low_pfn);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1741dd2..266c065 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5705,13 +5705,28 @@ void __init sparse_memory_present_with_active_regio=
ns(int nid)
 void __meminit get_pfn_range_for_nid(unsigned int nid,
 			unsigned long *start_pfn, unsigned long *end_pfn)
 {
+	get_pfn_range_for_nid_with_flags(nid, start_pfn, end_pfn,
+					 MEMBLOCK_MAX_TYPE);
+}
+
+/*
+ * If MAX_NUMNODES, includes all node memmory regions.
+ * If MEMBLOCK_MAX_TYPE, includes all memory regions with or without Flags=
.
+ */
+
+void __meminit get_pfn_range_for_nid_with_flags(unsigned int nid,
+						unsigned long *start_pfn,
+						unsigned long *end_pfn,
+						unsigned long flags)
+{
 	unsigned long this_start_pfn, this_end_pfn;
 	int i;
=20
 	*start_pfn =3D -1UL;
 	*end_pfn =3D 0;
=20
-	for_each_mem_pfn_range(i, nid, &this_start_pfn, &this_end_pfn, NULL) {
+	for_each_mem_pfn_range_with_flags(i, nid, &this_start_pfn,
+					  &this_end_pfn, NULL, flags) {
 		*start_pfn =3D min(*start_pfn, this_start_pfn);
 		*end_pfn =3D max(*end_pfn, this_end_pfn);
 	}
--=20
1.8.3.1
