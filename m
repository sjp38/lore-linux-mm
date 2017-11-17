Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED8B6B0038
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 03:20:42 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id g127so388926lfe.19
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 00:20:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k76sor548359ljb.31.2017.11.17.00.20.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 Nov 2017 00:20:40 -0800 (PST)
Date: Fri, 17 Nov 2017 09:20:32 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH] z3fold: use kref to prevent page free / compact race
Message-Id: <20171117092032.00ea56f42affbed19f4fcc6c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleksiy.Avramchenko@sony.com

There is a race in the current z3fold implementation between
do_compact() called in a work queue context and the page release
procedure when page's kref goes to 0. do_compact() may be waiting
for page lock, which is released by release_z3fold_page_locked
right before putting the page onto the "stale" list, and then the
page may be freed as do_compact() modifies its contents.
    
The mechanism currently implemented to handle that (checking the
PAGE_STALE flag) is not reliable enough. Instead, we'll use page's
kref counter to guarantee that the page is not released if its
compaction is scheduled. It then becomes compaction function's
responsibility to decrease the counter and quit immediately if
the page was actually freed.

Signed-off-by: Vitaly Wool <vitaly.wool@sonymobile.com>   
Cc: stable <stable@vger.kernel.org> 

---

 mm/z3fold.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 8984735..48d679d 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -404,8 +404,7 @@ static void do_compact_page(struct z3fold_header *zhdr, bool locked)
 		WARN_ON(z3fold_page_trylock(zhdr));
 	else
 		z3fold_page_lock(zhdr);
-	if (test_bit(PAGE_STALE, &page->private) ||
-	    !test_and_clear_bit(NEEDS_COMPACTING, &page->private)) {
+	if (WARN_ON(!test_and_clear_bit(NEEDS_COMPACTING, &page->private))) {
 		z3fold_page_unlock(zhdr);
 		return;
 	}
@@ -413,6 +412,11 @@ static void do_compact_page(struct z3fold_header *zhdr, bool locked)
 	list_del_init(&zhdr->buddy);
 	spin_unlock(&pool->lock);
 
+	if (kref_put(&zhdr->refcount, release_z3fold_page_locked)) {
+		atomic64_dec(&pool->pages_nr);
+		return;
+	}
+
 	z3fold_compact_page(zhdr);
 	unbuddied = get_cpu_ptr(pool->unbuddied);
 	fchunks = num_free_chunks(zhdr);
@@ -754,9 +758,11 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		list_del_init(&zhdr->buddy);
 		spin_unlock(&pool->lock);
 		zhdr->cpu = -1;
+		kref_get(&zhdr->refcount);
 		do_compact_page(zhdr, true);
 		return;
 	}
+	kref_get(&zhdr->refcount);
 	queue_work_on(zhdr->cpu, pool->compact_wq, &zhdr->work);
 	z3fold_page_unlock(zhdr);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
