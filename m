Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j7IKYmoG019331
	for <linux-mm@kvack.org>; Thu, 18 Aug 2005 16:34:48 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j7IKYmIc223558
	for <linux-mm@kvack.org>; Thu, 18 Aug 2005 16:34:48 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j7IKYldT015317
	for <linux-mm@kvack.org>; Thu, 18 Aug 2005 16:34:47 -0400
Subject: Re: [PATCH 0/4] Demand faunting for huge pages
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20050817210431.GR3996@wotan.suse.de>
References: <1124304966.3139.37.camel@localhost.localdomain>
	 <20050817210431.GR3996@wotan.suse.de>
Content-Type: text/plain
Date: Thu, 18 Aug 2005 15:29:30 -0500
Message-Id: <1124396970.3152.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm@kvack.org, christoph@lameter.com, kenneth.w.chen@intel.com, david@gibson.dropbear.id.au
List-ID: <linux-mm.kvack.org>

On Wed, 2005-08-17 at 23:04 +0200, Andi Kleen wrote:
> Also I still think your get_user_pages approach is questionable.

I am pretty sure that my approach is safe and merely removes an
optimization.  Hopefully the following better states my reasons for
thinking so.  If anyone else who was involved in the demand fault
discussion when it went around the last time (see below) could chime in
I think it would help further clarify the issue.

---

Initial Post (Thu, 18 Aug 2005)

In preparation for hugetlb demand faulting, remove this get_user_pages()
optimization.  Since huge pages will no longer be prefaulted, we can't assume
that the huge ptes are established and hence, calling follow_hugetlb_page() is
not valid.

With the follow_hugetlb_page() call removed, the normal code path will be
triggered.  follow_page() will either use follow_huge_addr() or
follow_huge_pmd() to check for a previously faulted "page" to return.  When
this fails (ie. with demand faults), __handle_mm_fault() gets called which
invokes the hugetlb_fault() handler to instantiate the huge page.

This patch doesn't make a lot of sense by itself, but I've broken it out to
facilitate discussion on this specific element of the demand fault changes.
While coding this up, I referenced previous discussion on this topic starting
at http://lkml.org/lkml/2004/4/13/176 , which contains more opinions about the
correctness of this approach.

Diffed against 2.6.13-rc6-git7

Signed-off-by: Adam Litke <agl@us.ibm.com>

---
 memory.c |    5 -----
 1 files changed, 5 deletions(-)
diff -upN reference/mm/memory.c current/mm/memory.c
--- reference/mm/memory.c
+++ current/mm/memory.c
@@ -937,11 +937,6 @@ int get_user_pages(struct task_struct *t
 				|| !(flags & vma->vm_flags))
 			return i ? : -EFAULT;
 
-		if (is_vm_hugetlb_page(vma)) {
-			i = follow_hugetlb_page(mm, vma, pages, vmas,
-						&start, &len, i);
-			continue;
-		}
 		spin_lock(&mm->page_table_lock);
 		do {
 			int write_access = write;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
