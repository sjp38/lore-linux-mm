Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E43886B026B
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 21:18:56 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id d125so5935788qkc.22
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 18:18:56 -0800 (PST)
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id g27si11434384qtb.187.2017.11.20.18.18.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Nov 2017 18:18:56 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH] mm: migrate: fix an incorrect call of prep_transhuge_page()
Date: Mon, 20 Nov 2017 21:18:55 -0500
Message-Id: <20171121021855.50525-1-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Andrea Reale <ar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, stable@vger.kernel.org

From: Zi Yan <zi.yan@cs.rutgers.edu>

In [1], Andrea reported that during memory hotplug/hot remove
prep_transhuge_page() is called incorrectly on non-THP pages for
migration, when THP is on but THP migration is not enabled.
This leads to a bad state of target pages for migration.

This patch fixes it by only calling prep_transhuge_page() when we are
certain that the target page is THP.

[1] https://lkml.org/lkml/2017/11/20/411

Cc: stable@vger.kernel.org # v4.14
Fixes: 8135d8926c08 ("mm: memory_hotplug: memory hotremove supports thp migration")
Reported-by: Andrea Reale <ar@linux.vnet.ibm.com>
Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
---
 include/linux/migrate.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 895ec0c4942e..a2246cf670ba 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -54,7 +54,7 @@ static inline struct page *new_page_nodemask(struct page *page,
 	new_page = __alloc_pages_nodemask(gfp_mask, order,
 				preferred_nid, nodemask);
 
-	if (new_page && PageTransHuge(page))
+	if (new_page && PageTransHuge(new_page))
 		prep_transhuge_page(new_page);
 
 	return new_page;
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
