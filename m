Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1C67F6B0036
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 05:11:15 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so5503999pde.6
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 02:11:14 -0800 (PST)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id zk9si10747626pac.289.2014.01.27.02.05.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 27 Jan 2014 02:05:09 -0800 (PST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N0200ES91CGKE70@mailout1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Jan 2014 19:05:04 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH 7/8] mm/swap: check swapfile blocksize greater than PAGE_SIZE
Date: Mon, 27 Jan 2014 18:03:04 +0800
Message-id: <000801cf1b47$3fcab170$bf601450$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Minchan Kim' <minchan@kernel.org>, shli@kernel.org, 'Bob Liu' <bob.liu@oracle.com>, weijie.yang.kh@gmail.com, 'Heesub Shin' <heesub.shin@samsung.com>, mquzik@redhat.com, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, stable@vger.kernel.org

If S_ISREG swapfile's blocksize > PAGE_SIZE, it is not suitable to be
a swapfile, because swap slot is fixed to PAGE_SIZE.

This patch check this situation and return -EINVAL if it happens.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/page_io.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/page_io.c b/mm/page_io.c
index 7247be6..3d9bd12 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -150,6 +150,8 @@ int generic_swapfile_activate(struct swap_info_struct *sis,
 	int ret;
 
 	blkbits = inode->i_blkbits;
+	if(blkbits > PAGE_SHIFT)
+		return -EINVAL;
 	blocks_per_page = PAGE_SIZE >> blkbits;
 
 	/*
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
