Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 968F1280268
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 19:45:13 -0400 (EDT)
Received: by ietj16 with SMTP id j16so22492928iet.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 16:45:13 -0700 (PDT)
Received: from mail-ie0-x22f.google.com (mail-ie0-x22f.google.com. [2607:f8b0:4001:c03::22f])
        by mx.google.com with ESMTPS id fp18si2653740icb.41.2015.07.14.16.45.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 16:45:13 -0700 (PDT)
Received: by ieik3 with SMTP id k3so22548170iei.3
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 16:45:12 -0700 (PDT)
Date: Tue, 14 Jul 2015 16:45:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 1/2] mm, oom: add description of struct oom_control
Message-ID: <alpine.DEB.2.10.1507141644320.16182@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Describe the purpose of struct oom_control and what each member does.

Also make gfp_mask and order const since they are never manipulated or
passed to functions that discard the qualifier.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/oom.h | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -12,11 +12,25 @@ struct notifier_block;
 struct mem_cgroup;
 struct task_struct;
 
+/*
+ * Details of the page allocation that triggered the oom killer that are used to
+ * determine what should be killed.
+ */
 struct oom_control {
+	/* Used to determine cpuset */
 	struct zonelist *zonelist;
-	nodemask_t	*nodemask;
-	gfp_t		gfp_mask;
-	int		order;
+
+	/* Used to determine mempolicy */
+	nodemask_t *nodemask;
+
+	/* Used to determine cpuset and node locality requirement */
+	const gfp_t gfp_mask;
+
+	/*
+	 * order == -1 means the oom kill is required by sysrq, otherwise only
+	 * for display purposes.
+	 */
+	const int order;
 };
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
