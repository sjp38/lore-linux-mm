Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 38210828E1
	for <linux-mm@kvack.org>; Mon, 30 May 2016 05:15:42 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id h68so47703743lfh.2
        for <linux-mm@kvack.org>; Mon, 30 May 2016 02:15:42 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id v1si9862049wjf.225.2016.05.30.02.15.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 02:15:18 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id q62so20633359wmg.3
        for <linux-mm@kvack.org>; Mon, 30 May 2016 02:15:18 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 15/17] tile: get rid of superfluous __GFP_REPEAT
Date: Mon, 30 May 2016 11:14:57 +0200
Message-Id: <1464599699-30131-16-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464599699-30131-1-git-send-email-mhocko@kernel.org>
References: <1464599699-30131-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org

From: Michal Hocko <mhocko@suse.com>

__GFP_REPEAT has a rather weak semantic but since it has been introduced
around 2.6.12 it has been ignored for low order allocations.

pgtable_alloc_one uses __GFP_REPEAT flag for L2_USER_PGTABLE_ORDER but
the order is either 0 or 3 if L2_KERNEL_PGTABLE_SHIFT for HPAGE_SHIFT.
This means that this flag has never been actually useful here because it
has always been used only for PAGE_ALLOC_COSTLY requests.

Cc: linux-arch@vger.kernel.org
Acked-by: Chris Metcalf <cmetcalf@mellanox.com> [for tile]
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
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
