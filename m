Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0A3556B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 14:51:07 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id n129so5948549oia.6
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 11:51:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y4si4701119oig.7.2017.10.02.11.51.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 11:51:06 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH] mm/migrate: fix indexing bug (off by one) and avoid out of bound access
Date: Mon,  2 Oct 2017 15:45:25 -0400
Message-Id: <1506973525-16491-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Mark Hairgrove <mhairgrove@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

From: Mark Hairgrove <mhairgrove@nvidia.com>

Index was incremented before last use and thus the second array
could dereference to an invalid address (not mentioning the fact
that it did not properly clear the entry we intended to clear).

Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/migrate.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 6954c14..e00814c 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2146,8 +2146,9 @@ static int migrate_vma_collect_hole(unsigned long start,
 	unsigned long addr;
 
 	for (addr = start & PAGE_MASK; addr < end; addr += PAGE_SIZE) {
-		migrate->src[migrate->npages++] = MIGRATE_PFN_MIGRATE;
+		migrate->src[migrate->npages] = MIGRATE_PFN_MIGRATE;
 		migrate->dst[migrate->npages] = 0;
+		migrate->npages++;
 		migrate->cpages++;
 	}
 
-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
