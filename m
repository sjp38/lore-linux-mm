Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 3BD1D6B0092
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:32:51 -0500 (EST)
From: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>
Subject: [PATCH 04/18] Page flag for tracking compound deque
Date: Thu, 16 Feb 2012 15:31:31 +0100
Message-Id: <1329402705-25454-4-git-send-email-mail@smogura.eu>
In-Reply-To: <1329402705-25454-1-git-send-email-mail@smogura.eu>
References: <1329402705-25454-1-git-send-email-mail@smogura.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Yongqiang Yang <xiaoqiangnk@gmail.com>, mail@smogura.eu, linux-ext4@vger.kernel.org

This flag is to inform caller that page is about to be splitted, caller
should not depend on fact that page is compound during page mapping.

In first approach we assumed page may be splitted conurently during
operations that makes compound cache pages not coherent with mapping
indices - e. g. when someone replaces 1st page in page cache, but at
this palce exists huge page.

Problem with above is that if two threads makes such change, they may
concurently deadlock. It's quite reasonable that both will have page
lock and should achieve compound lock (compound lock will be achieved
after page lock in many situations, probably during split), split method
should aquire page lock for each tail page at it changes some important
flags.

This is mainly dictated because of LRU, we can't use tail->lru as it
stores some compound data, from other side some code depends on PageLRU,
which should evolve to, event those it's quite reasonable that tail
pages should have LRU flag set, and mainly isolate_lru_pages should bug
on tail.

Signed-off-by: RadosA?aw Smogura <mail@smogura.eu>
---
 include/linux/page-flags.h |   31 +++++++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 393b8af..0d17a6f 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -108,6 +108,18 @@ enum pageflags {
 	/** For page head it's raised to protect page from spliting */
 	PG_compound_lock,
 #endif
+#ifdef CONFIG_HUGEPAGECACHE
+	/** Setted on head to inform that page is subject to split, but split
+	 * hasn't started yet or is it in progress. When this flag is set
+	 * caller should not belive that this compound page represents some
+	 * "continous data".<br/>
+	 * It's currently used for huge page cache and file base mapping,
+	 * and it informs that compound page dosen't represents continuous
+	 * region of file, in particullary some pages including head may be
+	 * removed or replaced in cache by other pages, or may be "invalid"
+	 */
+	PG_split_deque,
+#endif
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -433,6 +445,25 @@ static inline int PageTransCompound(struct page *page)
 }
 #endif
 
+#ifdef CONFIG_HUGEPAGECACHE
+TESTPAGEFLAG(SplitDeque, split_deque);
+TESTSETFLAG(SplitDeque, split_deque);
+TESTCLEARFLAG(SplitDeque, split_deque);
+#else
+static inline int PageSplitDeque(struct page *page)
+{
+	return 0;
+}
+static inline int TestClearPageSplitDeque(struct page *page)
+{
+	return 0;
+}
+static inline int TestSetPageSplitDeque(struct page *page)
+{
+	return 0;
+}
+#endif
+
 #ifdef CONFIG_MMU
 #define __PG_MLOCKED		(1 << PG_mlocked)
 #else
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
