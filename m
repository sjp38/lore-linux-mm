Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 359006B0087
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 08:32:44 -0400 (EDT)
Date: Thu, 19 Jul 2012 09:32:06 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v4 1/3] mm: introduce compaction and migration for virtio
 ballooned pages
Message-ID: <20120719123205.GA1752@t510.redhat.com>
References: <cover.1342485774.git.aquini@redhat.com>
 <49f828a9331c9b729fcf77226006921ec5bc52fa.1342485774.git.aquini@redhat.com>
 <20120718154605.cb0591bc.akpm@linux-foundation.org>
 <20120718230706.GB2313@t510.redhat.com>
 <20120718161239.9449e6b5.akpm@linux-foundation.org>
 <20120719010047.GD2313@t510.redhat.com>
 <20120718182944.24f59012.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120718182944.24f59012.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Rafael Aquini <aquini@linux.com>

On Wed, Jul 18, 2012 at 06:29:44PM -0700, Andrew Morton wrote:
> On Wed, 18 Jul 2012 22:00:48 -0300 Rafael Aquini <aquini@redhat.com> wrote:
> 
> > > So the function needs a better name - one which communicates that it is
> > > a balloon page *for the purposes of processing by the compaction code*. 
> > > Making the function private to compaction.c would help with that, if
> > > feasible.
> > > 
> > 
> > How about this (adjusted) approach:
> 
> it fails checkpatch ;)
>
Ugh! it fails due to a lacking whitespace... will fix that right away.
 
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1629,8 +1629,7 @@ static inline unsigned int debug_guardpage_minorder(void)
> > { return 0; }
> >  static inline bool page_is_guard(struct page *page) { return false; }
> >  #endif /* CONFIG_DEBUG_PAGEALLOC */
> >  
> > -#if (defined(CONFIG_VIRTIO_BALLOON) || \
> > -	defined(CONFIG_VIRTIO_BALLOON_MODULE)) && defined(CONFIG_COMPACTION)
> > +#if (defined(CONFIG_VIRTIO_BALLOON) ||defined(CONFIG_VIRTIO_BALLOON_MODULE))
> >  extern bool putback_balloon_page(struct page *);
> >  extern struct address_space *balloon_mapping;
> >  
> > @@ -1638,11 +1637,13 @@ static inline bool is_balloon_page(struct page *page)
> >  {
> >  	return (page->mapping && page->mapping == balloon_mapping);
> >  }
> > +#if defined(CONFIG_COMPACTION)
> > +static inline bool balloon_compaction_enabled(void) { return true; }
> >  #else
> > -static inline bool is_balloon_page(struct page *page)       { return false; }
> > -static inline bool isolate_balloon_page(struct page *page)  { return false; }
> > -static inline bool putback_balloon_page(struct page *page)  { return false; }
> > -#endif /* (VIRTIO_BALLOON || VIRTIO_BALLOON_MODULE) && COMPACTION */
> > +static inline bool putback_balloon_page(struct page *page) { return false; }
> > +static inline bool balloon_compaction_enabled(void) { return false; }
> > +#endif /* CONFIG_COMPACTION */
> > +#endif /* (CONFIG_VIRTIO_BALLOON || CONFIG_VIRTIO_BALLOON_MODULE) */
> >  
> >  #endif /* __KERNEL__ */
> >  #endif /* _LINUX_MM_H */
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 59c7bc5..f5f6a7d 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -78,7 +78,8 @@ void putback_lru_pages(struct list_head *l)
> >  		list_del(&page->lru);
> >  		dec_zone_page_state(page, NR_ISOLATED_ANON +
> >  				page_is_file_cache(page));
> > -		if (unlikely(is_balloon_page(page)))
> > +		if (unlikely(is_balloon_page(page)) &&
> > +		    balloon_compaction_enabled())
> 
> well, that helps readability.  But what does is_balloon_page() return
> when invoked on a balloon page when CONFIG_COMPACTION=n?  False,
> methinks.
It will (now) return the right thing accordingly to the page->mapping tests.

> 
> I think the code as you previously had it was OK, but the
> is_balloon_page() name is misleading.  It really wants to be called
> is_potentially_compactible_balloon_page() :( Maybe rename it to
> compactible_balloon_page()?

With all due respect, sir, I don't believe renaming it is the right thing to do.
My major supporting reason is since Lumpy Reclaim is already evicted it looks
natural CONFIG_COMPACTION=y becoming a permanent feature, thus making that
preprocessor test useless and the renamed function signature nonsense, IMHO.
That's why I keep respectfully figthing against your argument.

Here goes another suggestion, to keep is_balloon_page() name as is. This way I
believe all concerns are potentially addressed, as there's no implicit and
misleading relationship between is_balloon_page and CONFIG_COMPACTION=y anymore,
as well as there are no potential build breakages due to (unexpected) config options.


diff --git a/include/linux/mm.h b/include/linux/mm.h
index b36d08c..e29ad44 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1629,5 +1629,30 @@ static inline unsigned int debug_guardpage_minorder(void)
{ return 0; }
 static inline bool page_is_guard(struct page *page) { return false; }
 #endif /* CONFIG_DEBUG_PAGEALLOC */
 
+#if (defined(CONFIG_VIRTIO_BALLOON) || defined(CONFIG_VIRTIO_BALLOON_MODULE))
+extern bool putback_balloon_page(struct page *);
+extern struct address_space *balloon_mapping;
+
+static inline bool is_balloon_page(struct page *page)
+{
+	return (page->mapping && page->mapping == balloon_mapping);
+}
+
+static inline bool balloon_compaction_enabled(void)
+{
+#if defined(CONFIG_COMPACTION)
+	return true;
+#else
+	return false;
+#endif /* CONFIG_COMPACTION */
+}
+
+#else
+static inline bool isolate_balloon_page(struct page *page) { return false; }
+static inline bool putback_balloon_page(struct page *page) { return false; }
+static inline bool is_balloon_page(struct page *page)      { return false; }
+static inline bool balloon_compaction_enabled(void)        { return false; }
+#endif /* (CONFIG_VIRTIO_BALLOON || CONFIG_VIRTIO_BALLOON_MODULE) */
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
