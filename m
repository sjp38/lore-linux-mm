Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 65BD66B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 22:26:10 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so142938pab.34
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 19:26:09 -0700 (PDT)
Received: from x35.xmailserver.org (x35.xmailserver.org. [64.71.152.41])
        by mx.google.com with ESMTPS id uh4si449291pbc.36.2014.10.22.19.26.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 19:26:09 -0700 (PDT)
Received: from davide-lnx3.corp.ebay.com
	by x35.xmailserver.org with [XMail 1.27 ESMTP Server]
	id <S3FBD78> for <linux-mm@kvack.org> from <davidel@xmailserver.org>;
	Wed, 22 Oct 2014 22:31:22 -0400
Date: Wed, 22 Oct 2014 19:26:07 -0700 (PDT)
From: Davide Libenzi <davidel@xmailserver.org>
Subject: [patch][resend] MAP_HUGETLB munmap fails with size not 2MB aligned
Message-ID: <alpine.DEB.2.10.1410221518160.31326@davide-lnx3>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

[Resending with proper CC list suggested by Andrew]

Calling munmap on a MAP_HUGETLB area, and a size which is not 2MB aligned, 
causes munmap to fail.  Tested on 3.13.x but tracking back to 3.2.x.
In do_munmap() we forcibly want a 4KB default page, and we wrongly 
calculate the end of the map.  Since the calculated end is within the end 
address of the target vma, we try to do a split with an address right in 
the middle of a huge page, which would fail with EINVAL.

Tentative (untested) patch and test case attached (be sure you have a few 
huge pages available via /proc/sys/vm/nr_hugepages tinkering).


Signed-Off-By: Davide Libenzi <davidel@xmailserver.org>


- Davide


diff --git a/mm/mmap.c b/mm/mmap.c
index 7f85520..6dba257 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2528,10 +2528,6 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 	if ((start & ~PAGE_MASK) || start > TASK_SIZE || len > TASK_SIZE-start)
 		return -EINVAL;
 
-	len = PAGE_ALIGN(len);
-	if (len == 0)
-		return -EINVAL;
-
 	/* Find the first overlapping VMA */
 	vma = find_vma(mm, start);
 	if (!vma)
@@ -2539,6 +2535,16 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 	prev = vma->vm_prev;
 	/* we have  start < vma->vm_end  */
 
+	if (likely(!is_vm_hugetlb_page(vma)))
+		len = PAGE_ALIGN(len);
+	else {
+		unsigned long hpage_size = huge_page_size(hstate_vma(vma));
+
+		len = ALIGN(len, hpage_size);
+	}
+	if (unlikely(len == 0))
+		return -EINVAL;
+
 	/* if it doesn't overlap, we have nothing.. */
 	end = start + len;
 	if (vma->vm_start >= end)




[hugebug.c]

#include <sys/mman.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

static void test(int flags, size_t size)
{
    void* addr = mmap(NULL, size, PROT_READ | PROT_WRITE,
                      flags | MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);

    if (addr == MAP_FAILED)
    {
        perror("mmap");
        exit(1);
    }
    *(char*) addr = 17;

    if (munmap(addr, size) != 0)
    {
        perror("munmap");
        exit(1);
    }
}

int main(int ac, const char** av)
{
    static const size_t hugepage_size = 2 * 1024 * 1024;

    printf("Testing normal pages with 2MB size ...\n");
    test(0, hugepage_size);
    printf("OK\n");

    printf("Testing huge pages with 2MB size ...\n");
    test(MAP_HUGETLB, hugepage_size);
    printf("OK\n");


    printf("Testing normal pages with 4KB byte size ...\n");
    test(0, 4096);
    printf("OK\n");

    printf("Testing huge pages with 4KB byte size ...\n");
    test(MAP_HUGETLB, 4096);
    printf("OK\n");


    printf("Testing normal pages with 1 byte size ...\n");
    test(0, 1);
    printf("OK\n");

    printf("Testing huge pages with 1 byte size ...\n");
    test(MAP_HUGETLB, 1);
    printf("OK\n");

    return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
