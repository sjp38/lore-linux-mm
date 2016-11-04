Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 40D6E28026C
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 00:33:16 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p190so8664099wmp.3
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 21:33:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o196si2930728wmg.8.2016.11.03.21.25.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Nov 2016 21:25:28 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 17/21] mm: Change return values of finish_mkwrite_fault()
Date: Fri,  4 Nov 2016 05:25:13 +0100
Message-Id: <1478233517-3571-18-git-send-email-jack@suse.cz>
In-Reply-To: <1478233517-3571-1-git-send-email-jack@suse.cz>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>

Currently finish_mkwrite_fault() returns 0 when PTE got changed before
we acquired PTE lock and VM_FAULT_WRITE when we succeeded in modifying
the PTE. This is somewhat confusing since 0 generally means success, it
is also inconsistent with finish_fault() which returns 0 on success.
Change finish_mkwrite_fault() to return 0 on success and VM_FAULT_NOPAGE
when PTE changed. Practically, there should be no behavioral difference
since we bail out from the fault the same way regardless whether we
return 0, VM_FAULT_NOPAGE, or VM_FAULT_WRITE. Also note that
VM_FAULT_WRITE has no effect for shared mappings since the only two
places that check it - KSM and GUP - care about private mappings only.
Generally the meaning of VM_FAULT_WRITE for shared mappings is not well
defined and we should probably clean that up.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/memory.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 1517ff91c743..b3bd6b6c6472 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2296,10 +2296,10 @@ int finish_mkwrite_fault(struct vm_fault *vmf)
 	 */
 	if (!pte_same(*vmf->pte, vmf->orig_pte)) {
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
-		return 0;
+		return VM_FAULT_NOPAGE;
 	}
 	wp_page_reuse(vmf);
-	return VM_FAULT_WRITE;
+	return 0;
 }
 
 /*
@@ -2342,8 +2342,7 @@ static int wp_page_shared(struct vm_fault *vmf)
 			return tmp;
 		}
 		tmp = finish_mkwrite_fault(vmf);
-		if (unlikely(!tmp || (tmp &
-				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
+		if (unlikely(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
 			unlock_page(vmf->page);
 			put_page(vmf->page);
 			return tmp;
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
