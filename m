Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id AEECC6B0034
	for <linux-mm@kvack.org>; Thu, 30 May 2013 14:50:12 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 30 May 2013 14:50:11 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id B6A176E805F
	for <linux-mm@kvack.org>; Thu, 30 May 2013 14:50:05 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4UIo86f44695730
	for <linux-mm@kvack.org>; Thu, 30 May 2013 14:50:09 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4UInu7o008171
	for <linux-mm@kvack.org>; Thu, 30 May 2013 12:49:56 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH] sparsemem: BUILD_BUG_ON when sizeof mem_section is non-power-of-2
Date: Thu, 30 May 2013 11:40:48 -0700
Message-Id: <1369939248-10006-1-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <51A78EC4.4080703@intel.com>
References: <51A78EC4.4080703@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, David Hansen <dave.hansen@intel.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Instead of leaving a hidden trap for the next person who comes along and
wants to add something to mem_section, add a big fat warning about it
needing to be a power-of-2, and insert a BUILD_BUG_ON() in sparse_init()
to catch mistakes.

Right now non-power-of-2 mem_sections cause a number of WARNs at boot
(which don't clearly point to the size of mem_section as an issue), but
the system limps on (temporarily, at least).

This is based upon Dave Hansen's earlier RFC where he ran into the same
issue:
	"sparsemem: fix boot when SECTIONS_PER_ROOT is not power-of-2"
	http://lkml.indiana.edu/hypermail/linux/kernel/1205.2/03077.html

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---

Dave: Consider it resurrected.

---

 include/linux/mmzone.h | 4 ++++
 mm/sparse.c            | 3 +++
 2 files changed, 7 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 131989a..88e23f3 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1127,6 +1127,10 @@ struct mem_section {
 	struct page_cgroup *page_cgroup;
 	unsigned long pad;
 #endif
+	/*
+	 * WARNING: mem_section must be a power-of-2 in size for the
+	 * calculation and use of SECTION_ROOT_MASK to make sense.
+	 */
 };
 
 #ifdef CONFIG_SPARSEMEM_EXTREME
diff --git a/mm/sparse.c b/mm/sparse.c
index 1c91f0d3..3194ec4 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -481,6 +481,9 @@ void __init sparse_init(void)
 	struct page **map_map;
 #endif
 
+	/* see include/linux/mmzone.h 'struct mem_section' definition */
+	BUILD_BUG_ON(!is_power_of_2(sizeof(struct mem_section)));
+
 	/* Setup pageblock_order for HUGETLB_PAGE_SIZE_VARIABLE */
 	set_pageblock_order();
 
-- 
1.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
