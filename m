Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 567786B0360
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 17:48:35 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id q10so6803054pdj.14
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:48:35 -0700 (PDT)
Received: from psmtp.com ([74.125.245.173])
        by mx.google.com with SMTP id hj4si10229900pac.126.2013.10.21.14.48.33
        for <linux-mm@kvack.org>;
        Mon, 21 Oct 2013 14:48:34 -0700 (PDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so8676404pad.21
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:48:32 -0700 (PDT)
Date: Mon, 21 Oct 2013 14:48:28 -0700
From: Ning Qu <quning@google.com>
Subject: [PATCHv2 11/13] mm, thp, tmpfs: only alloc small pages in
 shmem_file_splice_read
Message-ID: <20131021214828.GL29870@hippobay.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>, Ning Qu <quning@gmail.com>

We just hope this is not a common case path. The huge page can't be
added without completely refactoring the code.

Signed-off-by: Ning Qu <quning@gmail.com>
---
 mm/shmem.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index 48b1d84..c42331a 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1950,6 +1950,7 @@ static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
 	index += spd.nr_pages;
 	error = 0;
 
+	i_split_down_read(inode);
 	while (spd.nr_pages < nr_pages) {
 		error = shmem_getpage(inode, index, &page, SGP_CACHE, gfp,
 					0, NULL);
@@ -2019,6 +2020,7 @@ static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
 		*ppos += error;
 		file_accessed(in);
 	}
+	i_split_up_read(inode);
 	return error;
 }
 
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
