Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D63736B02C3
	for <linux-mm@kvack.org>; Sun,  4 Jun 2017 16:01:42 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b9so59953718pfl.0
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 13:01:42 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id 66si28708537pfq.353.2017.06.04.13.01.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Jun 2017 13:01:42 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id m17so73459475pfg.3
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 13:01:42 -0700 (PDT)
From: Yu Zhao <yuzhao@google.com>
Subject: [PATCH v2] swap: cond_resched in swap_cgroup_prepare()
Date: Sun,  4 Jun 2017 13:01:09 -0700
Message-Id: <20170604200109.17606-1-yuzhao@google.com>
In-Reply-To: <20170601195635.20744-1-yuzhao@google.com>
References: <20170601195635.20744-1-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yu Zhao <yuzhao@google.com>

Saw need_resched() warnings when swapping on large swapfile (TBs)
because continuously allocating many pages in swap_cgroup_prepare()
took too long.

We already cond_resched when freeing page in swap_cgroup_swapoff().
Do the same for the page allocation.

Signed-off-by: Yu Zhao <yuzhao@google.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
---
Changelog since v1:
* clarify the problem in the commit message

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
2.13.0.506.g27d5fe0cd-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
