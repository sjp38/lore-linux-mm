Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 1E27C6B0085
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 06:42:39 -0400 (EDT)
Received: by mail-lpp01m010-f41.google.com with SMTP id i5so4784508lah.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 03:42:38 -0700 (PDT)
Subject: [PATCH v3 09/10] mm: prepare VM_DONTDUMP for using in drivers
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Tue, 31 Jul 2012 14:42:35 +0400
Message-ID: <20120731104235.20515.78297.stgit@zurg>
In-Reply-To: <20120731103724.20515.60334.stgit@zurg>
References: <20120731103724.20515.60334.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Jason Baron <jbaron@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>

This patch renames VM_NODUMP into VM_DONTDUMP: this name matches to other
negative flags: VM_DONTEXPAND, VM_DONTCOPY. Currently this flag used only for
sys_madvise next patch will use it for replacing outdated flag VM_RESERVED.

Also this patch forbids madvise(MADV_DODUMP) for special kernel mappings
VM_SPECIAL (VM_IO | VM_DONTEXPAND | VM_RESERVED | VM_PFNMAP)

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Jason Baron <jbaron@redhat.com>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Hugh Dickins <hughd@google.com>
---
 fs/binfmt_elf.c    |    2 +-
 include/linux/mm.h |    2 +-
 mm/madvise.c       |    8 ++++++--
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 1b52956..3adcc4b 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -1115,7 +1115,7 @@ static unsigned long vma_dump_size(struct vm_area_struct *vma,
 	if (always_dump_vma(vma))
 		goto whole;
 
-	if (vma->vm_flags & VM_NODUMP)
+	if (vma->vm_flags & VM_DONTDUMP)
 		return 0;
 
 	/* Hugetlb memory check */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ee2676e..21cad77 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -102,7 +102,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
 #define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
 #define VM_ARCH_1	0x01000000	/* Architecture-specific flag */
-#define VM_NODUMP	0x04000000	/* Do not include in the core dump */
+#define VM_DONTDUMP	0x04000000	/* Do not include in the core dump */
 
 #define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
 #define VM_HUGEPAGE	0x20000000	/* MADV_HUGEPAGE marked this vma */
diff --git a/mm/madvise.c b/mm/madvise.c
index 14d260f..03dfa5c 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -69,10 +69,14 @@ static long madvise_behavior(struct vm_area_struct * vma,
 		new_flags &= ~VM_DONTCOPY;
 		break;
 	case MADV_DONTDUMP:
-		new_flags |= VM_NODUMP;
+		new_flags |= VM_DONTDUMP;
 		break;
 	case MADV_DODUMP:
-		new_flags &= ~VM_NODUMP;
+		if (new_flags & VM_SPECIAL) {
+			error = -EINVAL;
+			goto out;
+		}
+		new_flags &= ~VM_DONTDUMP;
 		break;
 	case MADV_MERGEABLE:
 	case MADV_UNMERGEABLE:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
