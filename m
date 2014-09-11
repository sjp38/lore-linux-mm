Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 83D976B0039
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 17:33:56 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id cc10so1694708wib.14
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 14:33:55 -0700 (PDT)
Received: from mail-we0-x22d.google.com (mail-we0-x22d.google.com [2a00:1450:400c:c03::22d])
        by mx.google.com with ESMTPS id hu1si4296826wib.22.2014.09.11.14.33.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Sep 2014 14:33:55 -0700 (PDT)
Received: by mail-we0-f173.google.com with SMTP id u56so6671565wes.32
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 14:33:54 -0700 (PDT)
Date: Thu, 11 Sep 2014 17:33:39 -0400
From: Niv Yehezkel <executerx@gmail.com>
Subject: [PATCH] oom: break after selecting process to kill
Message-ID: <20140911213338.GA4098@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, mhocko@suse.cz, hannes@cmpxchg.org, oleg@redhat.com

There is no need to fallback and continue computing
badness for each running process after we have found a
process currently performing the swapoff syscall. We ought to
immediately select this process for killing.

Signed-off-by: Niv Yehezkel <executerx@gmail.com>
---
 mm/oom_kill.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1e11df8..68ac30e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -305,6 +305,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 	struct task_struct *g, *p;
 	struct task_struct *chosen = NULL;
 	unsigned long chosen_points = 0;
+	bool process_selected = false;
 
 	rcu_read_lock();
 	for_each_process_thread(g, p) {
@@ -315,7 +316,8 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 		case OOM_SCAN_SELECT:
 			chosen = p;
 			chosen_points = ULONG_MAX;
-			/* fall through */
+			process_selected = true;
+			break;
 		case OOM_SCAN_CONTINUE:
 			continue;
 		case OOM_SCAN_ABORT:
@@ -324,6 +326,8 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 		case OOM_SCAN_OK:
 			break;
 		};
+		if (process_selected)
+			break;
 		points = oom_badness(p, NULL, nodemask, totalpages);
 		if (!points || points < chosen_points)
 			continue;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
