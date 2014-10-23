Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3ACB26B006C
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 14:46:23 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id p10so1512824pdj.33
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 11:46:22 -0700 (PDT)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.180.66])
        by mx.google.com with ESMTP id gd2si2218478pbb.180.2014.10.23.11.46.21
        for <linux-mm@kvack.org>;
        Thu, 23 Oct 2014 11:46:22 -0700 (PDT)
From: Alex Thorlton <athorlton@sgi.com>
Subject: [PATCH 1/4] Disable khugepaged thread
Date: Thu, 23 Oct 2014 13:46:00 -0500
Message-Id: <1414089963-73165-2-git-send-email-athorlton@sgi.com>
In-Reply-To: <1414089963-73165-1-git-send-email-athorlton@sgi.com>
References: <1414089963-73165-1-git-send-email-athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Alex Thorlton <athorlton@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, David Rientjes <rientjes@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Vladimir Davydov <vdavydov@parallels.com>, linux-kernel@vger.kernel.org

This patch just removes any call to start khugepaged for now.  If we decide to
go forward with this new approach, then this patch will also dismantle the other
bits of khugepaged that we'll no longer need.

Signed-off-by: Alex Thorlton <athorlton@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Bob Liu <lliubbo@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org

---
 mm/huge_memory.c | 23 +++--------------------
 1 file changed, 3 insertions(+), 20 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 74c78aa..63abf52 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -295,24 +295,9 @@ static ssize_t enabled_store(struct kobject *kobj,
 			     struct kobj_attribute *attr,
 			     const char *buf, size_t count)
 {
-	ssize_t ret;
-
-	ret = double_flag_store(kobj, attr, buf, count,
-				TRANSPARENT_HUGEPAGE_FLAG,
-				TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG);
-
-	if (ret > 0) {
-		int err;
-
-		mutex_lock(&khugepaged_mutex);
-		err = start_khugepaged();
-		mutex_unlock(&khugepaged_mutex);
-
-		if (err)
-			ret = err;
-	}
-
-	return ret;
+	return double_flag_store(kobj, attr, buf, count,
+				 TRANSPARENT_HUGEPAGE_FLAG,
+				 TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG);
 }
 static struct kobj_attribute enabled_attr =
 	__ATTR(enabled, 0644, enabled_show, enabled_store);
@@ -655,8 +640,6 @@ static int __init hugepage_init(void)
 	if (totalram_pages < (512 << (20 - PAGE_SHIFT)))
 		transparent_hugepage_flags = 0;
 
-	start_khugepaged();
-
 	return 0;
 out:
 	hugepage_exit_sysfs(hugepage_kobj);
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
