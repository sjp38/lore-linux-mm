Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CD3AD6B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 02:34:31 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBA7YT57024255
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 10 Dec 2009 16:34:29 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EA8BC45DE50
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:34:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C81F945DE4F
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:34:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AEE6E1DB803E
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:34:28 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 601821DB8037
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:34:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH v2  7/8] Try to mark PG_mlocked if wipe_page_reference find VM_LOCKED vma
In-Reply-To: <20091210154822.2550.A69D9226@jp.fujitsu.com>
References: <20091210154822.2550.A69D9226@jp.fujitsu.com>
Message-Id: <20091210163331.2565.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 10 Dec 2009 16:34:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

Both try_to_unmap() and wipe_page_reference() walk each ptes, but
latter doesn't mark PG_mlocked altough find VM_LOCKED vma.

This patch does it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/rmap.c   |   14 ++++++++++++++
 mm/vmscan.c |    2 ++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 5ae7c81..cfda0a0 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -376,6 +376,7 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
  *
  * SWAP_SUCCESS  - success
  * SWAP_AGAIN    - give up to take lock, try later again
+ * SWAP_MLOCK    - the page is mlocked
  */
 int wipe_page_reference_one(struct page *page,
 			    struct page_reference_context *refctx,
@@ -401,6 +402,7 @@ int wipe_page_reference_one(struct page *page,
 	if (IS_ERR(pte)) {
 		if (PTR_ERR(pte) == -EAGAIN) {
 			ret = SWAP_AGAIN;
+			goto out_mlock;
 		}
 		goto out;
 	}
@@ -430,6 +432,17 @@ int wipe_page_reference_one(struct page *page,
 
 out:
 	return ret;
+
+out_mlock:
+	if (refctx->is_page_locked &&
+	    down_read_trylock(&vma->vm_mm->mmap_sem)) {
+		if (vma->vm_flags & VM_LOCKED) {
+			mlock_vma_page(page);
+			ret = SWAP_MLOCK;
+		}
+		up_read(&vma->vm_mm->mmap_sem);
+	}
+	return ret;
 }
 
 static int wipe_page_reference_anon(struct page *page,
@@ -550,6 +563,7 @@ static int wipe_page_reference_file(struct page *page,
  *
  * SWAP_SUCCESS  - success to wipe all ptes
  * SWAP_AGAIN    - temporary busy, try again later
+ * SWAP_MLOCK    - the page is mlocked
  */
 int wipe_page_reference(struct page *page,
 			struct mem_cgroup *memcg,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c235059..4738a12 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -625,6 +625,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		ret = wipe_page_reference(page, sc->mem_cgroup, &refctx);
 		if (ret == SWAP_AGAIN)
 			goto keep_locked;
+		else if (ret == SWAP_MLOCK)
+			goto cull_mlocked;
 		VM_BUG_ON(ret != SWAP_SUCCESS);
 
 		/*
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
