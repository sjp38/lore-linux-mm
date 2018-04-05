Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id B82166B0007
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 17:03:53 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id k135so17692508qke.6
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 14:03:53 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r47si8872930qtb.201.2018.04.05.14.03.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 14:03:52 -0700 (PDT)
Date: Fri, 6 Apr 2018 00:03:50 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v2 3/3] mm/gup: document return value
Message-ID: <1522962072-182137-6-git-send-email-mst@redhat.com>
References: <1522962072-182137-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522962072-182137-1-git-send-email-mst@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Jonathan Corbet <corbet@lwn.net>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Thorsten Leemhuis <regressions@leemhuis.info>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, linux-mips@linux-mips.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org

__get_user_pages_fast handles errors differently from
get_user_pages_fast: the former always returns the number of pages
pinned, the later might return a negative error code.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 arch/mips/mm/gup.c  | 2 ++
 arch/s390/mm/gup.c  | 2 ++
 arch/sh/mm/gup.c    | 2 ++
 arch/sparc/mm/gup.c | 4 ++++
 mm/gup.c            | 4 +++-
 mm/util.c           | 6 ++++--
 6 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/arch/mips/mm/gup.c b/arch/mips/mm/gup.c
index 1e4658e..5a4875ca 100644
--- a/arch/mips/mm/gup.c
+++ b/arch/mips/mm/gup.c
@@ -178,6 +178,8 @@ static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end,
 /*
  * Like get_user_pages_fast() except its IRQ-safe in that it won't fall
  * back to the regular GUP.
+ * Note a difference with get_user_pages_fast: this always returns the
+ * number of pages pinned, 0 if no pages were pinned.
  */
 int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			  struct page **pages)
diff --git a/arch/s390/mm/gup.c b/arch/s390/mm/gup.c
index 05c8abd..2809d11 100644
--- a/arch/s390/mm/gup.c
+++ b/arch/s390/mm/gup.c
@@ -220,6 +220,8 @@ static inline int gup_p4d_range(pgd_t *pgdp, pgd_t pgd, unsigned long addr,
 /*
  * Like get_user_pages_fast() except its IRQ-safe in that it won't fall
  * back to the regular GUP.
+ * Note a difference with get_user_pages_fast: this always returns the
+ * number of pages pinned, 0 if no pages were pinned.
  */
 int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			  struct page **pages)
diff --git a/arch/sh/mm/gup.c b/arch/sh/mm/gup.c
index 8045b5b..56c86ca 100644
--- a/arch/sh/mm/gup.c
+++ b/arch/sh/mm/gup.c
@@ -160,6 +160,8 @@ static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end,
 /*
  * Like get_user_pages_fast() except its IRQ-safe in that it won't fall
  * back to the regular GUP.
+ * Note a difference with get_user_pages_fast: this always returns the
+ * number of pages pinned, 0 if no pages were pinned.
  */
 int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			  struct page **pages)
diff --git a/arch/sparc/mm/gup.c b/arch/sparc/mm/gup.c
index 5335ba3..ca3eb69 100644
--- a/arch/sparc/mm/gup.c
+++ b/arch/sparc/mm/gup.c
@@ -192,6 +192,10 @@ static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end,
 	return 1;
 }
 
+/*
+ * Note a difference with get_user_pages_fast: this always returns the
+ * number of pages pinned, 0 if no pages were pinned.
+ */
 int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			  struct page **pages)
 {
diff --git a/mm/gup.c b/mm/gup.c
index 8f3a064..5cb5bb1 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1740,7 +1740,9 @@ bool gup_fast_permitted(unsigned long start, int nr_pages, int write)
 
 /*
  * Like get_user_pages_fast() except it's IRQ-safe in that it won't fall back to
- * the regular GUP. It will only return non-negative values.
+ * the regular GUP.
+ * Note a difference with get_user_pages_fast: this always returns the
+ * number of pages pinned, 0 if no pages were pinned.
  */
 int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			  struct page **pages)
diff --git a/mm/util.c b/mm/util.c
index c125050..db2f005 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -297,8 +297,10 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 /*
  * Like get_user_pages_fast() except its IRQ-safe in that it won't fall
  * back to the regular GUP.
- * If the architecture not support this function, simply return with no
- * page pinned
+ * Note a difference with get_user_pages_fast: this always returns the
+ * number of pages pinned, 0 if no pages were pinned.
+ * If the architecture does not support this function, simply return with no
+ * pages pinned.
  */
 int __weak __get_user_pages_fast(unsigned long start,
 				 int nr_pages, int write, struct page **pages)
-- 
MST
