Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 29A0E6B0039
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:21:10 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 07:21:09 -0600
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 20B1FC90048
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:20:53 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp22034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UDKqfS35455224
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 13:20:53 GMT
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7UDKp4v020129
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:20:52 -0400
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 10/35] mm: Use the correct migratetype during buddy
 merging
Date: Fri, 30 Aug 2013 18:46:56 +0530
Message-ID: <20130830131654.4947.85409.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
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
index b4b1275..07ac019 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -681,10 +681,14 @@ static inline void __free_one_page(struct page *page,
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
