Return-Path: <owner-linux-mm@kvack.org>
Date: Sat, 21 Dec 2013 18:06:44 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCHes - aio / migrate page, please review] Re: bad page state in 3.13-rc4
Message-ID: <20131221230644.GB29743@kvack.org>
References: <CA+55aFyoXCDNfHb+r5b=CgKQLPA1wrU_Tmh4ROZNEt5TPjpODA@mail.gmail.com> <20131219181134.GC25385@kmo-pixel> <20131219182920.GG30640@kvack.org> <CA+55aFzCo_r7ZGHk+zqUjmCW2w7-7z9oxEJjhR66tZ4qZPxnvw@mail.gmail.com> <20131219192621.GA9228@kvack.org> <CA+55aFz=tEkVAx9VndtCXApDxcw+5T-BxMsVuXp+vMSb05f8Aw@mail.gmail.com> <20131219195352.GB9228@kvack.org> <20131219202416.GA14519@redhat.com> <20131219233854.GD10905@kvack.org> <20131220010042.GA32112@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131220010042.GA32112@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Kent Overstreet <kmo@daterainc.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@gentwo.org>, Al Viro <viro@zeniv.linux.org.uk>

[ Patches inline below for people to comment on ]

On Thu, Dec 19, 2013 at 08:00:42PM -0500, Dave Jones wrote:
> On Thu, Dec 19, 2013 at 06:38:54PM -0500, Benjamin LaHaise wrote:
>  > On Thu, Dec 19, 2013 at 03:24:16PM -0500, Dave Jones wrote:
>  > > Yes. Note the original trace in this thread was a VM_BUG_ON(atomic_read(&page->_count) <= 0);
>  > > 
>  > > Right after these crashes btw, the box locks up solid. So bad that traces don't
>  > > always make it over usb-serial. Annoying.
>  > 
>  > I think I finally have an idea what's going on now.  Kent's changes in 
>  > e34ecee2ae791df674dfb466ce40692ca6218e43 are broken and result in a memory 
>  > leak of the aio kioctx.  This eventually leads to the system running out of 
>  > memory, which ends up triggering the otherwise hard to hit error paths in 
>  > aio_setup_ring().  Linus' suggested changes should fix the badness in the 
>  > aio_setup_ring(), but more work has to be done to fix up the percpu 
>  > reference counting tie in with the aio code.  I'll fix this up in the 
>  > morning if nobody beats me to it over night, as I'm just heading out right 
>  > now.
> 
> That would explain why I'm having difficulty repeating it in a hurry if it
> takes hours of runtime for the leak to reach a point where it becomes a problem.

Okay, I've put the below two patches plus Linus's change through a round 
of tests, and it passes millions of iterations of the aio numa migratepage 
test, as well as a number of repetitions of a few simple read and write 
tests.  The first patch fixes the memory leak Kent introduced, while the 
second patch makes aio_migratepage() much more paranoid and robust.  Those 
two changes are in git://git.kvack.org/~bcrl/aio-next.git -- can a few 
other folks please review to make sure I haven't missed anything?

Linus, feel free to add my Signed-off-by: to your sanitization of 
aio_setup_ring() as well, as it works okay in my testing.

		-ben
-- 
"Thought is the essence of where you are now."

 aio.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

commit 1881686f842065d2f92ec9c6424830ffc17d23b0
Author: Benjamin LaHaise <bcrl@kvack.org>
Date:   Sat Dec 21 15:49:28 2013 -0500

    aio: fix kioctx leak introduced by "aio: Fix a trinity splat"
    
    e34ecee2ae791df674dfb466ce40692ca6218e43 reworked the percpu reference
    counting to correct a bug trinity found.  Unfortunately, the change lead
    to kioctxes being leaked because there was no final reference count to
    put.  Add that reference count back in to fix things.
    
    Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
    Cc: stable@vger.kernel.org

diff --git a/fs/aio.c b/fs/aio.c
index 6efb7f6..fd1c0ba 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -652,7 +652,8 @@ static struct kioctx *ioctx_alloc(unsigned nr_events)
 	aio_nr += ctx->max_reqs;
 	spin_unlock(&aio_nr_lock);
 
-	percpu_ref_get(&ctx->users); /* io_setup() will drop this ref */
+	percpu_ref_get(&ctx->users);	/* io_setup() will drop this ref */
+	percpu_ref_get(&ctx->reqs);	/* free_ioctx_users() will drop this */
 
 	err = ioctx_add_table(ctx, mm);
 	if (err)


 fs/aio.c                |   52 ++++++++++++++++++++++++++++++++++++++++--------
 include/linux/migrate.h |    3 +-
 mm/migrate.c            |   13 ++++++------
 3 files changed, 53 insertions(+), 15 deletions(-)

commit 8e321fefb0e60bae4e2a28d20fc4fa30758d27c6
Author: Benjamin LaHaise <bcrl@kvack.org>
Date:   Sat Dec 21 17:56:08 2013 -0500

    aio/migratepages: make aio migrate pages sane
    
    The arbitrary restriction on page counts offered by the core
    migrate_page_move_mapping() code results in rather suspicious looking
    fiddling with page reference counts in the aio_migratepage() operation.
    To fix this, make migrate_page_move_mapping() take an extra_count parameter
    that allows aio to tell the code about its own reference count on the page
    being migrated.
    
    While cleaning up aio_migratepage(), make it validate that the old page
    being passed in is actually what aio_migratepage() expects to prevent
    misbehaviour in the case of races.
    
    Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

diff --git a/fs/aio.c b/fs/aio.c
index fd1c0ba..efa708b 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -244,9 +244,14 @@ static void aio_free_ring(struct kioctx *ctx)
 	int i;
 
 	for (i = 0; i < ctx->nr_pages; i++) {
+		struct page *page;
 		pr_debug("pid(%d) [%d] page->count=%d\n", current->pid, i,
 				page_count(ctx->ring_pages[i]));
-		put_page(ctx->ring_pages[i]);
+		page = ctx->ring_pages[i];
+		if (!page)
+			continue;
+		ctx->ring_pages[i] = NULL;
+		put_page(page);
 	}
 
 	put_aio_ring_file(ctx);
@@ -280,18 +285,38 @@ static int aio_migratepage(struct address_space *mapping, struct page *new,
 	unsigned long flags;
 	int rc;
 
+	rc = 0;
+
+	/* Make sure the old page hasn't already been changed */
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
+		put_page(new);
 		return rc;
 	}
 
-	get_page(new);
-
 	/* We can potentially race against kioctx teardown here.  Use the
 	 * address_space's private data lock to protect the mapping's
 	 * private_data.
@@ -303,13 +328,24 @@ static int aio_migratepage(struct address_space *mapping, struct page *new,
 		spin_lock_irqsave(&ctx->completion_lock, flags);
 		migrate_page_copy(new, old);
 		idx = old->index;
-		if (idx < (pgoff_t)ctx->nr_pages)
-			ctx->ring_pages[idx] = new;
+		if (idx < (pgoff_t)ctx->nr_pages) {
+			/* And only do the move if things haven't changed */
+			if (ctx->ring_pages[idx] == old)
+				ctx->ring_pages[idx] = new;
+			else
+				rc = -EAGAIN;
+		} else
+			rc = -EINVAL;
 		spin_unlock_irqrestore(&ctx->completion_lock, flags);
 	} else
 		rc = -EBUSY;
 	spin_unlock(&mapping->private_lock);
 
+	if (rc == MIGRATEPAGE_SUCCESS)
+		put_page(old);
+	else
+		put_page(new);
+
 	return rc;
 }
 #endif
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
index e9b7102..9194375 100644
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
-	int expected_count = 0;
+	int expected_count = 1 + extra_count;
 	void **pslot;
 
 	if (!mapping) {
 		/* Anonymous page without mapping */
-		if (page_count(page) != 1)
+		if (page_count(page) != expected_count)
 			return -EAGAIN;
 		return MIGRATEPAGE_SUCCESS;
 	}
@@ -334,7 +335,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
 	pslot = radix_tree_lookup_slot(&mapping->page_tree,
  					page_index(page));
 
-	expected_count = 2 + page_has_private(page);
+	expected_count += 1 + page_has_private(page);
 	if (page_count(page) != expected_count ||
 		radix_tree_deref_slot_protected(pslot, &mapping->tree_lock) != page) {
 		spin_unlock_irq(&mapping->tree_lock);
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
