Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9985D6B050E
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 09:38:42 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id g189-v6so1642730wmg.8
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 06:38:42 -0800 (PST)
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70120.outbound.protection.outlook.com. [40.107.7.120])
        by mx.google.com with ESMTPS id 19-v6si972089wmv.111.2018.11.07.06.38.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Nov 2018 06:38:40 -0800 (PST)
From: Janne Huttunen <janne.huttunen@nokia.com>
Subject: [PATCH] mm: fix NUMA statistics updates
Date: Wed, 7 Nov 2018 16:38:37 +0200
Message-ID: <1541601517-17282-1-git-send-email-janne.huttunen@nokia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@kernel.org, janne.huttunen@nokia.com

Scan through the whole array to see if an update is needed. While we're
at it, use sizeof() to be safe against any possible type changes in the
future.

Fixes: 1d90ca897cb0 ("mm: update NUMA counter threshold size")
Signed-off-by: Janne Huttunen <janne.huttunen@nokia.com>
---
Compile tested only! I don't know what error (if any) only scanning
half of the array causes, so I cannot verify that this patch actually
fixes it.

 mm/vmstat.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7878da7..eca984d 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1827,12 +1827,13 @@ static bool need_update(int cpu)
 
 		/*
 		 * The fast way of checking if there are any vmstat diffs.
-		 * This works because the diffs are byte sized items.
 		 */
-		if (memchr_inv(p->vm_stat_diff, 0, NR_VM_ZONE_STAT_ITEMS))
+		if (memchr_inv(p->vm_stat_diff, 0, NR_VM_ZONE_STAT_ITEMS *
+			       sizeof(p->vm_stat_diff[0])))
 			return true;
 #ifdef CONFIG_NUMA
-		if (memchr_inv(p->vm_numa_stat_diff, 0, NR_VM_NUMA_STAT_ITEMS))
+		if (memchr_inv(p->vm_numa_stat_diff, 0, NR_VM_NUMA_STAT_ITEMS *
+			       sizeof(p->vm_numa_stat_diff[0])))
 			return true;
 #endif
 	}
-- 
2.5.5
