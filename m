Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 76C638E0041
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 15:30:13 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r20-v6so8155999pgv.20
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 12:30:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1-v6sor36548plj.42.2018.09.24.12.30.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 12:30:11 -0700 (PDT)
Date: Mon, 24 Sep 2018 12:30:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] mm, thp: always specify ineligible vmas as nh in smaps
In-Reply-To: <alpine.DEB.2.21.1809241215170.239142@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.21.1809241227370.241621@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1809241054050.224429@chino.kir.corp.google.com> <e2f159f3-5373-dda4-5904-ed24d029de3c@suse.cz> <alpine.DEB.2.21.1809241215170.239142@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

Commit 1860033237d4 ("mm: make PR_SET_THP_DISABLE immediately active")
introduced a regression in that userspace cannot always determine the set
of vmas where thp is ineligible.

Userspace relies on the "nh" flag being emitted as part of /proc/pid/smaps
to determine if a vma is eligible to be backed by hugepages.

Previous to this commit, prctl(PR_SET_THP_DISABLE, 1) would cause thp to
be disabled and emit "nh" as a flag for the corresponding vmas as part of
/proc/pid/smaps.  After the commit, thp is disabled by means of an mm
flag and "nh" is not emitted.

This causes smaps parsing libraries to assume a vma is eligible for thp
and ends up puzzling the user on why its memory is not backed by thp.

This also clears the "hg" flag to make the behavior of MADV_HUGEPAGE and
PR_SET_THP_DISABLE definitive.

Fixes: 1860033237d4 ("mm: make PR_SET_THP_DISABLE immediately active")
Signed-off-by: David Rientjes <rientjes@google.com>
---
 v2:
  - clear VM_HUGEPAGE per Vlastimil
  - update Documentation/filesystems/proc.txt to be explicit

 Documentation/filesystems/proc.txt | 12 ++++++++++--
 fs/proc/task_mmu.c                 | 14 +++++++++++++-
 2 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -490,10 +490,18 @@ manner. The codes are the following:
     dd  - do not include area into core dump
     sd  - soft-dirty flag
     mm  - mixed map area
-    hg  - huge page advise flag
-    nh  - no-huge page advise flag
+    hg  - eligible for transparent hugepages [*]
+    nh  - not eligible for transparent hugepages [*]
     mg  - mergable advise flag
 
+ [*] A process mapping is eligible to be backed by transparent hugepages (thp)
+     depending on system-wide settings and the mapping itself.  See
+     Documentation/admin-guide/mm/transhuge.rst for default behavior.  If a
+     mapping has a flag of "nh", it is not eligible to be backed by hugepages
+     in any condition, either because of prctl(PR_SET_THP_DISABLE) or
+     madvise(MADV_NOHUGEPAGE).  PR_SET_THP_DISABLE takes precedence over any
+     MADV_HUGEPAGE.
+
 Note that there is no guarantee that every flag and associated mnemonic will
 be present in all further kernel releases. Things get changed, the flags may
 be vanished or the reverse -- new added.
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -653,13 +653,25 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 #endif
 #endif /* CONFIG_ARCH_HAS_PKEYS */
 	};
+	unsigned long flags = vma->vm_flags;
 	size_t i;
 
+	/*
+	 * Disabling thp is possible through both MADV_NOHUGEPAGE and
+	 * PR_SET_THP_DISABLE.  Both historically used VM_NOHUGEPAGE.  Since
+	 * the introduction of MMF_DISABLE_THP, however, userspace needs the
+	 * ability to detect vmas where thp is not eligible in the same manner.
+	 */
+	if (vma->vm_mm && test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags)) {
+		flags &= ~VM_HUGEPAGE;
+		flags |= VM_NOHUGEPAGE;
+	}
+
 	seq_puts(m, "VmFlags: ");
 	for (i = 0; i < BITS_PER_LONG; i++) {
 		if (!mnemonics[i][0])
 			continue;
-		if (vma->vm_flags & (1UL << i)) {
+		if (flags & (1UL << i)) {
 			seq_putc(m, mnemonics[i][0]);
 			seq_putc(m, mnemonics[i][1]);
 			seq_putc(m, ' ');
