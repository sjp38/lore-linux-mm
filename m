Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9549C6B0080
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 18:03:46 -0500 (EST)
Received: by mail-ie0-f182.google.com with SMTP id x19so11961551ier.13
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 15:03:46 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 193si5463605ioz.42.2014.12.15.15.03.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Dec 2014 15:03:45 -0800 (PST)
Date: Mon, 15 Dec 2014 15:03:43 -0800
From: akpm@linux-foundation.org
Subject: [patch 5/6]
 mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix
Message-ID: <548f68cf.6xGKPRYKtNb84wM5%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, ak@linux.intel.com, dave.hansen@linux.intel.com, kirill@shutemov.name, lliubbo@gmail.com, matthew.r.wilcox@intel.com, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, riel@redhat.com, sasha.levin@oracle.com

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix

add comment which may not be true :(

Cc: Andi Kleen <ak@linux.intel.com>
Cc: Bob Liu <lliubbo@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memory.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff -puN mm/memory.c~mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix mm/memory.c
--- a/mm/memory.c~mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix
+++ a/mm/memory.c
@@ -3009,6 +3009,12 @@ static int do_shared_fault(struct mm_str
 
 	if (set_page_dirty(fault_page))
 		dirtied = 1;
+	/*
+	 * Take a local copy of the address_space - page.mapping may be zeroed
+	 * by truncate after unlock_page().   The address_space itself remains
+	 * pinned by vma->vm_file's reference.  We rely on unlock_page()'s
+	 * release semantics to prevent the compiler from undoing this copying.
+	 */
 	mapping = fault_page->mapping;
 	unlock_page(fault_page);
 	if ((dirtied || vma->vm_ops->page_mkwrite) && mapping) {
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
