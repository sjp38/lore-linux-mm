Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id C82E86B0083
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 02:16:53 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 18 Apr 2012 11:46:49 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3I6GiUA3919914
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 11:46:45 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3IBlFsh030379
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 21:47:21 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] memcg: Use scnprintf instead of sprintf
Date: Wed, 18 Apr 2012 11:45:56 +0530
Message-Id: <1334729756-10212-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <20120416161354.b967790c.akpm@linux-foundation.org>
References: <20120416161354.b967790c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This make sure we don't overflow.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/memcontrol.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 519d370..0ccf934 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5269,14 +5269,14 @@ static void mem_cgroup_destroy(struct cgroup *cont)
 }
 
 #ifdef CONFIG_MEM_RES_CTLR_HUGETLB
-static char *mem_fmt(char *buf, unsigned long n)
+static char *mem_fmt(char *buf, int size, unsigned long hsize)
 {
-	if (n >= (1UL << 30))
-		sprintf(buf, "%luGB", n >> 30);
-	else if (n >= (1UL << 20))
-		sprintf(buf, "%luMB", n >> 20);
+	if (hsize >= (1UL << 30))
+		scnprintf(buf, size, "%luGB", hsize >> 30);
+	else if (hsize >= (1UL << 20))
+		scnprintf(buf, size, "%luMB", hsize >> 20);
 	else
-		sprintf(buf, "%luKB", n >> 10);
+		scnprintf(buf, size, "%luKB", hsize >> 10);
 	return buf;
 }
 
@@ -5287,7 +5287,7 @@ int __init mem_cgroup_hugetlb_file_init(int idx)
 	struct hstate *h = &hstates[idx];
 
 	/* format the size */
-	mem_fmt(buf, huge_page_size(h));
+	mem_fmt(buf, 32, huge_page_size(h));
 
 	/* Add the limit file */
 	cft = &h->mem_cgroup_files[0];
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
