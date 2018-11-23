Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7C5596B2FE0
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 02:22:12 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id k3-v6so10313340ioq.8
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 23:22:12 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id v8si12406189iol.153.2018.11.22.23.22.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 23:22:11 -0800 (PST)
Date: Fri, 23 Nov 2018 10:21:35 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH] mm: debug: Fix a width vs precision bug in printk
Message-ID: <20181123072135.gqvblm2vdujbvfjs@kili.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

We had intended to only print dentry->d_name.len characters but there is
a width vs precision typo so if the name isn't NUL terminated it will
read past the end of the buffer.

Fixes: 408ddbc22be3 ("mm: print more information about mapping in __dump_page")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 mm/debug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/debug.c b/mm/debug.c
index d18c5cea3320..faf856b652b6 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -80,7 +80,7 @@ void __dump_page(struct page *page, const char *reason)
 		if (mapping->host->i_dentry.first) {
 			struct dentry *dentry;
 			dentry = container_of(mapping->host->i_dentry.first, struct dentry, d_u.d_alias);
-			pr_warn("name:\"%*s\" ", dentry->d_name.len, dentry->d_name.name);
+			pr_warn("name:\"%.*s\" ", dentry->d_name.len, dentry->d_name.name);
 		}
 	}
 	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) != __NR_PAGEFLAGS + 1);
-- 
2.11.0
