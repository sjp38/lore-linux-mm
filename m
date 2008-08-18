Date: Mon, 18 Aug 2008 14:29:07 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] fs: buffer lock use lock bitops
Message-ID: <20080818122907.GD9062@wotan.suse.de>
References: <20080818122428.GA9062@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080818122428.GA9062@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

fs: use lock bitops for the buffer lock

trylock_buffer and unlock_buffer open and close a critical section. Hence,
we can use the lock bitops to get the desired memory ordering.

Signed-off-by: Nick Piggin <npiggin@suse.de>

---
 fs/buffer.c                 |    3 +--
 include/linux/buffer_head.h |    2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -76,8 +76,7 @@ EXPORT_SYMBOL(__lock_buffer);
 
 void unlock_buffer(struct buffer_head *bh)
 {
-	smp_mb__before_clear_bit();
-	clear_buffer_locked(bh);
+	clear_bit_unlock(BH_Lock, &bh->b_state);
 	smp_mb__after_clear_bit();
 	wake_up_bit(&bh->b_state, BH_Lock);
 }
Index: linux-2.6/include/linux/buffer_head.h
===================================================================
--- linux-2.6.orig/include/linux/buffer_head.h
+++ linux-2.6/include/linux/buffer_head.h
@@ -322,7 +322,7 @@ static inline void wait_on_buffer(struct
 
 static inline int trylock_buffer(struct buffer_head *bh)
 {
-	return likely(!test_and_set_bit(BH_Lock, &bh->b_state));
+	return likely(!test_and_set_bit_lock(BH_Lock, &bh->b_state));
 }
 
 static inline void lock_buffer(struct buffer_head *bh)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
