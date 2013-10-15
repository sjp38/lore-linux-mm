Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id A89D66B0036
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 20:13:49 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so118749pdj.30
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 17:13:49 -0700 (PDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so8109963pad.7
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 17:13:46 -0700 (PDT)
Date: Mon, 14 Oct 2013 17:13:42 -0700
From: Ning Qu <quning@google.com>
Subject: [PATCH 10/12] mm, thp, tmpfs: only alloc small pages in
 shmem_file_splice_read
Message-ID: <20131015001342.GK3432@hippobay.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>

We just hope this is not a common case path. The huge page can't be
added without completely refactoring the code.

Signed-off-by: Ning Qu <quning@gmail.com>
---
 mm/shmem.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index cbf01ce..75c0ac6 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1973,6 +1973,7 @@ static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
 	index += spd.nr_pages;
 	error = 0;
 
+	i_split_down_read(inode);
 	while (spd.nr_pages < nr_pages) {
 		error = shmem_getpage(inode, index, &page, SGP_CACHE, gfp,
 					0, NULL);
@@ -2042,6 +2043,7 @@ static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
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
