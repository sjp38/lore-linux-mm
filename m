Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 593FF6B00F5
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 14:29:37 -0500 (EST)
Received: by mail-qg0-f53.google.com with SMTP id l89so17408625qgf.12
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 11:29:37 -0800 (PST)
Received: from mail-qc0-x233.google.com (mail-qc0-x233.google.com. [2607:f8b0:400d:c01::233])
        by mx.google.com with ESMTPS id i9si65323236qaz.51.2015.01.06.11.29.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 11:29:32 -0800 (PST)
Received: by mail-qc0-f179.google.com with SMTP id c9so17036220qcz.24
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 11:29:32 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 06/16] blkcg: implement bio_associate_blkcg()
Date: Tue,  6 Jan 2015 14:29:07 -0500
Message-Id: <1420572557-11572-7-git-send-email-tj@kernel.org>
In-Reply-To: <1420572557-11572-1-git-send-email-tj@kernel.org>
References: <1420572557-11572-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, Tejun Heo <tj@kernel.org>

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
index a1e0b00..89aeae6 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -2015,6 +2015,28 @@ struct bio_set *bioset_create_nobvec(unsigned int pool_size, unsigned int front_
 EXPORT_SYMBOL(bioset_create_nobvec);
 
 #ifdef CONFIG_BLK_CGROUP
+
+/**
+ * bio_associate_blkcg - associate a bio with the specified blkcg
+ * @bio: target bio
+ * @blkcg_css: the css of the blkcg to associate
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
@@ -2032,7 +2054,7 @@ int bio_associate_current(struct bio *bio)
 {
 	struct io_context *ioc;
 
-	if (bio->bi_ioc)
+	if (bio->bi_css)
 		return -EBUSY;
 
 	ioc = current->io_context;
diff --git a/include/linux/bio.h b/include/linux/bio.h
index efead0b..0e863e7 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -475,9 +475,12 @@ extern void bvec_free(mempool_t *, struct bio_vec *, unsigned int);
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
