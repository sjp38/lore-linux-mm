Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id EB5C06B0044
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 00:44:53 -0500 (EST)
Date: Mon, 21 Dec 2009 14:32:54 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 2/8] cgroup: introduce coalesce css_get() and
 css_put()
Message-Id: <20091221143254.ae23d470.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp>
References: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Current css_get() and css_put() increment/decrement css->refcnt one by one.

This patch add a new function __css_get(), which takes "count" as a arg and
increment the css->refcnt by "count". And this patch also add a new arg("count")
to __css_put() and change the function to decrement the css->refcnt by "count".

These coalesce version of __css_get()/__css_put() will be used to improve
performance of memcg's moving charge feature later, where instead of calling
css_get()/css_put() repeatedly, these new functions will be used.

No change is needed for current users of css_get()/css_put().

Changelog: 2009/12/14
- new patch(I split "[4/7] memcg: improbe performance in moving charge" of
  04/Dec version into 2 part: cgroup part and memcg part. This is the cgroup
  part.)

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: Paul Menage <menage@google.com>
---
 include/linux/cgroup.h |   12 +++++++++---
 kernel/cgroup.c        |    5 +++--
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index d4cc200..61f75ae 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -75,6 +75,12 @@ enum {
 	CSS_REMOVED, /* This CSS is dead */
 };
 
+/* Caller must verify that the css is not for root cgroup */
+static inline void __css_get(struct cgroup_subsys_state *css, int count)
+{
+	atomic_add(count, &css->refcnt);
+}
+
 /*
  * Call css_get() to hold a reference on the css; it can be used
  * for a reference obtained via:
@@ -86,7 +92,7 @@ static inline void css_get(struct cgroup_subsys_state *css)
 {
 	/* We don't need to reference count the root state */
 	if (!test_bit(CSS_ROOT, &css->flags))
-		atomic_inc(&css->refcnt);
+		__css_get(css, 1);
 }
 
 static inline bool css_is_removed(struct cgroup_subsys_state *css)
@@ -117,11 +123,11 @@ static inline bool css_tryget(struct cgroup_subsys_state *css)
  * css_get() or css_tryget()
  */
 
-extern void __css_put(struct cgroup_subsys_state *css);
+extern void __css_put(struct cgroup_subsys_state *css, int count);
 static inline void css_put(struct cgroup_subsys_state *css)
 {
 	if (!test_bit(CSS_ROOT, &css->flags))
-		__css_put(css);
+		__css_put(css, 1);
 }
 
 /* bits in struct cgroup flags field */
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index d67d471..8f89c9d 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3729,12 +3729,13 @@ static void check_for_release(struct cgroup *cgrp)
 	}
 }
 
-void __css_put(struct cgroup_subsys_state *css)
+/* Caller must verify that the css is not for root cgroup */
+void __css_put(struct cgroup_subsys_state *css, int count)
 {
 	struct cgroup *cgrp = css->cgroup;
 	int val;
 	rcu_read_lock();
-	val = atomic_dec_return(&css->refcnt);
+	val = atomic_sub_return(count, &css->refcnt);
 	if (val == 1) {
 		if (notify_on_release(cgrp)) {
 			set_bit(CGRP_RELEASABLE, &cgrp->flags);
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
