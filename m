Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4952A82F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 18:46:12 -0400 (EDT)
Received: by obbwb3 with SMTP id wb3so75557129obb.0
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 15:46:12 -0700 (PDT)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id yu9si3392336oeb.26.2015.10.16.15.46.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 15:46:11 -0700 (PDT)
Received: by oies66 with SMTP id s66so32503132oie.1
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 15:46:11 -0700 (PDT)
Date: Fri, 16 Oct 2015 15:46:03 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH mmotm] mm: dont split thp page when syscall is called fix 4
Message-ID: <alpine.LSU.2.11.1510161540460.31102@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Compiler gives helpful warnings that madvise_free_pte_range()
has the args to split_huge_pmd() the wrong way round.

Signed-off-by: Hugh Dickins <hughd@google.com>

--- mmotm/mm/madvise.c	2015-10-15 15:26:59.839572171 -0700
+++ linux/mm/madvise.c	2015-10-16 11:59:10.144527813 -0700
@@ -283,7 +283,7 @@ static int madvise_free_pte_range(pmd_t
 	next = pmd_addr_end(addr, end);
 	if (pmd_trans_huge(*pmd)) {
 		if (next - addr != HPAGE_PMD_SIZE)
-			split_huge_pmd(vma, addr, pmd);
+			split_huge_pmd(vma, pmd, addr);
 		else if (!madvise_free_huge_pmd(tlb, vma, pmd, addr))
 			goto next;
 		/* fall through */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
