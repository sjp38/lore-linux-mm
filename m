Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 699416B004D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 17:03:40 -0400 (EDT)
Date: Mon, 31 Aug 2009 17:03:37 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: [PATCH, RFC] vm: Add an tuning knob for vm.max_writeback_pages
Message-ID: <20090831210337.GG23535@mit.edu>
References: <1251600858-21294-1-git-send-email-tytso@mit.edu> <20090830165229.GA5189@infradead.org> <20090830181731.GA20822@mit.edu> <20090830222710.GA9938@infradead.org> <20090831030815.GD20822@mit.edu> <20090831102909.GS12579@kernel.dk> <20090831104748.GT12579@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090831104748.GT12579@kernel.dk>
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-fsdevel@vger.kernel.org, chris.mason@oracle.com
List-ID: <linux-mm.kvack.org>

On Mon, Aug 31, 2009 at 12:47:49PM +0200, Jens Axboe wrote:
> It's because ext4 writepages sets ->range_start and wb_writeback() is
> range cyclic, then the next iteration will have the previous end point
> as the starting point. Looks like we need to clear ->range_start in
> wb_writeback(), the better place is probably to do that in
> fs/fs-writeback.c:generic_sync_wb_inodes() right after the
> writeback_single_inode() call. This, btw, should be no different than
> the current code, weird/correct or not :-)

Thanks for pointing it out.  After staring at the code, I now believe
this is the best fix for now.  What do other folks think?

     	    	     	       	       - Ted

commit 39cac8147479b48cd45b768d184aa6a80f23a2f7
Author: Theodore Ts'o <tytso@mit.edu>
Date:   Mon Aug 31 17:00:59 2009 -0400

    ext4: Restore wbc->range_start in ext4_da_writepages()
    
    To solve a lock inversion problem, we implement part of the
    range_cyclic algorithm in ext4_da_writepages().  (See commit 2acf2c26
    for more details.)
    
    As part of that change wbc->range_start was modified by ext4's
    writepages function, which causes its callers to get confused since
    they aren't expecting the filesystem to modify it.  The simplest fix
    is to save and restore wbc->range_start in ext4_da_writepages.
    
    Signed-off-by: "Theodore Ts'o" <tytso@mit.edu>

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index d61fb52..ff659e7 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -2749,6 +2749,7 @@ static int ext4_da_writepages(struct address_space *mapping,
 	long pages_skipped;
 	int range_cyclic, cycled = 1, io_done = 0;
 	int needed_blocks, ret = 0, nr_to_writebump = 0;
+	loff_t range_start = wbc->range_start;
 	struct ext4_sb_info *sbi = EXT4_SB(mapping->host->i_sb);
 
 	trace_ext4_da_writepages(inode, wbc);
@@ -2917,6 +2918,7 @@ out_writepages:
 	if (!no_nrwrite_index_update)
 		wbc->no_nrwrite_index_update = 0;
 	wbc->nr_to_write -= nr_to_writebump;
+	wbc->range_start = range_start;
 	trace_ext4_da_writepages_result(inode, wbc, ret, pages_written);
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
