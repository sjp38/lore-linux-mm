Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A53756B007D
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 02:46:31 -0500 (EST)
Date: Mon, 1 Feb 2010 08:45:24 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 04 of 31] update futex compound knowledge
Message-ID: <20100201074524.GE12034@random.random>
References: <patchbomb.1264689194@v2.random>
 <2503a08ae3183f675931.1264689198@v2.random>
 <20100128161153.GE7139@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100128161153.GE7139@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <hch@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

There was a little problem in the futex code, basically we can't take
PG_lock on a page that isn't pinned. This should fix it. I never had a
problem in practice. Untested still.. just wanted to update you on
this one.

diff --git a/kernel/futex.c b/kernel/futex.c
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -258,6 +258,18 @@ again:
 		local_irq_disable();
 		if (likely(__get_user_pages_fast(address, 1, 1, &page) == 1)) {
 			page_head = compound_head(page);
+			/*
+			 * page_head is valid pointer but we must pin
+			 * it before taking the PG_lock and/or
+			 * PG_compound_lock. The moment we re-enable
+			 * irqs __split_huge_page_splitting() can
+			 * return and the head page can be freed from
+			 * under us. We can't take the PG_lock and/or
+			 * PG_compound_lock on a page that could be
+			 * freed from under us.
+			 */
+			if (page != page_head)
+				get_page(page_head);
 			local_irq_enable();
 		} else {
 			local_irq_enable();
@@ -266,6 +278,8 @@ again:
 	}
 #else
 	page_head = compound_head(page);
+	if (page != page_head)
+		get_page(page_head);
 #endif
 
 	lock_page(page_head);
@@ -274,12 +288,15 @@ again:
 		if (unlikely(!PageTail(page))) {
 			compound_unlock(page_head);
 			unlock_page(page_head);
+			put_page(page_head);
 			put_page(page);
 			goto again;
 		}
 	}
 	if (!page_head->mapping) {
 		unlock_page(page_head);
+		if (page_head != page)
+			put_page(page_head);
 		put_page(page);
 		goto again;
 	}
@@ -303,9 +320,13 @@ again:
 
 	get_futex_key_refs(key);
 
-	if (unlikely(PageTail(page)))
+	unlock_page(page_head);
+	if (page != page_head) {
+		VM_BUG_ON(!PageTail(page));
+		/* releasing compound_lock after page_lock won't matter */
 		compound_unlock(page_head);
-	unlock_page(page_head);
+		put_page(page_head);
+	}
 	put_page(page);
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
