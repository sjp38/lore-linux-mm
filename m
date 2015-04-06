Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 456ED6B0078
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 15:59:14 -0400 (EDT)
Received: by qku63 with SMTP id 63so30969954qku.3
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 12:59:14 -0700 (PDT)
Received: from mail-qc0-x22a.google.com (mail-qc0-x22a.google.com. [2607:f8b0:400d:c01::22a])
        by mx.google.com with ESMTPS id x10si5167382qgx.9.2015.04.06.12.59.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 12:59:06 -0700 (PDT)
Received: by qcgx3 with SMTP id x3so15051931qcg.3
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 12:59:06 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 09/49] blkcg: implement bio_associate_blkcg()
Date: Mon,  6 Apr 2015 15:57:58 -0400
Message-Id: <1428350318-8215-10-git-send-email-tj@kernel.org>
In-Reply-To: <1428350318-8215-1-git-send-email-tj@kernel.org>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

Currently, a bio can only be associated with the io_context and blkcg
of %current using bio_associate_current().  This is too restrictive
for cgroup writeback support.  Implement bio_associate_blkcg() which
associates a bio with the specified blkcg.

bio_associate_blkcg() leaves the io_context unassociated.
bio_associate_current() is updated so that it considers a bio as
already associated if it has a blkcg_css, instead of an io_context,
associated with it.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Vivek Goyal <vgoyal@redhat.com>
---
 block/bio.c         | 24 +++++++++++++++++++++++-
 include/linux/bio.h |  3 +++
 2 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/block/bio.c b/block/bio.c
index 968683e..ab7517d 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -1971,6 +1971,28 @@ struct bio_set *bioset_create_nobvec(unsigned int pool_size, unsigned int front_
 EXPORT_SYMBOL(bioset_create_nobvec);
 
 #ifdef CONFIG_BLK_CGROUP
+
+/**
+ * bio_associate_blkcg - associate a bio with the specified blkcg
+ * @bio: target bio
+ * @blkcg_css: css of the blkcg to associate
+ *
+ * Associate @bio with the blkcg specified by @blkcg_css.  Block layer will
+ * treat @bio as if it were issued by a task which belongs to the blkcg.
+ *
+ * This function takes an extra reference of @blkcg_css which will be put
+ * when @bio is released.  The caller must own @bio and is responsible for
+ * synchronizing calls to this function.
+ */
+int bio_associate_blkcg(struct bio *bio, struct cgroup_subsys_state *blkcg_css)
+{
+	if (unlikely(bio->bi_css))
+		return -EBUSY;
+	css_get(blkcg_css);
+	bio->bi_css = blkcg_css;
+	return 0;
+}
+
 /**
  * bio_associate_current - associate a bio with %current
  * @bio: target bio
@@ -1988,7 +2010,7 @@ int bio_associate_current(struct bio *bio)
 {
 	struct io_context *ioc;
 
-	if (bio->bi_ioc)
+	if (bio->bi_css)
 		return -EBUSY;
 
 	ioc = current->io_context;
diff --git a/include/linux/bio.h b/include/linux/bio.h
index da3a127..cbc5d1d 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -469,9 +469,12 @@ extern void bvec_free(mempool_t *, struct bio_vec *, unsigned int);
 extern unsigned int bvec_nr_vecs(unsigned short idx);
 
 #ifdef CONFIG_BLK_CGROUP
+int bio_associate_blkcg(struct bio *bio, struct cgroup_subsys_state *blkcg_css);
 int bio_associate_current(struct bio *bio);
 void bio_disassociate_task(struct bio *bio);
 #else	/* CONFIG_BLK_CGROUP */
+static inline int bio_associate_blkcg(struct bio *bio,
+			struct cgroup_subsys_state *blkcg_css) { return 0; }
 static inline int bio_associate_current(struct bio *bio) { return -ENOENT; }
 static inline void bio_disassociate_task(struct bio *bio) { }
 #endif	/* CONFIG_BLK_CGROUP */
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
