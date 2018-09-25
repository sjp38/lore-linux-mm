Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A211E8E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 17:50:55 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id v9-v6so13308527pff.4
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 14:50:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h3-v6sor706241plb.4.2018.09.25.14.50.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Sep 2018 14:50:54 -0700 (PDT)
Date: Tue, 25 Sep 2018 14:50:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v3] mm, thp: always specify disabled vmas as nh in smaps
In-Reply-To: <alpine.DEB.2.21.1809251248450.50347@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.21.1809251449060.96762@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1809241054050.224429@chino.kir.corp.google.com> <e2f159f3-5373-dda4-5904-ed24d029de3c@suse.cz> <alpine.DEB.2.21.1809241215170.239142@chino.kir.corp.google.com> <alpine.DEB.2.21.1809241227370.241621@chino.kir.corp.google.com>
 <20180924195603.GJ18685@dhcp22.suse.cz> <20180924200258.GK18685@dhcp22.suse.cz> <0aa3eb55-82c0-eba3-b12c-2ba22e052a8e@suse.cz> <alpine.DEB.2.21.1809251248450.50347@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

Commit 1860033237d4 ("mm: make PR_SET_THP_DISABLE immediately active")
introduced a regression in that userspace cannot always determine the set
of vmas where thp is disabled.

Userspace relies on the "nh" flag being emitted as part of /proc/pid/smaps
to determine if a vma has been disabled from being backed by hugepages.

Previous to this commit, prctl(PR_SET_THP_DISABLE, 1) would cause thp to
be disabled and emit "nh" as a flag for the corresponding vmas as part of
/proc/pid/smaps.  After the commit, thp is disabled by means of an mm
flag and "nh" is not emitted.

This causes smaps parsing libraries to assume a vma is enabled for thp
and ends up puzzling the user on why its memory is not backed by thp.

This also clears the "hg" flag to make the behavior of MADV_HUGEPAGE and
PR_SET_THP_DISABLE definitive.

Fixes: 1860033237d4 ("mm: make PR_SET_THP_DISABLE immediately active")
Signed-off-by: David Rientjes <rientjes@google.com>
---
 v3:
  - reword Documentation/filesystems/proc.txt for eligibility

 v2:
  - clear VM_HUGEPAGE per Vlastimil
  - update Documentation/filesystems/proc.txt to be explicit

 Documentation/filesystems/proc.txt |  7 ++++++-
 fs/proc/task_mmu.c                 | 14 +++++++++++++-
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -491,9 +491,14 @@ manner. The codes are the following:
     sd  - soft-dirty flag
     mm  - mixed map area
     hg  - huge page advise flag
-    nh  - no-huge page advise flag
+    nh  - no-huge page advise flag [*]
     mg  - mergable advise flag
 
+ [*] A process mapping may be advised to not be backed by transparent hugepages
+     by either madvise(MADV_NOHUGEPAGE) or prctl(PR_SET_THP_DISABLE).  See
+     Documentation/admin-guide/mm/transhuge.rst for system-wide and process
+     mapping policies.
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
