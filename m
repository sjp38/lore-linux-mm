Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0GIoUMM003352
	for <linux-mm@kvack.org>; Wed, 16 Jan 2008 13:50:30 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0GIoHkD093642
	for <linux-mm@kvack.org>; Wed, 16 Jan 2008 11:50:18 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0GIoHn3008870
	for <linux-mm@kvack.org>; Wed, 16 Jan 2008 11:50:17 -0700
Subject: Re: [RFC] shared page table for hugetlbpage memory causing leak.
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <478E3DFA.9050900@redhat.com>
References: <478E3DFA.9050900@redhat.com>
Content-Type: text/plain
Date: Wed, 16 Jan 2008 12:54:28 -0600
Message-Id: <1200509668.3296.204.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Larry Woodman <lwoodman@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Since we know we are dealing with a hugetlb VMA, how about the
following, simpler, _untested_ patch:

Signed-off-by: Adam Litke <agl@us.ibm.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6f97821..75b0e4f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -644,6 +644,11 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 		dst_pte = huge_pte_alloc(dst, addr);
 		if (!dst_pte)
 			goto nomem;
+
+		/* If page table is shared do not copy or take references */
+		if (src_pte == dst_pte)
+			continue;
+
 		spin_lock(&dst->page_table_lock);
 		spin_lock(&src->page_table_lock);
 		if (!pte_none(*src_pte)) {


-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
