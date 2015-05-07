Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id BDB1B6B0038
	for <linux-mm@kvack.org>; Thu,  7 May 2015 02:44:35 -0400 (EDT)
Received: by pdea3 with SMTP id a3so32677735pde.3
        for <linux-mm@kvack.org>; Wed, 06 May 2015 23:44:35 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id og9si1525523pbc.66.2015.05.06.23.44.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 06 May 2015 23:44:34 -0700 (PDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NNY00EWTW28CCA0@mailout2.samsung.com> for linux-mm@kvack.org;
 Thu, 07 May 2015 15:44:32 +0900 (KST)
Date: Thu, 07 May 2015 15:45:57 +0900
From: Kyungmin Park <kmpark@infradead.org>
Subject: [RFC PATCH] PM, freezer: Don't thaw when it's intended frozen processes
Message-id: <20150507064557.GA26928@july>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

From: Kyungmin Park <kyungmin.park@samsung.com>

Some platform uses freezer cgroup for speicial purpose to schedule out some applications. but after suspend & resume, these processes are thawed and running. 

but it's inteneded and don't need to thaw it.

To avoid it, does it possible to modify resume code and don't thaw it when resume? does it resonable?

Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
diff --git a/kernel/power/process.c b/kernel/power/process.c
index 564f786..6eed7df 100644
--- a/kernel/power/process.c
+++ b/kernel/power/process.c
@@ -202,7 +202,9 @@ void thaw_processes(void)
 	for_each_process_thread(g, p) {
 		/* No other threads should have PF_SUSPEND_TASK set */
 		WARN_ON((p != curr) && (p->flags & PF_SUSPEND_TASK));
-		__thaw_task(p);
+		/* Don't need to thaw when it's already frozen by userspace */
+		if (!cgroup_freezing(p))
+			__thaw_task(p);
 	}
 	read_unlock(&tasklist_lock);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
