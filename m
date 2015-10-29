Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5BFD382F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 15:04:53 -0400 (EDT)
Received: by oifu63 with SMTP id u63so46675903oif.2
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 12:04:53 -0700 (PDT)
Received: from mail-ob0-x22e.google.com (mail-ob0-x22e.google.com. [2607:f8b0:4003:c01::22e])
        by mx.google.com with ESMTPS id b75si1954872oig.100.2015.10.29.12.04.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Oct 2015 12:04:52 -0700 (PDT)
Received: by obbwb3 with SMTP id wb3so25738508obb.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 12:04:52 -0700 (PDT)
Date: Thu, 29 Oct 2015 12:04:43 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH v7] mm: hugetlb: proc: add hugetlb-related fields to
 /proc/PID/smaps
In-Reply-To: <1442480955-7297-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.LSU.2.11.1510291153480.3475@eggly.anvils>
References: <1442480955-7297-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1442480955-7297-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, =?ISO-8859-15?Q?P=E1draig_Brady?= <P@draigbrady.com>, David Rientjes <rientjes@google.com>, Joern Engel <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Currently /proc/PID/smaps provides no usage info for vma(VM_HUGETLB), which
is inconvenient when we want to know per-task or per-vma base hugetlb usage.
To solve this, this patch adds new fields for hugetlb usage like below:

  Size:              20480 kB
  Rss:                   0 kB
  Pss:                   0 kB
  Shared_Clean:          0 kB
  Shared_Dirty:          0 kB
  Private_Clean:         0 kB
  Private_Dirty:         0 kB
  Referenced:            0 kB
  Anonymous:             0 kB
  AnonHugePages:         0 kB
  Shared_Hugetlb:    18432 kB
  Private_Hugetlb:    2048 kB
  Swap:                  0 kB
  KernelPageSize:     2048 kB
  MMUPageSize:        2048 kB
  Locked:                0 kB
  VmFlags: rd wr mr mw me de ht

[ hughd: fixed Private_Hugetlb alignment ]
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Joern Engel <joern@logfs.org>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
Andrew, please add back your Signed-off-by, and replace
mm-hugetlb-proc-add-hugetlb-related-fields-to-proc-pid-smaps.patch
by this version: I couldn't send a "fix" patch because an important
line was (commendably upfront) in the patch description itself.
The patch is just grabbed out of mmotm and fixed up inplace.

Seems I'm the only one to care, but I've been distressed by the
misalignment of the Private_Hugetlb field: most of us will never
see anything but "0 kB" there, so please don't uglify it for us;
it's not as if %7lu would truncate a larger number.

 Documentation/filesystems/proc.txt |    8 +++++
 fs/proc/task_mmu.c                 |   38 +++++++++++++++++++++++++++
 2 files changed, 46 insertions(+)

diff -puN Documentation/filesystems/proc.txt~mm-hugetlb-proc-add-hugetlb-related-fields-to-proc-pid-smaps Documentation/filesystems/proc.txt
--- a/Documentation/filesystems/proc.txt~mm-hugetlb-proc-add-hugetlb-related-fields-to-proc-pid-smaps
+++ a/Documentation/filesystems/proc.txt
@@ -423,6 +423,9 @@ Private_Clean:         0 kB
 Private_Dirty:         0 kB
 Referenced:          892 kB
 Anonymous:             0 kB
+AnonHugePages:         0 kB
+Shared_Hugetlb:        0 kB
+Private_Hugetlb:       0 kB
 Swap:                  0 kB
 SwapPss:               0 kB
 KernelPageSize:        4 kB
@@ -451,6 +454,11 @@ and a page is modified, the file page is
 "Swap" shows how much would-be-anonymous memory is also used, but out on
 swap.
 "SwapPss" shows proportional swap share of this mapping.
+"AnonHugePages" shows the ammount of memory backed by transparent hugepage.
+"Shared_Hugetlb" and "Private_Hugetlb" show the ammounts of memory backed by
+hugetlbfs page which is *not* counted in "RSS" or "PSS" field for historical
+reasons. And these are not included in {Shared,Private}_{Clean,Dirty} field.
+
 "VmFlags" field deserves a separate description. This member represents the kernel
 flags associated with the particular virtual memory area in two letter encoded
 manner. The codes are the following:
diff -puN fs/proc/task_mmu.c~mm-hugetlb-proc-add-hugetlb-related-fields-to-proc-pid-smaps fs/proc/task_mmu.c
--- a/fs/proc/task_mmu.c~mm-hugetlb-proc-add-hugetlb-related-fields-to-proc-pid-smaps
+++ a/fs/proc/task_mmu.c
@@ -446,6 +446,8 @@ struct mem_size_stats {
 	unsigned long anonymous;
 	unsigned long anonymous_thp;
 	unsigned long swap;
+	unsigned long shared_hugetlb;
+	unsigned long private_hugetlb;
 	u64 pss;
 	u64 swap_pss;
 };
@@ -625,12 +627,44 @@ static void show_smap_vma_flags(struct s
 	seq_putc(m, '\n');
 }
 
+#ifdef CONFIG_HUGETLB_PAGE
+static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
+				 unsigned long addr, unsigned long end,
+				 struct mm_walk *walk)
+{
+	struct mem_size_stats *mss = walk->private;
+	struct vm_area_struct *vma = walk->vma;
+	struct page *page = NULL;
+
+	if (pte_present(*pte)) {
+		page = vm_normal_page(vma, addr, *pte);
+	} else if (is_swap_pte(*pte)) {
+		swp_entry_t swpent = pte_to_swp_entry(*pte);
+
+		if (is_migration_entry(swpent))
+			page = migration_entry_to_page(swpent);
+	}
+	if (page) {
+		int mapcount = page_mapcount(page);
+
+		if (mapcount >= 2)
+			mss->shared_hugetlb += huge_page_size(hstate_vma(vma));
+		else
+			mss->private_hugetlb += huge_page_size(hstate_vma(vma));
+	}
+	return 0;
+}
+#endif /* HUGETLB_PAGE */
+
 static int show_smap(struct seq_file *m, void *v, int is_pid)
 {
 	struct vm_area_struct *vma = v;
 	struct mem_size_stats mss;
 	struct mm_walk smaps_walk = {
 		.pmd_entry = smaps_pte_range,
+#ifdef CONFIG_HUGETLB_PAGE
+		.hugetlb_entry = smaps_hugetlb_range,
+#endif
 		.mm = vma->vm_mm,
 		.private = &mss,
 	};
@@ -652,6 +686,8 @@ static int show_smap(struct seq_file *m,
 		   "Referenced:     %8lu kB\n"
 		   "Anonymous:      %8lu kB\n"
 		   "AnonHugePages:  %8lu kB\n"
+		   "Shared_Hugetlb: %8lu kB\n"
+		   "Private_Hugetlb: %7lu kB\n"
 		   "Swap:           %8lu kB\n"
 		   "SwapPss:        %8lu kB\n"
 		   "KernelPageSize: %8lu kB\n"
@@ -667,6 +703,8 @@ static int show_smap(struct seq_file *m,
 		   mss.referenced >> 10,
 		   mss.anonymous >> 10,
 		   mss.anonymous_thp >> 10,
+		   mss.shared_hugetlb >> 10,
+		   mss.private_hugetlb >> 10,
 		   mss.swap >> 10,
 		   (unsigned long)(mss.swap_pss >> (10 + PSS_SHIFT)),
 		   vma_kernel_pagesize(vma) >> 10,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
