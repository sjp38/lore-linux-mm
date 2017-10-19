Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DEB1B6B0069
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 03:03:30 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t188so5106906pfd.20
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 00:03:30 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id y10si3535033pfl.122.2017.10.19.00.03.29
        for <linux-mm@kvack.org>;
        Thu, 19 Oct 2017 00:03:29 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v2 1/4] completion: Add support for initializing completion with lockdep_map
Date: Thu, 19 Oct 2017 16:03:24 +0900
Message-Id: <1508396607-25362-2-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1508396607-25362-1-git-send-email-byungchul.park@lge.com>
References: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>
 <1508396607-25362-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com

Sometimes, we want to initialize completions with sparate lockdep maps
to assign lock classes under control. For example, the workqueue code
manages lockdep maps, as it can classify lockdep maps properly.
Provided a function for that purpose.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/completion.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/linux/completion.h b/include/linux/completion.h
index cae5400..182d56e 100644
--- a/include/linux/completion.h
+++ b/include/linux/completion.h
@@ -49,6 +49,13 @@ static inline void complete_release_commit(struct completion *x)
 	lock_commit_crosslock((struct lockdep_map *)&x->map);
 }
 
+#define init_completion_with_map(x, m)					\
+do {									\
+	lockdep_init_map_crosslock((struct lockdep_map *)&(x)->map,	\
+			(m)->name, (m)->key, 0);				\
+	__init_completion(x);						\
+} while (0)
+
 #define init_completion(x)						\
 do {									\
 	static struct lock_class_key __key;				\
@@ -58,6 +65,7 @@ static inline void complete_release_commit(struct completion *x)
 	__init_completion(x);						\
 } while (0)
 #else
+#define init_completion_with_map(x, m) __init_completion(x)
 #define init_completion(x) __init_completion(x)
 static inline void complete_acquire(struct completion *x) {}
 static inline void complete_release(struct completion *x) {}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
