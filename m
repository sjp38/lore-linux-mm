Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id D7C766B006E
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 14:48:28 -0400 (EDT)
Received: by mail-yk0-f170.google.com with SMTP id 9so24153652ykp.1
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 11:48:28 -0700 (PDT)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id k22si37681337yhj.107.2014.03.11.11.48.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 11:48:28 -0700 (PDT)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv2] mm/vmalloc: avoid soft lockup warnings when vunmap()'ing large ranges
Date: Tue, 11 Mar 2014 18:40:23 +0000
Message-ID: <1394563223-5045-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, xen-devel@lists.xenproject.org, Dietmar Hahn <dietmar.hahn@ts.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>

If vunmap() is used to unmap a large (e.g., 50 GB) region, it may take
sufficiently long that it triggers soft lockup warnings.

Add a cond_resched() into vunmap_pmd_range() so the calling task may
be resheduled after unmapping each PMD entry.  This is how
zap_pmd_range() fixes the same problem for userspace mappings.

All callers may sleep except for the APEI GHES driver (apei/ghes.c)
which calls unmap_kernel_range_no_flush() from NMI and IRQ contexts.
This driver only unmaps a single pages so don't call cond_resched() if
the unmap doesn't cross a PMD boundary.

Reported-by: Dietmar Hahn <dietmar.hahn@ts.fujitsu.com>
Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
v2: don't call cond_resched() at the end of a PMD range.
---
 mm/vmalloc.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 0fdf968..1a8b162 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -75,6 +75,8 @@ static void vunmap_pmd_range(pud_t *pud, unsigned long addr, unsigned long end)
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
 		vunmap_pte_range(pmd, addr, next);
+		if (next != end)
+			cond_resched();
 	} while (pmd++, addr = next, addr != end);
 }
 
-- 
1.7.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
