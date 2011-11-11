Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8903B6B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 08:01:23 -0500 (EST)
Received: by wyg24 with SMTP id 24so5147111wyg.14
        for <linux-mm@kvack.org>; Fri, 11 Nov 2011 05:01:20 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Nov 2011 21:01:20 +0800
Message-ID: <CAJd=RBC5Q48r0sYeqF9bucaBJPv3LR4UTAannUZ8KXxoXY_Qcw@mail.gmail.com>
Subject: [PATCH] hugetlb: release pages in the error path of hugetlb_cow()
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

If fail to prepare anon_vma, {new, old}_page should be released, or they will
escape the track and/or control of memory management.

Thanks

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/hugetlb.c	Fri Nov 11 20:36:32 2011
+++ b/mm/hugetlb.c	Fri Nov 11 20:43:06 2011
@@ -2422,6 +2422,8 @@ retry_avoidcopy:
 	 * anon_vma prepared.
 	 */
 	if (unlikely(anon_vma_prepare(vma))) {
+		page_cache_release(new_page);
+		page_cache_release(old_page);
 		/* Caller expects lock to be held */
 		spin_lock(&mm->page_table_lock);
 		return VM_FAULT_OOM;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
