Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F09186B00E7
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 11:31:28 -0500 (EST)
Date: Tue, 11 Jan 2011 17:31:20 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH mmotm] thp: transparent hugepage core fixlet
Message-ID: <20110111163120.GR9506@random.random>
References: <alpine.LSU.2.00.1101101652200.11559@sister.anvils>
 <20110111015742.GL9506@random.random>
 <AANLkTin=gzZuDBMdGmR5ZY_9f6kggvt0KJA3XK33-z+2@mail.gmail.com>
 <20110111140421.GM9506@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110111140421.GM9506@random.random>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 11, 2011 at 03:04:21PM +0100, Andrea Arcangeli wrote:
> architectural bug to me. Why can't pud_huge simply return 0 for
> x86_32? Any other place dealing with hugepages and calling pud_huge on
> x86 noPAE would be at risk, otherwise, no?

Isn't this better solution?

======
Subject: avoid confusing hugetlbfs code when pmd_trans_huge is set

From: Andrea Arcangeli <aarcange@redhat.com>

If pmd is set huge by THP, pud_huge shouldn't return 1 when pud doesn't exist
and it's just a 1:1 bypass over the pmd (like it happens on 32bit x86 because
there are at most 2 or 3 level of pagetables). Only pmd_huge can return 1.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -227,7 +227,15 @@ int pmd_huge(pmd_t pmd)
 
 int pud_huge(pud_t pud)
 {
+#ifdef CONFIG_X86_64
 	return !!(pud_val(pud) & _PAGE_PSE);
+#else
+	/*
+	 * pud is a bypass with 2 or 3 level pagetables, only pmd_huge
+	 * can return 1.
+	 */
+	return 0;
+#endif
 }
 
 struct page *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
