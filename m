Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5ED826B5217
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 10:42:01 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id l7-v6so8189801qte.2
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 07:42:01 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d24-v6si3383018qkh.150.2018.08.30.07.42.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 07:42:00 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 3/7] mm/rmap: map_pte() was not handling private ZONE_DEVICE page properly v2
Date: Thu, 30 Aug 2018 10:41:56 -0400
Message-Id: <20180830144156.7226-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
In-Reply-To: <20180824192549.30844-3-jglisse@redhat.com>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Balbir Singh <bsingharora@gmail.com>, stable@vger.kernel.org

From: Ralph Campbell <rcampbell@nvidia.com>

Private ZONE_DEVICE pages use a special pte entry and thus are not
present. Properly handle this case in map_pte(), it is already handled
in check_pte(), the map_pte() part was lost in some rebase most probably.

Without this patch the slow migration path can not migrate back private
ZONE_DEVICE memory to regular memory. This was found after stress
testing migration back to system memory. This ultimatly can lead the
CPU to an infinite page fault loop on the special swap entry.

Changes since v1:
    - properly lock pte directory in map_pte()

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: stable@vger.kernel.org
---
 mm/page_vma_mapped.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
index ae3c2a35d61b..bd67e23dce33 100644
--- a/mm/page_vma_mapped.c
+++ b/mm/page_vma_mapped.c
@@ -21,7 +21,14 @@ static bool map_pte(struct page_vma_mapped_walk *pvmw)
 			if (!is_swap_pte(*pvmw->pte))
 				return false;
 		} else {
-			if (!pte_present(*pvmw->pte))
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
2.17.1
