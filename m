Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A09B36B00A3
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 16:56:12 -0500 (EST)
Date: Tue, 22 Nov 2011 13:56:08 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/3] mm: more intensive memory corruption debug
Message-Id: <20111122135608.42686f14.akpm@linux-foundation.org>
In-Reply-To: <1321633507-13614-1-git-send-email-sgruszka@redhat.com>
References: <1321633507-13614-1-git-send-email-sgruszka@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Christoph Lameter <cl@linux-foundation.org>

On Fri, 18 Nov 2011 17:25:05 +0100
Stanislaw Gruszka <sgruszka@redhat.com> wrote:

> With CONFIG_DEBUG_PAGEALLOC configured, cpu will generate exception on
> access (read,write) to not allocated page, what allow to catch code
> which corrupt memory. However kernel is trying to maximalise memory
> usage, hence there is usually not much free pages in the system and
> buggy code usually corrupt some crucial data.
> 
> This patch change buddy allocator to keep more free/protected pages
> and interlace free/protected and allocated pages to increase probability
> of catch a corruption.
> 
> When kernel is compiled with CONFIG_DEBUG_PAGEALLOC,
> debug_guardpage_minorder defines the minimum order used by the page
> allocator to grant a request. The requested size will be returned with
> the remaining pages used as guard pages.
> 

I added this:

  The default value of debug_guardpage_minorder is zero: no change
  from current behaviour.

correct?

>
> ...
>
> +static int __init debug_guardpage_minorder_setup(char *buf)
> +{
> +	unsigned long res;
> +
> +	if (kstrtoul(buf, 10, &res) < 0 ||  res > MAX_ORDER / 2) {
> +		printk(KERN_ERR "Bad debug_guardpage_minorder value\n");
> +		return 0;
> +	}
> +	_debug_guardpage_minorder = res;
> +	printk(KERN_INFO "Setting debug_guardpage_minorder to %lu\n", res);
> +	return 0;
> +}
> +__setup("debug_guardpage_minorder=", debug_guardpage_minorder_setup);
> +
> +static inline void set_page_guard_flg(struct page *page)

"flag" not "flg", please ;)

> +{
> +	__set_bit(PAGE_DEBUG_FLAG_GUARD, &page->debug_flags);
> +}
> +
> +static inline void clear_page_guard_flg(struct page *page)
> +{
> +	__clear_bit(PAGE_DEBUG_FLAG_GUARD, &page->debug_flags);
> +}

Why is it safe to use the non-atomic bitops here.

Please verify that CONFIG_WANT_PAGE_DEBUG_FLAGS is always reliably
enabled when this feature is turned on.

>
> ...
>


Some changes I made - please review.


 Documentation/kernel-parameters.txt |   31 +++++++++++++-------------
 mm/page_alloc.c                     |   12 +++++-----
 2 files changed, 22 insertions(+), 21 deletions(-)

diff -puN Documentation/kernel-parameters.txt~mm-more-intensive-memory-corruption-debug-fix Documentation/kernel-parameters.txt
--- a/Documentation/kernel-parameters.txt~mm-more-intensive-memory-corruption-debug-fix
+++ a/Documentation/kernel-parameters.txt
@@ -625,21 +625,22 @@ bytes respectively. Such letter suffixes
 
 	debug_guardpage_minorder=
 			[KNL] When CONFIG_DEBUG_PAGEALLOC is set, this
-			parameter allows control order of pages that will be
-			intentionally kept free (and hence protected) by buddy
-			allocator. Bigger value increase probability of
-			catching random memory corruption, but reduce amount
-			of memory for normal system use. Maximum possible
-			value is MAX_ORDER/2. Setting this parameter to 1 or 2,
-			should be enough to identify most random memory
-			corruption problems caused by bugs in kernel/drivers
-			code when CPU write to (or read from) random memory
-			location. Note that there exist class of memory
-			corruptions problems caused by buggy H/W or F/W or by
-			drivers badly programing DMA (basically when memory is
-			written at bus level and CPU MMU is bypassed), which
-			are not detectable by CONFIG_DEBUG_PAGEALLOC, hence this
-			option would not help tracking down these problems too.
+			parameter allows control of the order of pages that will
+			be intentionally kept free (and hence protected) by the
+			buddy allocator. Bigger value increase the probability
+			of catching random memory corruption, but reduce the
+			amount of memory for normal system use. The maximum
+			possible value is MAX_ORDER/2.  Setting this parameter
+			to 1 or 2 should be enough to identify most random
+			memory corruption problems caused by bugs in kernel or
+			driver code when a CPU writes to (or reads from) a
+			random memory location. Note that there exists a class
+			of memory corruptions problems caused by buggy H/W or
+			F/W or by drivers badly programing DMA (basically when
+			memory is written at bus level and the CPU MMU is
+			bypassed) which are not detectable by
+			CONFIG_DEBUG_PAGEALLOC, hence this option will not help
+			tracking down these problems.
 
 	debugpat	[X86] Enable PAT debugging
 
diff -puN mm/page_alloc.c~mm-more-intensive-memory-corruption-debug-fix mm/page_alloc.c
--- a/mm/page_alloc.c~mm-more-intensive-memory-corruption-debug-fix
+++ a/mm/page_alloc.c
@@ -441,18 +441,18 @@ static int __init debug_guardpage_minord
 }
 __setup("debug_guardpage_minorder=", debug_guardpage_minorder_setup);
 
-static inline void set_page_guard_flg(struct page *page)
+static inline void set_page_guard_flag(struct page *page)
 {
 	__set_bit(PAGE_DEBUG_FLAG_GUARD, &page->debug_flags);
 }
 
-static inline void clear_page_guard_flg(struct page *page)
+static inline void clear_page_guard_flag(struct page *page)
 {
 	__clear_bit(PAGE_DEBUG_FLAG_GUARD, &page->debug_flags);
 }
 #else
-static inline void set_page_guard_flg(struct page *page) { }
-static inline void clear_page_guard_flg(struct page *page) { }
+static inline void set_page_guard_flag(struct page *page) { }
+static inline void clear_page_guard_flag(struct page *page) { }
 #endif
 
 static inline void set_page_order(struct page *page, int order)
@@ -578,7 +578,7 @@ static inline void __free_one_page(struc
 		 * merge with it and move up one order.
 		 */
 		if (page_is_guard(buddy)) {
-			clear_page_guard_flg(buddy);
+			clear_page_guard_flag(buddy);
 			set_page_private(page, 0);
 			__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
 		} else {
@@ -821,7 +821,7 @@ static inline void expand(struct zone *z
 			 * pages will stay not present in virtual address space
 			 */
 			INIT_LIST_HEAD(&page[size].lru);
-			set_page_guard_flg(&page[size]);
+			set_page_guard_flag(&page[size]);
 			set_page_private(&page[size], high);
 			/* Guard pages are not available for any usage */
 			__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << high));
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
