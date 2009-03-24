Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C82676B003D
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 10:38:10 -0400 (EDT)
Date: Tue, 24 Mar 2009 15:47:09 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
Message-ID: <20090324144709.GF23439@duck.suse.cz>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com> <20090324125510.GA9434@duck.suse.cz> <20090324132637.GA14607@duck.suse.cz> <200903250130.02485.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200903250130.02485.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Jan Kara <jack@suse.cz>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ext4@vger.kernel.org, Ying Han <yinghan@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Wed 25-03-09 01:30:00, Nick Piggin wrote:
> On Wednesday 25 March 2009 00:26:37 Jan Kara wrote:
> > On Tue 24-03-09 13:55:10, Jan Kara wrote:
> > > On Tue 24-03-09 13:39:36, Jan Kara wrote:
> > > >   Hi,
> > > >
> > > > On Tue 24-03-09 18:44:21, Nick Piggin wrote:
> > > > > On Friday 20 March 2009 03:46:39 Jan Kara wrote:
> > > > > > On Fri 20-03-09 02:48:21, Nick Piggin wrote:
> > > > > > > Holding mapping->private_lock over the __set_page_dirty should
> > > > > > > fix it, although I guess you'd want to release it before calling
> > > > > > > __mark_inode_dirty so as not to put inode_lock under there. I
> > > > > > > have a patch for this if it sounds reasonable.
> > > > > >
> > > > > >   Yes, that seems to be a bug - the function actually looked
> > > > > > suspitious to me yesterday but I somehow convinced myself that it's
> > > > > > fine. Probably because fsx-linux is single-threaded.
> > > > >
> > > > > After a whole lot of chasing my own tail in the VM and buffer layers,
> > > > > I think it is a problem in ext2 (and I haven't been able to reproduce
> > > > > with ext3 yet, which might lend weight to that, although as we have
> > > > > seen, it is very timing dependent).
> > > > >
> > > > > That would be slightly unfortunate because we still have Jan's ext3
> > > > > problem, and also another reported problem of corruption on ext3 (on
> > > > > brd driver).
> > > > >
> > > > > Anyway, when I have reproduced the problem with the test case, the
> > > > > "lost" writes are all reported to be holes. Unfortunately, that
> > > > > doesn't point straight to the filesystem, because ext2 allocates
> > > > > blocks in this case at writeout time, so if dirty bits are getting
> > > > > lost, then it would be normal to see holes.
> > > > >
> > > > > I then put in a whole lot of extra infrastructure to track metadata
> > > > > about each struct page (when it was last written out, when it last
> > > > > had the number of writable ptes reach 0, when the dirty bits were
> > > > > last cleared etc). And none of the normal asertions were triggering:
> > > > > eg. when any page is removed from pagecache (except truncates), it
> > > > > has always had all its buffers written out *after* all ptes were made
> > > > > readonly or unmapped. Lots of other tests and crap like that.
> > > >
> > > >   I see we're going the same way ;)
> > > >
> > > > > So I tried what I should have done to start with and did an e2fsck
> > > > > after seeing corruption. Yes, it comes up with errors. Now that is
> > > > > unusual because that should be largely insulated from the vm: if a
> > > > > dirty bit gets lost, then the filesystem image should be quite happy
> > > > > and error-free with a hole or unwritten data there.
> > > >
> > > >   This is different for me. I see no corruption on the filesystem with
> > > > ext3. Anyway, errors from fsck would be useful to see what kind of
> > > > corruption you saw.
> > > >
> > > > > I don't know ext? locking very well, except that it looks pretty
> > > > > overly complex and crufty.
> > > > >
> > > > > Usually, blocks are instantiated by write(2), under i_mutex,
> > > > > serialising the allocator somewhat. mmap-write blocks are
> > > > > instantiated at writeout time, unserialised. I moved truncate_mutex
> > > > > to cover the entire get_blocks function, and can no longer trigger
> > > > > the problem. Might be a timing issue though -- Ying, can you try this
> > > > > and see if you can still reproduce?
> > > > >
> > > > > I close my eyes and pick something out of a hat. a686cd89. Search for
> > > > > XXX. Nice. Whether or not this cased the problem, can someone please
> > > > > tell me why it got merged in that state?
> > > >
> > > >   Maybe, I see it did some changes to ext2_get_blocks() which could be
> > > > where the problem was introduced...
> > > >
> > > > > I'm leaving ext3 running for now. It looks like a nasty task to
> > > > > bisect ext2 down to that commit :( and I would be more interested in
> > > > > trying to reproduce Jan's ext3 problem, however, because I'm not too
> > > > > interested in diving into ext2 locking to work out exactly what is
> > > > > racing and how to fix it properly. I suspect it would be most
> > > > > productive to wire up some ioctls right into the block
> > > > > allocator/lookup and code up a userspace tester for it that could
> > > > > probably stress it a lot harder than kernel writeout can.
> > > >
> > > >   Yes, what I observed with ext3 so far is that data is properly copied
> > > > and page marked dirty when the data is copied in. But then at some
> > > > point dirty bit is cleared via block_write_full_page() but we don't get
> > > > to submitting at least one buffer in that page. I'm now debugging which
> > > > path we take so that this happens...
> > >
> > >   And one more interesting thing I don't yet fully understand - I see
> > > pages having PageError() set when they are removed from page cache (and
> > > they have been faulted in before). It's probably some interaction with
> > > pagecache readahead...
> >
> >   Argh... So the problem seems to be that get_block() occasionally returns
> > ENOSPC and we then discard the dirty data (hmm, we could give at least a
> > warning for that). I'm not yet sure why getblock behaves like this because
> > the filesystem seems to have enough space but anyway this seems to be some
> > strange fs trouble as well.
> 
> Ah good find.
> 
> I don't think it is a very good idea for block_write_full_page recovery
> to do clear_buffer_dirty for !mapped buffers. I think that should rather
> be a redirty_page_for_writepage in the case that the buffer is dirty.
> 
> Perhaps not the cleanest way to solve the problem if it is just due to
> transient shortage of space in ext3, but generic code shouldn't be
> allowed to throw away dirty data even if it can't be written back due
> to some software or hardware error.
  Well, that would be one possibility. But then we'd be left with dirty
pages we cannot ever release since they are constantly dirty (when the
filesystem really becomes out of space). So what I
rather want to do is something like below:

diff --git a/fs/ext3/inode.c b/fs/ext3/inode.c
index d351eab..77c526f 100644
--- a/fs/ext3/inode.c
+++ b/fs/ext3/inode.c
@@ -1440,6 +1440,40 @@ static int journal_dirty_data_fn(handle_t *handle, struct buffer_head *bh)
 }
 
 /*
+ * Decides whether it's worthwhile to wait for transaction commit and
+ * retry allocation. If it is, function waits 1 is returns, otherwise
+ * 0 is returned. In both cases we redirty page and it's buffers so that
+ * data is not lost. In case we've retried too many times, we also return
+ * 0 and don't redirty the page. Data gets discarded but we cannot hang
+ * writepage forever...
+ */
+static int ext3_writepage_retry_alloc(struct page *page, int *retries,
+				      struct writeback_control *wbc)
+{
+	struct super_block *sb = ((struct inode *)page->mapping->host)->i_sb;
+	int ret = 0;
+
+	/*
+	 * We don't want to slow down background writeback too much. On the
+	 * other hand if most of the dirty data needs allocation, we better
+	 * wait to make some progress
+	 */
+	if (wbc->sync_mode == WB_SYNC_NONE && !wbc->for_reclaim &&
+	    wbc->pages_skipped < wbc->nr_to_write / 2)
+		goto redirty;
+	/*
+	 * Now wait if commit can free some space and we haven't retried
+	 * too much
+	 */
+	if (!ext3_should_retry_alloc(sb, retries))
+		return 0;
+	ret = 1;
+redirty:
+	set_page_dirty(page);
+	return ret;
+}
+
+/*
  * Note that we always start a transaction even if we're not journalling
  * data.  This is to preserve ordering: any hole instantiation within
  * __block_write_full_page -> ext3_get_block() should be journalled
@@ -1564,10 +1598,12 @@ static int ext3_writeback_writepage(struct page *page,
 	handle_t *handle = NULL;
 	int ret = 0;
 	int err;
+	int retries;
 
 	if (ext3_journal_current_handle())
 		goto out_fail;
 
+restart:
 	handle = ext3_journal_start(inode, ext3_writepage_trans_blocks(inode));
 	if (IS_ERR(handle)) {
 		ret = PTR_ERR(handle);
@@ -1580,8 +1616,13 @@ static int ext3_writeback_writepage(struct page *page,
 		ret = block_write_full_page(page, ext3_get_block, wbc);
 
 	err = ext3_journal_stop(handle);
-	if (!ret)
+	if (!ret) {
 		ret = err;
+	} else {
+		if (ret == -ENOSPC &&
+		    ext3_writepage_retry_alloc(page, &retries, wbc))
+			goto restart;
+	}
 	return ret;
 
 out_fail:

  And similarly for the other two writepage implementations in ext3...
But it currently gives me:
WARNING: at fs/buffer.c:781 __set_page_dirty+0x8d/0x145()
probably because of that set_page_dirty() in ext3_writepage_retry_alloc().

Or we could implement ext3_mkwrite() to allocate buffers already when we
make page writeable. But it costs some performace (we have to write page
full of zeros when allocating those buffers, where previously we didn't
have to do anything) and it's not trivial to make it work if pagesize >
blocksize (we should not allocate buffers outside of i_size so if i_size
= 1024, we create just one block in ext3_mkwrite() but then we need to
allocate more when we extend the file).

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
