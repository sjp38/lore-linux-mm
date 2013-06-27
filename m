Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 4CBA56B0034
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 08:37:48 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <519BDDEF.9020705@sr71.net>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1368321816-17719-18-git-send-email-kirill.shutemov@linux.intel.com>
 <519BDDEF.9020705@sr71.net>
Subject: Re: [PATCHv4 17/39] thp, mm: handle tail pages in
 page_cache_get_speculative()
Content-Transfer-Encoding: 7bit
Message-Id: <20130627124036.4FBCDE0090@blue.fi.intel.com>
Date: Thu, 27 Jun 2013 15:40:36 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > 
> > For tail page we call __get_page_tail(). It has the same semantics, but
> > for tail page.
> 
> page_cache_get_speculative() has a ~50-line comment above it with lots
> of scariness about grace periods and RCU.  A two line comment saying
> that the semantics are the same doesn't make me feel great that you've
> done your homework here.

Okay. Will fix commit message and the comment.

> Are there any performance implications here?  __get_page_tail() says:
> "It implements the slow path of get_page().".
> page_cache_get_speculative() seems awfully speculative which would make
> me think that it is part of a _fast_ path.

It's slow path in the sense that we have to do more for tail page then for
non-compound or head page.

Probably, we can get it a bit faster by unrolling function calls and doing
only what is relevant for our case. Like this:

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index ad60dcc..57ad1ae 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -161,6 +161,8 @@ void release_pages(struct page **pages, int nr, int cold);
  */
 static inline int page_cache_get_speculative(struct page *page)
 {
+	struct page *page_head = compound_trans_head(page);
+
 	VM_BUG_ON(in_interrupt());
 
 #ifdef CONFIG_TINY_RCU
@@ -176,11 +178,11 @@ static inline int page_cache_get_speculative(struct page *page)
 	 * disabling preempt, and hence no need for the "speculative get" that
 	 * SMP requires.
 	 */
-	VM_BUG_ON(page_count(page) == 0);
+	VM_BUG_ON(page_count(page_head) == 0);
 	atomic_inc(&page->_count);
 
 #else
-	if (unlikely(!get_page_unless_zero(page))) {
+	if (unlikely(!get_page_unless_zero(page_head))) {
 		/*
 		 * Either the page has been freed, or will be freed.
 		 * In either case, retry here and the caller should
@@ -189,7 +191,23 @@ static inline int page_cache_get_speculative(struct page *page)
 		return 0;
 	}
 #endif
-	VM_BUG_ON(PageTail(page));
+
+	if (unlikely(PageTransTail(page))) {
+		unsigned long flags;
+		int got = 0;
+
+		flags = compound_lock_irqsave(page_head);
+		if (likely(PageTransTail(page))) {
+			atomic_inc(&page->_mapcount);
+			got = 1;
+		}
+		compound_unlock_irqrestore(page_head, flags);
+
+		if (unlikely(!got))
+			put_page(page_head);
+
+		return got;
+	}
 
 	return 1;
 }

What do you think? Is it better?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
