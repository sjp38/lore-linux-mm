Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D1BC06B0038
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 14:51:16 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x70so14521886pfk.0
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 11:51:16 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id h185si3741684pgc.324.2016.10.21.11.51.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 21 Oct 2016 11:51:15 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4] shmem: avoid huge pages for small files
Date: Fri, 21 Oct 2016 21:51:03 +0300
Message-Id: <20161021185103.117938-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Huge pages are detrimental for small file: they causes noticible
overhead on both allocation performance and memory footprint.

This patch aimed to address this issue by avoiding huge pages until file
grown to size of huge page. This would cover most of the cases where huge
pages causes regressions in performance.

Couple notes:

  - if shmem_enabled is set to 'force', the limit is ignored. We still
    want to generate as many pages as possible for functional testing.

  - the limit doesn't affect khugepaged behaviour: it still can collapse
    pages based on its settings;

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/vm/transhuge.txt | 3 +++
 mm/shmem.c                     | 5 +++++
 2 files changed, 8 insertions(+)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index 2ec6adb5a4ce..d1889c7c8c46 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -238,6 +238,9 @@ values:
   - "force":
     Force the huge option on for all - very useful for testing;
 
+To avoid overhead for small files, we don't allocate huge pages for a file
+until it grows to size of huge pages.
+
 == Need of application restart ==
 
 The transparent_hugepage/enabled values and tmpfs mount option only affect
diff --git a/mm/shmem.c b/mm/shmem.c
index ad7813d73ea7..c7b3cb5aecdc 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1692,6 +1692,11 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 				goto alloc_huge;
 			/* TODO: implement fadvise() hints */
 			goto alloc_nohuge;
+		case SHEME_HUGE_ALWAYS:
+			i_size = i_size_read(inode);
+			if (index < HPAGE_PMD_NR && i_size < HPAGE_PMD_SIZE)
+				goto alloc_nohuge;
+			break;
 		}
 
 alloc_huge:
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
