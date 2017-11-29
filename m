Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A8E256B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 04:40:12 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id n13so1154593wmc.3
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 01:40:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k60si1508404edc.530.2017.11.29.01.40.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Nov 2017 01:40:11 -0800 (PST)
Date: Wed, 29 Nov 2017 10:40:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 2/2] mm, hugetlb: do not rely on overcommit limit
 during migration
Message-ID: <20171129094010.ycf23oibkdq6cggq@dhcp22.suse.cz>
References: <20171128101907.jtjthykeuefxu7gl@dhcp22.suse.cz>
 <20171128141211.11117-1-mhocko@kernel.org>
 <20171128141211.11117-3-mhocko@kernel.org>
 <20171129092234.eluli2gl7gotj35x@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171129092234.eluli2gl7gotj35x@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 29-11-17 10:22:34, Michal Hocko wrote:
> What about this on top. I haven't tested this yet though.
> ---

We will need to drop surplus_huge_pages_node handling from the free path
obviously as well

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 1be43563e226..756833f9ef8b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1312,8 +1312,6 @@ void free_huge_page(struct page *page)
 		list_del(&page->lru);
 		ClearPageHugeTemporary(page);
 		update_and_free_page(h, page);
-		if (h->surplus_huge_pages_node[nid])
-			h->surplus_huge_pages_node[nid]--;
 	} else if (h->surplus_huge_pages_node[nid]) {
 		/* remove the page from active list */
 		list_del(&page->lru);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
