Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 30C1E280290
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:24:17 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a2so835057pgn.7
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:24:17 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y5si4903049pfl.267.2018.01.17.12.22.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:22:39 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 29/99] page cache: Convert filemap_range_has_page to XArray
Date: Wed, 17 Jan 2018 12:20:53 -0800
Message-Id: <20180117202203.19756-30-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Instead of calling find_get_pages_range() and putting any reference,
just use xa_find() to look for a page in the right range.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/filemap.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 2536fcacb5bc..cd01f353cf6a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -461,18 +461,11 @@ bool filemap_range_has_page(struct address_space *mapping,
 {
 	pgoff_t index = start_byte >> PAGE_SHIFT;
 	pgoff_t end = end_byte >> PAGE_SHIFT;
-	struct page *page;
 
 	if (end_byte < start_byte)
 		return false;
 
-	if (mapping->nrpages == 0)
-		return false;
-
-	if (!find_get_pages_range(mapping, &index, end, 1, &page))
-		return false;
-	put_page(page);
-	return true;
+	return xa_find(&mapping->pages, &index, end, XA_PRESENT);
 }
 EXPORT_SYMBOL(filemap_range_has_page);
 
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
