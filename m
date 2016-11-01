Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BA1776B02AF
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 18:37:35 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id m203so490526wma.2
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 15:37:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h84si4467000wmf.90.2016.11.01.15.37.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Nov 2016 15:37:34 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 08/21] mm: Allow full handling of COW faults in ->fault handlers
Date: Tue,  1 Nov 2016 23:36:17 +0100
Message-Id: <1478039794-20253-12-git-send-email-jack@suse.cz>
In-Reply-To: <1478039794-20253-1-git-send-email-jack@suse.cz>
References: <1478039794-20253-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>

To allow full handling of COW faults add memcg field to struct vm_fault
and a return value of ->fault() handler meaning that COW fault is fully
handled and memcg charge must not be canceled. This will allow us to
remove knowledge about special DAX locking from the generic fault code.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/mm.h | 4 +++-
 mm/memory.c        | 8 +++++---
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f8e758060851..78173d7de007 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -301,7 +301,8 @@ struct vm_fault {
 					 * the 'address' */
 	pte_t orig_pte;			/* Value of PTE at the time of fault */
 
-	struct page *cow_page;		/* Handler may choose to COW */
+	struct page *cow_page;		/* Page handler may use for COW fault */
+	struct mem_cgroup *memcg;	/* Cgroup cow_page belongs to */
 	struct page *page;		/* ->fault handlers should return a
 					 * page here, unless VM_FAULT_NOPAGE
 					 * is set (which is also implied by
@@ -1103,6 +1104,7 @@ static inline void clear_page_pfmemalloc(struct page *page)
 #define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
 #define VM_FAULT_FALLBACK 0x0800	/* huge page fault failed, fall back to small */
 #define VM_FAULT_DAX_LOCKED 0x1000	/* ->fault has locked DAX entry */
+#define VM_FAULT_DONE_COW   0x2000	/* ->fault has fully handled COW */
 
 #define VM_FAULT_HWPOISON_LARGE_MASK 0xf000 /* encodes hpage index for large hwpoison */
 
diff --git a/mm/memory.c b/mm/memory.c
index 25028422a578..ac901bb02398 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2848,9 +2848,8 @@ static int __do_fault(struct vm_fault *vmf)
 	int ret;
 
 	ret = vma->vm_ops->fault(vma, vmf);
-	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
-		return ret;
-	if (ret & VM_FAULT_DAX_LOCKED)
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY |
+			    VM_FAULT_DAX_LOCKED | VM_FAULT_DONE_COW)))
 		return ret;
 
 	if (unlikely(PageHWPoison(vmf->page))) {
@@ -3209,9 +3208,12 @@ static int do_cow_fault(struct vm_fault *vmf)
 	}
 
 	vmf->cow_page = new_page;
+	vmf->memcg = memcg;
 	ret = __do_fault(vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		goto uncharge_out;
+	if (ret & VM_FAULT_DONE_COW)
+		return ret;
 
 	if (!(ret & VM_FAULT_DAX_LOCKED))
 		copy_user_highpage(new_page, vmf->page, vmf->address, vma);
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
