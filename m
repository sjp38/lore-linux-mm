Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 400756B0071
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 00:55:17 -0400 (EDT)
Received: by qcbkw5 with SMTP id kw5so136820362qcb.2
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:55:17 -0700 (PDT)
Received: from mail-qc0-x229.google.com (mail-qc0-x229.google.com. [2607:f8b0:400d:c01::229])
        by mx.google.com with ESMTPS id 2si11169989qku.103.2015.03.22.21.55.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 21:55:13 -0700 (PDT)
Received: by qcto4 with SMTP id o4so136673462qct.3
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:55:13 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 03/48] update !CONFIG_BLK_CGROUP dummies in include/linux/blk-cgroup.h
Date: Mon, 23 Mar 2015 00:54:14 -0400
Message-Id: <1427086499-15657-4-git-send-email-tj@kernel.org>
In-Reply-To: <1427086499-15657-1-git-send-email-tj@kernel.org>
References: <1427086499-15657-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

The header file will be used more widely with the pending cgroup
writeback support and the current set of dummy declarations aren't
enough to handle different config combinations.  Update as follows.

* Drop the struct cgroup declaration.  None of the dummy defs need it.

* Define blkcg as an empty struct instead of just declaring it.

* Wrap dummy function defs in CONFIG_BLOCK.  Some functions use block
  data types and none of them are to be used w/o block enabled.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 include/linux/blk-cgroup.h | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/blk-cgroup.h b/include/linux/blk-cgroup.h
index c567865..51f95b3 100644
--- a/include/linux/blk-cgroup.h
+++ b/include/linux/blk-cgroup.h
@@ -558,8 +558,8 @@ static inline void blkg_rwstat_merge(struct blkg_rwstat *to,
 
 #else	/* CONFIG_BLK_CGROUP */
 
-struct cgroup;
-struct blkcg;
+struct blkcg {
+};
 
 struct blkg_policy_data {
 };
@@ -570,6 +570,8 @@ struct blkcg_gq {
 struct blkcg_policy {
 };
 
+#ifdef CONFIG_BLOCK
+
 static inline struct blkcg_gq *blkg_lookup(struct blkcg *blkcg, void *key) { return NULL; }
 static inline int blkcg_init_queue(struct request_queue *q) { return 0; }
 static inline void blkcg_drain_queue(struct request_queue *q) { }
@@ -599,5 +601,6 @@ static inline struct request_list *blk_rq_rl(struct request *rq) { return &rq->q
 #define blk_queue_for_each_rl(rl, q)	\
 	for ((rl) = &(q)->root_rl; (rl); (rl) = NULL)
 
+#endif	/* CONFIG_BLOCK */
 #endif	/* CONFIG_BLK_CGROUP */
 #endif	/* _BLK_CGROUP_H */
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
