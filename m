Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id D00706B000E
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 12:04:51 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id t27-v6so37583057qta.1
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 09:04:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c7-v6si2047455qtp.300.2018.10.19.09.04.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Oct 2018 09:04:50 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 2/6] mm/rmap: map_pte() was not handling private ZONE_DEVICE page properly v3
Date: Fri, 19 Oct 2018 12:04:38 -0400
Message-Id: <20181019160442.18723-3-jglisse@redhat.com>
In-Reply-To: <20181019160442.18723-1-jglisse@redhat.com>
References: <20181019160442.18723-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, stable@vger.kernel.org

From: Ralph Campbell <rcampbell@nvidia.com>

Private ZONE_DEVICE pages use a special pte entry and thus are not
present. Properly handle this case in map_pte(), it is already handled
in check_pte(), the map_pte() part was lost in some rebase most probably.

Without this patch the slow migration path can not migrate back to any
private ZONE_DEVICE memory to regular memory. This was found after stress
testing migration back to system memory. This ultimatly can lead to the CPU
constantly page fault looping on the special swap entry.

Changes since v2:
    - add comments explaining what is going on
Changes since v1:
    - properly lock pte directory in map_pte()

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Reviewed-by: Balbir Singh <bsingharora@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: stable@vger.kernel.org
---
 mm/page_vma_mapped.c | 24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
index ae3c2a35d61b..11df03e71288 100644
--- a/mm/page_vma_mapped.c
+++ b/mm/page_vma_mapped.c
@@ -21,7 +21,29 @@ static bool map_pte(struct page_vma_mapped_walk *pvmw)
 			if (!is_swap_pte(*pvmw->pte))
 				return false;
 		} else {
-			if (!pte_present(*pvmw->pte))
+			/*
+			 * We get here when we are trying to unmap a private
+			 * device page from the process address space. Such
+			 * page is not CPU accessible and thus is mapped as
+			 * a special swap entry, nonetheless it still does
+			 * count as a valid regular mapping for the page (and
+			 * is accounted as such in page maps count).
+			 *
+			 * So handle this special case as if it was a normal
+			 * page mapping ie lock CPU page table and returns
+			 * true.
+			 *
+			 * For more details on device private memory see HMM
+			 * (include/linux/hmm.h or mm/hmm.c).
+			 */
+			if (is_swap_pte(*pvmw->pte)) {
+				swp_entry_t entry;
+
+				/* Handle un-addressable ZONE_DEVICE memory */
+				entry = pte_to_swp_entry(*pvmw->pte);
+				if (!is_device_private_entry(entry))
+					return false;
+			} else if (!pte_present(*pvmw->pte))
 				return false;
 		}
 	}
-- 
2.17.2
