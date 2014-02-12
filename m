Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7E99B6B0035
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 18:53:51 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kp14so9942774pab.20
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 15:53:51 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id b4si12582137pbe.58.2014.02.12.15.53.49
        for <linux-mm@kvack.org>;
        Wed, 12 Feb 2014 15:53:50 -0800 (PST)
Date: Wed, 12 Feb 2014 16:53:53 -0700 (MST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v5 06/22] Treat XIP like O_DIRECT
In-Reply-To: <CF215477.24281%matthew.r.wilcox@intel.com>
Message-ID: <alpine.OSX.2.00.1402121640310.60058@scrumpy>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com> <CF215477.24281%matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org

On Wed, 15 Jan 2014, Matthew Wilcox wrote:
> Instead of separate read and write methods, use the generic AIO
> infrastructure.  In addition to giving us support for AIO, this adds
> the locking between read() and truncate() that was missing.
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>

...

> +static ssize_t xip_io(int rw, struct inode *inode, const struct iovec
> *iov,
> +			loff_t start, loff_t end, unsigned nr_segs,
> +			get_block_t get_block, struct buffer_head *bh)
> +{
> +	ssize_t retval = 0;
> +	unsigned seg = 0;
> +	unsigned len;
> +	unsigned copied = 0;
> +	loff_t offset = start;
> +	loff_t max = start;
> +	void *addr;
> +	bool hole = false;
> +
> +	while (offset < end) {
> +		void __user *buf = iov[seg].iov_base + copied;
> +
> +		if (max == offset) {
> +			sector_t block = offset >> inode->i_blkbits;
> +			long size;
> +			memset(bh, 0, sizeof(*bh));
> +			bh->b_size = ALIGN(end - offset, PAGE_SIZE);
> +			retval = get_block(inode, block, bh, rw == WRITE);
> +			if (retval)
> +				break;
> +			if (buffer_mapped(bh)) {
> +				retval = xip_get_addr(inode, bh, &addr);
> +				if (retval < 0)
> +					break;
> +				addr += offset - (block << inode->i_blkbits);
> +				hole = false;
> +				size = retval;
> +			} else {
> +				if (rw == WRITE) {
> +					retval = -EIO;
> +					break;
> +				}
> +				addr = NULL;
> +				hole = true;
> +				size = bh->b_size;
> +			}
> +			max = offset + size;
> +		}
> +
> +		len = min_t(unsigned, iov[seg].iov_len - copied, max - offset);
> +
> +		if (rw == WRITE)
> +			len -= __copy_from_user_nocache(addr, buf, len);
> +		else if (!hole)
> +			len -= __copy_to_user(buf, addr, len);
> +		else
> +			len -= __clear_user(buf, len);
> +
> +		if (!len)
> +			break;
> +
> +		offset += len;
> +		copied += len;
> +		if (copied == iov[seg].iov_len) {
> +			seg++;
> +			copied = 0;
> +		}
> +	}
> +
> +	return (offset == start) ? retval : offset - start;
> +}

xip_io() as it is currently written has an issue where reads can go beyond
inode->i_size.  A quick test to show this issue is:

	create a new file
	write to the file for 1/2 a block
	seek back to 0
	read for a full block

The read in this case will return 4096, the length of the full block that was
requested.  It should return 2048, reading just the data that was written.

The issue is that we do have a full block allocated in ext4, we do have it
available via XIP via xip_get_addr(), and the only extra check that we
currently have is a check against iov_len.  iov_len in this case is 4096, so
no one stops us from doing a full block read.

Here is a quick patch that fixes this issue:

diff --git a/fs/xip.c b/fs/xip.c
index e902593..1608f29 100644
--- a/fs/xip.c
+++ b/fs/xip.c
@@ -91,13 +91,16 @@ static ssize_t xip_io(int rw, struct inode *inode, const struct
 {
        ssize_t retval = 0;
        unsigned seg = 0;
-       unsigned len;
+       unsigned len, total_len;
        unsigned copied = 0;
        loff_t offset = start;
        loff_t max = start;
        void *addr;
        bool hole = false;
 
+       end = min(end, inode->i_size);
+       total_len = end - start;
+
        while (offset < end) {
                void __user *buf = iov[seg].iov_base + copied;
 
@@ -136,6 +139,7 @@ static ssize_t xip_io(int rw, struct inode *inode, const struct
                }
 
                len = min_t(unsigned, iov[seg].iov_len - copied, max - offset);
+               len = min(len, total_len);
 
                if (rw == WRITE)
                        len -= __copy_from_user_nocache(addr, buf, len);
@@ -149,6 +153,7 @@ static ssize_t xip_io(int rw, struct inode *inode, const struct
 
                offset += len;
                copied += len;
+               total_len -= len;
                if (copied == iov[seg].iov_len) {
                        seg++;
                        copied = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
