Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6B9086B0005
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 14:33:49 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id a4so224311600wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 11:33:49 -0800 (PST)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id d73si41459770wma.57.2016.02.23.11.33.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 11:33:48 -0800 (PST)
Received: by mail-wm0-x235.google.com with SMTP id g62so239050841wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 11:33:48 -0800 (PST)
Date: Tue, 23 Feb 2016 22:33:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe also
 on PowerPC and ARM)
Message-ID: <20160223193345.GC21820@node.shutemov.name>
References: <20160211192223.4b517057@thinkpad>
 <20160211190942.GA10244@node.shutemov.name>
 <20160211205702.24f0d17a@thinkpad>
 <20160212154116.GA15142@node.shutemov.name>
 <56BE00E7.1010303@de.ibm.com>
 <20160212181640.4eabb85f@thinkpad>
 <20160223103221.GA1418@node.shutemov.name>
 <20160223191907.25719a4d@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160223191907.25719a4d@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>

On Tue, Feb 23, 2016 at 07:19:07PM +0100, Gerald Schaefer wrote:
> I'll check with Martin, maybe it is actually trivial, then we can
> do a quick test it to rule that one out.

Oh. I found a bug in __split_huge_pmd_locked(). Although, not sure if it's
_the_ bug.

pmdp_invalidate() is called for the wrong address :-/
I guess that can be destructive on the architecture, right?

Could you check this?

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1c317b85ea7d..4246bc70e55a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2865,7 +2865,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
 	pmd_populate(mm, &_pmd, pgtable);
 
-	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
+	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		pte_t entry, *pte;
 		/*
 		 * Note that NUMA hinting access restrictions are not
@@ -2886,9 +2886,9 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		}
 		if (dirty)
 			SetPageDirty(page + i);
-		pte = pte_offset_map(&_pmd, haddr);
+		pte = pte_offset_map(&_pmd, haddr + i * PAGE_SIZE);
 		BUG_ON(!pte_none(*pte));
-		set_pte_at(mm, haddr, pte, entry);
+		set_pte_at(mm, haddr + i * PAGE_SIZE, pte, entry);
 		atomic_inc(&page[i]._mapcount);
 		pte_unmap(pte);
 	}
@@ -2938,7 +2938,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	pmd_populate(mm, pmd, pgtable);
 
 	if (freeze) {
-		for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
+		for (i = 0; i < HPAGE_PMD_NR; i++) {
 			page_remove_rmap(page + i, false);
 			put_page(page + i);
 		}
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
