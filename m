Date: Sat, 2 Aug 2008 12:02:13 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] convert test_set_buffer_locked to trylock_buffer
Message-ID: <20080802100213.GB14757@wotan.suse.de>
References: <20080802100103.GA14757@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080802100103.GA14757@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

fs: rename buffer trylock

Like the page lock change, this also requires name change, so convert the
raw test_and_set bitop to a trylock.

Signed-off-by: Nick Piggin <npiggin@suse.de>

---
 fs/buffer.c                 |    4 ++--
 fs/jbd/commit.c             |    2 +-
 fs/ntfs/aops.c              |    2 +-
 fs/ntfs/compress.c          |    2 +-
 fs/ntfs/mft.c               |    4 ++--
 fs/reiserfs/inode.c         |    2 +-
 fs/reiserfs/journal.c       |    4 ++--
 fs/xfs/linux-2.6/xfs_aops.c |    2 +-
 include/linux/buffer_head.h |    8 ++++++--
 9 files changed, 17 insertions(+), 13 deletions(-)

Index: linux-2.6/fs/jbd/commit.c
===================================================================
--- linux-2.6.orig/fs/jbd/commit.c
+++ linux-2.6/fs/jbd/commit.c
@@ -221,7 +221,7 @@ write_out_data:
 		 * blocking lock_buffer().
 		 */
 		if (buffer_dirty(bh)) {
-			if (test_set_buffer_locked(bh)) {
+			if (!trylock_buffer(bh)) {
 				BUFFER_TRACE(bh, "needs blocking lock");
 				spin_unlock(&journal->j_list_lock);
 				/* Write out all data to prevent deadlocks */
Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -1720,7 +1720,7 @@ static int __block_write_full_page(struc
 		 */
 		if (wbc->sync_mode != WB_SYNC_NONE || !wbc->nonblocking) {
 			lock_buffer(bh);
-		} else if (test_set_buffer_locked(bh)) {
+		} else if (!trylock_buffer(bh)) {
 			redirty_page_for_writepage(wbc, page);
 			continue;
 		}
@@ -3000,7 +3000,7 @@ void ll_rw_block(int rw, int nr, struct 
 
 		if (rw == SWRITE || rw == SWRITE_SYNC)
 			lock_buffer(bh);
-		else if (test_set_buffer_locked(bh))
+		else if (!trylock_buffer(bh))
 			continue;
 
 		if (rw == WRITE || rw == SWRITE || rw == SWRITE_SYNC) {
Index: linux-2.6/include/linux/buffer_head.h
===================================================================
--- linux-2.6.orig/include/linux/buffer_head.h
+++ linux-2.6/include/linux/buffer_head.h
@@ -115,7 +115,6 @@ BUFFER_FNS(Uptodate, uptodate)
 BUFFER_FNS(Dirty, dirty)
 TAS_BUFFER_FNS(Dirty, dirty)
 BUFFER_FNS(Lock, locked)
-TAS_BUFFER_FNS(Lock, locked)
 BUFFER_FNS(Req, req)
 TAS_BUFFER_FNS(Req, req)
 BUFFER_FNS(Mapped, mapped)
@@ -321,10 +320,15 @@ static inline void wait_on_buffer(struct
 		__wait_on_buffer(bh);
 }
 
+static inline int trylock_buffer(struct buffer_head *bh)
+{
+	return likely(!test_and_set_bit(BH_Lock, &bh->b_state));
+}
+
 static inline void lock_buffer(struct buffer_head *bh)
 {
 	might_sleep();
-	if (test_set_buffer_locked(bh))
+	if (!trylock_buffer(bh))
 		__lock_buffer(bh);
 }
 
Index: linux-2.6/fs/ntfs/aops.c
===================================================================
--- linux-2.6.orig/fs/ntfs/aops.c
+++ linux-2.6/fs/ntfs/aops.c
@@ -1194,7 +1194,7 @@ lock_retry_remap:
 		tbh = bhs[i];
 		if (!tbh)
 			continue;
-		if (unlikely(test_set_buffer_locked(tbh)))
+		if (!trylock_buffer(tbh))
 			BUG();
 		/* The buffer dirty state is now irrelevant, just clean it. */
 		clear_buffer_dirty(tbh);
Index: linux-2.6/fs/ntfs/compress.c
===================================================================
--- linux-2.6.orig/fs/ntfs/compress.c
+++ linux-2.6/fs/ntfs/compress.c
@@ -665,7 +665,7 @@ lock_retry_remap:
 	for (i = 0; i < nr_bhs; i++) {
 		struct buffer_head *tbh = bhs[i];
 
-		if (unlikely(test_set_buffer_locked(tbh)))
+		if (!trylock_buffer(tbh))
 			continue;
 		if (unlikely(buffer_uptodate(tbh))) {
 			unlock_buffer(tbh);
Index: linux-2.6/fs/ntfs/mft.c
===================================================================
--- linux-2.6.orig/fs/ntfs/mft.c
+++ linux-2.6/fs/ntfs/mft.c
@@ -586,7 +586,7 @@ int ntfs_sync_mft_mirror(ntfs_volume *vo
 		for (i_bhs = 0; i_bhs < nr_bhs; i_bhs++) {
 			struct buffer_head *tbh = bhs[i_bhs];
 
-			if (unlikely(test_set_buffer_locked(tbh)))
+			if (!trylock_buffer(tbh))
 				BUG();
 			BUG_ON(!buffer_uptodate(tbh));
 			clear_buffer_dirty(tbh);
@@ -779,7 +779,7 @@ int write_mft_record_nolock(ntfs_inode *
 	for (i_bhs = 0; i_bhs < nr_bhs; i_bhs++) {
 		struct buffer_head *tbh = bhs[i_bhs];
 
-		if (unlikely(test_set_buffer_locked(tbh)))
+		if (!trylock_buffer(tbh))
 			BUG();
 		BUG_ON(!buffer_uptodate(tbh));
 		clear_buffer_dirty(tbh);
Index: linux-2.6/fs/reiserfs/inode.c
===================================================================
--- linux-2.6.orig/fs/reiserfs/inode.c
+++ linux-2.6/fs/reiserfs/inode.c
@@ -2435,7 +2435,7 @@ static int reiserfs_write_full_page(stru
 		if (wbc->sync_mode != WB_SYNC_NONE || !wbc->nonblocking) {
 			lock_buffer(bh);
 		} else {
-			if (test_set_buffer_locked(bh)) {
+			if (!trylock_buffer(bh)) {
 				redirty_page_for_writepage(wbc, page);
 				continue;
 			}
Index: linux-2.6/fs/reiserfs/journal.c
===================================================================
--- linux-2.6.orig/fs/reiserfs/journal.c
+++ linux-2.6/fs/reiserfs/journal.c
@@ -855,7 +855,7 @@ static int write_ordered_buffers(spinloc
 		jh = JH_ENTRY(list->next);
 		bh = jh->bh;
 		get_bh(bh);
-		if (test_set_buffer_locked(bh)) {
+		if (!trylock_buffer(bh)) {
 			if (!buffer_dirty(bh)) {
 				list_move(&jh->list, &tmp);
 				goto loop_next;
@@ -3871,7 +3871,7 @@ int reiserfs_prepare_for_journal(struct 
 {
 	PROC_INFO_INC(p_s_sb, journal.prepare);
 
-	if (test_set_buffer_locked(bh)) {
+	if (!trylock_buffer(bh)) {
 		if (!wait)
 			return 0;
 		lock_buffer(bh);
Index: linux-2.6/fs/xfs/linux-2.6/xfs_aops.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_aops.c
+++ linux-2.6/fs/xfs/linux-2.6/xfs_aops.c
@@ -1104,7 +1104,7 @@ xfs_page_state_convert(
 			 * that we are writing into for the first time.
 			 */
 			type = IOMAP_NEW;
-			if (!test_and_set_bit(BH_Lock, &bh->b_state)) {
+			if (trylock_buffer(bh)) {
 				ASSERT(buffer_mapped(bh));
 				if (iomap_valid)
 					all_bh = 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
