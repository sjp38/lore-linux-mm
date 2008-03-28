Date: Fri, 28 Mar 2008 02:08:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/9] Page flags V3: Cleanup and reorg
Message-Id: <20080328020832.5f6f8e92.akpm@linux-foundation.org>
In-Reply-To: <20080318181957.138598511@sgi.com>
References: <20080318181957.138598511@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: apw@shadowen.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Mar 2008 11:19:57 -0700 Christoph Lameter <clameter@sgi.com> wrote:

> A set of patches that attempts to improve page flag handling.

sh allmodconfig blows up with various unsatisfied link-time references to
swapper_space.

this:

--- a/include/linux/mm.h~a
+++ a/include/linux/mm.h
@@ -605,9 +605,12 @@ static inline struct address_space *page
 	struct address_space *mapping = page->mapping;
 
 	VM_BUG_ON(PageSlab(page));
+#ifdef CONFIG_SWAP
 	if (unlikely(PageSwapCache(page)))
 		mapping = &swapper_space;
-	else if (unlikely((unsigned long)mapping & PAGE_MAPPING_ANON))
+	else
+#endif
+	if (unlikely((unsigned long)mapping & PAGE_MAPPING_ANON))
 		mapping = NULL;
 	return mapping;
 }
_

fixes it, but it shouldn't, unless it's a cimpiler bug.  Could you
investigate please, check that we're not adding unintended code bloat for
some reason?

http://userweb.kernel.org/~akpm/cross-compilers/ has the toolchain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
