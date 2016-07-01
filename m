Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A48D66B025F
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 20:12:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g62so204227816pfb.3
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 17:12:31 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ai12si908080pac.139.2016.06.30.17.12.29
        for <linux-mm@kvack.org>;
        Thu, 30 Jun 2016 17:12:30 -0700 (PDT)
Subject: [PATCH 4/6] mm: move flush in madvise_free_pte_range()
From: Dave Hansen <dave@sr71.net>
Date: Thu, 30 Jun 2016 17:12:15 -0700
References: <20160701001209.7DA24D1C@viggo.jf.intel.com>
In-Reply-To: <20160701001209.7DA24D1C@viggo.jf.intel.com>
Message-Id: <20160701001215.C0689717@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, mhocko@suse.com, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, minchan@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

I think this code is OK and does not *need* to be patched.  We
are just rewriting the PTE without the Accessed and Dirty bits.
The hardware could come along and set them at any time with or
without the erratum that this series addresses

But this does make the ptep_get_and_clear_full() and
tlb_remove_tlb_entry() calls here more consistent with the other
places they are used together and look *obviously* the same
between call-sites.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Minchan Kim <minchan@kernel.org>
---

 b/mm/madvise.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN mm/madvise.c~knl-leak-40-madvise_free_pte_range-move-flush mm/madvise.c
--- a/mm/madvise.c~knl-leak-40-madvise_free_pte_range-move-flush	2016-06-30 17:10:42.557246755 -0700
+++ b/mm/madvise.c	2016-06-30 17:10:42.561246936 -0700
@@ -369,13 +369,13 @@ static int madvise_free_pte_range(pmd_t
 			 */
 			ptent = ptep_get_and_clear_full(mm, addr, pte,
 							tlb->fullmm);
+			tlb_remove_tlb_entry(tlb, pte, addr);
 
 			ptent = pte_mkold(ptent);
 			ptent = pte_mkclean(ptent);
 			set_pte_at(mm, addr, pte, ptent);
 			if (PageActive(page))
 				deactivate_page(page);
-			tlb_remove_tlb_entry(tlb, pte, addr);
 		}
 	}
 out:
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
