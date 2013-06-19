Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 098186B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 12:37:58 -0400 (EDT)
Date: Wed, 19 Jun 2013 18:37:53 +0200 (CEST)
From: =?ISO-8859-15?Q?Luk=E1=A8_Czerner?= <lczerner@redhat.com>
Subject: Re: [PATCH v4 15/20] ext4: use ext4_zero_partial_blocks in
 punch_hole
In-Reply-To: <20130614030154.GA18731@thunk.org>
Message-ID: <alpine.LFD.2.00.1306191831210.2085@localhost.localdomain>
References: <1368549454-8930-1-git-send-email-lczerner@redhat.com> <1368549454-8930-16-git-send-email-lczerner@redhat.com> <20130614030154.GA18731@thunk.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, akpm@linux-foundation.org, hughd@google.com

On Thu, 13 Jun 2013, Theodore Ts'o wrote:

> Date: Thu, 13 Jun 2013 23:01:54 -0400
> From: Theodore Ts'o <tytso@mit.edu>
> To: Lukas Czerner <lczerner@redhat.com>
> Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
>     linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
>     akpm@linux-foundation.org, hughd@google.com
> Subject: Re: [PATCH v4 15/20] ext4: use ext4_zero_partial_blocks in punch_hole
> 
> On Tue, May 14, 2013 at 06:37:29PM +0200, Lukas Czerner wrote:
> > We're doing to get rid of ext4_discard_partial_page_buffers() since it is
> > duplicating some code and also partially duplicating work of
> > truncate_pagecache_range(), moreover the old implementation was much
> > clearer.
> > 
> > Now when the truncate_inode_pages_range() can handle truncating non page
> > aligned regions we can use this to invalidate and zero out block aligned
> > region of the punched out range and then use ext4_block_truncate_page()
> > to zero the unaligned blocks on the start and end of the range. This
> > will greatly simplify the punch hole code. Moreover after this commit we
> > can get rid of the ext4_discard_partial_page_buffers() completely.
> > 
> > We also introduce function ext4_prepare_punch_hole() to do come common
> > operations before we attempt to do the actual punch hole on
> > indirect or extent file which saves us some code duplication.
> > 
> > This has been tested on ppc64 with 1k block size with fsx and xfstests
> > without any problems.
> > 
> > Signed-off-by: Lukas Czerner <lczerner@redhat.com>
> 
> Hi Lukas,
> 
> I've been seeing xfstests failures on test generic/300 in nojournal
> mode.
> 
> BEGIN TEST: Ext4 4k block w/ no journal Thu Jun 13 22:38:47 EDT 2013
> Device: /dev/vdb
> mk2fs options: -q -O ^has_journal
> mount options: -o block_validity,noload
> FSTYP         -- ext4
> PLATFORM      -- Linux/i686 candygram 3.10.0-rc2-00477-g1e1cad7
> MKFS_OPTIONS  -- -q -O ^has_journal /dev/vdc
> MOUNT_OPTIONS -- -o acl,user_xattr -o block_validity,noload /dev/vdc /vdc
> 
> generic/300		[20:42:18][  116.877278] fio (3320) used greatest stack depth: 5580 bytes left
> [  116.967122] fio (3321) used greatest stack depth: 5560 bytes left
> [  117.573861] fio (3325) used greatest stack depth: 5504 bytes left
>  [20:44:01] [failed, exit status 1] - output mismatch (see /root/xfstests/results/generic/300.out.bad)
>     --- tests/generic/300.out	 2013-06-04 22:42:55.000000000 -0400
>     +++ /root/xfstests/results/generic/300.out.bad	       2013-06-13 20:44:01.306666665 -0400
>     @@ -2,3 +2,4 @@
>      
>      Run fio with random aio-dio pattern
>      
>     +_check_generic_filesystem: filesystem on /dev/vdc is inconsistent (see /root/xfstests/results/generic/300.full)
>      ...
>      (Run 'diff -u tests/generic/300.out /root/xfstests/results/generic/300.out.bad' to see the entire diff)

I think I've got this. The problem actually is in
ext4_zero_partial_blocks() where we would attempt to zero out page
which has been previously released by truncate_pagecache_range().
This might happen when we're punching out just a single page because
in ext4_zero_partial_blocks() we do not check whether we're dealing
with the whole, or partial page. At the point we're going to zero it
out it might have been already released and reused by someone else.

This patch should fix this issue. And indeed with this applied I do
not see the problem anymore but I am still testing.

-Lukas


diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 3acf353..ce9f926 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3698,33 +3698,36 @@ int ext4_zero_partial_blocks(handle_t *handle, struct inode *inode,
 {
 	struct super_block *sb = inode->i_sb;
 	struct address_space *mapping = inode->i_mapping;
-	unsigned partial = lstart & (sb->s_blocksize - 1);
+	unsigned partial_start, partial_end;
 	ext4_fsblk_t start, end;
 	loff_t byte_end = (lstart + length - 1);
 	int err = 0;
 
+	partial_start = lstart & (sb->s_blocksize - 1);
+	partial_end = byte_end & (sb->s_blocksize - 1);
+
 	start = lstart >> sb->s_blocksize_bits;
 	end = byte_end >> sb->s_blocksize_bits;
 
 	/* Handle partial zero within the single block */
-	if (start == end) {
+	if (start == end &&
+	    (partial_start || (partial_end != sb->s_blocksize - 1))) {
 		err = ext4_block_zero_page_range(handle, mapping,
 						 lstart, length);
 		return err;
 	}
 	/* Handle partial zero out on the start of the range */
-	if (partial) {
+	if (partial_start) {
 		err = ext4_block_zero_page_range(handle, mapping,
 						 lstart, sb->s_blocksize);
 		if (err)
 			return err;
 	}
 	/* Handle partial zero out on the end of the range */
-	partial = byte_end & (sb->s_blocksize - 1);
-	if (partial != sb->s_blocksize - 1)
+	if (partial_end != sb->s_blocksize - 1)
 		err = ext4_block_zero_page_range(handle, mapping,
-						 byte_end - partial,
-						 partial + 1);
+						 byte_end - partial_end,
+						 partial_end + 1);
 	return err;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
