Return-Path: <owner-linux-mm@kvack.org>
Date: Thu, 19 Dec 2013 15:31:11 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: bad page state in 3.13-rc4
Message-ID: <20131219203111.GA10905@kvack.org>
References: <20131219155313.GA25771@redhat.com> <CA+55aFyoXCDNfHb+r5b=CgKQLPA1wrU_Tmh4ROZNEt5TPjpODA@mail.gmail.com> <20131219181134.GC25385@kmo-pixel> <20131219182920.GG30640@kvack.org> <CA+55aFzCo_r7ZGHk+zqUjmCW2w7-7z9oxEJjhR66tZ4qZPxnvw@mail.gmail.com> <20131219192621.GA9228@kvack.org> <CA+55aFz=tEkVAx9VndtCXApDxcw+5T-BxMsVuXp+vMSb05f8Aw@mail.gmail.com> <20131219195352.GB9228@kvack.org> <CA+55aFy5zg_cJueMZFzuqr06rT-hwnHhvBpM6W9657sxnCzxKg@mail.gmail.com> <CA+55aFwu_KN+1Ep5RmgFTvBdH3xRJDmCjZ9Fo_pH28hTdiHyiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwu_KN+1Ep5RmgFTvBdH3xRJDmCjZ9Fo_pH28hTdiHyiQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kent Overstreet <kmo@daterainc.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@gentwo.org>, Al Viro <viro@zeniv.linux.org.uk>

On Fri, Dec 20, 2013 at 05:11:12AM +0900, Linus Torvalds wrote:
> On Fri, Dec 20, 2013 at 5:02 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > Why not just get rid of the idiotic get_user_pages() crap then?
> > Something like the attached patch?
> >
> > Totally untested, but at least it makes *some* amount of sense.
> 
> Ok, that can't work, since the ring_pages[] allocation happens later.
> So that part needs to be moved up, and it needs to initialize
> 'nr_pages'.
> 
> So here's the same patch, but with stuff moved around a bit, and the
> "oops, couldn't create page" part fixed.
> 
> Bit it's still totally and entirely untested.

That looks much better.  I think the following is also needed to nail down 
the migratepage operation as well.  I'll give these two a few tests 
together.

		-ben
-- 
"Thought is the essence of where you are now."


diff --git a/fs/aio.c b/fs/aio.c
index 6efb7f6..eec0ae4 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -244,8 +244,13 @@ static void aio_free_ring(struct kioctx *ctx)
 	int i;
 
 	for (i = 0; i < ctx->nr_pages; i++) {
+		struct page *page;
 		pr_debug("pid(%d) [%d] page->count=%d\n", current->pid, i,
 				page_count(ctx->ring_pages[i]));
+		page = ctx->ring_pages[i];
+		if (!page)
+			continue;
+		ctx->ring_pages[i] = NULL;
 		put_page(ctx->ring_pages[i]);
 	}
 
@@ -280,18 +285,42 @@ static int aio_migratepage(struct address_space *mapping, struct page *new,
 	unsigned long flags;
 	int rc;
 
+	/* Serialize access to the old page */
+	if (!trylock_page(old))
+		return -EAGAIN;
+
+	rc = 0;
+
+	spin_lock(&mapping->private_lock);
+	ctx = mapping->private_data;
+	if (ctx) {
+		pgoff_t idx;
+		spin_lock_irqsave(&ctx->completion_lock, flags);
+		idx = old->index;
+		if (idx < (pgoff_t)ctx->nr_pages) {
+			if (ctx->ring_pages[idx] != old)
+				rc = -EAGAIN;
+		} else
+			rc = -EINVAL;
+		spin_unlock_irqrestore(&ctx->completion_lock, flags);
+	} else
+		rc = -EINVAL;
+	spin_unlock(&mapping->private_lock);
+
+	if (rc != 0)
+		return rc;
+
 	/* Writeback must be complete */
 	BUG_ON(PageWriteback(old));
-	put_page(old);
+	get_page(new);
 
-	rc = migrate_page_move_mapping(mapping, new, old, NULL, mode);
+	rc = migrate_page_move_mapping(mapping, new, old, NULL, mode, 1);
 	if (rc != MIGRATEPAGE_SUCCESS) {
-		get_page(old);
+		unlock_page(old);
+		put_page(new);
 		return rc;
 	}
 
-	get_page(new);
-
 	/* We can potentially race against kioctx teardown here.  Use the
 	 * address_space's private data lock to protect the mapping's
 	 * private_data.
@@ -305,10 +334,16 @@ static int aio_migratepage(struct address_space *mapping, struct page *new,
 		idx = old->index;
 		if (idx < (pgoff_t)ctx->nr_pages)
 			ctx->ring_pages[idx] = new;
+		else
+			rc = -EINVAL;
 		spin_unlock_irqrestore(&ctx->completion_lock, flags);
 	} else
 		rc = -EBUSY;
 	spin_unlock(&mapping->private_lock);
+	unlock_page(old);
+
+	if (rc == MIGRATEPAGE_SUCCESS)
+		put_page(old);
 
 	return rc;
 }
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index b7717d7..f015c05 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -55,7 +55,8 @@ extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 				  struct page *newpage, struct page *page);
 extern int migrate_page_move_mapping(struct address_space *mapping,
 		struct page *newpage, struct page *page,
-		struct buffer_head *head, enum migrate_mode mode);
+		struct buffer_head *head, enum migrate_mode mode,
+		int extra_count);
 #else
 
 static inline void putback_lru_pages(struct list_head *l) {}
diff --git a/mm/migrate.c b/mm/migrate.c
index e9b7102..e73823e 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -317,14 +317,15 @@ static inline bool buffer_migrate_lock_buffers(struct buffer_head *head,
  */
 int migrate_page_move_mapping(struct address_space *mapping,
 		struct page *newpage, struct page *page,
-		struct buffer_head *head, enum migrate_mode mode)
+		struct buffer_head *head, enum migrate_mode mode,
+		int extra_count)
 {
 	int expected_count = 0;
 	void **pslot;
 
 	if (!mapping) {
 		/* Anonymous page without mapping */
-		if (page_count(page) != 1)
+		if (page_count(page) != (expected_count + 1))
 			return -EAGAIN;
 		return MIGRATEPAGE_SUCCESS;
 	}
@@ -584,7 +585,7 @@ int migrate_page(struct address_space *mapping,
 
 	BUG_ON(PageWriteback(page));	/* Writeback must be complete */
 
-	rc = migrate_page_move_mapping(mapping, newpage, page, NULL, mode);
+	rc = migrate_page_move_mapping(mapping, newpage, page, NULL, mode, 0);
 
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
@@ -611,7 +612,7 @@ int buffer_migrate_page(struct address_space *mapping,
 
 	head = page_buffers(page);
 
-	rc = migrate_page_move_mapping(mapping, newpage, page, head, mode);
+	rc = migrate_page_move_mapping(mapping, newpage, page, head, mode, 0);
 
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
