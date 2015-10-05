Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1C08082FA8
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 17:45:00 -0400 (EDT)
Received: by qgez77 with SMTP id z77so162739310qge.1
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 14:44:59 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u77si25090561qge.103.2015.10.05.14.44.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 05 Oct 2015 14:44:59 -0700 (PDT)
Received: from pps.filterd (m0001255 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t95Lh549020986
	for <linux-mm@kvack.org>; Mon, 5 Oct 2015 14:44:58 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1xc010gdj9-12
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 05 Oct 2015 14:44:58 -0700
Received: from facebook.com (2401:db00:11:d0a2:face:0:39:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 3d9b8b8a6baa11e5afee0002c9521c9e-c8dfc240 for <linux-mm@kvack.org>;	Mon, 05
 Oct 2015 14:44:22 -0700
From: Shaohua Li <shli@fb.com>
Subject: [PATCH] memcg: convert threshold to bytes
Date: Mon, 5 Oct 2015 14:44:22 -0700
Message-ID: <fc100a5a381d1961c3b917489eb82b098d9e0840.1444081366.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

The page_counter_memparse() returns pages for the threshold, while
mem_cgroup_usage() returns bytes for memory usage. Convert the threshold
to bytes.

Looks a regression introduced by 3e32cb2e0a12b69150

Signed-off-by: Shaohua Li <shli@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
---
 mm/memcontrol.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1fedbde..d9b5c81 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3387,6 +3387,7 @@ static int __mem_cgroup_usage_register_event(struct mem_cgroup *memcg,
 	ret = page_counter_memparse(args, "-1", &threshold);
 	if (ret)
 		return ret;
+	threshold <<= PAGE_SHIFT;
 
 	mutex_lock(&memcg->thresholds_lock);
 
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
