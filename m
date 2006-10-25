Date: Wed, 25 Oct 2006 03:38:24 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 3/3] hugetlb: fix absurd HugePages_Rsvd
In-Reply-To: <Pine.LNX.4.64.0610250323570.30678@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0610250335530.30678@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0610250323570.30678@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Ken Chen <kenneth.w.chen@intel.com>, Bill Irwin <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If you truncated an mmap'ed hugetlbfs file, then faulted on the truncated
area, /proc/meminfo's HugePages_Rsvd wrapped hugely "negative".  Reinstate
my preliminary i_size check before attempting to allocate the page (though
this only fixes the most obvious case: more work will be needed here).

Signed-off-by: Hugh Dickins <hugh@veritas.com>
___

This is not a complete solution (what if hugetlb_no_page is actually
racing with truncate_hugepages?), and there are several other accounting
anomalies in here (private versus shared pages, hugetlbfs quota handling);
but those all need more thought.  It'll probably make sense to use i_mutex
instead of hugetlb_instantiation_mutex, so locking out truncation and mmap.

 mm/hugetlb.c |    3 +++
 1 file changed, 3 insertions(+)

--- 2.6.19-rc3/mm/hugetlb.c	2006-10-24 04:34:37.000000000 +0100
+++ linux/mm/hugetlb.c	2006-10-24 16:23:17.000000000 +0100
@@ -478,6 +478,9 @@ int hugetlb_no_page(struct mm_struct *mm
 retry:
 	page = find_lock_page(mapping, idx);
 	if (!page) {
+		size = i_size_read(mapping->host) >> HPAGE_SHIFT;
+		if (idx >= size)
+			goto out;
 		if (hugetlb_get_quota(mapping))
 			goto out;
 		page = alloc_huge_page(vma, address);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
