Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id DF7E628024B
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 23:24:26 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id r126so330640935oib.2
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 20:24:26 -0700 (PDT)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id f127si8158581oia.151.2016.09.23.20.24.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 20:24:26 -0700 (PDT)
Received: by mail-oi0-x234.google.com with SMTP id r126so155249691oib.0
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 20:24:26 -0700 (PDT)
Date: Fri, 23 Sep 2016 20:24:23 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 2/3] huge tmpfs: fix Committed_AS leak
In-Reply-To: <alpine.LSU.2.11.1609232014130.2495@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1609232022110.2495@eggly.anvils>
References: <alpine.LSU.2.11.1609232014130.2495@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Under swapping load on huge tmpfs, /proc/meminfo's Committed_AS grows
bigger and bigger: just a cosmetic issue for most users, but disabling
for those who run without overcommit (/proc/sys/vm/overcommit_memory 2).

shmem_uncharge() was forgetting to unaccount __vm_enough_memory's charge,
and shmem_charge() was forgetting it on the filesystem-full error path.

Fixes: 800d8c63b2e9 ("shmem: add huge pages support")
Signed-off-by: Hugh Dickins <hughd@google.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
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
