Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 311E96B038B
	for <linux-mm@kvack.org>; Sun,  5 Mar 2017 08:35:40 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id n127so206767363qkf.3
        for <linux-mm@kvack.org>; Sun, 05 Mar 2017 05:35:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l76si13476268qkh.86.2017.03.05.05.35.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Mar 2017 05:35:39 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/3] mm: set mapping error when launder_pages fails
Date: Sun,  5 Mar 2017 08:35:35 -0500
Message-Id: <20170305133535.6516-4-jlayton@redhat.com>
In-Reply-To: <20170305133535.6516-1-jlayton@redhat.com>
References: <20170305133535.6516-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, konishi.ryusuke@lab.ntt.co.jp
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nilfs@vger.kernel.org

If launder_page fails, then we hit a problem writing back some inode
data. Ensure that we communicate that fact in a subsequent fsync since
another task could still have it open for write.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 mm/truncate.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index dd7b24e083c5..49ad4e2a6cb6 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -593,11 +593,15 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 
 static int do_launder_page(struct address_space *mapping, struct page *page)
 {
+	int ret;
+
 	if (!PageDirty(page))
 		return 0;
 	if (page->mapping != mapping || mapping->a_ops->launder_page == NULL)
 		return 0;
-	return mapping->a_ops->launder_page(page);
+	ret = mapping->a_ops->launder_page(page);
+	mapping_set_error(mapping, ret);
+	return ret;
 }
 
 /**
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
