Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 37B02440844
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 07:13:42 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g46so23439402wrd.3
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 04:13:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y8si6439921wmc.2.2017.07.10.04.13.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 04:13:41 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6AB8uEK044975
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 07:13:39 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2bm48y1jxs-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 07:13:39 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 10 Jul 2017 21:13:36 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6ABCBxY13172930
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 21:12:19 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6ABBNcm023213
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 21:11:23 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC] mm/mremap: Remove redundant checks inside vma_expandable()
Date: Mon, 10 Jul 2017 16:40:59 +0530
Message-Id: <20170710111059.30795-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, mike.kravetz@oracle.com

As 'delta' is an unsigned long, 'end' (vma->vm_end + delta) cannot
be less than 'vma->vm_end'. Checking for availability of virtual
address range at the end of the VMA for the incremental size is
also reduntant at this point. Hence drop them both.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---

The following test program achieves fatser execution time with
this change.

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/mman.h>
#include <sys/time.h>

#define ALLOC_SIZE 0x10000UL
#define MAX_COUNT 1024 * 1024

int main(int argc, char *argv[])
{
        unsigned long count;
        char *ptr;

        ptr = mmap(NULL, ALLOC_SIZE, PROT_READ | PROT_WRITE, MAP_PRIVATE| MAP_ANONYMOUS, -1, 0);
        if (ptr == MAP_FAILED) {
                perror("map() failed");
                return -1;
        }
        memset(ptr, 0, ALLOC_SIZE);

        for (count = 1; count <= MAX_COUNT; count++) {
                ptr =  (char *) mremap(ptr, ALLOC_SIZE * count, ALLOC_SIZE * (count + 1), 1);
                if (ptr == MAP_FAILED) {
                        perror("mremap() failed");
                        printf("At %lu size", ALLOC_SIZE * (count + 1));
                        return -1;
                }
                /*
                memset(ptr, 0, ALLOC_SIZE * (count + 1));
                */
        }


        for (count = MAX_COUNT; count > 1; count--) {
                ptr =  (char *) mremap(ptr, ALLOC_SIZE * count, ALLOC_SIZE * (count - 1), 1);
                if (ptr == MAP_FAILED) {
                        perror("mremap() failed");
                        printf("At %lu size", ALLOC_SIZE * (count - 1));
                        return -1;
                }
                /*
                memset(ptr, 0, ALLOC_SIZE * (count - 1));
                */
        }
        return 0;
}


 mm/mremap.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/mm/mremap.c b/mm/mremap.c
index cd8a1b1..b937c28 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -487,12 +487,9 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 static int vma_expandable(struct vm_area_struct *vma, unsigned long delta)
 {
 	unsigned long end = vma->vm_end + delta;
-	if (end < vma->vm_end) /* overflow */
-		return 0;
-	if (vma->vm_next && vma->vm_next->vm_start < end) /* intersection */
-		return 0;
-	if (get_unmapped_area(NULL, vma->vm_start, end - vma->vm_start,
-			      0, MAP_FIXED) & ~PAGE_MASK)
+
+	/* Intersection with next VMA */
+	if (vma->vm_next && vma->vm_next->vm_start < end)
 		return 0;
 	return 1;
 }
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
