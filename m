Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 2CD946B0002
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 07:47:33 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id ta14so1869589obb.14
        for <linux-mm@kvack.org>; Mon, 04 Mar 2013 04:47:32 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 4 Mar 2013 20:47:31 +0800
Message-ID: <CAJd=RBD0UWxpMv7W78fH0U_zBAOozP1owaMePGaUEVitotRfBg@mail.gmail.com>
Subject: [PATCH resend] rmap: recompute pgoff for unmapping huge page
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>

[Resend due to error in delivering to linux-kernel@vger.kernel.org,
caused probably by the rich format provided by the mail agent by default.]

We have to recompute pgoff if the given page is huge, since result based on
HPAGE_SIZE is not approapriate for scanning the vma interval tree, as shown
by commit 36e4f20af833(hugetlb: do not use vma_hugecache_offset() for
vma_prio_tree_foreach)

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/rmap.c	Mon Mar  4 20:00:00 2013
+++ b/mm/rmap.c	Mon Mar  4 20:02:16 2013
@@ -1513,6 +1513,9 @@ static int try_to_unmap_file(struct page
 	unsigned long max_nl_size = 0;
 	unsigned int mapcount;

+	if (PageHuge(page))
+		pgoff = page->index << compound_order(page);
+
 	mutex_lock(&mapping->i_mmap_mutex);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
