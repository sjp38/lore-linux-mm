Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DFFB76B0006
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:25:40 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p9so5549645pfk.5
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 11:25:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 64sor1188026pgj.144.2018.03.16.11.25.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Mar 2018 11:25:39 -0700 (PDT)
From: Wei Wang <wvw@google.com>
Subject: [PATCH] mm: add config for readahead window
Date: Fri, 16 Mar 2018 11:25:08 -0700
Message-Id: <20180316182512.118361-1-wvw@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: gregkh@linuxfoundation.org, toddpoynor@google.com, wei.vince.wang@gmail.com, Wei Wang <wvw@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@kernel.org>, Sherry Cheung <SCheung@nvidia.com>, Oliver O'Halloran <oohall@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Huang Ying <ying.huang@intel.com>, Dennis Zhou <dennisz@fb.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Wei Wang <wvw@google.com>

Change VM_MAX_READAHEAD value from the default 128KB to a configurable
value. This will allow the readahead window to grow to a maximum size
bigger than 128KB during boot, which could benefit to sequential read
throughput and thus boot performance.

Signed-off-by: Wei Wang <wvw@google.com>
---
 include/linux/mm.h | 2 +-
 mm/Kconfig         | 8 ++++++++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad06d42adb1a..d7dc6125833e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2291,7 +2291,7 @@ int __must_check write_one_page(struct page *page);
 void task_dirty_inc(struct task_struct *tsk);
 
 /* readahead.c */
-#define VM_MAX_READAHEAD	128	/* kbytes */
+#define VM_MAX_READAHEAD	CONFIG_VM_MAX_READAHEAD_KB
 #define VM_MIN_READAHEAD	16	/* kbytes (includes current page) */
 
 int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
diff --git a/mm/Kconfig b/mm/Kconfig
index c782e8fb7235..da9ff543bdb9 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -760,3 +760,11 @@ config GUP_BENCHMARK
 	  performance of get_user_pages_fast().
 
 	  See tools/testing/selftests/vm/gup_benchmark.c
+
+config VM_MAX_READAHEAD_KB
+	int "Default max readahead window size in Kilobytes"
+	default 128
+	help
+	  This sets the VM_MAX_READAHEAD value to allow the readahead window
+	  to grow to a maximum size of configured. Increasing this value will
+	  benefit sequential read throughput.
-- 
2.16.2.804.g6dcf76e118-goog
