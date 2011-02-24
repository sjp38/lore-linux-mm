Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0AE9E8D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 01:57:26 -0500 (EST)
Message-ID: <4D6601B2.1090207@cn.fujitsu.com>
Date: Thu, 24 Feb 2011 14:58:58 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] cpuset: Add a missing unlock in cpuset_write_resmask()
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, =?UTF-8?B?57yqIOWLsA==?= <miaox@cn.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Don't forget to release cgroup_mutex if alloc_trial_cpuset() fails.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 kernel/cpuset.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 1ca786a..6272503 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1561,8 +1561,10 @@ static int cpuset_write_resmask(struct cgroup *cgrp, struct cftype *cft,
 		return -ENODEV;
 
 	trialcs = alloc_trial_cpuset(cs);
-	if (!trialcs)
+	if (!trialcs) {
+		cgroup_unlock();
 		return -ENOMEM;
+	}
 
 	switch (cft->private) {
 	case FILE_CPULIST:
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
