Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 0C9236B006E
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 14:25:59 -0500 (EST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH v6 05/12] thp: change_huge_pmd(): keep huge zero page write-protected
Date: Thu, 15 Nov 2012 21:26:55 +0200
Message-Id: <1353007622-18393-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1353007622-18393-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1353007622-18393-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org
Cc: Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We want to get page fault on write attempt to huge zero page, so let's
keep it write-protected.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index f5589c0..42607a1 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1245,6 +1245,8 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		pmd_t entry;
 		entry = pmdp_get_and_clear(mm, addr, pmd);
 		entry = pmd_modify(entry, newprot);
+		if (is_huge_zero_pmd(entry))
+			entry = pmd_wrprotect(entry);
 		set_pmd_at(mm, addr, pmd, entry);
 		spin_unlock(&vma->vm_mm->page_table_lock);
 		ret = 1;
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
