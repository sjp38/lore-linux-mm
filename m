Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9221F82F66
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 11:06:07 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so32489831wic.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 08:06:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s6si17148318wjy.175.2015.09.24.08.06.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Sep 2015 08:06:06 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC] futex: prevent endless loop on s390x with emulated hugepages
Date: Thu, 24 Sep 2015 17:05:48 +0200
Message-Id: <1443107148-28625-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Yong Sun <yosun@suse.com>, linux390@de.ibm.com, linux-s390@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yi <wetpzy@gmail.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>

Yong Sun has reported the LTP futex_wake04 test to hang a s390x with our
kernel based on 3.12. This is reproducible on upstream 4.1.8 as well. 4.2+
is OK thanks to removal of emulated hugepages, but we should do something
about the stable kernels here.

The LTP test is a regression test for commit 13d60f4b6a ("futex: Take
hugepages into account when generating futex_key"), but it turns out that it's
sufficient to just attempt to wait for a single futex on a tail page of a
hugetlbfs page:

==== BEGIN REPRODUCER ====

static struct timespec to = {.tv_sec = 1, .tv_nsec = 0};

int main(int argc, char *argv[])
{
	void *addr;
	int hpsz = 1024*1024;
	int pgsz = 4096;
	int * futex1;

	addr = mmap(NULL, hpsz, PROT_WRITE | PROT_READ,
	            MAP_SHARED | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);

	if (addr == MAP_FAILED) {
		perror("mmap()");
		return 1;
	}

	futex1 = (int *)((char *)addr + pgsz);
	*futex1 = 0;

	syscall(SYS_futex, futex1, FUTEX_WAIT, *futex1, &to, 0, 0);

	return 0;
}

==== END REPRODUCER ===

The problem is an endless loop in get_futex_key() when
CONFIG_TRANSPARENT_HUGEPAGE is enabled and the s390x machine has emulated
hugepages. The code tries to serialize against __split_huge_page_splitting(),
but __get_user_pages_fast() fails on the hugetlbfs tail page. This happens
because pmd_large() is false for emulated hugepages, so the code will proceed
into gup_pte_range() and fail page_cache_get_speculative() through failing
get_page_unless_zero() as the tail page count is zero. Failing __gup_fast is
supposed to be temporary due to a race, so get_futex_key() will try again
endlessly.

This attempt for a fix is a bandaid solution and probably incomplete.
Hopefully something better will emerge from the discussion. Fully fixing
emulated hugepages just for stable backports is unlikely due to them being
removed. Also THP refcounting redesign should soon remove the trickery from
get_futex_key().

This patch relies on the fact that s390x with emulated hugepages returns false
in has_transparent_hugepage(), so we don't need to do the serialization
trickery and just use the code for !CONFIG_TRANSPARENT_HUGEPAGE. We just need
an extra variable to cache the result of has_transparent_hugepage(), which is
__init and potentially expensive on some architectures.

However, __get_user_pages_fast() is still broken. The get_user_pages_fast()
wrapper will hide this in the common case. The other user of the __ variant
is kvm, which is mentioned as the reason for removal of emulated hugepages.
The call of page_cache_get_speculative() looks also broken in this scenario
on debug builds because of VM_BUG_ON_PAGE(PageTail(page), page). With
CONFIG_TINY_RCU enabled, there's plain atomic_inc(&page->_count) which also
probably shouldn't happen for a tail page...

Not-yet-signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Reported-by: Yong Sun <yosun@suse.com>
Cc: Zhang Yi <wetpzy@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dominik Dingel <dingel@linux.vnet.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>
---
 include/linux/huge_mm.h |  1 +
 kernel/futex.c          | 10 ++++++++--
 mm/huge_memory.c        |  4 ++++
 3 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index f10b20f..5dbaca3 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -92,6 +92,7 @@ extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 #define transparent_hugepage_debug_cow() 0
 #endif /* CONFIG_DEBUG_VM */
 
+extern bool transparent_hugepage_available;
 extern unsigned long transparent_hugepage_flags;
 extern int split_huge_page_to_list(struct page *page, struct list_head *list);
 static inline int split_huge_page(struct page *page)
diff --git a/kernel/futex.c b/kernel/futex.c
index c4a182f..be9cd1c 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -443,6 +443,9 @@ get_futex_key(u32 __user *uaddr, int fshared, union futex_key *key, int rw)
 		err = 0;
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	if (!transparent_hugepage_available)
+		goto no_thp;
+
 	page_head = page;
 	if (unlikely(PageTail(page))) {
 		put_page(page);
@@ -470,14 +473,17 @@ get_futex_key(u32 __user *uaddr, int fshared, union futex_key *key, int rw)
 			goto again;
 		}
 	}
-#else
+	goto lockpage;
+#endif
+
+no_thp:
 	page_head = compound_head(page);
 	if (page != page_head) {
 		get_page(page_head);
 		put_page(page);
 	}
-#endif
 
+lockpage:
 	lock_page(page_head);
 
 	/*
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 097c7a4..6aea047 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -36,6 +36,7 @@
  * Defrag is invoked by khugepaged hugepage allocations and by page faults
  * for all hugepage allocations.
  */
+bool transparent_hugepage_available __read_mostly = false;
 unsigned long transparent_hugepage_flags __read_mostly =
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS
 	(1<<TRANSPARENT_HUGEPAGE_FLAG)|
@@ -626,10 +627,13 @@ static int __init hugepage_init(void)
 	struct kobject *hugepage_kobj;
 
 	if (!has_transparent_hugepage()) {
+		transparent_hugepage_available = false;
 		transparent_hugepage_flags = 0;
 		return -EINVAL;
 	}
 
+	transparent_hugepage_available = true;
+
 	err = hugepage_init_sysfs(&hugepage_kobj);
 	if (err)
 		goto err_sysfs;
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
