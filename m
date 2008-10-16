Received: by gxk8 with SMTP id 8so6928114gxk.14
        for <linux-mm@kvack.org>; Thu, 16 Oct 2008 02:10:26 -0700 (PDT)
Date: Thu, 16 Oct 2008 14:40:15 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@gmail.com>
Subject: Re: [PATCH updated] ext4: Fix file fragmentation during large file
	write.
Message-ID: <20081016091015.GA3354@skywalker>
References: <1223661776-20098-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1224103260.6938.45.camel@think.oraclecorp.com> <1224114692.6938.48.camel@think.oraclecorp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1224114692.6938.48.camel@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, cmm@us.ibm.com, tytso@mit.edu, sandeen@redhat.com, akpm@linux-foundation.org, hch@infradead.org, steve@chygwyn.com, npiggin@suse.de, mpatocka@redhat.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
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

last patch I sent didn't solve the problem. The below patch
fixes it for me. The problem is not introduced by the file fragmentation
fixes. Full diff below. The first hunk is the important change. I also
kept the rest of the changes because I think they are fine. Also I added
a printk to figure out whether we ever exit from ext4_da_writepages with
increasing pages_skipped value

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 3c4b9b4..b6768eb 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -2136,6 +2136,9 @@ static int mpage_da_writepages(struct address_space *mapping,
 	if (!mpd->io_done && mpd->next_page != mpd->first_page) {
 		if (mpage_da_map_blocks(mpd) == 0)
 			mpage_da_submit_io(mpd);
+
+		mpd->io_done = 1;
+		ret = MPAGE_DA_EXTENT_TAIL;
 	}
 
 	wbc->nr_to_write -= mpd->pages_written;
@@ -2370,10 +2373,10 @@ static int ext4_da_writepages(struct address_space *mapping,
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
 
@@ -2411,6 +2414,7 @@ static int ext4_da_writepages(struct address_space *mapping,
 	 */
 	no_nrwrite_index_update = wbc->no_nrwrite_index_update;
 	wbc->no_nrwrite_index_update = 1;
+	pages_skipped = wbc->pages_skipped;
 
 	while (!ret && wbc->nr_to_write > 0) {
 
@@ -2444,6 +2448,7 @@ static int ext4_da_writepages(struct address_space *mapping,
 			 * and try again
 			 */
 			jbd2_journal_force_commit_nested(sbi->s_journal);
+			wbc->pages_skipped = pages_skipped;
 			ret = 0;
 		} else if (ret == MPAGE_DA_EXTENT_TAIL) {
 			/*
@@ -2451,6 +2456,7 @@ static int ext4_da_writepages(struct address_space *mapping,
 			 * rest of the pages
 			 */
 			pages_written += mpd.pages_written;
+			wbc->pages_skipped = pages_skipped;
 			ret = 0;
 		} else if (wbc->nr_to_write)
 			/*
@@ -2460,6 +2466,11 @@ static int ext4_da_writepages(struct address_space *mapping,
 			 */
 			break;
 	}
+	if (pages_skipped != wbc->pages_skipped)
+		printk(KERN_EMERG "This should not happen leaving %s "
+				"with nr_to_write %ld ret = %d\n",
+				__func__, wbc->nr_to_write, ret);
+
 	/* Update index */
 	index += pages_written;
 	if (wbc->range_cyclic || (range_whole && wbc->nr_to_write > 0))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
