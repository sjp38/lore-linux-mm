Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 282076B007E
	for <linux-mm@kvack.org>; Sun, 24 Apr 2016 16:29:14 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r12so31936149wme.0
        for <linux-mm@kvack.org>; Sun, 24 Apr 2016 13:29:14 -0700 (PDT)
Received: from mail-lf0-x22e.google.com (mail-lf0-x22e.google.com. [2a00:1450:4010:c07::22e])
        by mx.google.com with ESMTPS id l6si10666942lbc.86.2016.04.24.13.29.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Apr 2016 13:29:12 -0700 (PDT)
Received: by mail-lf0-x22e.google.com with SMTP id u64so6550368lff.3
        for <linux-mm@kvack.org>; Sun, 24 Apr 2016 13:29:12 -0700 (PDT)
Subject: [PATCH v2] mm: enable RLIMIT_DATA by default with workaround for
 valgrind
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sun, 24 Apr 2016 23:29:09 +0300
Message-ID: <146152974907.13871.12611587818290919394.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Cyrill Gorcunov <gorcunov@openvz.org>, Christian Borntraeger <borntraeger@de.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>

Since commit 84638335900f ("mm: rework virtual memory accounting")
RLIMIT_DATA limits both brk() and private mmap() but this's disabled by
default because of incompatibility with older versions of valgrind.

Valgrind always set limit to zero and fails if RLIMIT_DATA is enabled.
Fortunately it changes only rlim_cur and keeps rlim_max for reverting
limit back when needed.

This patch checks current usage also against rlim_max if rlim_cur is zero.
This is safe because task anyway can increase rlim_cur up to rlim_max.
Size of brk is still checked against rlim_cur, so this part is completely
compatible - zero rlim_cur forbids brk() but allows private mmap().

v2: tweak line breaking and keep warn-once warning

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
Link: http://lkml.kernel.org/r/56A28613.5070104@de.ibm.com
---
 mm/mmap.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index bd2e1a533bc1..dae8283b749d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -70,7 +70,7 @@ const int mmap_rnd_compat_bits_max = CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX;
 int mmap_rnd_compat_bits __read_mostly = CONFIG_ARCH_MMAP_RND_COMPAT_BITS;
 #endif
 
-static bool ignore_rlimit_data = true;
+static bool ignore_rlimit_data;
 core_param(ignore_rlimit_data, ignore_rlimit_data, bool, 0644);
 
 static void unmap_region(struct mm_struct *mm,
@@ -2891,13 +2891,17 @@ bool may_expand_vm(struct mm_struct *mm, vm_flags_t flags, unsigned long npages)
 
 	if (is_data_mapping(flags) &&
 	    mm->data_vm + npages > rlimit(RLIMIT_DATA) >> PAGE_SHIFT) {
-		if (ignore_rlimit_data)
-			pr_warn_once("%s (%d): VmData %lu exceed data ulimit %lu. Will be forbidden soon.\n",
+		/* Workaround for Valgrind */
+		if (rlimit(RLIMIT_DATA) == 0 &&
+		    mm->data_vm + npages <= rlimit_max(RLIMIT_DATA) >> PAGE_SHIFT)
+			return true;
+		if (!ignore_rlimit_data) {
+			pr_warn_once("%s (%d): VmData %lu exceed data ulimit %lu. Update limits or use boot option ignore_rlimit_data.\n",
 				     current->comm, current->pid,
 				     (mm->data_vm + npages) << PAGE_SHIFT,
 				     rlimit(RLIMIT_DATA));
-		else
 			return false;
+		}
 	}
 
 	return true;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
