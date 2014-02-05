Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 44B486B003C
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 19:02:43 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id un15so9099529pbc.18
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 16:02:42 -0800 (PST)
Received: from mail-pb0-x230.google.com (mail-pb0-x230.google.com [2607:f8b0:400e:c01::230])
        by mx.google.com with ESMTPS id fb4si2036725pbb.292.2014.02.04.16.02.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 16:02:42 -0800 (PST)
Received: by mail-pb0-f48.google.com with SMTP id rr13so9112748pbb.21
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 16:02:42 -0800 (PST)
Date: Tue, 4 Feb 2014 16:02:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, page_alloc: make first_page visible before PageTail
In-Reply-To: <alpine.LRH.2.02.1402040713220.13901@diagnostix.dwd.de>
Message-ID: <alpine.DEB.2.02.1402041557380.10140@chino.kir.corp.google.com>
References: <alpine.LRH.2.02.1401312037340.6630@diagnostix.dwd.de> <20140203122052.GC2495@dhcp22.suse.cz> <alpine.LRH.2.02.1402031426510.13382@diagnostix.dwd.de> <20140203162036.GJ2495@dhcp22.suse.cz> <52EFC93D.3030106@suse.cz>
 <alpine.DEB.2.02.1402031602060.10778@chino.kir.corp.google.com> <alpine.LRH.2.02.1402040713220.13901@diagnostix.dwd.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Holger Kiehl <Holger.Kiehl@dwd.de>
Cc: Christoph Lameter <cl@linux.com>, Rafael Aquini <aquini@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Commit bf6bddf1924e ("mm: introduce compaction and migration for ballooned 
pages") introduces page_count(page) into memory compaction which 
dereferences page->first_page if PageTail(page).

Introduce a store memory barrier to ensure page->first_page is properly 
initialized so that code that does page_count(page) on pages off the lru 
always have a valid p->first_page.

Reported-by: Holger Kiehl <Holger.Kiehl@dwd.de>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -369,9 +369,10 @@ void prep_compound_page(struct page *page, unsigned long order)
 	__SetPageHead(page);
 	for (i = 1; i < nr_pages; i++) {
 		struct page *p = page + i;
-		__SetPageTail(p);
 		set_page_count(p, 0);
 		p->first_page = page;
+		smp_wmb();
+		__SetPageTail(p);
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
