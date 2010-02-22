Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 816FB62001B
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 10:43:57 -0500 (EST)
Received: by mail-fx0-f222.google.com with SMTP id 22so2837093fxm.6
        for <linux-mm@kvack.org>; Mon, 22 Feb 2010 07:43:55 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH v2 -mmotm 2/4] cgroups: remove events before destroying subsystem state objects
Date: Mon, 22 Feb 2010 17:43:40 +0200
Message-Id: <690745ebd257c74a1c47d552fec7fbb0b5efb7d0.1266853233.git.kirill@shutemov.name>
In-Reply-To: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill@shutemov.name>
References: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill@shutemov.name>
In-Reply-To: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill@shutemov.name>
References: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: containers@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

Events should be removed after rmdir of cgroup directory, but before
destroying subsystem state objects. Let's take reference to cgroup
directory dentry to do that.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hioryu@jp.fujitsu.com>
---
 include/linux/cgroup.h |    3 ---
 kernel/cgroup.c        |    8 ++++++++
 mm/memcontrol.c        |    9 ---------
 3 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 64cebfe..1719c75 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -395,9 +395,6 @@ struct cftype {
 	 * closes the eventfd or on cgroup removing.
 	 * This callback must be implemented, if you want provide
 	 * notification functionality.
-	 *
-	 * Be careful. It can be called after destroy(), so you have
-	 * to keep all nesessary data, until all events are removed.
 	 */
 	int (*unregister_event)(struct cgroup *cgrp, struct cftype *cft,
 			struct eventfd_ctx *eventfd);
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 46903cb..d142524 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2979,6 +2979,7 @@ static void cgroup_event_remove(struct work_struct *work)
 
 	eventfd_ctx_put(event->eventfd);
 	kfree(event);
+	dput(cgrp->dentry);
 }
 
 /*
@@ -3099,6 +3100,13 @@ static int cgroup_write_event_control(struct cgroup *cgrp, struct cftype *cft,
 		goto fail;
 	}
 
+	/*
+	 * Events should be removed after rmdir of cgroup directory, but before
+	 * destroying subsystem state objects. Let's take reference to cgroup
+	 * directory dentry to do that.
+	 */
+	dget(cgrp->dentry);
+
 	spin_lock(&cgrp->event_list_lock);
 	list_add(&event->list, &cgrp->event_list);
 	spin_unlock(&cgrp->event_list_lock);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a443c30..8fe6e7f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3358,12 +3358,6 @@ static int mem_cgroup_register_event(struct cgroup *cgrp, struct cftype *cft,
 		}
 	}
 
-	/*
-	 * We need to increment refcnt to be sure that all thresholds
-	 * will be unregistered before calling __mem_cgroup_free()
-	 */
-	mem_cgroup_get(memcg);
-
 	if (type == _MEM)
 		rcu_assign_pointer(memcg->thresholds, thresholds_new);
 	else
@@ -3457,9 +3451,6 @@ assign:
 	/* To be sure that nobody uses thresholds before freeing it */
 	synchronize_rcu();
 
-	for (i = 0; i < thresholds->size - size; i++)
-		mem_cgroup_put(memcg);
-
 	kfree(thresholds);
 unlock:
 	mutex_unlock(&memcg->thresholds_lock);
-- 
1.6.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
