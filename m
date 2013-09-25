Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 085986B006E
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:22:32 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so318290pde.24
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:22:32 -0700 (PDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 04:52:27 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id DD4EE394003F
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:52:09 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNOf5046661842
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:54:41 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNMOX1015618
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:52:24 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 19/40] mm: Provide a mechanism to release free memory
 to the region allocator
Date: Thu, 26 Sep 2013 04:48:18 +0530
Message-ID: <20130925231816.26184.98910.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Implement helper functions to release freepages from the buddy freelists to
the region allocator.

For simplicity, all operations related to the region allocator are performed
at the granularity of entire memory regions. That is, when we release freepages
to the region allocator, we free all the pages belonging to that region.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d96746e..c727bba 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -919,6 +919,26 @@ static void move_page_freelist(struct page *page, struct free_list *old_list,
 	add_to_freelist(page, new_list, order);
 }
 
+/* Add pages from the given buddy freelist to the region allocator */
+static void add_to_region_allocator(struct zone *z, struct free_list *free_list,
+				    int region_id)
+{
+	struct region_allocator *reg_alloc;
+	struct list_head *ralloc_list;
+	int order;
+
+	if (WARN_ON(list_empty(&free_list->list)))
+		return;
+
+	order = page_order(list_first_entry(&free_list->list,
+					    struct page, lru));
+
+	reg_alloc = &z->region_allocator;
+	ralloc_list = &reg_alloc->region[region_id].region_area[order].list;
+
+	del_from_freelist_bulk(ralloc_list, free_list, order, region_id);
+}
+
 /*
  * Freeing function for a buddy system allocator.
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
