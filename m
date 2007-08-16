Message-Id: <20070816074625.218766000@chello.nl>
References: <20070816074525.065850000@chello.nl>
Date: Thu, 16 Aug 2007 09:45:28 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 03/23] lib: percpu_counter_sub
Content-Disposition: inline; filename=percpu_counter_sub.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hugh spotted that some code does:
  percpu_counter_add(&counter, -unsignedlong)

which, when the amount argument is of type s32, sort-of works thanks to
two's-complement. However when we'd change the type to s64 this breaks on 32bit
machines, because the promotion rules zero extend the unsigned number.

Provide percpu_counter_sub() to hide the s64 cast. That is:
  percpu_counter_sub(&counter, foo)
is equal to:
  percpu_counter_add(&counter, -(s64)foo);

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Hugh Dickins <hugh@veritas.com>
---
 fs/ext2/balloc.c               |    4 ++--
 fs/ext3/balloc.c               |    2 +-
 fs/ext4/balloc.c               |    2 +-
 include/linux/percpu_counter.h |    5 +++++
 4 files changed, 9 insertions(+), 4 deletions(-)

Index: linux-2.6/fs/ext2/balloc.c
===================================================================
--- linux-2.6.orig/fs/ext2/balloc.c
+++ linux-2.6/fs/ext2/balloc.c
@@ -163,7 +163,7 @@ static int reserve_blocks(struct super_b
 			return 0;
 	}
 
-	percpu_counter_add(&sbi->s_freeblocks_counter, -count);
+	percpu_counter_sub(&sbi->s_freeblocks_counter, count);
 	sb->s_dirt = 1;
 	return count;
 }
@@ -1402,7 +1402,7 @@ allocated:
 	}
 
 	group_adjust_blocks(sb, group_no, gdp, gdp_bh, -num);
-	percpu_counter_add(&sbi->s_freeblocks_counter, -num);
+	percpu_counter_sub(&sbi->s_freeblocks_counter, num);
 
 	mark_buffer_dirty(bitmap_bh);
 	if (sb->s_flags & MS_SYNCHRONOUS)
Index: linux-2.6/fs/ext3/balloc.c
===================================================================
--- linux-2.6.orig/fs/ext3/balloc.c
+++ linux-2.6/fs/ext3/balloc.c
@@ -1672,7 +1672,7 @@ allocated:
 	gdp->bg_free_blocks_count =
 			cpu_to_le16(le16_to_cpu(gdp->bg_free_blocks_count)-num);
 	spin_unlock(sb_bgl_lock(sbi, group_no));
-	percpu_counter_add(&sbi->s_freeblocks_counter, -num);
+	percpu_counter_sub(&sbi->s_freeblocks_counter, num);
 
 	BUFFER_TRACE(gdp_bh, "journal_dirty_metadata for group descriptor");
 	err = ext3_journal_dirty_metadata(handle, gdp_bh);
Index: linux-2.6/fs/ext4/balloc.c
===================================================================
--- linux-2.6.orig/fs/ext4/balloc.c
+++ linux-2.6/fs/ext4/balloc.c
@@ -1697,7 +1697,7 @@ allocated:
 	gdp->bg_free_blocks_count =
 			cpu_to_le16(le16_to_cpu(gdp->bg_free_blocks_count)-num);
 	spin_unlock(sb_bgl_lock(sbi, group_no));
-	percpu_counter_add(&sbi->s_freeblocks_counter, -num);
+	percpu_counter_sub(&sbi->s_freeblocks_counter, num);
 
 	BUFFER_TRACE(gdp_bh, "journal_dirty_metadata for group descriptor");
 	err = ext4_journal_dirty_metadata(handle, gdp_bh);
Index: linux-2.6/include/linux/percpu_counter.h
===================================================================
--- linux-2.6.orig/include/linux/percpu_counter.h
+++ linux-2.6/include/linux/percpu_counter.h
@@ -105,4 +105,9 @@ static inline void percpu_counter_dec(st
 	percpu_counter_add(fbc, -1);
 }
 
+static inline void percpu_counter_sub(struct percpu_counter *fbc, s64 amount)
+{
+	percpu_counter_add(fbc, -amount);
+}
+
 #endif /* _LINUX_PERCPU_COUNTER_H */

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
