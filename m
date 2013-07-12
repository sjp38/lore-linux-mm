Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id D556A6B0034
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 05:25:17 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 3/3] vmpressure: do not check for pending work to prevent from new work
Date: Fri, 12 Jul 2013 11:24:58 +0200
Message-Id: <1373621098-15261-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1373621098-15261-1-git-send-email-mhocko@suse.cz>
References: <20130712084039.GA13224@dhcp22.suse.cz>
 <1373621098-15261-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

because it is racy and it doesn't give us much anyway as schedule_work
handles this case already.

Brought-up-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/vmpressure.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index b8e16fe..581a7d7 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -253,7 +253,7 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
 	scanned = vmpr->scanned;
 	spin_unlock(&vmpr->sr_lock);
 
-	if (scanned < vmpressure_win || work_pending(&vmpr->work))
+	if (scanned < vmpressure_win)
 		return;
 	schedule_work(&vmpr->work);
 }
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
