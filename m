Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 402F16B00E3
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 02:50:19 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH -mmotm 4/5] memcg: dirty pages accounting and limiting infrastructure
Date: Wed, 17 Mar 2010 23:48:38 -0700
Message-Id: <1268894918-26797-1-git-send-email-gthelen@google.com>
In-Reply-To: <1268609202-15581-5-git-send-email-arighi@develer.com>
References: <1268609202-15581-5-git-send-email-arighi@develer.com>
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

I have a proposed change to "[PATCH -mmotm 4/5] memcg: dirty pages accounting
and limiting infrastructure" v6.  The change is small and I am presenting it
as a git patch (below) to be applied after 4/5 v6 has been applied.
The change is fairly simple.  An alternative would be to reject my
patch (below) and enhance get_vm_dirty_param() to loop for consistenty in all
cases.

---patch snip here, rest of email is git patch of 4/5 v6 ---

Removed unneeded looping from get_vm_dirty_param().  The only caller of
get_vm_dirty_param() gracefully handles inconsistent values, so there is no
need for get_vm_dirty_param() to loop to ensure consistency.  The previous
looping was inconsistent because it did not loop for the case where memory
cgroups were disabled.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/memcontrol.c |   28 ++++++++++++----------------
 1 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4d00c0f..990a907 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1081,6 +1081,10 @@ static void __mem_cgroup_get_dirty_param(struct vm_dirty_param *param,
  * The function fills @param with the current memcg dirty memory settings. If
  * memory cgroup is disabled or in case of error the structure is filled with
  * the global dirty memory settings.
+ *
+ * Because global and memcg vm_dirty_param are not protected, inconsistent
+ * values may be returned.  If consistent values are required, then the caller
+ * should call this routine until dirty_param_is_valid() returns true.
  */
 void get_vm_dirty_param(struct vm_dirty_param *param)
 {
@@ -1090,28 +1094,20 @@ void get_vm_dirty_param(struct vm_dirty_param *param)
 		get_global_vm_dirty_param(param);
 		return;
 	}
+
 	/*
 	 * It's possible that "current" may be moved to other cgroup while we
 	 * access cgroup. But precise check is meaningless because the task can
 	 * be moved after our access and writeback tends to take long time.
 	 * At least, "memcg" will not be freed under rcu_read_lock().
 	 */
-	while (1) {
-		rcu_read_lock();
-		memcg = mem_cgroup_from_task(current);
-		if (likely(memcg))
-			__mem_cgroup_get_dirty_param(param, memcg);
-		else
-			get_global_vm_dirty_param(param);
-		rcu_read_unlock();
-		/*
-		 * Since global and memcg vm_dirty_param are not protected we
-		 * try to speculatively read them and retry if we get
-		 * inconsistent values.
-		 */
-		if (likely(dirty_param_is_valid(param)))
-			break;
-	}
+	rcu_read_lock();
+	memcg = mem_cgroup_from_task(current);
+	if (likely(memcg))
+		__mem_cgroup_get_dirty_param(param, memcg);
+	else
+		get_global_vm_dirty_param(param);
+	rcu_read_unlock();
 }
 
 /*
-- 
1.7.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
