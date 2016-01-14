Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id B5C61828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 08:35:20 -0500 (EST)
Received: by mail-qg0-f50.google.com with SMTP id b35so349880429qge.0
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 05:35:20 -0800 (PST)
Received: from mail-qk0-x249.google.com (mail-qk0-x249.google.com. [2607:f8b0:400d:c09::249])
        by mx.google.com with ESMTPS id 110si7488729qgy.36.2016.01.14.05.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 05:35:19 -0800 (PST)
Received: by mail-qk0-x249.google.com with SMTP id p186so40682325qke.1
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 05:35:19 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 14 Jan 2016 14:33:52 +0100
Message-ID: <001a113abaa499606605294b5b17@google.com>
Subject: [PATCH] memcg: Only free spare array when readers are done
From: Martijn Coenen <maco@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

A spare array holding mem cgroup threshold events is kept around
to make sure we can always safely deregister an event and have an
array to store the new set of events in.

In the scenario where we're going from 1 to 0 registered events, the
pointer to the primary array containing 1 event is copied to the spare
slot, and then the spare slot is freed because no events are left.
However, it is freed before calling synchronize_rcu(), which means
readers may still be accessing threshold->primary after it is freed.

Fixed by only freeing after synchronize_rcu().

Signed-off-by: Martijn Coenen <maco@google.com>
---
  mm/memcontrol.c | 11 ++++++-----
  1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 14cb1db..73228b6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3522,16 +3522,17 @@ static void  
__mem_cgroup_usage_unregister_event(struct mem_cgroup *memcg,
  swap_buffers:
  	/* Swap primary and spare array */
  	thresholds->spare = thresholds->primary;
-	/* If all events are unregistered, free the spare array */
-	if (!new) {
-		kfree(thresholds->spare);
-		thresholds->spare = NULL;
-	}

  	rcu_assign_pointer(thresholds->primary, new);

  	/* To be sure that nobody uses thresholds */
  	synchronize_rcu();
+
+	/* If all events are unregistered, free the spare array */
+	if (!new) {
+		kfree(thresholds->spare);
+		thresholds->spare = NULL;
+	}
  unlock:
  	mutex_unlock(&memcg->thresholds_lock);
  }
-- 
2.6.0.rc2.230.g3dd15c0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
