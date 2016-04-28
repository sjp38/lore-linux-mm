Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id B3FAA6B0271
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 09:24:46 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id j8so64594348lfd.0
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 06:24:46 -0700 (PDT)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id f142si37211561wmf.54.2016.04.28.06.24.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 06:24:23 -0700 (PDT)
Received: by mail-wm0-f53.google.com with SMTP id n129so65340640wmn.1
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 06:24:23 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 15/20] tile: get rid of superfluous __GFP_REPEAT
Date: Thu, 28 Apr 2016 15:24:01 +0200
Message-Id: <1461849846-27209-16-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461849846-27209-1-git-send-email-mhocko@kernel.org>
References: <1461849846-27209-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Chris Metcalf <cmetcalf@mellanox.com>, linux-arch@vger.kernel.org

From: Michal Hocko <mhocko@suse.com>

__GFP_REPEAT has a rather weak semantic but since it has been introduced
around 2.6.12 it has been ignored for low order allocations.

pgtable_alloc_one uses __GFP_REPEAT flag for L2_USER_PGTABLE_ORDER but
the order is either 0 or 3 if L2_KERNEL_PGTABLE_SHIFT for HPAGE_SHIFT.
This means that this flag has never been actually useful here because it
has always been used only for PAGE_ALLOC_COSTLY requests.

Cc: Chris Metcalf <cmetcalf@mellanox.com>
Cc: linux-arch@vger.kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/tile/mm/pgtable.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
index 7bf2491a9c1f..c4d5bf841a7f 100644
--- a/arch/tile/mm/pgtable.c
+++ b/arch/tile/mm/pgtable.c
@@ -231,7 +231,7 @@ void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 struct page *pgtable_alloc_one(struct mm_struct *mm, unsigned long address,
 			       int order)
 {
-	gfp_t flags = GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO;
+	gfp_t flags = GFP_KERNEL|__GFP_ZERO;
 	struct page *p;
 	int i;
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
