Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 78FD5828DF
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:49:52 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id n1so18834282pfn.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:49:52 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id ds16si10136912pac.149.2016.04.05.14.49.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:49:51 -0700 (PDT)
Received: by mail-pa0-x236.google.com with SMTP id bx7so2401961pad.3
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:49:51 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:49:49 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 21/31] huge tmpfs: show page team flag in pageflags
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051448040.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Andres Lagar-Cavilla <andreslc@google.com>

For debugging and testing.

Signed-off-by: Andres Lagar-Cavilla <andreslc@google.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
This patchset has been based on v4.6-rc2: here we get a clash with
the addition of KPF_MOVABLE in current mmotm, not hard to fix up.

 Documentation/vm/pagemap.txt           |    2 ++
 fs/proc/page.c                         |    6 ++++++
 include/uapi/linux/kernel-page-flags.h |    3 ++-
 tools/vm/page-types.c                  |    2 ++
 4 files changed, 12 insertions(+), 1 deletion(-)

--- a/Documentation/vm/pagemap.txt
+++ b/Documentation/vm/pagemap.txt
@@ -71,6 +71,8 @@ There are four components to pagemap:
     23. BALLOON
     24. ZERO_PAGE
     25. IDLE
+    26. TEAM
+    27. TEAM_PMD_MMAP (only if the whole team is mapped as a pmd at least once)
 
  * /proc/kpagecgroup.  This file contains a 64-bit inode number of the
    memory cgroup each page is charged to, indexed by PFN. Only available when
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -12,6 +12,7 @@
 #include <linux/memcontrol.h>
 #include <linux/mmu_notifier.h>
 #include <linux/page_idle.h>
+#include <linux/pageteam.h>
 #include <linux/kernel-page-flags.h>
 #include <asm/uaccess.h>
 #include "internal.h"
@@ -112,6 +113,11 @@ u64 stable_page_flags(struct page *page)
 	if (PageKsm(page))
 		u |= 1 << KPF_KSM;
 
+	if (PageTeam(page)) {
+		u |= 1 << KPF_TEAM;
+		if (page == team_head(page) && team_pmd_mapped(page))
+			u |= 1 << KPF_TEAM_PMD_MMAP;
+	}
 	/*
 	 * compound pages: export both head/tail info
 	 * they together define a compound page's start/end pos and order
--- a/include/uapi/linux/kernel-page-flags.h
+++ b/include/uapi/linux/kernel-page-flags.h
@@ -34,6 +34,7 @@
 #define KPF_BALLOON		23
 #define KPF_ZERO_PAGE		24
 #define KPF_IDLE		25
-
+#define KPF_TEAM		26
+#define KPF_TEAM_PMD_MMAP	27
 
 #endif /* _UAPILINUX_KERNEL_PAGE_FLAGS_H */
--- a/tools/vm/page-types.c
+++ b/tools/vm/page-types.c
@@ -133,6 +133,8 @@ static const char * const page_flag_name
 	[KPF_BALLOON]		= "o:balloon",
 	[KPF_ZERO_PAGE]		= "z:zero_page",
 	[KPF_IDLE]              = "i:idle_page",
+	[KPF_TEAM]		= "y:team",
+	[KPF_TEAM_PMD_MMAP]	= "Y:team_pmd_mmap",
 
 	[KPF_RESERVED]		= "r:reserved",
 	[KPF_MLOCKED]		= "m:mlocked",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
