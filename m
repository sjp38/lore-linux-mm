Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id AB9566B005C
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 18:46:10 -0400 (EDT)
Date: Wed, 18 Jul 2012 15:46:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 1/3] mm: introduce compaction and migration for
 virtio ballooned pages
Message-Id: <20120718154605.cb0591bc.akpm@linux-foundation.org>
In-Reply-To: <49f828a9331c9b729fcf77226006921ec5bc52fa.1342485774.git.aquini@redhat.com>
References: <cover.1342485774.git.aquini@redhat.com>
	<49f828a9331c9b729fcf77226006921ec5bc52fa.1342485774.git.aquini@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Rafael Aquini <aquini@linux.com>

On Tue, 17 Jul 2012 13:50:41 -0300
Rafael Aquini <aquini@redhat.com> wrote:

> This patch introduces the helper functions as well as the necessary changes
> to teach compaction and migration bits how to cope with pages which are
> part of a guest memory balloon, in order to make them movable by memory
> compaction procedures.
> 
> ...
>
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1629,5 +1629,20 @@ static inline unsigned int debug_guardpage_minorder(void) { return 0; }
>  static inline bool page_is_guard(struct page *page) { return false; }
>  #endif /* CONFIG_DEBUG_PAGEALLOC */
>  
> +#if (defined(CONFIG_VIRTIO_BALLOON) || \
> +	defined(CONFIG_VIRTIO_BALLOON_MODULE)) && defined(CONFIG_COMPACTION)
> +extern bool putback_balloon_page(struct page *);
> +extern struct address_space *balloon_mapping;
> +
> +static inline bool is_balloon_page(struct page *page)
> +{
> +	return (page->mapping == balloon_mapping) ? true : false;

You can simply do

	return page->mapping == balloon_mapping;

> +}
> +#else
> +static inline bool is_balloon_page(struct page *page)       { return false; }
> +static inline bool isolate_balloon_page(struct page *page)  { return false; }
> +static inline bool putback_balloon_page(struct page *page)  { return false; }
> +#endif /* (VIRTIO_BALLOON || VIRTIO_BALLOON_MODULE) && COMPACTION */

This means that if CONFIG_VIRTIO_BALLOON=y and CONFIG_COMPACTION=n,
is_balloon_page() will always return NULL.  IOW, no pages are balloon
pages!  This is wrong.

I'm not sure what to do about this, apart from renaming the function to
is_compactible_balloon_page() or something similarly aawkward.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
