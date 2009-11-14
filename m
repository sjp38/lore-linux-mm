Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 63EA96B0088
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:25 -0500 (EST)
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nAEIAN9P011348
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:24 -0500
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 22 of 25] split_huge_page paging
Message-Id: <57e7f057bfa6b6455213.1258220320@v2.random>
In-Reply-To: <patchbomb.1258220298@v2.random>
References: <patchbomb.1258220298@v2.random>
Date: Sat, 14 Nov 2009 17:38:40 -0000
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Paging logic that splits the page before it is unmapped and added to swap to
ensure backwards compatibility with the legacy swap code. Eventually swap
should natively pageout the hugepages to increase performance and decrease
seeking and fragmentation of swap space. swapoff can just skip over huge pmd as
they cannot be part of swap yet.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1248,6 +1248,10 @@ int try_to_unmap(struct page *page, enum
 
 	BUG_ON(!PageLocked(page));
 
+	if (unlikely(PageCompound(page)))
+		if (unlikely(split_huge_page(page)))
+			return SWAP_AGAIN;
+
 	if (PageAnon(page))
 		ret = try_to_unmap_anon(page, flags);
 	else
diff --git a/mm/swap_state.c b/mm/swap_state.c
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -152,6 +152,10 @@ int add_to_swap(struct page *page)
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(!PageUptodate(page));
 
+	if (unlikely(PageCompound(page)))
+		if (unlikely(split_huge_page(page)))
+			return 0;
+
 	entry = get_swap_page();
 	if (!entry.val)
 		return 0;
diff --git a/mm/swapfile.c b/mm/swapfile.c
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -896,6 +896,8 @@ static inline int unuse_pmd_range(struct
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
+		if (unlikely(pmd_trans_huge(*pmd)))
+			continue;
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
 		ret = unuse_pte_range(vma, pmd, addr, next, entry, page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
