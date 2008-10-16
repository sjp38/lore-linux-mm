Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id m9G7p4kC008239
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 13:21:04 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9G7p3He1360060
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 13:21:03 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m9G7p26j009594
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 13:21:04 +0530
Date: Thu, 16 Oct 2008 13:20:54 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH updated] ext4: Fix file fragmentation during large file
	write.
Message-ID: <20081016075054.GC19480@skywalker>
References: <1223661776-20098-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1224103260.6938.45.camel@think.oraclecorp.com> <1224114692.6938.48.camel@think.oraclecorp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1224114692.6938.48.camel@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: cmm@us.ibm.com, tytso@mit.edu, sandeen@redhat.com, akpm@linux-foundation.org, hch@infradead.org, steve@chygwyn.com, npiggin@suse.de, mpatocka@redhat.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 15, 2008 at 07:51:32PM -0400, Chris Mason wrote:
> On Wed, 2008-10-15 at 16:41 -0400, Chris Mason wrote:
> > On Fri, 2008-10-10 at 23:32 +0530, Aneesh Kumar K.V wrote:
> > > The range_cyclic writeback mode use the address_space
> > > writeback_index as the start index for writeback. With
> > > delayed allocation we were updating writeback_index
> > > wrongly resulting in highly fragmented file. Number of
> > > extents reduced from 4000 to 27 for a 3GB file with
> > > the below patch.
> > > 
> > 
> > I tested the ext4 patch queue from today on top of 2.6.27, and this
> > includes Aneesh's latest patches.
> > 
> > Things are going at disk speed for streaming writes, with the number of
> > extents generated for a 32GB file down to 27.  So, this is definitely an
> > improvement for ext4.
> 
> Just FYI, I ran this with compilebench -i 20 --makej and my log is full
> of these:
> 
> ext4_da_writepages: jbd2_start: 1024 pages, ino 520417; err -30
> Pid: 4072, comm: pdflush Not tainted 2.6.27 #2
> 
> Call Trace:
>  [<ffffffffa0048493>] ext4_da_writepages+0x171/0x2d3 [ext4]
>  [<ffffffff802336be>] ? pick_next_task_fair+0x80/0x91
>  [<ffffffff80228fa8>] ? source_load+0x2a/0x58
>  [<ffffffff8038e499>] ? __next_cpu+0x19/0x26
>  [<ffffffff8026748f>] do_writepages+0x28/0x37
>  [<ffffffff802a6b39>] __writeback_single_inode+0x14f/0x26d
>  [<ffffffff802a6fb7>] generic_sync_sb_inodes+0x1c1/0x2a2
>  [<ffffffff802a70a1>] sync_sb_inodes+0x9/0xb
>  [<ffffffff802a73dc>] writeback_inodes+0x64/0xad
>  [<ffffffff802675db>] wb_kupdate+0x9a/0x10c
>  [<ffffffff80267fd1>] ? pdflush+0x0/0x1e9
>  [<ffffffff80267fd1>] ? pdflush+0x0/0x1e9
>  [<ffffffff8026810e>] pdflush+0x13d/0x1e9
>  [<ffffffff80267541>] ? wb_kupdate+0x0/0x10c
>  [<ffffffff80248222>] kthread+0x49/0x77
>  [<ffffffff8020c5e9>] child_rip+0xa/0x11
>  [<ffffffff802481d9>] ? kthread+0x0/0x77
>  [<ffffffff8020c5df>] ? child_rip+0x0/0x11

I actually did the mount -o remount,ro test before sending out the
patches to see if we are skipping some pages during writeback. I
didn't see the error at that time. Today i tried again on a larger
file system and i am able to reproduce the above stack with -o
remount,ro. The patch below fix it for me. The VFS writeback looks
at pages_skipped and make some decision if the value  increase
during call back(__fynsc_super -> generic_sync_sb_inodes).
So we need to update pages_skipped also. This may not apply on
top of what patches are in patchqueue. I also have other changes
to use single variable no_nrwite_index_update as per Christoph
suggestion. I will send out the patches for patchqueue after 
I look at the compile bench numbers you reported.

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 3c4b9b4..88ce29e 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -2370,10 +2370,10 @@ static int ext4_da_writepages(struct address_space *mapping,
 	pgoff_t	index;
 	int range_whole = 0;
 	handle_t *handle = NULL;
-	long pages_written = 0;
 	struct mpage_da_data mpd;
 	struct inode *inode = mapping->host;
 	int no_nrwrite_index_update;
+	long pages_written = 0, pages_skipped;
 	int needed_blocks, ret = 0, nr_to_writebump = 0;
 	struct ext4_sb_info *sbi = EXT4_SB(mapping->host->i_sb);
 
@@ -2411,6 +2411,7 @@ static int ext4_da_writepages(struct address_space *mapping,
 	 */
 	no_nrwrite_index_update = wbc->no_nrwrite_index_update;
 	wbc->no_nrwrite_index_update = 1;
+	pages_skipped = wbc->pages_skipped;
 
 	while (!ret && wbc->nr_to_write > 0) {
 
@@ -2444,6 +2445,7 @@ static int ext4_da_writepages(struct address_space *mapping,
 			 * and try again
 			 */
 			jbd2_journal_force_commit_nested(sbi->s_journal);
+			wbc->pages_skipped = pages_skipeed;
 			ret = 0;
 		} else if (ret == MPAGE_DA_EXTENT_TAIL) {
 			/*
@@ -2451,6 +2453,7 @@ static int ext4_da_writepages(struct address_space *mapping,
 			 * rest of the pages
 			 */
 			pages_written += mpd.pages_written;
+			wbc->pages_skipped = pages_skipeed;
 			ret = 0;
 		} else if (wbc->nr_to_write)
 			/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
