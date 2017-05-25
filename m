Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id ACD676B0311
	for <linux-mm@kvack.org>; Thu, 25 May 2017 02:47:03 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 62so218349230pft.3
        for <linux-mm@kvack.org>; Wed, 24 May 2017 23:47:03 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id u69si26530689pgb.168.2017.05.24.23.47.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 23:47:03 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm 06/13] block: Increase BIO_MAX_PAGES to PMD size if THP_SWAP enabled
Date: Thu, 25 May 2017 14:46:28 +0800
Message-Id: <20170525064635.2832-7-ying.huang@intel.com>
In-Reply-To: <20170525064635.2832-1-ying.huang@intel.com>
References: <20170525064635.2832-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Jens Axboe <axboe@kernel.dk>, Ming Lei <tom.leiming@gmail.com>, Shaohua Li <shli@fb.com>, linux-block@vger.kernel.org

From: Huang Ying <ying.huang@intel.com>

In this patch, BIO_MAX_PAGES is changed from 256 to HPAGE_PMD_NR if
CONFIG_THP_SWAP is enabled and HPAGE_PMD_NR > 256.  This is to support
THP (Transparent Huge Page) swap optimization.  Where the THP will be
write to disk as a whole instead of HPAGE_PMD_NR normal pages to batch
the various operations during swap.  And the page is likely to be
written to disk to free memory when system memory goes really low, the
memory pool need to be used to avoid deadlock.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Ming Lei <tom.leiming@gmail.com>
Cc: Shaohua Li <shli@fb.com>
Cc: linux-block@vger.kernel.org
---
 include/linux/bio.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index d1b04b0e99cf..314796486507 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -38,7 +38,15 @@
 #define BIO_BUG_ON
 #endif
 
+#ifdef CONFIG_THP_SWAP
+#if HPAGE_PMD_NR > 256
+#define BIO_MAX_PAGES		HPAGE_PMD_NR
+#else
 #define BIO_MAX_PAGES		256
+#endif
+#else
+#define BIO_MAX_PAGES		256
+#endif
 
 #define bio_prio(bio)			(bio)->bi_ioprio
 #define bio_set_prio(bio, prio)		((bio)->bi_ioprio = prio)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
