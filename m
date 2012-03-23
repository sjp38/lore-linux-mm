Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id C3BDB6B007E
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 17:01:21 -0400 (EDT)
Date: Fri, 23 Mar 2012 14:01:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm for fs: add truncate_pagecache_range
Message-Id: <20120323140120.11f95cd5.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1203231343380.1940@eggly.anvils>
References: <alpine.LSU.2.00.1203231343380.1940@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, 23 Mar 2012 13:46:35 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> +/**
> + * truncate_pagecache_range - unmap and remove pagecache that is hole-punched
> + * @inode: inode
> + * @lstart: offset of beginning of hole
> + * @lend: offset of last byte of hole
> + *
> + * This function should typically be called before the filesystem
> + * releases resources associated with the freed range (eg. deallocates
> + * blocks). This way, pagecache will always stay logically coherent
> + * with on-disk format, and the filesystem would not have to deal with
> + * situations such as writepage being called for a page that has already
> + * had its underlying blocks deallocated.
> + */

--- a/mm/truncate.c~mm-for-fs-add-truncate_pagecache_range-fix
+++ a/mm/truncate.c
@@ -639,6 +639,9 @@ int vmtruncate_range(struct inode *inode
  * with on-disk format, and the filesystem would not have to deal with
  * situations such as writepage being called for a page that has already
  * had its underlying blocks deallocated.
+ *
+ * Must be called with inode->i_mapping->i_mutex held.
+ * Takes inode->i_mapping->i_mmap_mutex.
  */
 void truncate_pagecache_range(struct inode *inode, loff_t lstart, loff_t lend)
 {

yes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
