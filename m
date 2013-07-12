Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id E06D46B0033
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 05:25:15 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 2/3] vmpressure: change vmpressure::sr_lock to spinlock
Date: Fri, 12 Jul 2013 11:24:57 +0200
Message-Id: <1373621098-15261-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1373621098-15261-1-git-send-email-mhocko@suse.cz>
References: <20130712084039.GA13224@dhcp22.suse.cz>
 <1373621098-15261-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

There is nothing that can sleep inside critical sections protected by
this lock and those sections are really small so there doesn't make much
sense to use mutex for them. Change the log to a spinlock

Brought-up-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/vmpressure.h |  2 +-
 mm/vmpressure.c            | 10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
index 76be077..2081680 100644
--- a/include/linux/vmpressure.h
+++ b/include/linux/vmpressure.h
@@ -12,7 +12,7 @@ struct vmpressure {
 	unsigned long scanned;
 	unsigned long reclaimed;
 	/* The lock is used to keep the scanned/reclaimed above in sync. */
-	struct mutex sr_lock;
+	struct spinlock sr_lock;
 
 	/* The list of vmpressure_event structs. */
 	struct list_head events;
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index eb2bcf9..b8e16fe 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -187,12 +187,12 @@ static void vmpressure_work_fn(struct work_struct *work)
 	if (!vmpr->scanned)
 		return;
 
-	mutex_lock(&vmpr->sr_lock);
+	spin_lock(&vmpr->sr_lock);
 	scanned = vmpr->scanned;
 	reclaimed = vmpr->reclaimed;
 	vmpr->scanned = 0;
 	vmpr->reclaimed = 0;
-	mutex_unlock(&vmpr->sr_lock);
+	spin_unlock(&vmpr->sr_lock);
 
 	do {
 		if (vmpressure_event(vmpr, scanned, reclaimed))
@@ -247,11 +247,11 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
 	if (!scanned)
 		return;
 
-	mutex_lock(&vmpr->sr_lock);
+	spin_lock(&vmpr->sr_lock);
 	vmpr->scanned += scanned;
 	vmpr->reclaimed += reclaimed;
 	scanned = vmpr->scanned;
-	mutex_unlock(&vmpr->sr_lock);
+	spin_unlock(&vmpr->sr_lock);
 
 	if (scanned < vmpressure_win || work_pending(&vmpr->work))
 		return;
@@ -374,7 +374,7 @@ void vmpressure_unregister_event(struct cgroup *cg, struct cftype *cft,
  */
 void vmpressure_init(struct vmpressure *vmpr)
 {
-	mutex_init(&vmpr->sr_lock);
+	spin_lock_init(&vmpr->sr_lock);
 	mutex_init(&vmpr->events_lock);
 	INIT_LIST_HEAD(&vmpr->events);
 	INIT_WORK(&vmpr->work, vmpressure_work_fn);
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
