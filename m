Message-Id: <200405222208.i4MM8Xr13396@mail.osdl.org>
Subject: [patch 29/57] numa api: fix end of memory handling in mbind
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:08:03 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

From: Andi Kleen <ak@suse.de>

This fixes a user triggerable crash in mbind() in NUMA API.  It would oops
when running into the end of memory.  Actually not really oops, because a
oops with the mm sem hold for writing always deadlocks.


---

 25-akpm/mm/mempolicy.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN mm/mempolicy.c~numa-api-fix-end-of-memory-handling-in-mbind mm/mempolicy.c
--- 25/mm/mempolicy.c~numa-api-fix-end-of-memory-handling-in-mbind	2004-05-22 14:56:26.186110632 -0700
+++ 25-akpm/mm/mempolicy.c	2004-05-22 14:56:26.190110024 -0700
@@ -271,7 +271,7 @@ check_range(struct mm_struct *mm, unsign
 	if (!first)
 		return ERR_PTR(-EFAULT);
 	prev = NULL;
-	for (vma = first; vma->vm_start < end; vma = vma->vm_next) {
+	for (vma = first; vma && vma->vm_start < end; vma = vma->vm_next) {
 		if (!vma->vm_next && vma->vm_end < end)
 			return ERR_PTR(-EFAULT);
 		if (prev && prev->vm_end < vma->vm_start)
@@ -317,7 +317,7 @@ static int mbind_range(struct vm_area_st
 	int err;
 
 	err = 0;
-	for (; vma->vm_start < end; vma = next) {
+	for (; vma && vma->vm_start < end; vma = next) {
 		next = vma->vm_next;
 		if (vma->vm_start < start)
 			err = split_vma(vma->vm_mm, vma, start, 1);

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
