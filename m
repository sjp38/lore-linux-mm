Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 4BE866B005C
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 19:12:41 -0400 (EDT)
Date: Wed, 18 Jul 2012 16:12:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 1/3] mm: introduce compaction and migration for
 virtio ballooned pages
Message-Id: <20120718161239.9449e6b5.akpm@linux-foundation.org>
In-Reply-To: <20120718230706.GB2313@t510.redhat.com>
References: <cover.1342485774.git.aquini@redhat.com>
	<49f828a9331c9b729fcf77226006921ec5bc52fa.1342485774.git.aquini@redhat.com>
	<20120718154605.cb0591bc.akpm@linux-foundation.org>
	<20120718230706.GB2313@t510.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Rafael Aquini <aquini@linux.com>

On Wed, 18 Jul 2012 20:07:07 -0300
Rafael Aquini <aquini@redhat.com> wrote:

> > 
> > > +}
> > > +#else
> > > +static inline bool is_balloon_page(struct page *page)       { return false; }
> > > +static inline bool isolate_balloon_page(struct page *page)  { return false; }
> > > +static inline bool putback_balloon_page(struct page *page)  { return false; }
> > > +#endif /* (VIRTIO_BALLOON || VIRTIO_BALLOON_MODULE) && COMPACTION */
> > 
> > This means that if CONFIG_VIRTIO_BALLOON=y and CONFIG_COMPACTION=n,
> > is_balloon_page() will always return NULL.  IOW, no pages are balloon
> > pages!  This is wrong.
> > 
> I believe it's right, actually, as we can see CONFIG_COMPACTION=n associated with
> CONFIG_MIGRATION=y (and  CONFIG_VIRTIO_BALLOON=y).
> For such config case we cannot perform the is_balloon_page() test branches
> placed on mm/migration.c

No, it isn't right.  Look at the name: "is_balloon_page".  If a caller
runs is_balloon_page() against a balloon page with CONFIG_COMPACTION=n
then they will get "false", which is incorrect.

So the function needs a better name - one which communicates that it is
a balloon page *for the purposes of processing by the compaction code*. 
Making the function private to compaction.c would help with that, if
feasible.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
