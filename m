Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 908FE6B13F0
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 15:10:32 -0500 (EST)
Date: Wed, 1 Feb 2012 15:10:17 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH] fix readahead pipeline break caused by block plug
Message-ID: <20120201201017.GC13246@redhat.com>
References: <1327996780.21268.42.camel@sli10-conroe>
 <20120131220333.GD4378@redhat.com>
 <20120131141301.ba35ffe0.akpm@linux-foundation.org>
 <20120131222217.GE4378@redhat.com>
 <20120201033653.GA12092@redhat.com>
 <20120201091807.GA7451@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120201091807.GA7451@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Herbert Poetzl <herbert@13thfloor.at>, Eric Dumazet <eric.dumazet@gmail.com>, Wu Fengguang <wfg@linux.intel.com>

On Wed, Feb 01, 2012 at 04:18:07AM -0500, Christoph Hellwig wrote:
> On Tue, Jan 31, 2012 at 10:36:53PM -0500, Vivek Goyal wrote:
> > I still see that IO is being submitted one page at a time. The only
> > real difference seems to be that queue unplug happening at random times
> > and many a times we are submitting much smaller requests (40 sectors, 48
> > sectors etc).
> 
> This is expected given that the block device node uses
> block_read_full_page, and not mpage_readpage(s).

What is the difference between block_read_full_page() and
mpage_readpage(). IOW, why block device does not use mpage_readpage(s)
interface?

Is enabling mpage_readpages() on block devices is as simple as following
patch or more is involved? (I suspect it has to be more than this. If it
was this simple, it would have been done by now).

This patch complies and seems to work. (system does not crash and dd
seems to be working. I can't verify the contents of the file though).

Applying following patch improved the speed from 110MB/s to more than
230MB/s.

# dd if=/dev/sdb of=/dev/null bs=1M count=1K
1024+0 records in
1024+0 records out
1073741824 bytes (1.1 GB) copied, 4.6269 s, 232 MB/s

---
 fs/block_dev.c |    7 +++++++
 1 file changed, 7 insertions(+)

Index: linux-2.6/fs/block_dev.c
===================================================================
--- linux-2.6.orig/fs/block_dev.c	2012-02-01 22:21:42.000000000 -0500
+++ linux-2.6/fs/block_dev.c	2012-02-02 01:52:40.000000000 -0500
@@ -347,6 +347,12 @@ static int blkdev_readpage(struct file *
 	return block_read_full_page(page, blkdev_get_block);
 }
 
+static int blkdev_readpages(struct file * file, struct address_space *mapping,
+		struct list_head *pages, unsigned nr_pages)
+{
+	return mpage_readpages(mapping, pages, nr_pages, blkdev_get_block);
+}
+
 static int blkdev_write_begin(struct file *file, struct address_space *mapping,
 			loff_t pos, unsigned len, unsigned flags,
 			struct page **pagep, void **fsdata)
@@ -1601,6 +1607,7 @@ static int blkdev_releasepage(struct pag
 
 static const struct address_space_operations def_blk_aops = {
 	.readpage	= blkdev_readpage,
+	.readpages	= blkdev_readpages,
 	.writepage	= blkdev_writepage,
 	.write_begin	= blkdev_write_begin,
 	.write_end	= blkdev_write_end,




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
