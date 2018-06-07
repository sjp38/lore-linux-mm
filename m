Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2419B6B02A4
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:57:28 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id c6-v6so5535543pll.4
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:57:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t13-v6si30479831pgs.242.2018.06.07.07.57.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Jun 2018 07:57:26 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 2/6] Convert infiniband uverbs to struct_size
Date: Thu,  7 Jun 2018 07:57:16 -0700
Message-Id: <20180607145720.22590-3-willy@infradead.org>
In-Reply-To: <20180607145720.22590-1-willy@infradead.org>
References: <20180607145720.22590-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

From: Matthew Wilcox <mawilcox@microsoft.com>

The flows were hidden from the C compiler; expose them as a zero-length
array to allow struct_size to work.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/infiniband/core/uverbs_cmd.c | 4 ++--
 include/rdma/ib_verbs.h              | 5 +----
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/core/uverbs_cmd.c b/drivers/infiniband/core/uverbs_cmd.c
index e3662a8ee465..67cab6102f7a 100644
--- a/drivers/infiniband/core/uverbs_cmd.c
+++ b/drivers/infiniband/core/uverbs_cmd.c
@@ -3478,8 +3478,8 @@ int ib_uverbs_ex_create_flow(struct ib_uverbs_file *file,
 		goto err_uobj;
 	}
 
-	flow_attr = kzalloc(sizeof(*flow_attr) + cmd.flow_attr.num_of_specs *
-			    sizeof(union ib_flow_spec), GFP_KERNEL);
+	flow_attr = kzalloc(struct_size(flow_attr, flows,
+				cmd.flow_attr.num_of_specs), GFP_KERNEL);
 	if (!flow_attr) {
 		err = -ENOMEM;
 		goto err_put;
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 9fc8a825aa28..bb6125ceb187 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -2035,10 +2035,7 @@ struct ib_flow_attr {
 	u32	     flags;
 	u8	     num_of_specs;
 	u8	     port;
-	/* Following are the optional layers according to user request
-	 * struct ib_flow_spec_xxx
-	 * struct ib_flow_spec_yyy
-	 */
+	union ib_flow_spec flows[];
 };
 
 struct ib_flow {
-- 
2.17.0
