Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EEE9E6B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 07:43:51 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so67212031wmw.2
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 04:43:51 -0700 (PDT)
Received: from forward-corp1o.mail.yandex.net (forward-corp1o.mail.yandex.net. [2a02:6b8:0:1a2d::1010])
        by mx.google.com with ESMTPS id i1si20557597lba.71.2016.04.18.04.43.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Apr 2016 04:43:50 -0700 (PDT)
Subject: [PATCH] mm/memory-failure: fix race with compound page split/merge
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Mon, 18 Apr 2016 14:43:45 +0300
Message-ID: <146097982568.15733.13924990169211134049.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Get_hwpoison_page() must recheck relation between head and tail pages.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/memory-failure.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 78f5f2641b91..ca5acee53b7a 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -888,7 +888,15 @@ int get_hwpoison_page(struct page *page)
 		}
 	}
 
-	return get_page_unless_zero(head);
+	if (get_page_unless_zero(head)) {
+		if (head == compound_head(page))
+			return 1;
+
+		pr_info("MCE: %#lx cannot catch tail\n", page_to_pfn(page));
+		put_page(head);
+	}
+
+	return 0;
 }
 EXPORT_SYMBOL_GPL(get_hwpoison_page);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
