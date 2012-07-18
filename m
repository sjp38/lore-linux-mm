Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 106916B005C
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 19:07:46 -0400 (EDT)
Date: Wed, 18 Jul 2012 20:07:07 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v4 1/3] mm: introduce compaction and migration for virtio
 ballooned pages
Message-ID: <20120718230706.GB2313@t510.redhat.com>
References: <cover.1342485774.git.aquini@redhat.com>
 <49f828a9331c9b729fcf77226006921ec5bc52fa.1342485774.git.aquini@redhat.com>
 <20120718154605.cb0591bc.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120718154605.cb0591bc.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Rafael Aquini <aquini@linux.com>

Howdy Andrew,

Thanks for taking the time to go through this work and provide me with such good
feedback.

On Wed, Jul 18, 2012 at 03:46:05PM -0700, Andrew Morton wrote:
> On Tue, 17 Jul 2012 13:50:41 -0300
> Rafael Aquini <aquini@redhat.com> wrote:
> 
> > This patch introduces the helper functions as well as the necessary changes
> > to teach compaction and migration bits how to cope with pages which are
> > part of a guest memory balloon, in order to make them movable by memory
> > compaction procedures.
> > 
> > ...
> >
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1629,5 +1629,20 @@ static inline unsigned int debug_guardpage_minorder(void) { return 0; }
> >  static inline bool page_is_guard(struct page *page) { return false; }
> >  #endif /* CONFIG_DEBUG_PAGEALLOC */
> >  
> > +#if (defined(CONFIG_VIRTIO_BALLOON) || \
> > +	defined(CONFIG_VIRTIO_BALLOON_MODULE)) && defined(CONFIG_COMPACTION)
> > +extern bool putback_balloon_page(struct page *);
> > +extern struct address_space *balloon_mapping;
> > +
> > +static inline bool is_balloon_page(struct page *page)
> > +{
> > +	return (page->mapping == balloon_mapping) ? true : false;
> 
> You can simply do
> 
> 	return page->mapping == balloon_mapping;

Yes, I will do 
   return (page->mapping && page->mapping == balloon_mapping);

actually. I just got a case of NULL pointer deref while running on bare-metal
with no balloon driver loaded.

> 
> > +}
> > +#else
> > +static inline bool is_balloon_page(struct page *page)       { return false; }
> > +static inline bool isolate_balloon_page(struct page *page)  { return false; }
> > +static inline bool putback_balloon_page(struct page *page)  { return false; }
> > +#endif /* (VIRTIO_BALLOON || VIRTIO_BALLOON_MODULE) && COMPACTION */
> 
> This means that if CONFIG_VIRTIO_BALLOON=y and CONFIG_COMPACTION=n,
> is_balloon_page() will always return NULL.  IOW, no pages are balloon
> pages!  This is wrong.
> 
I believe it's right, actually, as we can see CONFIG_COMPACTION=n associated with
CONFIG_MIGRATION=y (and  CONFIG_VIRTIO_BALLOON=y).
For such config case we cannot perform the is_balloon_page() test branches
placed on mm/migration.c


> I'm not sure what to do about this, apart from renaming the function to
> is_compactible_balloon_page() or something similarly aawkward.
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
