Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 05B776B000E
	for <linux-mm@kvack.org>; Tue, 29 May 2018 17:17:36 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id x186-v6so14873700qkb.0
        for <linux-mm@kvack.org>; Tue, 29 May 2018 14:17:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b4-v6sor19056893qvo.134.2018.05.29.14.17.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 May 2018 14:17:35 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 05/13] swap,blkcg: issue swap io with the appropriate context
Date: Tue, 29 May 2018 17:17:16 -0400
Message-Id: <20180529211724.4531-6-josef@toxicpanda.com>
In-Reply-To: <20180529211724.4531-1-josef@toxicpanda.com>
References: <20180529211724.4531-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, kernel-team@fb.com, linux-block@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, linux-fsdevel@vger.kernel.org

From: Tejun Heo <tj@kernel.org>

For backcharging we need to know who the page belongs to when swapping
it out.

Signed-off-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 mm/page_io.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/page_io.c b/mm/page_io.c
index a552cb37e220..61e1268e5dbc 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -339,6 +339,16 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 		goto out;
 	}
 	bio->bi_opf = REQ_OP_WRITE | REQ_SWAP | wbc_to_write_flags(wbc);
+#if defined(CONFIG_MEMCG) && defined(CONFIG_BLK_CGROUP)
+	if (page->mem_cgroup) {
+		struct cgroup_subsys_state *blkcg_css;
+
+		blkcg_css = cgroup_get_e_css(page->mem_cgroup->css.cgroup,
+					     &io_cgrp_subsys);
+		bio_associate_blkcg(bio, blkcg_css);
+		css_put(blkcg_css);
+	}
+#endif
 	count_swpout_vm_event(page);
 	set_page_writeback(page);
 	unlock_page(page);
-- 
2.14.3
