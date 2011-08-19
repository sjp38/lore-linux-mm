Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 95C7690013A
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 03:49:03 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p7J7n1u3006601
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:49:01 -0700
Received: from ywp17 (ywp17.prod.google.com [10.192.16.17])
	by hpaq2.eem.corp.google.com with ESMTP id p7J7mxS3017364
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:59 -0700
Received: by ywp17 with SMTP id 17so2773681ywp.22
        for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:58 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 7/9] rcu: rcu_get_gp_cookie() / rcu_gp_cookie_elapsed() stand-ins
Date: Fri, 19 Aug 2011 00:48:29 -0700
Message-Id: <1313740111-27446-8-git-send-email-walken@google.com>
In-Reply-To: <1313740111-27446-1-git-send-email-walken@google.com>
References: <1313740111-27446-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

Prototypes for the proposed rcu_get_gp_cookie() / rcu_gp_cookie_elapsed()
functionality as discussed in http://marc.info/?l=linux-mm&m=131316547914194

(This is not a correct implementation of the proposed API;
Paul McKenney is to provide that as a follow-up to this RFC)

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 include/linux/rcupdate.h |   35 +++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 99f9aa7..315a0f1 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -865,4 +865,39 @@ static inline void __rcu_reclaim(struct rcu_head *head)
 #define kfree_rcu(ptr, rcu_head)					\
 	__kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
 
+struct rcu_cookie {long x; };
+
+/*
+ * rcu_get_gp_cookie() / rcu_gp_cookie_elapsed()
+ *
+ * rcu_get_gp_cookie() stores an opaque cookie to the provided location.
+ *
+ * rcu_gp_cookie_elapsed() returns true if it can guarantee that
+ * an rcu grace period has elapsed since the provided cookie was
+ * created by rcu_get_gp_cookie(). A return value of false indicates
+ * that rcu_gp_cookie_elapsed() does not know if an rcu grace period has
+ * elapsed or not - the call site is then expected to drop locks as desired,
+ * call rcu_synchronize(), and retry.
+ *
+ * Note that call sites are allowed to assume that rcu_gp_cookie_elapsed()
+ * will return true if they try enough times. An implementation that always
+ * returns false would be incorrect.
+ *
+ * The implementation below is also incorrect (may return false positives),
+ * however it does test that one always calls rcu_get_gp_cookie() before
+ * rcu_gp_cookie_elapsed() and that rcu_gp_cookie_elapsed() call sites
+ * are ready to handle both possible cases.
+ */
+static inline void rcu_get_gp_cookie(struct rcu_cookie *rcp)
+{
+	rcp->x = 12345678;
+}
+
+static inline bool rcu_gp_cookie_elapsed(struct rcu_cookie *rcp)
+{
+	static int count = 0;
+	BUG_ON(rcp->x != 12345678);
+	return (count++ % 16) != 0;
+}
+
 #endif /* __LINUX_RCUPDATE_H */
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
