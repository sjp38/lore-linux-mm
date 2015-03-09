Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 15BBB6B0032
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 03:42:18 -0400 (EDT)
Received: by iecat20 with SMTP id at20so47204427iec.6
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 00:42:17 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id c20si8495793igv.0.2015.03.09.00.42.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Mar 2015 00:42:17 -0700 (PDT)
Received: by igal13 with SMTP id l13so17320014iga.1
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 00:42:17 -0700 (PDT)
Date: Mon, 9 Mar 2015 00:42:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] mm, hugetlb: abort __get_user_pages if current has been
 oom killed
In-Reply-To: <20150309043051.GA13380@node.dhcp.inet.fi>
Message-ID: <alpine.DEB.2.10.1503090041120.21058@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503081611290.15536@chino.kir.corp.google.com> <20150309043051.GA13380@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

If __get_user_pages() is faulting a significant number of hugetlb pages,
usually as the result of mmap(MAP_LOCKED), it can potentially allocate a
very large amount of memory.

If the process has been oom killed, this will cause a lot of memory to
be overcharged to its memcg since it has access to memory reserves or
could potentially deplete all system memory reserves.

In the same way that commit 4779280d1ea4 ("mm: make get_user_pages() 
interruptible") aborted for pending SIGKILLs when faulting non-hugetlb
memory, based on the premise of commit 462e00cc7151 ("oom: stop
allocating user memory if TIF_MEMDIE is set"), hugetlb page faults now
terminate when the process has been oom killed.

Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 v2: check signal inside follow_huegtlb_page() loop per Kirill

 mm/hugetlb.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3276,6 +3276,15 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct page *page;
 
 		/*
+		 * If we have a pending SIGKILL, don't keep faulting pages and
+		 * potentially allocating memory.
+		 */
+		if (unlikely(fatal_signal_pending(current))) {
+			remainder = 0;
+			break;
+		}
+
+		/*
 		 * Some archs (sparc64, sh*) have multiple pte_ts to
 		 * each hugepage.  We have to make sure we get the
 		 * first, for the page indexing below to work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
