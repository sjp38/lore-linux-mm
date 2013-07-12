Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 9B6576B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 05:25:14 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 1/3] vmpressure: document why css_get/put is not necessary for work queue based signaling
Date: Fri, 12 Jul 2013 11:24:56 +0200
Message-Id: <1373621098-15261-1-git-send-email-mhocko@suse.cz>
In-Reply-To: <20130712084039.GA13224@dhcp22.suse.cz>
References: <20130712084039.GA13224@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

Tejun raised a concern that vmpressure() doesn't take any reference to
memcg which embeds vmpressure structure when it schedules work item so
there is no guarantee that memcg (thus vmpr) is still valid when the
work item is processed.

Normally we should take a css reference on memcg before scheduling the
work and release it in vmpressure_work_fn but this doesn't seem to be
necessary because of the way how eventfd is implemented at cgroup level.

Cgroup events are unregistered from the workqueue context by
cgroup_event_remove scheduled by cgroup_destroy_locked (when a cgroup is
removed by rmdir).

cgroup_event_remove removes the eventfd wait queue from the work
queue, then it unregisters all the registered events and finally
puts a reference to the cgroup dentry. css_free which triggers memcg
deallocation is called after the last reference is dropped.

The scheduled vmpressure work item either happens before
cgroup_event_remove or it is not triggered at all so it always happen
_before_ the last dput thus css_free.

This patch just documents this trickiness.

Brought-up-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/vmpressure.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 736a601..eb2bcf9 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -165,6 +165,13 @@ static bool vmpressure_event(struct vmpressure *vmpr,
 
 static void vmpressure_work_fn(struct work_struct *work)
 {
+	/*
+	 * vmpr which is embedded inside memcg is safe to use from
+	 * this context because cgroup_event_remove which unregisters
+	 * vmpressure events and removes work item from the queue is
+	 * called before dput on the cgroup so css_free is called
+	 * later. So css_get/put on memcg is not necessary.
+	 */
 	struct vmpressure *vmpr = work_to_vmpressure(work);
 	unsigned long scanned;
 	unsigned long reclaimed;
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
