Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 483A46B0037
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 03:38:55 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC v7 03/11] add new system call vrange(2)
Date: Tue, 12 Mar 2013 16:38:27 +0900
Message-Id: <1363073915-25000-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1363073915-25000-1-git-send-email-minchan@kernel.org>
References: <1363073915-25000-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, John Stultz <john.stultz@linaro.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>

This patch adds new system call sys_vrange.

NAME
	vrange - give pin/unpin hint for kernel to help reclaim.

SYNOPSIS
	int vrange(unsigned_long start, size_t length, int mode, int behavior);

DESCRIPTOIN
	Applications can use vrange(2) to advise the kernel how it should
	handle paging I/O in this VM area.  The idea is to help the kernel
	discard pages of vrange instead of reclaiming when memory pressure
	happens. It means kernel doesn't discard any pages of vrange if ther is
	no memory pressure.

	mode:

	VRANGE_VOLATILE
		hint to kernel so VM can discard in vrange pages when
		memory pressure happens.
	VRANGE_NOVOLATILE
		hint to kernel so VM doesn't discard vrange pages
		any more.

	behavior:

	VRANGE_FULL_MODE
		Once VM start to discard pages, it discards all pages
		in a vrange.
	VRANGE_PARTIAL_MODE
		VM discards some pages of all vranges by round-robin
		return values:

	If user try to access purged memory without VRANGE_NOVOLATILE call,
	he can encounter SIGBUS if the page was discarded by kernel.

RETURN VALUE
	On success vrange returns zero or 1. zero means kernel doesn't discard
	any pages on [start, start + length). 1 means kernel did discard
	one of pages on the range.

ERRORS
	EINVAL This error can occur for the following reasons:

		* The value length is negative.
		* addr is not page-aligned
		* mode or behavior are not a vaild value.

	ENOMEM Not enough memory

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 arch/x86/syscalls/syscall_64.tbl       |  1 +
 include/uapi/asm-generic/mman-common.h |  5 +++
 mm/vrange.c                            | 58 ++++++++++++++++++++++++++++++++++
 3 files changed, 64 insertions(+)

diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
index 38ae65d..dc332bd 100644
--- a/arch/x86/syscalls/syscall_64.tbl
+++ b/arch/x86/syscalls/syscall_64.tbl
@@ -320,6 +320,7 @@
 311	64	process_vm_writev	sys_process_vm_writev
 312	common	kcmp			sys_kcmp
 313	common	finit_module		sys_finit_module
+314	common	vrange			sys_vrange
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 4164529..736696e 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -66,4 +66,9 @@
 #define MAP_HUGE_SHIFT	26
 #define MAP_HUGE_MASK	0x3f
 
+#define VRANGE_VOLATILE	0	/* unpin all pages so VM can discard them */
+#define VRANGE_NOVOLATILE	1	/* pin all pages so VM can't discard them */
+
+#define VRANGE_FULL_MODE	0	/* discard all pages of the range */
+#define VRANGE_PARTIAL_MODE	1	/* discard a few pages of the range */
 #endif /* __ASM_GENERIC_MMAN_COMMON_H */
diff --git a/mm/vrange.c b/mm/vrange.c
index e265c82..2f77d89 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -4,6 +4,8 @@
 
 #include <linux/vrange.h>
 #include <linux/slab.h>
+#include <linux/syscalls.h>
+#include <linux/mman.h>
 
 static struct kmem_cache *vrange_cachep;
 
@@ -155,3 +157,59 @@ void exit_vrange(struct mm_struct *mm)
 		free_vrange(range);
 	}
 }
+
+/*
+ * The vrange(2) system call.
+ *
+ * Applications can use vrange() to advise the kernel how it should
+ * handle paging I/O in this VM area.  The idea is to help the kernel
+ * discard pages of vrange instead of swapping out when memory pressure
+ * happens. The information provided is advisory only, and can be safely
+ * disregarded by the kernel if system has enough free memory.
+ *
+ * mode values:
+ *  VRANGE_VOLATILE - hint to kernel so VM can discard vrange pages when
+ *		memory pressure happens.
+ *  VRANGE_NOVOLATILE - hint to kernel so VM doesn't discard vrange pages
+ *		any more.
+ * behavior values:
+ *
+ * VRANGE_FULL_MODE - Once VM start to discard pages, it discards all pages
+ * 		in a vrange.
+ * VRANGE_PARTIAL_MODE - VM discards some pages of all vranges by round-robin
+ *
+ * return values:
+ *  0 - success and NOT purged.
+ *  1 - at least, one of pages [start, start + len) is discarded by VM.
+ *  -EINVAL - start  len < 0, start is not page-aligned, start is greater
+ *		than TASK_SIZE or "mode" is not a valid value.
+ *  -ENOMEM -  Short of free memory in system for successful system call.
+ */
+SYSCALL_DEFINE4(vrange, unsigned long, start,
+		size_t, len, int, mode, int, behavior)
+{
+	unsigned long end;
+	struct mm_struct *mm = current->mm;
+	int ret = -EINVAL;
+
+	if (start & ~PAGE_MASK)
+		goto out;
+
+	len &= PAGE_MASK;
+	if (!len)
+		goto out;
+
+	end = start  len;
+	if (end < start)
+		goto out;
+
+	if (start >= TASK_SIZE)
+		goto out;
+
+	if (mode == VRANGE_VOLATILE)
+		ret = add_vrange(mm, start, end - 1);
+	else if (mode == VRANGE_NOVOLATILE)
+		ret = remove_vrange(mm, start, end - 1);
+out:
+	return ret;
+}
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
