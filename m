Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1C0EF6B026E
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 15:47:35 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id q63so96031423pfb.0
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 12:47:35 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id 20si12357679pfp.195.2015.12.29.12.47.31
        for <linux-mm@kvack.org>;
        Tue, 29 Dec 2015 12:47:32 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/2] mm, oom: skip mlocked VMAs in __oom_reap_vmas()
Date: Tue, 29 Dec 2015 23:46:29 +0300
Message-Id: <1451421990-32297-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1451421990-32297-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1451421990-32297-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>

As far as I can see we explicitly munlock pages everywhere before unmap
them. The only case when we don't to that is OOM-reaper.

I don't think we should bother with munlocking in this case, we can just
skip the locked VMA.

I think this patch would fix this crash:
 http://lkml.kernel.org/r/5661FBB6.6050307@oracle.com

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Sasha Levin <sasha.levin@oracle.com>
Cc: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4b0a5d8b92e1..fe58d76c1215 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -447,6 +447,13 @@ static bool __oom_reap_vmas(struct mm_struct *mm)
 			continue;
 
 		/*
+		 * mlocked VMAs require explicit munlocking before unmap.
+		 * Let's keep it simple here and skip such VMAs.
+		 */
+		if (vma->vm_flags & VM_LOCKED)
+			continue;
+
+		/*
 		 * Only anonymous pages have a good chance to be dropped
 		 * without additional steps which we cannot afford as we
 		 * are OOM already.
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
