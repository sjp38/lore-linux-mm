Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id B76EA6B000A
	for <linux-mm@kvack.org>; Tue, 29 May 2018 17:17:31 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id s133-v6so6954908qke.21
        for <linux-mm@kvack.org>; Tue, 29 May 2018 14:17:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w141-v6sor21481811qkw.68.2018.05.29.14.17.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 May 2018 14:17:31 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 02/13] block: introduce bio_issue_as_root_blkg
Date: Tue, 29 May 2018 17:17:13 -0400
Message-Id: <20180529211724.4531-3-josef@toxicpanda.com>
In-Reply-To: <20180529211724.4531-1-josef@toxicpanda.com>
References: <20180529211724.4531-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, kernel-team@fb.com, linux-block@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, linux-fsdevel@vger.kernel.org
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

Instead of forcing all file systems to get the right context on their
bio's, simply check for REQ_META to see if we need to issue as the root
blkg.  We don't want to force all bio's to have the root blkg associated
with them if REQ_META is set, as some controllers (blk-iolatency) need
to know who the originating cgroup is so it can backcharge them for the
work they are doing.  This helper will make sure that the controllers do
the proper thing wrt the IO priority and backcharging.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 include/linux/blk-cgroup.h | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/include/linux/blk-cgroup.h b/include/linux/blk-cgroup.h
index 6c666fd7de3c..69aa71dc0c04 100644
--- a/include/linux/blk-cgroup.h
+++ b/include/linux/blk-cgroup.h
@@ -238,6 +238,22 @@ static inline struct blkcg *bio_blkcg(struct bio *bio)
 	return css_to_blkcg(task_css(current, io_cgrp_id));
 }
 
+/**
+ * bio_issue_as_root_blkg - see if this bio needs to be issued as root blkg
+ * @return: true if this bio needs to be submitted with the root blkg context.
+ *
+ * In order to avoid priority inversions we sometimes need to issue a bio as if
+ * it were attached to the root blkg, and then backcharge to the actual owning
+ * blkg.  The idea is we do bio_blkcg() to look up the actual context for the
+ * bio and attach the appropriate blkg to the bio.  Then we call this helper and
+ * if it is true run with the root blkg for that queue and then do any
+ * backcharging to the originating cgroup once the io is complete.
+ */
+static inline bool bio_issue_as_root_blkg(struct bio *bio)
+{
+	return (bio->bi_opf & REQ_META);
+}
+
 /**
  * blkcg_parent - get the parent of a blkcg
  * @blkcg: blkcg of interest
-- 
2.14.3
