Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 361E36B0311
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 15:56:48 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j28so55252451pfk.14
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 12:56:48 -0700 (PDT)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id k20si20937260pfb.241.2017.06.01.12.56.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 12:56:47 -0700 (PDT)
Received: by mail-pf0-x231.google.com with SMTP id n23so36131951pfb.2
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 12:56:47 -0700 (PDT)
From: Yu Zhao <yuzhao@google.com>
Subject: [PATCH] swap: cond_resched in swap_cgroup_prepare()
Date: Thu,  1 Jun 2017 12:56:35 -0700
Message-Id: <20170601195635.20744-1-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yu Zhao <yuzhao@google.com>

Saw need_resched() warnings when swapping on large swapfile (TBs)
because page allocation in swap_cgroup_prepare() took too long.

We already cond_resched when freeing page in swap_cgroup_swapoff().
Do the same for the page allocation.

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 mm/swap_cgroup.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/swap_cgroup.c b/mm/swap_cgroup.c
index ac6318a064d3..3405b4ee1757 100644
--- a/mm/swap_cgroup.c
+++ b/mm/swap_cgroup.c
@@ -48,6 +48,9 @@ static int swap_cgroup_prepare(int type)
 		if (!page)
 			goto not_enough_page;
 		ctrl->map[idx] = page;
+
+		if (!(idx % SWAP_CLUSTER_MAX))
+			cond_resched();
 	}
 	return 0;
 not_enough_page:
-- 
2.13.0.219.gdb65acc882-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
