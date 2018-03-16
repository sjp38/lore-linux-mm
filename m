Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 104746B0033
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 16:35:58 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id z83so7339278qka.7
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 13:35:58 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id o184si2407005qkc.403.2018.03.16.13.35.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 13:35:57 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 11/14] mm/hmm: move hmm_pfns_clear() closer to where it is use
Date: Fri, 16 Mar 2018 16:35:49 -0400
Message-Id: <20180316203552.4155-2-jglisse@redhat.com>
In-Reply-To: <20180316203552.4155-1-jglisse@redhat.com>
References: <20180316203552.4155-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Move hmm_pfns_clear() closer to where it is use to make it clear it
is not use by page table walkers.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 mm/hmm.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 857eec622c98..3a708f500b80 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -297,14 +297,6 @@ static int hmm_pfns_bad(unsigned long addr,
 	return 0;
 }
 
-static void hmm_pfns_clear(uint64_t *pfns,
-			   unsigned long addr,
-			   unsigned long end)
-{
-	for (; addr < end; addr += PAGE_SIZE, pfns++)
-		*pfns = 0;
-}
-
 /*
  * hmm_vma_walk_hole() - handle a range back by no pmd or no pte
  * @start: range virtual start address (inclusive)
@@ -463,6 +455,14 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 	return 0;
 }
 
+static void hmm_pfns_clear(uint64_t *pfns,
+			   unsigned long addr,
+			   unsigned long end)
+{
+	for (; addr < end; addr += PAGE_SIZE, pfns++)
+		*pfns = 0;
+}
+
 static void hmm_pfns_special(struct hmm_range *range)
 {
 	unsigned long addr = range->start, i = 0;
-- 
2.14.3
