Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 616406B000C
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 15:12:04 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id o2so11454196pls.10
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 12:12:04 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g5si3924947pgc.234.2018.02.14.12.12.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Feb 2018 12:12:03 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v2 5/8] Convert infiniband uverbs to kvzalloc_struct
Date: Wed, 14 Feb 2018 12:11:51 -0800
Message-Id: <20180214201154.10186-6-willy@infradead.org>
In-Reply-To: <20180214201154.10186-1-willy@infradead.org>
References: <20180214201154.10186-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Joe Perches <joe@perches.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/infiniband/core/uverbs_cmd.c | 4 ++--
 include/rdma/ib_verbs.h              | 5 +----
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/core/uverbs_cmd.c b/drivers/infiniband/core/uverbs_cmd.c
index 256934d1f64f..7e4114a8954d 100644
--- a/drivers/infiniband/core/uverbs_cmd.c
+++ b/drivers/infiniband/core/uverbs_cmd.c
@@ -3346,8 +3346,8 @@ int ib_uverbs_ex_create_flow(struct ib_uverbs_file *file,
 		goto err_uobj;
 	}
 
-	flow_attr = kzalloc(sizeof(*flow_attr) + cmd.flow_attr.num_of_specs *
-			    sizeof(union ib_flow_spec), GFP_KERNEL);
+	flow_attr = kvzalloc_struct(flow_attr, flows,
+				    cmd.flow_attr.num_of_specs, GFP_KERNEL);
 	if (!flow_attr) {
 		err = -ENOMEM;
 		goto err_put;
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 73b2387e3f74..895509ee7f80 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1977,10 +1977,7 @@ struct ib_flow_attr {
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
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
