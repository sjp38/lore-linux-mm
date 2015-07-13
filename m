Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0C56F6B0258
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 06:54:26 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so223755399pdb.1
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 03:54:25 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 4si27800277pdk.216.2015.07.13.03.54.19
        for <linux-mm@kvack.org>;
        Mon, 13 Jul 2015 03:54:19 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 5/5] mm, memcontrol: use vma_is_anonymous() to check for anon VMA
Date: Mon, 13 Jul 2015 13:54:12 +0300
Message-Id: <1436784852-144369-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

!vma->vm_file is not reliable to detect anon VMA, because not all
drivers bother set it. Let's use vma_is_anonymous() instead.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index acb93c554f6e..a624709f0dd7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4809,7 +4809,7 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
 	struct address_space *mapping;
 	pgoff_t pgoff;
 
-	if (!vma->vm_file) /* anonymous vma */
+	if (vma_is_anonymous(vma)) /* anonymous vma */
 		return NULL;
 	if (!(mc.flags & MOVE_FILE))
 		return NULL;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
