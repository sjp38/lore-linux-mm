Message-ID: <478E5306.5030709@redhat.com>
Date: Wed, 16 Jan 2008 13:55:02 -0500
From: Larry Woodman <lwoodman@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] shared page table for hugetlbpage memory causing leak.
References: <478E3DFA.9050900@redhat.com> <1200509668.3296.204.camel@localhost.localdomain>
In-Reply-To: <1200509668.3296.204.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Adam Litke wrote:

>Since we know we are dealing with a hugetlb VMA, how about the
>following, simpler, _untested_ patch:
>
>Signed-off-by: Adam Litke <agl@us.ibm.com>
>
>diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>index 6f97821..75b0e4f 100644
>--- a/mm/hugetlb.c
>+++ b/mm/hugetlb.c
>@@ -644,6 +644,11 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
> 		dst_pte = huge_pte_alloc(dst, addr);
> 		if (!dst_pte)
> 			goto nomem;
>+
>+		/* If page table is shared do not copy or take references */
>+		if (src_pte == dst_pte)
>+			continue;
>+
> 		spin_lock(&dst->page_table_lock);
> 		spin_lock(&src->page_table_lock);
> 		if (!pte_none(*src_pte)) {
>
>
>  
>
Agreed.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
