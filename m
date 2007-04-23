Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3NGTwBe032053
	for <linux-mm@kvack.org>; Mon, 23 Apr 2007 12:29:58 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l3NGTwSd112492
	for <linux-mm@kvack.org>; Mon, 23 Apr 2007 10:29:58 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l3NGTvjw012929
	for <linux-mm@kvack.org>; Mon, 23 Apr 2007 10:29:58 -0600
Subject: Re: [RFC 15/16] ext2: Add variable page size support
From: Badari Pulavarty <pbadari@gmail.com>
In-Reply-To: <20070423065003.5458.83524.sendpatchset@schroedinger.engr.sgi.com>
References: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com>
	 <20070423065003.5458.83524.sendpatchset@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 23 Apr 2007 09:30:12 -0700
Message-Id: <1177345812.19676.4.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, David Chinner <dgc@sgi.com>, Adam Litke <aglitke@gmail.com>, Avi Kivity <avi@argo.co.il>, Mel Gorman <mel@skynet.ie>, Dave Hansen <hansendc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sun, 2007-04-22 at 23:50 -0700, Christoph Lameter wrote:
> ext2: Add variable page size support
> 
> This adds variable page size support. It is then possible to mount filesystems
> that have a larger blocksize than the page size.
> 
> F.e. the following is possible on x86_64 and i386 that have only a 4k page
> size.
> 
> mke2fs -b 16384 /dev/hdd2	<Ignore warning about too large block size>
> 
> mount /dev/hdd2 /media
> ls -l /media
> 
> .... Do more things with the volume that uses a 16k page cache size on
> a 4k page sized platform..
> 
> Note that there are issues with ext2 support:
> 
> 1. Data is not writtten back correctly (block layer?)
> 2. Reclaim does not work right.

Here is the fix you need to get ext2 writeback working properly :)
I am able to run fsx with this fix (without mapped IO).

Thanks,
Badari

 fs/buffer.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.21-rc7/fs/buffer.c
===================================================================
--- linux-2.6.21-rc7.orig/fs/buffer.c	2007-04-23 09:44:19.000000000 -0700
+++ linux-2.6.21-rc7/fs/buffer.c	2007-04-23 10:28:45.000000000 -0700
@@ -1619,7 +1619,7 @@ static int __block_write_full_page(struc
 	 * handle that here by just cleaning them.
 	 */
 
-	block = (sector_t)page->index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+	block = (sector_t)page->index << (page_cache_shift(page->mapping) - inode->i_blkbits);
 	head = page_buffers(page);
 	bh = head;
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
