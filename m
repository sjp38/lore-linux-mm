Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 643286B025E
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 08:00:25 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u138so9384160wmu.2
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 05:00:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n128sor315958wma.79.2017.10.13.05.00.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Oct 2017 05:00:24 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] mm, page_alloc: fail has_unmovable_pages when seeing reserved pages
Date: Fri, 13 Oct 2017 14:00:13 +0200
Message-Id: <20171013120013.698-2-mhocko@kernel.org>
In-Reply-To: <20171013120013.698-1-mhocko@kernel.org>
References: <20171013115835.zaehapuucuzl2vlv@dhcp22.suse.cz>
 <20171013120013.698-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michael Ellerman <mpe@ellerman.id.au>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Reserved pages should be completely ignored by the core mm because they
have a special meaning for their owners. has_unmovable_pages doesn't
check those so we rely on other tests (reference count, or PageLRU) to
fail on such pages. Althought this happens to work it is safer to simply
check for those explicitly and do not rely on the owner of the page
to abuse those fields for special purposes.

Please note that this is more of a further fortification of the code
rahter than a fix of an existing issue.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ad0294ab3e4f..a8800b0a5619 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7365,6 +7365,9 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 
 		page = pfn_to_page(check);
 
+		if (PageReferenced(page))
+			return true;
+
 		/*
 		 * Hugepages are not in LRU lists, but they're movable.
 		 * We need not scan over tail pages bacause we don't
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
