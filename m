Date: Tue, 27 Jun 2006 17:57:47 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 1/5] mm: tracking shared dirty pages
Message-Id: <20060627175747.521c6733.akpm@osdl.org>
In-Reply-To: <20060627182814.20891.36856.sendpatchset@lappy>
References: <20060627182801.20891.11456.sendpatchset@lappy>
	<20060627182814.20891.36856.sendpatchset@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hugh@veritas.com, dhowells@redhat.com, christoph@lameter.com, mbligh@google.com, npiggin@suse.de, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
> Tracking of dirty pages in shared writeable mmap()s.

I mangled this a bit to fit it on top of Christoph's vm counters rewrite
(mm/page-writeback.c).

I worry about the changes to __set_page_dirty_nobuffers() and
test_clear_page_dirty().

They both already require that the page be locked (or that the
address_space be otherwise pinned).  But I'm not sure we get that right at
present.  With these changes, our exposure to that gets worse, and we
additionally are exposed to the possibility of the page itself being
reclaimed, and not just the address_space.

So ho hum.  I'll stick this:

--- a/mm/page-writeback.c~mm-tracking-shared-dirty-pages-checks
+++ a/mm/page-writeback.c
@@ -625,6 +625,7 @@ EXPORT_SYMBOL(write_one_page);
  */
 int __set_page_dirty_nobuffers(struct page *page)
 {
+	WARN_ON_ONCE(!PageLocked(page));
 	if (!TestSetPageDirty(page)) {
 		struct address_space *mapping = page_mapping(page);
 		struct address_space *mapping2;
@@ -722,6 +723,7 @@ int test_clear_page_dirty(struct page *p
 	struct address_space *mapping = page_mapping(page);
 	unsigned long flags;
 
+	WARN_ON_ONCE(!PageLocked(page));
 	if (mapping) {
 		write_lock_irqsave(&mapping->tree_lock, flags);
 		if (TestClearPageDirty(page)) {
_

in there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
