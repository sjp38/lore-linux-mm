Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E0DED6B04AC
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:51:40 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id o5so12898643qki.2
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:51:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l10si750703qtc.525.2017.08.08.01.51.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:51:40 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v3 28/49] block: introduce bvec_get_last_page()
Date: Tue,  8 Aug 2017 16:45:27 +0800
Message-Id: <20170808084548.18963-29-ming.lei@redhat.com>
In-Reply-To: <20170808084548.18963-1-ming.lei@redhat.com>
References: <20170808084548.18963-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

BTRFS and guard_bio_eod() need to get the last page, so introduce
this helper to make them happy.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bvec.h | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index 23d3abdf057c..ceb6292750d6 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -238,4 +238,18 @@ static inline bool bvec_iter_advance_mp(const struct bio_vec *bv,
 #define bvec_for_each_sp_bvec(sp_bvl, mp_bvec, iter)			\
 	__bvec_for_each_sp_bvec(sp_bvl, mp_bvec, iter, BVEC_ITER_ALL_INIT)
 
+/*
+ * get the last page from the multipage bvec and store it
+ * in @sp_bv
+ */
+static inline void bvec_get_last_page(struct bio_vec *mp_bv,
+				      struct bio_vec *sp_bv)
+{
+	struct bvec_iter iter;
+
+	*sp_bv = *mp_bv;
+	bvec_for_each_sp_bvec(*sp_bv, mp_bv, iter)
+		;
+}
+
 #endif /* __LINUX_BVEC_ITER_H */
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
