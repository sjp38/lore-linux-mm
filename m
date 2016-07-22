Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E32C96B0253
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 08:19:52 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o80so33289379wme.1
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 05:19:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i2si9828905wmd.60.2016.07.22.05.19.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 05:19:51 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 04/15] mm: Allow full handling of COW faults in ->fault handlers
Date: Fri, 22 Jul 2016 14:19:30 +0200
Message-Id: <1469189981-19000-5-git-send-email-jack@suse.cz>
In-Reply-To: <1469189981-19000-1-git-send-email-jack@suse.cz>
References: <1469189981-19000-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>

To allow full handling of COW faults add memcg field to struct vm_fault
and a return value of ->fault() handler meaning that COW fault is fully
handled and memcg charge must not be canceled. This will allow us to
remove knowledge about special DAX locking from the generic fault code.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/mm.h | 4 +++-
 mm/memory.c        | 5 ++++-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index dfb59b1f3584..2442f972bdc8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -297,7 +297,8 @@ struct vm_fault {
 	pgoff_t pgoff;			/* Logical page offset based on vma */
 	void __user *virtual_address;	/* Faulting virtual address */
 
-	struct page *cow_page;		/* Handler may choose to COW */
+	struct page *cow_page;		/* Page handler may use for COW fault */
+	struct mem_cgroup *memcg;	/* Cgroup cow_page belongs to */
 	struct page *page;		/* ->fault handlers should return a
 					 * page here, unless VM_FAULT_NOPAGE
 					 * is set (which is also implied by
@@ -1085,6 +1086,7 @@ static inline void clear_page_pfmemalloc(struct page *page)
 #define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
 #define VM_FAULT_FALLBACK 0x0800	/* huge page fault failed, fall back to small */
 #define VM_FAULT_DAX_LOCKED 0x1000	/* ->fault has locked DAX entry */
+#define VM_FAULT_DONE_COW   0x2000	/* ->fault has fully handled COW */
 
 #define VM_FAULT_HWPOISON_LARGE_MASK 0xf000 /* encodes hpage index for large hwpoison */
 
diff --git a/mm/memory.c b/mm/memory.c
index 3c8bc4f08ee2..aef88d634072 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2836,7 +2836,7 @@ static int __do_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 	ret = vma->vm_ops->fault(vma, vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY |
-			    VM_FAULT_DAX_LOCKED)))
+			    VM_FAULT_DAX_LOCKED | VM_FAULT_DONE_COW)))
 		return ret;
 
 	if (unlikely(PageHWPoison(vmf->page))) {
@@ -3059,9 +3059,12 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	vmf->cow_page = new_page;
+	vmf->memcg = memcg;
 	ret = __do_fault(vma, vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		goto uncharge_out;
+	if (ret & VM_FAULT_DONE_COW)
+		return ret;
 
 	if (!(ret & VM_FAULT_DAX_LOCKED))
 		copy_user_highpage(new_page, vmf->page, address, vma);
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
