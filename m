Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id A048D6B0081
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 18:51:00 -0400 (EDT)
Received: by ggnf4 with SMTP id f4so241518ggn.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 15:50:59 -0700 (PDT)
From: Ezequiel Garcia <elezegarcia@gmail.com>
Subject: [PATCH 3/5] mm, util: Do strndup_user allocation directly, instead of through memdup_user
Date: Wed,  5 Sep 2012 19:48:41 -0300
Message-Id: <1346885323-15689-3-git-send-email-elezegarcia@gmail.com>
In-Reply-To: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com>
References: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

Since the allocation was being done throug memdup_user, the caller
is wrongly traced as being strndup_user (the correct trace should
report the caller of strndup_user).

This is a common problem: in order to get accurate callsite tracing,
a utils function can't allocate through another utils function,
but instead do the allocation himself.

Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
---
I'm not sure this is the best solution,
but creating another function to reuse between strndup_user
and memdup_user seemed like an overkill.

 mm/util.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/mm/util.c b/mm/util.c
index dc3036c..87ff667 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -214,10 +214,19 @@ char *strndup_user(const char __user *s, long n)
 	if (length > n)
 		return ERR_PTR(-EINVAL);
 
-	p = memdup_user(s, length);
+	/*
+	 * Always use GFP_KERNEL, since copy_from_user() can sleep and
+	 * cause pagefault, which makes it pointless to use GFP_NOFS
+	 * or GFP_ATOMIC.
+	 */
+	p = kmalloc_track_caller(length, GFP_KERNEL);
+	if (!p)
+		return ERR_PTR(-ENOMEM);
 
-	if (IS_ERR(p))
-		return p;
+	if (copy_from_user(p, s, length)) {
+		kfree(p);
+		return ERR_PTR(-EFAULT);
+	}
 
 	p[length - 1] = '\0';
 
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
