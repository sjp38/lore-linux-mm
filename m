Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 335406B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:19:46 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld10so471313pab.22
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:19:45 -0700 (PDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 09:19:41 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 8E3582CE8052
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:19:39 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNJSU29503132
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:19:28 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNJcw6013290
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:19:39 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 08/40] mm: Use the correct migratetype during buddy
 merging
Date: Thu, 26 Sep 2013 04:45:28 +0530
Message-ID: <20130925231526.26184.60112.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

While merging buddy free pages of a given order to make a higher order page,
the buddy allocator might coalesce pages belonging to *two* *different*
migratetypes of that order!

So, don't assume that both the buddies come from the same freelist;
instead, explicitly find out the migratetype info of the buddy page and use
it while merging the buddies.

Also, set the freepage migratetype of the buddy to the new one.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e31daf4..c40715c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -685,10 +685,14 @@ static inline void __free_one_page(struct page *page,
 			__mod_zone_freepage_state(zone, 1 << order,
 						  migratetype);
 		} else {
+			int mt;
+
 			area = &zone->free_area[order];
-			del_from_freelist(buddy, &area->free_list[migratetype]);
+			mt = get_freepage_migratetype(buddy);
+			del_from_freelist(buddy, &area->free_list[mt]);
 			area->nr_free--;
 			rmv_page_order(buddy);
+			set_freepage_migratetype(buddy, migratetype);
 		}
 		combined_idx = buddy_idx & page_idx;
 		page = page + (combined_idx - page_idx);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
