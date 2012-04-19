Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id CD88F6B004D
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 04:55:20 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so12595120pbc.14
        for <linux-mm@kvack.org>; Thu, 19 Apr 2012 01:55:20 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH RESEND] memcg: Free spare array to avoid memory leak
Date: Thu, 19 Apr 2012 16:54:50 +0800
Message-Id: <1334825690-9065-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

When the last event is unregistered, there is no need to keep the spare
array anymore. So free it to avoid memory leak.

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Kirill A. Shutemov <kirill@shutemov.name>

---
Hi, Andrew

This patch has been reviewed days ago. Do you have any comments about it?

Thanks,
Sha
 
 mm/memcontrol.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 22d94f5..3c09a84 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4412,6 +4412,12 @@ static void mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
 swap_buffers:
 	/* Swap primary and spare array */
 	thresholds->spare = thresholds->primary;
+	/* If all events are unregistered, free the spare array */
+	if (!new) {
+		kfree(thresholds->spare);
+		thresholds->spare = NULL;
+	}
+
 	rcu_assign_pointer(thresholds->primary, new);
 
 	/* To be sure that nobody uses thresholds */
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
