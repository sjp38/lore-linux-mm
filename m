Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9F2536B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 05:25:53 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id p9so7782322lbv.3
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 02:25:53 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m10si1169523lbc.81.2014.09.23.02.25.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 02:25:51 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] mm, debug: mm-introduce-vm_bug_on_mm-fix.patch
Date: Tue, 23 Sep 2014 11:24:39 +0200
Message-Id: <1411464279-20158-1-git-send-email-mhocko@suse.cz>
In-Reply-To: <5420b8b0.9HdYLyyuTikszzH8%akpm@linux-foundation.org>
References: <5420b8b0.9HdYLyyuTikszzH8%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, Sasha Levin <sasha.levin@oracle.com>

dump_mm wants to dump mm->owner even when CONFIG_MEMCG is not defined
which leads to a compilation error:
mm/debug.c: In function a??dump_mma??:
mm/debug.c:212:5: error: a??const struct mm_structa?? has no member named a??ownera??
   mm->owner, mm->exe_file,

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/debug.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/debug.c b/mm/debug.c
index 281abb2edddd..63aba9dcfb4e 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -181,7 +181,10 @@ void dump_mm(const struct mm_struct *mm)
 #ifdef CONFIG_AIO
 		"ioctx_table %p\n"
 #endif
-		"owner %p exe_file %p\n"
+#ifdef CONFIG_MEMCG
+		"owner %p "
+#endif
+		"exe_file %p\n"
 #ifdef CONFIG_MMU_NOTIFIER
 		"mmu_notifier_mm %p\n"
 #endif
@@ -209,7 +212,10 @@ void dump_mm(const struct mm_struct *mm)
 #ifdef CONFIG_AIO
 		mm->ioctx_table,
 #endif
-		mm->owner, mm->exe_file,
+#ifdef CONFIG_MEMCG
+		mm->owner,
+#endif
+		mm->exe_file,
 #ifdef CONFIG_MMU_NOTIFIER
 		mm->mmu_notifier_mm,
 #endif
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
