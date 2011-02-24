Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 55C348D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 01:55:14 -0500 (EST)
Message-ID: <4D660130.8020009@cn.fujitsu.com>
Date: Thu, 24 Feb 2011 14:56:48 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH v2 1/4] cpuset: Remove unneeded NODEMASK_ALLOC() in cpuset_sprintf_memlist()
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, =?UTF-8?B?57yqIOWLsA==?= <miaox@cn.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

It's not necessary to copy cpuset->mems_allowed to a buffer
allocated by NODEMASK_ALLOC(). Just pass it to nodelist_scnprintf().

As spotted by Paul, a side effect is we fix a bug that the function
can return -ENOMEM but the caller doesn't expect negative return
value. Therefore change the return value of cpuset_sprintf_cpulist()
and cpuset_sprintf_memlist() from int to size_t.

Acked-by: Paul Menage <menage@google.com>
Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 kernel/cpuset.c |   24 ++++++++----------------
 1 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 10f1835..e79650b 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1607,34 +1607,26 @@ static int cpuset_write_resmask(struct cgroup *cgrp, struct cftype *cft,
  * across a page fault.
  */
 
-static int cpuset_sprintf_cpulist(char *page, struct cpuset *cs)
+static size_t cpuset_sprintf_cpulist(char *page, struct cpuset *cs)
 {
-	int ret;
+	size_t count;
 
 	mutex_lock(&callback_mutex);
-	ret = cpulist_scnprintf(page, PAGE_SIZE, cs->cpus_allowed);
+	count = cpulist_scnprintf(page, PAGE_SIZE, cs->cpus_allowed);
 	mutex_unlock(&callback_mutex);
 
-	return ret;
+	return count;
 }
 
-static int cpuset_sprintf_memlist(char *page, struct cpuset *cs)
+static size_t cpuset_sprintf_memlist(char *page, struct cpuset *cs)
 {
-	NODEMASK_ALLOC(nodemask_t, mask, GFP_KERNEL);
-	int retval;
-
-	if (mask == NULL)
-		return -ENOMEM;
+	size_t count;
 
 	mutex_lock(&callback_mutex);
-	*mask = cs->mems_allowed;
+	count = nodelist_scnprintf(page, PAGE_SIZE, cs->mems_allowed);
 	mutex_unlock(&callback_mutex);
 
-	retval = nodelist_scnprintf(page, PAGE_SIZE, *mask);
-
-	NODEMASK_FREE(mask);
-
-	return retval;
+	return count;
 }
 
 static ssize_t cpuset_common_file_read(struct cgroup *cont,
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
