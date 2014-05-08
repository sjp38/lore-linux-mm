Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id ECBEB6B00E4
	for <linux-mm@kvack.org>; Thu,  8 May 2014 08:41:39 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id w8so2421813qac.19
        for <linux-mm@kvack.org>; Thu, 08 May 2014 05:41:39 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id xt2si454485pbb.412.2014.05.08.05.41.38
        for <linux-mm@kvack.org>;
        Thu, 08 May 2014 05:41:39 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/2] mm: mark remap_file_pages() syscall as deprecated
Date: Thu,  8 May 2014 15:41:27 +0300
Message-Id: <1399552888-11024-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The remap_file_pages() system call is used to create a nonlinear mapping,
that is, a mapping in which the pages of the file are mapped into a
nonsequential order in memory. The advantage of using remap_file_pages()
over using repeated calls to mmap(2) is that the former approach does not
require the kernel to create additional VMA (Virtual Memory Area) data
structures.

Supporting of nonlinear mapping requires significant amount of non-trivial
code in kernel virtual memory subsystem including hot paths. Also to get
nonlinear mapping work kernel need a way to distinguish normal page table
entries from entries with file offset (pte_file). Kernel reserves flag in
PTE for this purpose. PTE flags are scarce resource especially on some CPU
architectures. It would be nice to free up the flag for other usage.

Fortunately, there are not many users of remap_file_pages() in the wild.
It's only known that one enterprise RDBMS implementation uses the syscall
on 32-bit systems to map files bigger than can linearly fit into 32-bit
virtual address space. This use-case is not critical anymore since 64-bit
systems are widely available.

The plan is to deprecate the syscall and replace it with an emulation.
The emulation will create new VMAs instead of nonlinear mappings. It's
going to work slower for rare users of remap_file_pages() but ABI is
preserved.

One side effect of emulation (apart from performance) is that user can hit
vm.max_map_count limit more easily due to additional VMAs. See comment for
DEFAULT_MAX_MAP_COUNT for more details on the limit.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/vm/remap_file_pages.txt | 28 ++++++++++++++++++++++++++++
 mm/fremap.c                           |  4 ++++
 2 files changed, 32 insertions(+)
 create mode 100644 Documentation/vm/remap_file_pages.txt

diff --git a/Documentation/vm/remap_file_pages.txt b/Documentation/vm/remap_file_pages.txt
new file mode 100644
index 000000000000..560e4363a55d
--- /dev/null
+++ b/Documentation/vm/remap_file_pages.txt
@@ -0,0 +1,28 @@
+The remap_file_pages() system call is used to create a nonlinear mapping,
+that is, a mapping in which the pages of the file are mapped into a
+nonsequential order in memory. The advantage of using remap_file_pages()
+over using repeated calls to mmap(2) is that the former approach does not
+require the kernel to create additional VMA (Virtual Memory Area) data
+structures.
+
+Supporting of nonlinear mapping requires significant amount of non-trivial
+code in kernel virtual memory subsystem including hot paths. Also to get
+nonlinear mapping work kernel need a way to distinguish normal page table
+entries from entries with file offset (pte_file). Kernel reserves flag in
+PTE for this purpose. PTE flags are scarce resource especially on some CPU
+architectures. It would be nice to free up the flag for other usage.
+
+Fortunately, there are not many users of remap_file_pages() in the wild.
+It's only known that one enterprise RDBMS implementation uses the syscall
+on 32-bit systems to map files bigger than can linearly fit into 32-bit
+virtual address space. This use-case is not critical anymore since 64-bit
+systems are widely available.
+
+The plan is to deprecate the syscall and replace it with an emulation.
+The emulation will create new VMAs instead of nonlinear mappings. It's
+going to work slower for rare users of remap_file_pages() but ABI is
+preserved.
+
+One side effect of emulation (apart from performance) is that user can hit
+vm.max_map_count limit more easily due to additional VMAs. See comment for
+DEFAULT_MAX_MAP_COUNT for more details on the limit.
diff --git a/mm/fremap.c b/mm/fremap.c
index 34feba60a17e..12c3bb63b7f9 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -152,6 +152,10 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	int has_write_lock = 0;
 	vm_flags_t vm_flags = 0;
 
+	pr_warn_once("%s (%d) uses depricated remap_file_pages() syscall. "
+			"See Documentation/vm/remap_file_pages.txt.\n",
+			current->comm, current->pid);
+
 	if (prot)
 		return err;
 	/*
-- 
2.0.0.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
