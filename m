Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE6D6B312D
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 15:25:54 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u129-v6so8613359qkf.15
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 12:25:54 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id o23-v6si1162440qtp.279.2018.08.24.12.25.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 12:25:53 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 2/7] mm/rmap: map_pte() was not handling private ZONE_DEVICE page properly
Date: Fri, 24 Aug 2018 15:25:44 -0400
Message-Id: <20180824192549.30844-3-jglisse@redhat.com>
In-Reply-To: <20180824192549.30844-1-jglisse@redhat.com>
References: <20180824192549.30844-1-jglisse@redhat.com>
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

Without this patch the slow migration path can not migrate back private
ZONE_DEVICE memory to regular memory. This was found after stress
testing migration back to system memory. This ultimatly can lead the
CPU to an infinite page fault loop on the special swap entry.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: stable@vger.kernel.org
---
 mm/page_vma_mapped.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
index ae3c2a35d61b..1cf5b9bfb559 100644
--- a/mm/page_vma_mapped.c
+++ b/mm/page_vma_mapped.c
@@ -21,6 +21,15 @@ static bool map_pte(struct page_vma_mapped_walk *pvmw)
 			if (!is_swap_pte(*pvmw->pte))
 				return false;
 		} else {
+			if (is_swap_pte(*pvmw->pte)) {
+				swp_entry_t entry;
+
+				/* Handle un-addressable ZONE_DEVICE memory */
+				entry = pte_to_swp_entry(*pvmw->pte);
+				if (is_device_private_entry(entry))
+					return true;
+			}
+
 			if (!pte_present(*pvmw->pte))
 				return false;
 		}
-- 
2.17.1
