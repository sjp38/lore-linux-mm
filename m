Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 0B2046B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 15:47:43 -0400 (EDT)
Date: Tue, 14 Aug 2012 22:48:37 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v7 1/4] mm: introduce compaction and migration for virtio
 ballooned pages
Message-ID: <20120814194837.GA28863@redhat.com>
References: <cover.1344619987.git.aquini@redhat.com>
 <292b1b52e863a05b299f94bda69a61371011ac19.1344619987.git.aquini@redhat.com>
 <20120813082619.GE14081@redhat.com>
 <20120814174404.GA13338@t510.redhat.com>
 <20120814193525.GB28840@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120814193525.GB28840@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Tue, Aug 14, 2012 at 10:35:25PM +0300, Michael S. Tsirkin wrote:
> On Tue, Aug 14, 2012 at 02:44:05PM -0300, Rafael Aquini wrote:
> > On Mon, Aug 13, 2012 at 11:26:19AM +0300, Michael S. Tsirkin wrote:
> > > > +static inline bool movable_balloon_page(struct page *page)
> > > > +{
> > > > +	return (page->mapping && page->mapping == balloon_mapping);
> > > 
> > > I am guessing this needs smp_read_barrier_depends, and maybe
> > > ACCESS_ONCE ...
> > > 
> > 
> > I'm curious about your guessing here. Could you ellaborate it further, please?
> > 
> > 
> > > > +#else
> > > > +static inline bool isolate_balloon_page(struct page *page) { return false; }
> > > > +static inline void putback_balloon_page(struct page *page) { return false; }
> > > > +static inline bool movable_balloon_page(struct page *page) { return false; }
> > > > +#endif /* (VIRTIO_BALLOON || VIRTIO_BALLOON_MODULE) && CONFIG_COMPACTION */
> > > > +
> > > 
> > > This does mean that only one type of balloon is useable at a time.
> > > I wonder whether using a flag in address_space structure instead
> > > is possible ...
> > 
> > This means we are only introducing this feature for virtio_balloon by now.
> > Despite the flagging address_space stuff is something we surely can look in the
> > future, I quite didn't get how we could be using two different types of balloon
> > devices at the same time for the same system. Could you ellaborate it a little
> > more, please?
> > 
> 
> E.g. kvm can emulate hyperv so it could in theory have hyperv balloon.
> This is mm stuff it is best not to tie it to specific drivers.

But of course I agree this is not top priority, no need
to block submission on this, just nice to have.

> > > > +/* __isolate_lru_page() counterpart for a ballooned page */
> > > > +bool isolate_balloon_page(struct page *page)
> > > > +{
> > > > +	if (WARN_ON(!movable_balloon_page(page)))
> > > 
> > > Looks like this actually can happen if the page is leaked
> > > between previous movable_balloon_page and here.
> > > 
> > > > +		return false;
> > 
> > Yes, it surely can happen, and it does not harm to catch it here, print a warn and
> > return.
> 
> If it is legal, why warn? For that matter why test here at all?
> 
> > While testing it, I wasn't lucky to see this small window opening, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
