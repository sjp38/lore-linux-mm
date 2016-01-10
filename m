Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9F596828F3
	for <linux-mm@kvack.org>; Sat,  9 Jan 2016 19:51:10 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id q63so27699147pfb.1
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 16:51:10 -0800 (PST)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id rt5si15254953pab.98.2016.01.09.16.51.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jan 2016 16:51:09 -0800 (PST)
Received: by mail-pf0-x22b.google.com with SMTP id n128so26973523pfn.3
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 16:51:09 -0800 (PST)
Date: Sat, 9 Jan 2016 16:50:53 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH next] powerpc/mm: fix _PAGE_PTE breaking swapoff
Message-ID: <alpine.LSU.2.11.1601091643060.9808@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Swapoff after swapping hangs on the G5.  That's because the _PAGE_PTE
bit, added by set_pte_at(), is not expected by swapoff: so swap ptes
cannot be recognized.

I'm not sure whether a swap pte should or should not have _PAGE_PTE set:
this patch assumes not, and fixes set_pte_at() to set _PAGE_PTE only on
present entries.

But if that's wrong, a reasonable alternative would be to
#define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) & ~_PAGE_PTE })
#define __swp_entry_to_pte(x)	__pte((x).val | _PAGE_PTE)

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 arch/powerpc/mm/pgtable.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- 4.4-next/arch/powerpc/mm/pgtable.c	2016-01-06 11:54:01.477512251 -0800
+++ linux/arch/powerpc/mm/pgtable.c	2016-01-09 13:51:15.793485717 -0800
@@ -180,9 +180,10 @@ void set_pte_at(struct mm_struct *mm, un
 	VM_WARN_ON((pte_val(*ptep) & (_PAGE_PRESENT | _PAGE_USER)) ==
 		(_PAGE_PRESENT | _PAGE_USER));
 	/*
-	 * Add the pte bit when tryint set a pte
+	 * Add the pte bit when setting a pte (not a swap entry)
 	 */
-	pte = __pte(pte_val(pte) | _PAGE_PTE);
+	if (pte_val(pte) & _PAGE_PRESENT)
+		pte = __pte(pte_val(pte) | _PAGE_PTE);
 
 	/* Note: mm->context.id might not yet have been assigned as
 	 * this context might not have been activated yet when this

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
