Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 91B716B007E
	for <linux-mm@kvack.org>; Fri,  6 May 2016 11:04:04 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id v81so271319570ywa.1
        for <linux-mm@kvack.org>; Fri, 06 May 2016 08:04:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m128si9770170qkd.253.2016.05.06.08.04.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 May 2016 08:04:03 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/3] mm: thp: microoptimize compound_mapcount()
Date: Fri,  6 May 2016 17:03:59 +0200
Message-Id: <1462547040-1737-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1462547040-1737-1-git-send-email-aarcange@redhat.com>
References: <1462547040-1737-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Alex Williamson <alex.williamson@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

compound_mapcount() is only called after PageCompound() has already
been checked by the caller, so there's no point to check it again. Gcc
may optimize it away too because it's inline but this will remove the
runtime check for sure and add it'll add an assert instead.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mm.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 263f229..726ba80 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -471,8 +471,7 @@ static inline atomic_t *compound_mapcount_ptr(struct page *page)
 
 static inline int compound_mapcount(struct page *page)
 {
-	if (!PageCompound(page))
-		return 0;
+	VM_BUG_ON_PAGE(!PageCompound(page), page);
 	page = compound_head(page);
 	return atomic_read(compound_mapcount_ptr(page)) + 1;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
