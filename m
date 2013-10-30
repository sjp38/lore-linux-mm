Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f80.google.com (mail-pb0-f80.google.com [209.85.160.80])
	by kanga.kvack.org (Postfix) with ESMTP id EE3AF6B0031
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 10:06:33 -0400 (EDT)
Received: by mail-pb0-f80.google.com with SMTP id md4so79358pbc.7
        for <linux-mm@kvack.org>; Fri, 01 Nov 2013 07:06:33 -0700 (PDT)
Received: from psmtp.com ([74.125.245.177])
        by mx.google.com with SMTP id bf5si379307pab.136.2013.10.30.14.58.17
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 14:58:35 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/3] mm: memcg: use proper memcg in limit bypass
Date: Wed, 30 Oct 2013 17:55:25 -0400
Message-Id: <1383170127-32284-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1383170127-32284-1-git-send-email-hannes@cmpxchg.org>
References: <1383170127-32284-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

84235de ("fs: buffer: move allocation failure loop into the
allocator") allowed __GFP_NOFAIL allocations to bypass the limit if
they fail to reclaim enough memory for the charge.  Because the main
test case was on a 3.2-based system, this patch missed the fact that
on newer kernels the charge function needs to return root_mem_cgroup
when bypassing the limit, and not NULL.  This will corrupt whatever
memory is at NULL + percpu pointer offset.  Fix this quickly before
problems are reported.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 34d3ca9572d6..13a9c80d5708 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2765,10 +2765,10 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 	*ptr = memcg;
 	return 0;
 nomem:
-	*ptr = NULL;
-	if (gfp_mask & __GFP_NOFAIL)
-		return 0;
-	return -ENOMEM;
+	if (!(gfp_mask & __GFP_NOFAIL)) {
+		*ptr = NULL;
+		return -ENOMEM;
+	}
 bypass:
 	*ptr = root_mem_cgroup;
 	return -EINTR;
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
