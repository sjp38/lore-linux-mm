Date: Mon, 5 Nov 2007 15:40:51 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland 
In-Reply-To: <200710312353.l9VNr67n013016@agora.fsl.cs.sunysb.edu>
Message-ID: <Pine.LNX.4.64.0711051358440.7629@blonde.wat.veritas.com>
References: <200710312353.l9VNr67n013016@agora.fsl.cs.sunysb.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Erez Zadok <ezk@cs.sunysb.edu>
Cc: Dave Hansen <haveblue@us.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[Dave, I've Cc'ed you re handle_write_count_underflow, see below.]

On Wed, 31 Oct 2007, Erez Zadok wrote:
> 
> Hi Hugh, I've addressed all of your concerns and am happy to report that the
> newly revised unionfs_writepage works even better, including under my
> memory-pressure conditions.  To summarize my changes since the last time:
> 
> - I'm only masking __GFP_FS, not __GFP_IO
> - using find_or_create_page to avoid locking issues around mapping mask
> - handle for_reclaim case more efficiently
> - using copy_highpage so we handle KM_USER*
> - un/locking upper/lower page as/when needed
> - updated comments to clarify what/why
> - unionfs_sync_page: gone (yes, vfs.txt did confuse me, plus ecryptfs used
>   to have it)
> 
> Below is the newest version of unionfs_writepage.  Let me know what you
> think.
> 
> I have to say that with these changes, unionfs appears visibly faster under
> memory pressure.  I suspect the for_reclaim handling is probably the largest
> contributor to this speedup.

That's good news, and that unionfs_writepage looks good to me -
with three reservations I've not observed before.

One, I think you would be safer to do a set_page_dirty(lower_page)
before your clear_page_dirty_for_io(lower_page).  I know that sounds
silly, but see Linus' "Yes, Virginia" comment in clear_page_dirty_for_io:
there's a lot of subtlety hereabouts, and I think you'd be mimicing the
usual path closer if you set_page_dirty first - there's nothing else
doing it on that lower_page, is there?  I'm not certain that you need
to, but I think you'd do well to look into it and make up your own mind.

Two, I'm unsure of the way you're clearing or setting PageUptodate on
the upper page there.  The rules for PageUptodate are fairly obvious
when reading, but when a write fails, it's not so obvious.  Again, I'm
not saying what you've got is wrong (it may be unavoidable, to keep
synch between lower and upper), but it deserves a second thought.

Three, I believe you need to add a flush_dcache_page(lower_page)
after the copy_highpage(lower_page): some architectures will need
that to see the new data if they have lower_page mapped (though I
expect it's anyway shaky ground to be accessing through the lower
mount at the same time as modifying through the upper).

I've been trying this out on 2.6.23-mm1 with your 21 Oct 1-9/9
and your 2 Nov 1-8/8 patches applied (rejects being patches which
were already in 2.6.23-mm1).  I was hoping to reproduce the
BUG_ON(entry->val) that I fear from shmem_writepage(), before
fixing it; but not seen that at all yet - that might be good
news, but it's more likely I just haven't tried hard enough yet.

For now I'm doing repeated make -j20 kernel builds, pushing into
swap, in a unionfs mount of just a single dir on tmpfs.  This has
shown up several problems, two of which I've had to hack around to
get further.

The first: I very quickly hit "BUG: atomic counter underflow"
from -mm's i386 atomic_dec_and_test: from filp_close calling
unionfs_flush.  I did a little test fork()ing while holding a file
open on unionfs, and indeed it appears that your totalopens code is
broken, being unaware of how fork() bumps up a file count without
an open.  That's rather basic, I'm puzzled that this has remained
undiscovered until now - or perhaps it's just a recent addition.

It looked to me as if the totalopens count was about avoiding some
d_deleted processing in unionfs_flush, which actually should be left
until unionfs_release (and that your unionfs_flush ought to be calling
the lower level flush in all cases).  To get going, I've been running
with the quick hack patch below: but I've spent very little time
thinking about it, plus it's a long time since I've done VFS stuff;
so that patch may be nothing but an embarrassment that reflects
neither your intentions nor the VFS rules!  And it may itself be
responsible for the further problems I've seen.

The second problem was a hang: all cpus in handle_write_count_underflow
doing lock_and_coalesce_cpu_mnt_writer_counts: new -mm stuff from Dave
Hansen.  At first I thought that was a locking problem in Dave's code,
but I now suspect it's that your unionfs reference counting is wrong
somewhere, and the error accumulates until __mnt_writers drops below
MNT_WRITER_UNDERFLOW_LIMIT, but the coalescence does nothing to help
and we're stuck in that loop.  My even greater hack to solve that one
was to change Dave's "while" to "if"!  Then indeed tests can run for
some while.  As I say, my suspicion is that the actual error is within
unionfs (perhaps introduced by my first hack); but I hope Dave can
also make handle_write_count_underflow more robust, it's unfortunate
if refcount errors elsewhere first show up as a hang there.

I've had CONFIG_UNION_FS_DEBUG=y but will probably turn it off when
I come back to this, since it's rather noisy at present.  I've not
checked whether its reports are peculiar to having tmpfs below or not.
I get lots of "unionfs: new lower inode mtime" reports on directories
(if there have been any on regular files, I've missed them in the
noise on directories); "unionfs: unhashed dentry being revalidated"s
(mostly or all directories again); "unionfs: saving rdstate with cookie"s.
After five hours hit "kernel BUG at fs/unionfs/fanout.h:128!".

But the first two problems probably make the rest uninteresting:
I'm hoping you can look at those and provide patches for them,
for now I'll switch away to other work.

Hugh

Dubious patch, Not-Signed-off-by: Nobody <anonymous@nowhere.org>

--- 2.6.23-mm1++/fs/unionfs/commonfops.c	2007-11-04 13:14:42.000000000 +0000
+++ linux/fs/unionfs/commonfops.c	2007-11-04 14:21:12.000000000 +0000
@@ -551,9 +551,6 @@ int unionfs_open(struct inode *inode, st
 	bstart = fbstart(file) = dbstart(dentry);
 	bend = fbend(file) = dbend(dentry);
 
-	/* increment, so that we can flush appropriately */
-	atomic_inc(&UNIONFS_I(dentry->d_inode)->totalopens);
-
 	/*
 	 * open all directories and make the unionfs file struct point to
 	 * these lower file structs
@@ -565,7 +562,6 @@ int unionfs_open(struct inode *inode, st
 
 	/* freeing the allocated resources, and fput the opened files */
 	if (err) {
-		atomic_dec(&UNIONFS_I(dentry->d_inode)->totalopens);
 		for (bindex = bstart; bindex <= bend; bindex++) {
 			lower_file = unionfs_lower_file_idx(file, bindex);
 			if (!lower_file)
@@ -606,6 +602,7 @@ int unionfs_file_release(struct inode *i
 	struct unionfs_file_info *fileinfo;
 	struct unionfs_inode_info *inodeinfo;
 	struct super_block *sb = inode->i_sb;
+	struct dentry *dentry = file->f_path.dentry;
 	int bindex, bstart, bend;
 	int fgen, err = 0;
 
@@ -628,6 +625,7 @@ int unionfs_file_release(struct inode *i
 	bstart = fbstart(file);
 	bend = fbend(file);
 
+	unionfs_lock_dentry(dentry);
 	for (bindex = bstart; bindex <= bend; bindex++) {
 		lower_file = unionfs_lower_file_idx(file, bindex);
 
@@ -635,7 +633,15 @@ int unionfs_file_release(struct inode *i
 			fput(lower_file);
 			branchput(sb, bindex);
 		}
+
+		/* if there are no more refs to the dentry, dput it */
+		if (d_deleted(dentry)) {
+			dput(unionfs_lower_dentry_idx(dentry, bindex));
+			unionfs_set_lower_dentry_idx(dentry, bindex, NULL);
+		}
 	}
+	unionfs_unlock_dentry(dentry);
+
 	kfree(fileinfo->lower_files);
 	kfree(fileinfo->saved_branch_ids);
 
@@ -799,11 +805,6 @@ int unionfs_flush(struct file *file, fl_
 		goto out;
 	unionfs_check_file(file);
 
-	if (!atomic_dec_and_test(&UNIONFS_I(dentry->d_inode)->totalopens))
-		goto out;
-
-	unionfs_lock_dentry(dentry);
-
 	bstart = fbstart(file);
 	bend = fbend(file);
 	for (bindex = bstart; bindex <= bend; bindex++) {
@@ -813,14 +814,7 @@ int unionfs_flush(struct file *file, fl_
 		    lower_file->f_op->flush) {
 			err = lower_file->f_op->flush(lower_file, id);
 			if (err)
-				goto out_lock;
-
-			/* if there are no more refs to the dentry, dput it */
-			if (d_deleted(dentry)) {
-				dput(unionfs_lower_dentry_idx(dentry, bindex));
-				unionfs_set_lower_dentry_idx(dentry, bindex,
-							     NULL);
-			}
+				goto out;
 		}
 
 	}
@@ -830,8 +824,6 @@ int unionfs_flush(struct file *file, fl_
 	/* parent time could have changed too (async) */
 	unionfs_copy_attr_times(dentry->d_parent->d_inode);
 
-out_lock:
-	unionfs_unlock_dentry(dentry);
 out:
 	unionfs_read_unlock(dentry->d_sb);
 	unionfs_check_file(file);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
