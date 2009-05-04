Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5590D6B00B6
	for <linux-mm@kvack.org>; Mon,  4 May 2009 18:25:01 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 4/6] ksm: change the prot handling to use the generic helper functions
Date: Tue,  5 May 2009 01:25:33 +0300
Message-Id: <1241475935-21162-5-git-send-email-ieidus@redhat.com>
In-Reply-To: <1241475935-21162-4-git-send-email-ieidus@redhat.com>
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com>
 <1241475935-21162-2-git-send-email-ieidus@redhat.com>
 <1241475935-21162-3-git-send-email-ieidus@redhat.com>
 <1241475935-21162-4-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, hugh@veritas.com, nickpiggin@yahoo.com.au, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

This is needed to avoid breaking some architectures.

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 mm/ksm.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 6e8b24b..8a0489b 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -762,8 +762,8 @@ static int try_to_merge_two_pages_alloc(struct mm_struct *mm1,
 		up_read(&mm1->mmap_sem);
 		return ret;
 	}
-	prot = vma->vm_page_prot;
-	pgprot_val(prot) &= ~_PAGE_RW;
+
+	prot = vm_get_page_prot(vma->vm_flags & ~VM_WRITE);
 
 	copy_user_highpage(kpage, page1, addr1, vma);
 	ret = try_to_merge_one_page(mm1, vma, page1, kpage, prot);
@@ -780,8 +780,7 @@ static int try_to_merge_two_pages_alloc(struct mm_struct *mm1,
 			return ret;
 		}
 
-		prot = vma->vm_page_prot;
-		pgprot_val(prot) &= ~_PAGE_RW;
+		prot = vm_get_page_prot(vma->vm_flags & ~VM_WRITE);
 
 		ret = try_to_merge_one_page(mm2, vma, page2, kpage,
 					    prot);
@@ -827,8 +826,9 @@ static int try_to_merge_two_pages_noalloc(struct mm_struct *mm1,
 		up_read(&mm1->mmap_sem);
 		return ret;
 	}
-	prot = vma->vm_page_prot;
-	pgprot_val(prot) &= ~_PAGE_RW;
+
+	prot = vm_get_page_prot(vma->vm_flags & ~VM_WRITE);
+
 	ret = try_to_merge_one_page(mm1, vma, page1, page2, prot);
 	up_read(&mm1->mmap_sem);
 	if (!ret)
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
