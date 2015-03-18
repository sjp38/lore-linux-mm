Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id EA5396B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 04:30:42 -0400 (EDT)
Received: by ladw1 with SMTP id w1so29738772lad.0
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 01:30:42 -0700 (PDT)
Received: from mail-la0-x236.google.com (mail-la0-x236.google.com. [2a00:1450:4010:c03::236])
        by mx.google.com with ESMTPS id pl9si7338528lbb.70.2015.03.18.01.30.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 01:30:41 -0700 (PDT)
Received: by lagg8 with SMTP id g8so29724775lag.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 01:30:40 -0700 (PDT)
Subject: [PATCH RFC] mm: protect suid binaries against rowhammer with
 copy-on-read mappings
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Wed, 18 Mar 2015 11:30:40 +0300
Message-ID: <20150318083040.7838.76933.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Each user gets private copy of the code thus nobody will be able to exploit
pages in the page cache. This works for statically-linked binaries. Shared
libraries are still vulnerable, but setting suid bit will protect them too.

[1] http://googleprojectzero.blogspot.com/2015/03/exploiting-dram-rowhammer-bug-to-gain.html

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 include/linux/mm.h |    1 +
 mm/memory.c        |    4 ++--
 mm/mmap.c          |   11 +++++++++++
 3 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 47a9392..25edb4a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -123,6 +123,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_MAYSHARE	0x00000080
 
 #define VM_GROWSDOWN	0x00000100	/* general info on the segment */
+#define VM_COR		0x00000200	/* copy-on-read */
 #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
 #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
 
diff --git a/mm/memory.c b/mm/memory.c
index 411144f..a3c1064 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2904,7 +2904,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 		goto uncharge_out;
 	}
-	do_set_pte(vma, address, new_page, pte, true, true);
+	do_set_pte(vma, address, new_page, pte, vma->vm_flags & VM_WRITE, true);
 	mem_cgroup_commit_charge(new_page, memcg, false);
 	lru_cache_add_active_or_unevictable(new_page, vma);
 	pte_unmap_unlock(pte, ptl);
@@ -3002,7 +3002,7 @@ static int do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 
 	pte_unmap(page_table);
-	if (!(flags & FAULT_FLAG_WRITE))
+	if (!(flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_COR))
 		return do_read_fault(mm, vma, address, pmd, pgoff, flags,
 				orig_pte);
 	if (!(vma->vm_flags & VM_SHARED))
diff --git a/mm/mmap.c b/mm/mmap.c
index da9990a..a91dd2b 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1354,6 +1354,17 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 		default:
 			return -EINVAL;
 		}
+
+		/*
+		 * Read-only SUID/SGID binares are mapped as copy-on-read
+		 * this protects them against exploiting with Rowhammer.
+		 */
+		if (!(file->f_mode & FMODE_WRITE) &&
+		    ((inode->i_mode & S_ISUID) || ((inode->i_mode & S_ISGID) &&
+			    (inode->i_mode & S_IXGRP)))) {
+			vm_flags &= ~(VM_SHARED | VM_MAYSHARE);
+			vm_flags |= VM_COR;
+		}
 	} else {
 		switch (flags & MAP_TYPE) {
 		case MAP_SHARED:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
