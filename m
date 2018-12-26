Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A161B8E0002
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:06 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id j8so14043738plb.1
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:06 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r12si1487152plo.59.2018.12.26.05.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:05 -0800 (PST)
Message-Id: <20181226133351.229014333@intel.com>
Date: Wed, 26 Dec 2018 21:14:49 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 03/21] x86/numa_emulation: fix fake NUMA in uniform case
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=fix-fake-numa.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Fan Du <fan.du@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Fengguang Wu <fengguang.wu@intel.com>

From: Fan Du <fan.du@intel.com>

The index of numa_meminfo is expected to the same as of numa_meminfo.blk[].
and numa_remove_memblk_from break the expectation.

2S system does not break, because

before numa_remove_memblk_from
index  nid
0	0
1	1

after numa_remove_memblk_from

index  nid
0	1
1	1

If you try to configure uniform fake node in 4S system.
index  nid
0	0
1	1
2       2
3	3

node 3 will be removed by numa_remove_memblk_from when iterate index 2.
so we only create fake node for 3 physcial node, and a portion of memroy
wasted as much as it hit lost pages checking in numa_meminfo_cover_memory.

Signed-off-by: Fan Du <fan.du@intel.com>

---
 arch/x86/mm/numa_emulation.c |   16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

--- linux.orig/arch/x86/mm/numa_emulation.c	2018-12-23 19:20:51.570664269 +0800
+++ linux/arch/x86/mm/numa_emulation.c	2018-12-23 19:20:51.566664364 +0800
@@ -381,7 +381,21 @@ void __init numa_emulation(struct numa_m
 		goto no_emu;
 
 	memset(&ei, 0, sizeof(ei));
-	pi = *numa_meminfo;
+
+	{
+		/* Make sure the index is identical with nid */
+		struct numa_meminfo *mi = numa_meminfo;
+		int nid;
+
+		for (i = 0; i < mi->nr_blks; i++) {
+			nid = mi->blk[i].nid;
+			pi.blk[nid].nid = nid;
+			pi.blk[nid].start = mi->blk[i].start;
+			pi.blk[nid].end = mi->blk[i].end;
+		}
+		pi.nr_blks = mi->nr_blks;
+
+	}
 
 	for (i = 0; i < MAX_NUMNODES; i++)
 		emu_nid_to_phys[i] = NUMA_NO_NODE;
