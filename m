Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 923418E000C
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id t72so17766609pfi.21
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id p11si31508288plk.191.2018.12.26.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
Message-Id: <20181226133351.579378360@intel.com>
Date: Wed, 26 Dec 2018 21:14:55 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 09/21] mm: avoid duplicate peer target node
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0020-page_alloc-avoid-duplicate-peer-target-node.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Fengguang Wu <fengguang.wu@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

To ensure 1:1 peer node mapping on broken BIOS

	node distances:
	node   0   1   2   3
	  0:  10  21  20  20
	  1:  21  10  20  20
	  2:  20  20  10  20
	  3:  20  20  20  10

or with numa=fake=4U

	node distances:
	node   0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15
	  0:  10  10  10  10  21  21  21  21  17  17  17  17  28  28  28  28
	  1:  10  10  10  10  21  21  21  21  17  17  17  17  28  28  28  28
	  2:  10  10  10  10  21  21  21  21  17  17  17  17  28  28  28  28
	  3:  10  10  10  10  21  21  21  21  17  17  17  17  28  28  28  28
	  4:  21  21  21  21  10  10  10  10  28  28  28  28  17  17  17  17
	  5:  21  21  21  21  10  10  10  10  28  28  28  28  17  17  17  17
	  6:  21  21  21  21  10  10  10  10  28  28  28  28  17  17  17  17
	  7:  21  21  21  21  10  10  10  10  28  28  28  28  17  17  17  17
	  8:  17  17  17  17  28  28  28  28  10  10  10  10  28  28  28  28
	  9:  17  17  17  17  28  28  28  28  10  10  10  10  28  28  28  28
	 10:  17  17  17  17  28  28  28  28  10  10  10  10  28  28  28  28
	 11:  17  17  17  17  28  28  28  28  10  10  10  10  28  28  28  28
	 12:  28  28  28  28  17  17  17  17  28  28  28  28  10  10  10  10
	 13:  28  28  28  28  17  17  17  17  28  28  28  28  10  10  10  10
	 14:  28  28  28  28  17  17  17  17  28  28  28  28  10  10  10  10
	 15:  28  28  28  28  17  17  17  17  28  28  28  28  10  10  10  10

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 mm/page_alloc.c |    6 ++++++
 1 file changed, 6 insertions(+)

--- linux.orig/mm/page_alloc.c	2018-12-23 19:48:27.366110325 +0800
+++ linux/mm/page_alloc.c	2018-12-23 19:48:27.362110332 +0800
@@ -6941,16 +6941,22 @@ static int find_best_peer_node(int nid)
 	int n, val;
 	int min_val = INT_MAX;
 	int peer = NUMA_NO_NODE;
+	static nodemask_t target_nodes = NODE_MASK_NONE;
 
 	for_each_online_node(n) {
 		if (n == nid)
 			continue;
 		val = node_distance(nid, n);
+		if (val == LOCAL_DISTANCE)
+			continue;
+		if (node_isset(n, target_nodes))
+			continue;
 		if (val < min_val) {
 			min_val = val;
 			peer = n;
 		}
 	}
+	node_set(peer, target_nodes);
 	return peer;
 }
 
