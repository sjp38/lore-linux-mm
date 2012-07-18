Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id C92F86B005C
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 19:16:50 -0400 (EDT)
Date: Wed, 18 Jul 2012 20:16:37 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v4 2/3] virtio_balloon: introduce migration primitives to
 balloon pages
Message-ID: <20120718231637.GC2313@t510.redhat.com>
References: <cover.1342485774.git.aquini@redhat.com>
 <050e06731e0489867ed804387509e36d072507ec.1342485774.git.aquini@redhat.com>
 <20120718154908.14704344.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120718154908.14704344.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Rafael Aquini <aquini@linux.com>

Howdy Andrew,

Thanks for taking the time to go through this work and provide me with such good
feedback.

On Wed, Jul 18, 2012 at 03:49:08PM -0700, Andrew Morton wrote:
> On Tue, 17 Jul 2012 13:50:42 -0300
> Rafael Aquini <aquini@redhat.com> wrote:
> 
> > Besides making balloon pages movable at allocation time and introducing
> > the necessary primitives to perform balloon page migration/compaction,
> > this patch also introduces the following locking scheme to provide the
> > proper synchronization and protection for struct virtio_balloon elements
> > against concurrent accesses due to parallel operations introduced by
> > memory compaction / page migration.
> >  - balloon_lock (mutex) : synchronizes the access demand to elements of
> > 			  struct virtio_balloon and its queue operations;
> >  - pages_lock (spinlock): special protection to balloon pages list against
> > 			  concurrent list handling operations;
> > 
> > ...
> >
> > +	balloon_mapping->a_ops = &virtio_balloon_aops;
> > +	balloon_mapping->backing_dev_info = (void *)vb;
> 
> hoo boy.  We're making page->mapping->backing_dev_info point at a
> struct which does not have type `struct backing_dev_info'.  And then we
> are exposing that page to core MM functions.  So we're hoping that core
> MM will never walk down page->mapping->backing_dev_info and explode.
> 
> That's nasty, hacky and fragile.

Shame on me, on this one.

Mea culpa: I took this approach, originally, because I stuck the spinlock within
the struct virtio_balloon and this was the easiest way to recover it just by
having the page pointer. I did this stupidity because on earlier stages of this
patch some functions that demanded access to that list spinlock were placed
outside the balloon driver's code -- this is a left-over
(I know, it's a total lame excuse, but it's the truth)

This is easily fixable, however, as the balloon page list spinlock is now only
being accessed within driver's code and it can be declared outside the struct.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
