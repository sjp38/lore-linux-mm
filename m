Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 85EAC6B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 09:39:57 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so117028440wic.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 06:39:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id rz14si12566413wjb.96.2015.09.09.06.39.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Sep 2015 06:39:56 -0700 (PDT)
Subject: Re: [PATCH v3] mm/page_alloc: add a helper function to check page
 before alloc/free
References: <1440679917-3507-1-git-send-email-bywxiaobai@163.com>
 <55EF34AB.5040003@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55F036AA.9040508@suse.cz>
Date: Wed, 9 Sep 2015 15:39:54 +0200
MIME-Version: 1.0
In-Reply-To: <55EF34AB.5040003@suse.cz>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <bywxiaobai@163.com>, akpm@linux-foundation.org, mgorman@suse.de, mhocko@kernel.org, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/08/2015 09:19 PM, Vlastimil Babka wrote:
> bloat-o-meter looks favorably with my gcc, although there shouldn't be a real
> reason for it, as the inlining didn't change:
>
> add/remove: 1/1 grow/shrink: 1/1 up/down: 285/-336 (-51)
> function                                     old     new   delta
> bad_page                                       -     276    +276
> get_page_from_freelist                      2521    2530      +9
> free_pages_prepare                           745     667     -78
> bad_page.part                                258       -    -258
>
> With that,
>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

BTW, why do we do all these checks in non-DEBUG_VM builds? Are they so 
often hit nowadays? Shouldn't we check just for hwpoison in the 
non-debug case?

Alternatively, I've considered creating a fast inline pre-check that 
calls a non-inline check-with-report:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0c9c82a..cff92f8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -707,7 +707,20 @@ static inline void __free_one_page(struct page *page,
  	zone->free_area[order].nr_free++;
  }

-static inline int check_one_page(struct page *page, unsigned long 
bad_flags)
+static inline int check_one_page_fast(struct page *page, unsigned long
+		bad_flags)
+{
+	return (page_mapcount(page)
+			|| page->mapping != NULL
+			|| atomic_read(&page->_count) != 0
+			|| page->flags & bad_flags
+#ifdef CONFIG_MEMCG
+			|| page->mem_cgroup
+#endif
+			);
+}
+
+static noinline int check_one_page(struct page *page, unsigned long 
bad_flags)
  {
  	const char *bad_reason = NULL;

@@ -743,9 +756,12 @@ static inline int free_pages_check(struct page *page)
  {
  	int ret = 0;

-	ret = check_one_page(page, PAGE_FLAGS_CHECK_AT_FREE);
-	if (ret)
-		return ret;
+	ret = check_one_page_fast(page, PAGE_FLAGS_CHECK_AT_FREE);
+	if (ret) {
+		ret = check_one_page(page, PAGE_FLAGS_CHECK_AT_FREE);
+		if (ret)
+			return ret;
+	}

  	page_cpupid_reset_last(page);
  	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
@@ -1304,7 +1320,9 @@ static inline void expand(struct zone *zone, 
struct page *page,
   */
  static inline int check_new_page(struct page *page)
  {
-	return check_one_page(page, PAGE_FLAGS_CHECK_AT_PREP);
+	if (check_one_page_fast(page, PAGE_FLAGS_CHECK_AT_PREP | __PG_HWPOISON))
+		return check_one_page(page, PAGE_FLAGS_CHECK_AT_PREP);
+	return 0;
  }

  static int prep_new_page(struct page *page, unsigned int order, gfp_t 
gfp_flags,

---

That shrinks the fast paths nicely:

add/remove: 1/1 grow/shrink: 0/2 up/down: 480/-498 (-18)
function                                     old     new   delta
check_one_page                                 -     480    +480
get_page_from_freelist                      2530    2458     -72
free_pages_prepare                           667     517    -150
bad_page                                     276       -    -276

On top of that, the number of branches in the fast paths can be reduced 
if we use arithmetic OR to avoid the short-circuit boolean evaluation:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cff92f8..e8b42ba 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -710,12 +710,12 @@ static inline void __free_one_page(struct page *page,
  static inline int check_one_page_fast(struct page *page, unsigned long
  		bad_flags)
  {
-	return (page_mapcount(page)
-			|| page->mapping != NULL
-			|| atomic_read(&page->_count) != 0
-			|| page->flags & bad_flags
+	return ((unsigned long) page_mapcount(page)
+			| (unsigned long) page->mapping
+			| (unsigned long) atomic_read(&page->_count)
+			| (page->flags & bad_flags)
  #ifdef CONFIG_MEMCG
-			|| page->mem_cgroup
+			| (unsigned long) page->mem_cgroup
  #endif
  			);
  }

That further reduces the fast paths, not much in bytes, but importantly 
in branches:

add/remove: 0/0 grow/shrink: 0/2 up/down: 0/-51 (-51)
function                                     old     new   delta
get_page_from_freelist                      2458    2443     -15
free_pages_prepare                           517     481     -36

But I can understand it's rather hackish, and maybe some architectures 
won't be happy with the extra unsigned long arithmetics. Thoughts?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
