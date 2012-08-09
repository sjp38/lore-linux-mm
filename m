Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id C2D3B6B0044
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 08:21:38 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so377487vcb.14
        for <linux-mm@kvack.org>; Thu, 09 Aug 2012 05:21:37 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 9 Aug 2012 20:21:37 +0800
Message-ID: <CAJd=RBAjGaOXfQQ_NX+ax6=tJJ0eg7EXCFHz3rdvSR3j1K3qHA@mail.gmail.com>
Subject: [patch] mmap: feed back correct prev vma when finding vma
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>, Mikulas Patocka <mpatocka@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <dhillf@gmail.com>

After walking rb tree, if vma is determined, prev vma has to be determined
based on vma; and rb_prev should be considered only if no vma determined.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/mmap.c	Fri Aug  3 07:38:10 2012
+++ b/mm/mmap.c	Mon Aug  6 20:10:18 2012
@@ -385,9 +385,13 @@ find_vma_prepare(struct mm_struct *mm, u
 		}
 	}

-	*pprev = NULL;
-	if (rb_prev)
-		*pprev = rb_entry(rb_prev, struct vm_area_struct, vm_rb);
+	if (vma) {
+		*pprev = vma->vm_prev;
+	} else {
+		*pprev = NULL;
+		if (rb_prev)
+			*pprev = rb_entry(rb_prev, struct vm_area_struct, vm_rb);
+	}
 	*rb_link = __rb_link;
 	*rb_parent = __rb_parent;
 	return vma;
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
