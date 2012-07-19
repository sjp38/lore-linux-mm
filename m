Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 1CCEC6B004D
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 21:01:26 -0400 (EDT)
Date: Wed, 18 Jul 2012 22:00:48 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v4 1/3] mm: introduce compaction and migration for virtio
 ballooned pages
Message-ID: <20120719010047.GD2313@t510.redhat.com>
References: <cover.1342485774.git.aquini@redhat.com>
 <49f828a9331c9b729fcf77226006921ec5bc52fa.1342485774.git.aquini@redhat.com>
 <20120718154605.cb0591bc.akpm@linux-foundation.org>
 <20120718230706.GB2313@t510.redhat.com>
 <20120718161239.9449e6b5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120718161239.9449e6b5.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Rafael Aquini <aquini@linux.com>

On Wed, Jul 18, 2012 at 04:12:39PM -0700, Andrew Morton wrote:
> On Wed, 18 Jul 2012 20:07:07 -0300
> Rafael Aquini <aquini@redhat.com> wrote:
> 
> > > 
> > > > +}
> > > > +#else
> > > > +static inline bool is_balloon_page(struct page *page)       { return false; }
> > > > +static inline bool isolate_balloon_page(struct page *page)  { return false; }
> > > > +static inline bool putback_balloon_page(struct page *page)  { return false; }
> > > > +#endif /* (VIRTIO_BALLOON || VIRTIO_BALLOON_MODULE) && COMPACTION */
> > > 
> > > This means that if CONFIG_VIRTIO_BALLOON=y and CONFIG_COMPACTION=n,
> > > is_balloon_page() will always return NULL.  IOW, no pages are balloon
> > > pages!  This is wrong.
> > > 
> > I believe it's right, actually, as we can see CONFIG_COMPACTION=n associated with
> > CONFIG_MIGRATION=y (and  CONFIG_VIRTIO_BALLOON=y).
> > For such config case we cannot perform the is_balloon_page() test branches
> > placed on mm/migration.c
> 
> No, it isn't right.  Look at the name: "is_balloon_page".  If a caller
> runs is_balloon_page() against a balloon page with CONFIG_COMPACTION=n
> then they will get "false", which is incorrect.
>
You're right, I got your point. 
 
> So the function needs a better name - one which communicates that it is
> a balloon page *for the purposes of processing by the compaction code*. 
> Making the function private to compaction.c would help with that, if
> feasible.
> 

How about this (adjusted) approach:

diff --git a/include/linux/mm.h b/include/linux/mm.h
index b94f17a..02a8f80 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1629,8 +1629,7 @@ static inline unsigned int debug_guardpage_minorder(void)
{ return 0; }
 static inline bool page_is_guard(struct page *page) { return false; }
 #endif /* CONFIG_DEBUG_PAGEALLOC */
 
-#if (defined(CONFIG_VIRTIO_BALLOON) || \
-	defined(CONFIG_VIRTIO_BALLOON_MODULE)) && defined(CONFIG_COMPACTION)
+#if (defined(CONFIG_VIRTIO_BALLOON) ||defined(CONFIG_VIRTIO_BALLOON_MODULE))
 extern bool putback_balloon_page(struct page *);
 extern struct address_space *balloon_mapping;
 
@@ -1638,11 +1637,13 @@ static inline bool is_balloon_page(struct page *page)
 {
 	return (page->mapping && page->mapping == balloon_mapping);
 }
+#if defined(CONFIG_COMPACTION)
+static inline bool balloon_compaction_enabled(void) { return true; }
 #else
-static inline bool is_balloon_page(struct page *page)       { return false; }
-static inline bool isolate_balloon_page(struct page *page)  { return false; }
-static inline bool putback_balloon_page(struct page *page)  { return false; }
-#endif /* (VIRTIO_BALLOON || VIRTIO_BALLOON_MODULE) && COMPACTION */
+static inline bool putback_balloon_page(struct page *page) { return false; }
+static inline bool balloon_compaction_enabled(void) { return false; }
+#endif /* CONFIG_COMPACTION */
+#endif /* (CONFIG_VIRTIO_BALLOON || CONFIG_VIRTIO_BALLOON_MODULE) */
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/mm/migrate.c b/mm/migrate.c
index 59c7bc5..f5f6a7d 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -78,7 +78,8 @@ void putback_lru_pages(struct list_head *l)
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		if (unlikely(is_balloon_page(page)))
+		if (unlikely(is_balloon_page(page)) &&
+		    balloon_compaction_enabled())
 			WARN_ON(!putback_balloon_page(page));
 		else
 			putback_lru_page(page);
@@ -786,7 +787,7 @@ static int __unmap_and_move(struct page *page, struct page
*newpage,
 		}
 	}
 
-	if (is_balloon_page(page)) {
+	if (is_balloon_page(page) && balloon_compaction_enabled()) {
 		/*
 		 * A ballooned page does not need any special attention from
 		 * physical to virtual reverse mapping procedures.
@@ -867,7 +868,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned
long private,
 
 	rc = __unmap_and_move(page, newpage, force, offlining, mode);
 
-	if (is_balloon_page(newpage)) {
+	if (is_balloon_page(newpage) && balloon_compaction_enabled()) {
 		/*
 		 * A ballooned page has been migrated already. Now, it is the
 		 * time to wrap-up counters, handle the old page back to Buddy
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
