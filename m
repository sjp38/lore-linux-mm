Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 329266B013E
	for <linux-mm@kvack.org>; Wed, 29 May 2013 19:14:54 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 29 May 2013 19:14:53 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 30EEA6E803F
	for <linux-mm@kvack.org>; Wed, 29 May 2013 19:14:46 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4TNEn8P40501442
	for <linux-mm@kvack.org>; Wed, 29 May 2013 19:14:49 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4TNEn01029792
	for <linux-mm@kvack.org>; Wed, 29 May 2013 19:14:49 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH] mm: sparse: use __aligned() instead of manual padding in mem_section
Date: Wed, 29 May 2013 16:14:39 -0700
Message-Id: <1369869279-20155-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

Instead of leaving a trap for the next person who comes along and wants
to add something to mem_section, add an __aligned() and remove the
manual padding added for MEMCG.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 include/linux/mmzone.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

---

Also, does anyone know what causes this alignment to be required here? I found
this was breaking things in a patchset I'm working on (WARNs in sysfs code
about duplicate filenames when initing mem_sections). Adding some documentation
for the reason would be appreciated.

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 131989a..a8e8056 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1125,9 +1125,8 @@ struct mem_section {
 	 * section. (see memcontrol.h/page_cgroup.h about this.)
 	 */
 	struct page_cgroup *page_cgroup;
-	unsigned long pad;
 #endif
-};
+} __aligned(2 * sizeof(unsigned long));
 
 #ifdef CONFIG_SPARSEMEM_EXTREME
 #define SECTIONS_PER_ROOT       (PAGE_SIZE / sizeof (struct mem_section))
-- 
1.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
