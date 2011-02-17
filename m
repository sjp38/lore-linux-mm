Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6B98E8D0039
	for <linux-mm@kvack.org>; Wed, 16 Feb 2011 20:54:08 -0500 (EST)
Message-ID: <4D5C7EA7.1030409@cn.fujitsu.com>
Date: Thu, 17 Feb 2011 09:49:27 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 1/4] cpuset: Remove unneeded NODEMASK_ALLOC() in cpuset_sprintf_memlist()
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, =?UTF-8?B?57yqIOWLsA==?= <miaox@cn.fujitsu.com>, linux-mm@kvack.org

It's not necessary to copy cpuset->mems_allowed to a buffer
allocated by NODEMASK_ALLOC(). Just pass it to nodelist_scnprintf().

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 kernel/cpuset.c |   10 +---------
 1 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 10f1835..f13ff2e 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1620,20 +1620,12 @@ static int cpuset_sprintf_cpulist(char *page, struct cpuset *cs)
 
 static int cpuset_sprintf_memlist(char *page, struct cpuset *cs)
 {
-	NODEMASK_ALLOC(nodemask_t, mask, GFP_KERNEL);
 	int retval;
 
-	if (mask == NULL)
-		return -ENOMEM;
-
 	mutex_lock(&callback_mutex);
-	*mask = cs->mems_allowed;
+	retval = nodelist_scnprintf(page, PAGE_SIZE, cs->mems_allowed);
 	mutex_unlock(&callback_mutex);
 
-	retval = nodelist_scnprintf(page, PAGE_SIZE, *mask);
-
-	NODEMASK_FREE(mask);
-
 	return retval;
 }
 
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
