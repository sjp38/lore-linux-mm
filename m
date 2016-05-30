Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 313F66B025F
	for <linux-mm@kvack.org>; Mon, 30 May 2016 05:22:07 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f75so26497672wmf.2
        for <linux-mm@kvack.org>; Mon, 30 May 2016 02:22:07 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id a138si29703879wmd.114.2016.05.30.02.15.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 02:15:19 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id q62so20633496wmg.3
        for <linux-mm@kvack.org>; Mon, 30 May 2016 02:15:19 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 16/17] unicore32: get rid of superfluous __GFP_REPEAT
Date: Mon, 30 May 2016 11:14:58 +0200
Message-Id: <1464599699-30131-17-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464599699-30131-1-git-send-email-mhocko@kernel.org>
References: <1464599699-30131-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-arch@vger.kernel.org

From: Michal Hocko <mhocko@suse.com>

__GFP_REPEAT has a rather weak semantic but since it has been introduced
around 2.6.12 it has been ignored for low order allocations.

PGALLOC_GFP uses __GFP_REPEAT but it is only used in pte_alloc_one,
pte_alloc_one_kernel which does order-0 request.  This means that this
flag has never been actually useful here because it has always been used
only for PAGE_ALLOC_COSTLY requests.

Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
Cc: linux-arch@vger.kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/unicore32/include/asm/pgalloc.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/unicore32/include/asm/pgalloc.h b/arch/unicore32/include/asm/pgalloc.h
index 2e02d1356fdf..26775793c204 100644
--- a/arch/unicore32/include/asm/pgalloc.h
+++ b/arch/unicore32/include/asm/pgalloc.h
@@ -28,7 +28,7 @@ extern void free_pgd_slow(struct mm_struct *mm, pgd_t *pgd);
 #define pgd_alloc(mm)			get_pgd_slow(mm)
 #define pgd_free(mm, pgd)		free_pgd_slow(mm, pgd)
 
-#define PGALLOC_GFP	(GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO)
+#define PGALLOC_GFP	(GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO)
 
 /*
  * Allocate one PTE table.
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
