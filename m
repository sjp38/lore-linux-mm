Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EDED56B0047
	for <linux-mm@kvack.org>; Sat,  2 Oct 2010 20:46:13 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o930kB13005140
	for <linux-mm@kvack.org>; Sat, 2 Oct 2010 17:46:11 -0700
Received: from pzk28 (pzk28.prod.google.com [10.243.19.156])
	by wpaz37.hot.corp.google.com with ESMTP id o930kAIF025858
	for <linux-mm@kvack.org>; Sat, 2 Oct 2010 17:46:10 -0700
Received: by pzk28 with SMTP id 28so958497pzk.39
        for <linux-mm@kvack.org>; Sat, 02 Oct 2010 17:46:10 -0700 (PDT)
Date: Sat, 2 Oct 2010 17:46:06 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] ksm: fix page_address_in_vma anon_vma oops
Message-ID: <alpine.LSU.2.00.1010021742070.27679@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

2.6.36-rc1 commit 21d0d443cdc1658a8c1484fdcece4803f0f96d0e "rmap:
resurrect page_address_in_vma anon_vma check" was right to resurrect
that check; but now that it's comparing anon_vma->roots instead of
just anon_vmas, there's a danger of oopsing on a NULL anon_vma.

In most cases no NULL anon_vma ever gets here; but it turns out that
occasionally KSM, when enabled on a forked or forking process, will
itself call page_address_in_vma() on a "half-KSM" page left over from
an earlier failed attempt to merge - whose page_anon_vma() is NULL.

It's my bug that those should be getting here at all: I thought they
were already dealt with, this oops proves me wrong, I'll fix it in
the next release - such pages are effectively pinned until their
process exits, since rmap cannot find their ptes (though swapoff can).

For now just work around it by making page_address_in_vma() safe (and
add a comment on why that check is wanted anyway).  A similar check
in __page_check_anon_rmap() is safe because do_page_add_anon_rmap()
already excluded KSM pages.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/rmap.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

--- 2.6.36-rc6/mm/rmap.c	2010-09-28 22:42:43.000000000 -0700
+++ linux/mm/rmap.c	2010-09-28 23:27:05.000000000 -0700
@@ -381,7 +381,13 @@ vma_address(struct page *page, struct vm
 unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
 {
 	if (PageAnon(page)) {
-		if (vma->anon_vma->root != page_anon_vma(page)->root)
+		struct anon_vma *page__anon_vma = page_anon_vma(page);
+		/*
+		 * Note: swapoff's unuse_vma() is more efficient with this
+		 * check, and needs it to match anon_vma when KSM is active.
+		 */
+		if (!vma->anon_vma || !page__anon_vma ||
+		    vma->anon_vma->root != page__anon_vma->root)
 			return -EFAULT;
 	} else if (page->mapping && !(vma->vm_flags & VM_NONLINEAR)) {
 		if (!vma->vm_file ||

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
