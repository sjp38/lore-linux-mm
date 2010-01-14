Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 659486B0092
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 01:48:55 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0E6mpim008580
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 Jan 2010 15:48:52 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D48D45DE51
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 15:48:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D26545DE4F
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 15:48:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 62A5FE38002
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 15:48:51 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F68BE08004
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 15:48:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] mm: Fix mbind vma merge problem
Message-Id: <20100114154720.6732.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 Jan 2010 15:48:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Strangely, current mbind() doesn't merge vma with neighbor vma although it's possible.
Unfortunately, many vma can reduce performance...

This patch fixes it.

    reproduced program
    ----------------------------------------------------------------
     #include <numaif.h>
     #include <numa.h>
     #include <sys/mman.h>
     #include <stdio.h>
     #include <unistd.h>
     #include <stdlib.h>
     #include <string.h>

    static unsigned long pagesize;

    int main(int argc, char** argv)
    {
    	void* addr;
    	int ch;
    	int node;
    	struct bitmask *nmask = numa_allocate_nodemask();
    	int err;
    	int node_set = 0;
    	char buf[128];

    	while ((ch = getopt(argc, argv, "n:")) != -1){
    		switch (ch){
    		case 'n':
    			node = strtol(optarg, NULL, 0);
    			numa_bitmask_setbit(nmask, node);
    			node_set = 1;
    			break;
    		default:
    			;
    		}
    	}
    	argc -= optind;
    	argv += optind;

    	if (!node_set)
    		numa_bitmask_setbit(nmask, 0);

    	pagesize = getpagesize();

    	addr = mmap(NULL, pagesize*3, PROT_READ|PROT_WRITE,
    		    MAP_ANON|MAP_PRIVATE, 0, 0);
    	if (addr == MAP_FAILED)
    		perror("mmap "), exit(1);

    	fprintf(stderr, "pid = %d \n" "addr = %p\n", getpid(), addr);

    	/* make page populate */
    	memset(addr, 0, pagesize*3);

    	/* first mbind */
    	err = mbind(addr+pagesize, pagesize, MPOL_BIND, nmask->maskp,
    		    nmask->size, MPOL_MF_MOVE_ALL);
    	if (err)
    		error("mbind1 ");

    	/* second mbind */
    	err = mbind(addr, pagesize*3, MPOL_DEFAULT, NULL, 0, 0);
    	if (err)
    		error("mbind2 ");

    	sprintf(buf, "cat /proc/%d/maps", getpid());
    	system(buf);

    	return 0;
    }
    ----------------------------------------------------------------

result without this patch

	addr = 0x7fe26ef09000
	[snip]
	7fe26ef09000-7fe26ef0a000 rw-p 00000000 00:00 0
	7fe26ef0a000-7fe26ef0b000 rw-p 00000000 00:00 0
	7fe26ef0b000-7fe26ef0c000 rw-p 00000000 00:00 0
	7fe26ef0c000-7fe26ef0d000 rw-p 00000000 00:00 0

	=> 0x7fe26ef09000-0x7fe26ef0c000 have three vmas.

result with this patch

	addr = 0x7fc9ebc76000
	[snip]
	7fc9ebc76000-7fc9ebc7a000 rw-p 00000000 00:00 0
	7fffbe690000-7fffbe6a5000 rw-p 00000000	00:00 0	[stack]

	=> 0x7fc9ebc76000-0x7fc9ebc7a000 have only one vma.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/mempolicy.c |   51 ++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 38 insertions(+), 13 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 290fb5b..9751f3f 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -563,24 +563,49 @@ static int policy_vma(struct vm_area_struct *vma, struct mempolicy *new)
 }
 
 /* Step 2: apply policy to a range and do splits. */
-static int mbind_range(struct vm_area_struct *vma, unsigned long start,
-		       unsigned long end, struct mempolicy *new)
+static int mbind_range(struct mm_struct *mm, unsigned long start,
+		       unsigned long end, struct mempolicy *new_pol)
 {
 	struct vm_area_struct *next;
-	int err;
+	struct vm_area_struct *prev;
+	struct vm_area_struct *vma;
+	int err = 0;
+	unsigned long vmstart;
+	unsigned long vmend;
 
-	err = 0;
-	for (; vma && vma->vm_start < end; vma = next) {
+	vma = find_vma_prev(mm, start, &prev);
+	if (!vma || vma->vm_start > start)
+		return -EFAULT;
+
+	for (; vma && vma->vm_start < end; prev = vma, vma = next) {
 		next = vma->vm_next;
-		if (vma->vm_start < start)
-			err = split_vma(vma->vm_mm, vma, start, 1);
-		if (!err && vma->vm_end > end)
-			err = split_vma(vma->vm_mm, vma, end, 0);
-		if (!err)
-			err = policy_vma(vma, new);
+		vmstart = max(start, vma->vm_start);
+		vmend   = min(end, vma->vm_end);
+
+		prev = vma_merge(mm, prev, vmstart, vmend, vma->vm_flags,
+				  vma->anon_vma, vma->vm_file, vma->vm_pgoff,
+				  new_pol);
+		if (prev) {
+			vma = prev;
+			next = vma->vm_next;
+			continue;
+		}
+		if (vma->vm_start != vmstart) {
+			err = split_vma(vma->vm_mm, vma, vmstart, 1);
+			if (err)
+				goto out;
+		}
+		if (vma->vm_end != vmend) {
+			err = split_vma(vma->vm_mm, vma, vmend, 0);
+			if (err)
+				goto out;
+		}
+		err = policy_vma(vma, new_pol);
 		if (err)
-			break;
+			goto out;
 	}
+
+ out:
 	return err;
 }
 
@@ -1047,7 +1072,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 	if (!IS_ERR(vma)) {
 		int nr_failed = 0;
 
-		err = mbind_range(vma, start, end, new);
+		err = mbind_range(mm, start, end, new);
 
 		if (!list_empty(&pagelist))
 			nr_failed = migrate_pages(&pagelist, new_vma_page,
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
