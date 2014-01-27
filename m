Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3E9CE6B0036
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 05:09:07 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id md12so5694975pbc.12
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 02:09:06 -0800 (PST)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id gx4si10837655pbc.51.2014.01.27.02.09.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 27 Jan 2014 02:09:05 -0800 (PST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N0200D5G1J3YG90@mailout1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Jan 2014 19:09:03 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH 3/8] mm/swap: prevent concurrent swapon on the same S_ISBLK
 blockdev
Date: Mon, 27 Jan 2014 18:03:04 +0800
Message-id: <000c01cf1b47$ce280170$6a780450$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Minchan Kim' <minchan@kernel.org>, shli@kernel.org, 'Bob Liu' <bob.liu@oracle.com>, weijie.yang.kh@gmail.com, 'Seth Jennings' <sjennings@variantweb.net>, 'Heesub Shin' <heesub.shin@samsung.com>, mquzik@redhat.com, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, stable@vger.kernel.org

When swapon the same S_ISBLK blockdev concurrent, the allocated two
swap_info could hold the same block_device, because claim_swapfile()
allow the same holder(here, it is sys_swapon function).

To prevent this situation, This patch adds swap_lock protect to ensure
we can find this situation and return -EBUSY for one swapon call.

As for S_ISREG swapfile, claim_swapfile() already prevent this scenario
by holding inode->i_mutex.

This patch is just for a rare scenario, aim to correct of code.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/swapfile.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 4d24158..413c213 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2459,9 +2459,10 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		goto bad_swap;
 	}
 
+	/* prevent concurrent swapon on the same S_ISBLK blockdev */
+	spin_lock(&swap_lock);
 	p->swap_file = swap_file;
 	mapping = swap_file->f_mapping;
-
 	for (i = 0; i < nr_swapfiles; i++) {
 		struct swap_info_struct *q = swap_info[i];
 
@@ -2472,6 +2473,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 			goto bad_swap;
 		}
 	}
+	spin_unlock(&swap_lock);
 
 	inode = mapping->host;
 	/* If S_ISREG(inode->i_mode) will do mutex_lock(&inode->i_mutex); */
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
