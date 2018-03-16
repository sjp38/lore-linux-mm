Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 309626B000A
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:14:22 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id a207so4776580qkb.23
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:14:22 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p18si1340698qtp.357.2018.03.16.12.14.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 12:14:21 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 04/14] mm/hmm: hmm_pfns_bad() was accessing wrong struct
Date: Fri, 16 Mar 2018 15:14:09 -0400
Message-Id: <20180316191414.3223-5-jglisse@redhat.com>
In-Reply-To: <20180316191414.3223-1-jglisse@redhat.com>
References: <20180316191414.3223-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, stable@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

The private field of mm_walk struct point to an hmm_vma_walk struct and
not to the hmm_range struct desired. Fix to get proper struct pointer.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: stable@vger.kernel.org
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 mm/hmm.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 6088fa6ed137..64d9e7dae712 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -293,7 +293,8 @@ static int hmm_pfns_bad(unsigned long addr,
 			unsigned long end,
 			struct mm_walk *walk)
 {
-	struct hmm_range *range = walk->private;
+	struct hmm_vma_walk *hmm_vma_walk = walk->private;
+	struct hmm_range *range = hmm_vma_walk->range;
 	hmm_pfn_t *pfns = range->pfns;
 	unsigned long i;
 
-- 
2.14.3
