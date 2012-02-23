Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id EA8F36B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 15:27:00 -0500 (EST)
Date: Thu, 23 Feb 2012 14:56:36 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 1/2] mm: fix quadratic behaviour in
 get_unmapped_area_topdown
Message-ID: <20120223145636.616bef1c@cuia.bos.redhat.com>
In-Reply-To: <20120223145417.261225fd@cuia.bos.redhat.com>
References: <20120223145417.261225fd@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, hughd@google.com

When we look for a VMA smaller than the cached_hole_size, we set the
starting search address to mm->mmap_base, to try and find our hole.

However, even in the case where we fall through and found nothing at
the mm->free_area_cache, we still reset the search address to mm->mmap_base.
This bug results in quadratic behaviour, with observed mmap times of 0.4
seconds for processes that have very fragmented memory.

If there is no hole small enough for us to fit the VMA, and we have
no good spot for us right at mm->free_area_cache, we are much better
off continuing the search down from mm->free_area_cache, instead of
all the way from the top.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
Tested on x86-64, the other architectures have the exact same bug cut'n'pasted.

 arch/sh/mm/mmap.c            |    1 -
 arch/sparc/mm/hugetlbpage.c  |    2 --
 arch/x86/kernel/sys_x86_64.c |    2 --
 mm/mmap.c                    |    2 --
 4 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/arch/sh/mm/mmap.c b/arch/sh/mm/mmap.c
index afeb710..fba1b32 100644
--- a/arch/sh/mm/mmap.c
+++ b/arch/sh/mm/mmap.c
@@ -188,7 +188,6 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	if (unlikely(mm->mmap_base < len))
 		goto bottomup;
 
-	addr = mm->mmap_base-len;
 	if (do_colour_align)
 		addr = COLOUR_ALIGN_DOWN(addr, pgoff);
 
diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
index 07e1453..603a01d 100644
--- a/arch/sparc/mm/hugetlbpage.c
+++ b/arch/sparc/mm/hugetlbpage.c
@@ -115,8 +115,6 @@ hugetlb_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	if (unlikely(mm->mmap_base < len))
 		goto bottomup;
 
-	addr = (mm->mmap_base-len) & HPAGE_MASK;
-
 	do {
 		/*
 		 * Lookup failure means no vma is above this address,
diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index 0514890..1a3fa81 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -240,8 +240,6 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	if (mm->mmap_base < len)
 		goto bottomup;
 
-	addr = mm->mmap_base-len;
-
 	do {
 		addr = align_addr(addr, filp, ALIGN_TOPDOWN);
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 3f758c7..5eafe26 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1479,8 +1479,6 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	if (mm->mmap_base < len)
 		goto bottomup;
 
-	addr = mm->mmap_base-len;
-
 	do {
 		/*
 		 * Lookup failure means no vma is above this address,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
