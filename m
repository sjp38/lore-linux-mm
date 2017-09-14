Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8FBAD6B0033
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 15:00:23 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id o200so1801453itg.2
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 12:00:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t193si10699357oif.93.2017.09.14.12.00.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Sep 2017 12:00:17 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH] mm/memcg: avoid page count check for zone device
Date: Thu, 14 Sep 2017 15:00:11 -0400
Message-Id: <20170914190011.5217-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Fix for 4.14, zone device page always have an elevated refcount
of one and thus page count sanity check in uncharge_page() is
inappropriate for them.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Reported-by: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
---
 mm/memcontrol.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 15af3da5af02..d51d3e1f49c9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5648,7 +5648,8 @@ static void uncharge_batch(const struct uncharge_gather *ug)
 static void uncharge_page(struct page *page, struct uncharge_gather *ug)
 {
 	VM_BUG_ON_PAGE(PageLRU(page), page);
-	VM_BUG_ON_PAGE(!PageHWPoison(page) && page_count(page), page);
+	VM_BUG_ON_PAGE(!PageHWPoison(page) && !is_zone_device_page(page) &&
+			page_count(page), page);
 
 	if (!page->mem_cgroup)
 		return;
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
