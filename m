Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9CCC56B0269
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 13:37:12 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e20so215963656itc.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 10:37:12 -0700 (PDT)
Received: from mail-it0-x236.google.com (mail-it0-x236.google.com. [2607:f8b0:4001:c0b::236])
        by mx.google.com with ESMTPS id 123si3275022ioo.108.2016.09.22.10.37.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 10:37:11 -0700 (PDT)
Received: by mail-it0-x236.google.com with SMTP id 186so89147146itf.0
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 10:37:11 -0700 (PDT)
Date: Thu, 22 Sep 2016 10:37:03 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] huge tmpfs: fix Committed_AS leak
Message-ID: <alpine.LSU.2.11.1609221034040.17333@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Under swapping load on huge tmpfs, /proc/meminfo's Committed_AS grows
bigger and bigger: just a cosmetic issue for most users, but disabling
for those who run without overcommit (/proc/sys/vm/overcommit_memory 2).

shmem_uncharge() was forgetting to unaccount __vm_enough_memory's charge,
and shmem_charge() was forgetting it on the filesystem-full error path.

Fixes: 800d8c63b2e9 ("shmem: add huge pages support")
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/shmem.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- 4.8-rc7/mm/shmem.c	2016-08-14 20:17:02.388843463 -0700
+++ linux/mm/shmem.c	2016-09-22 09:29:15.462690346 -0700
@@ -270,7 +270,7 @@ bool shmem_charge(struct inode *inode, l
 		info->alloced -= pages;
 		shmem_recalc_inode(inode);
 		spin_unlock_irqrestore(&info->lock, flags);
-
+		shmem_unacct_blocks(info->flags, pages);
 		return false;
 	}
 	percpu_counter_add(&sbinfo->used_blocks, pages);
@@ -291,6 +291,7 @@ void shmem_uncharge(struct inode *inode,
 
 	if (sbinfo->max_blocks)
 		percpu_counter_sub(&sbinfo->used_blocks, pages);
+	shmem_unacct_blocks(info->flags, pages);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
