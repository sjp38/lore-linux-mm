Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D4ADB6B00A6
	for <linux-mm@kvack.org>; Mon,  5 Jan 2009 18:39:13 -0500 (EST)
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id n05NdAUq017061
	for <linux-mm@kvack.org>; Mon, 5 Jan 2009 15:39:11 -0800
Received: from rv-out-0708.google.com (rvfc5.prod.google.com [10.140.180.5])
	by spaceape10.eur.corp.google.com with ESMTP id n05NcNbl017172
	for <linux-mm@kvack.org>; Mon, 5 Jan 2009 15:39:07 -0800
Received: by rv-out-0708.google.com with SMTP id c5so8351447rvf.10
        for <linux-mm@kvack.org>; Mon, 05 Jan 2009 15:39:07 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 5 Jan 2009 15:39:07 -0800
Message-ID: <604427e00901051539x52ab85bcua94cd8036e5b619a@mail.gmail.com>
Subject: [PATCH]Fix: 32bit binary has 64bit address of stack vma
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

From: Ying Han <yinghan@google.com>

Fix 32bit binary get 64bit stack vma offset.

32bit binary running on 64bit system, the /proc/pid/maps shows for the
vma represents stack get a 64bit adress:
ff96c000-ff981000 rwxp 7ffffffea000 00:00 0 [stack]

Signed-off-by:	Ying Han <yinghan@google.com>

fs/exec.c                     |    5 +-

diff --git a/fs/exec.c b/fs/exec.c
index 4e834f1..8c3eff4 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -517,6 +517,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, uns
 	unsigned long length = old_end - old_start;
 	unsigned long new_start = old_start - shift;
 	unsigned long new_end = old_end - shift;
+	unsigned long new_pgoff = new_start >> PAGE_SHIFT;
 	struct mmu_gather *tlb;

 	BUG_ON(new_start > new_end);
@@ -531,7 +532,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, uns
 	/*
 	 * cover the whole range: [new_start, old_end)
 	 */
-	vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL);
+	vma_adjust(vma, new_start, old_end, new_pgoff, NULL);

 	/*
 	 * move the page tables downwards, on failure we rely on
@@ -564,7 +565,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, uns
 	/*
 	 * shrink the vma to just the new range.
 	 */
-	vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL);
+	vma_adjust(vma, new_start, new_end, new_pgoff, NULL);

 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
