Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id BA76A6B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 20:35:51 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so119262985pab.0
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 17:35:51 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id n3si24487487pdp.202.2015.08.17.17.35.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Aug 2015 17:35:50 -0700 (PDT)
Received: by pawq9 with SMTP id q9so21719893paw.3
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 17:35:50 -0700 (PDT)
Date: Mon, 17 Aug 2015 17:34:27 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: fix potential data race in SyS_swapon
In-Reply-To: <alpine.LSU.2.11.1508171610190.2618@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1508171729420.3404@eggly.anvils>
References: <CAAeHK+w7bQtAUAWFrcqE5Gf8t8nZoHim6iXg1axXdC_bVmrNDw@mail.gmail.com> <alpine.LSU.2.11.1508171610190.2618@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Konovalov <andreyknvl@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Jason Low <jason.low2@hp.com>, Cesar Eduardo Barros <cesarb@cesarb.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>

While running KernelThreadSanitizer (ktsan) on upstream kernel with
trinity, we got a few reports from SyS_swapon, here is one of them:

Read of size 8 by thread T307 (K7621):
 [<     inlined    >] SyS_swapon+0x3c0/0x1850 SYSC_swapon mm/swapfile.c:2395
 [<ffffffff812242c0>] SyS_swapon+0x3c0/0x1850 mm/swapfile.c:2345
 [<ffffffff81e97c8a>] ia32_do_call+0x1b/0x25

Looks like the swap_lock should be taken when iterating through the
swap_info array on lines 2392 - 2401: q->swap_file may be reset to
NULL by another thread before it is dereferenced for f_mapping.

But why is that iteration needed at all?  Doesn't the claim_swapfile()
which follows do all that is needed to check for a duplicate entry -
FMODE_EXCL on a bdev, testing IS_SWAPFILE under i_mutex on a regfile?

Well, not quite: bd_may_claim() allows the same "holder" to claim the
bdev again, so we do need to use a different holder than "sys_swapon";
and we should not replace appropriate -EBUSY by inappropriate -EINVAL.

Index i was reused in a cpu loop further down: renamed cpu there.

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/swapfile.c |   25 +++++++------------------
 1 file changed, 7 insertions(+), 18 deletions(-)

--- 4.2-rc7/mm/swapfile.c	2015-07-05 19:25:02.852131158 -0700
+++ linux/mm/swapfile.c	2015-08-16 21:30:22.694123923 -0700
@@ -2143,11 +2143,10 @@ static int claim_swapfile(struct swap_in
 	if (S_ISBLK(inode->i_mode)) {
 		p->bdev = bdgrab(I_BDEV(inode));
 		error = blkdev_get(p->bdev,
-				   FMODE_READ | FMODE_WRITE | FMODE_EXCL,
-				   sys_swapon);
+				   FMODE_READ | FMODE_WRITE | FMODE_EXCL, p);
 		if (error < 0) {
 			p->bdev = NULL;
-			return -EINVAL;
+			return error;
 		}
 		p->old_block_size = block_size(p->bdev);
 		error = set_blocksize(p->bdev, PAGE_SIZE);
@@ -2348,7 +2347,6 @@ SYSCALL_DEFINE2(swapon, const char __use
 	struct filename *name;
 	struct file *swap_file = NULL;
 	struct address_space *mapping;
-	int i;
 	int prio;
 	int error;
 	union swap_header *swap_header;
@@ -2388,19 +2386,8 @@ SYSCALL_DEFINE2(swapon, const char __use
 
 	p->swap_file = swap_file;
 	mapping = swap_file->f_mapping;
-
-	for (i = 0; i < nr_swapfiles; i++) {
-		struct swap_info_struct *q = swap_info[i];
-
-		if (q == p || !q->swap_file)
-			continue;
-		if (mapping == q->swap_file->f_mapping) {
-			error = -EBUSY;
-			goto bad_swap;
-		}
-	}
-
 	inode = mapping->host;
+
 	/* If S_ISREG(inode->i_mode) will do mutex_lock(&inode->i_mutex); */
 	error = claim_swapfile(p, inode);
 	if (unlikely(error))
@@ -2433,6 +2420,8 @@ SYSCALL_DEFINE2(swapon, const char __use
 		goto bad_swap;
 	}
 	if (p->bdev && blk_queue_nonrot(bdev_get_queue(p->bdev))) {
+		int cpu;
+
 		p->flags |= SWP_SOLIDSTATE;
 		/*
 		 * select a random position to start with to help wear leveling
@@ -2451,9 +2440,9 @@ SYSCALL_DEFINE2(swapon, const char __use
 			error = -ENOMEM;
 			goto bad_swap;
 		}
-		for_each_possible_cpu(i) {
+		for_each_possible_cpu(cpu) {
 			struct percpu_cluster *cluster;
-			cluster = per_cpu_ptr(p->percpu_cluster, i);
+			cluster = per_cpu_ptr(p->percpu_cluster, cpu);
 			cluster_set_null(&cluster->index);
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
