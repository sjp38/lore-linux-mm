Date: Thu, 13 Dec 2007 17:11:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] fix page_alloc for larger I/O segments (improved)
Message-Id: <20071213171103.17c3b924.akpm@linux-foundation.org>
In-Reply-To: <1197593849.3154.62.camel@localhost.localdomain>
References: <20071213185326.GQ26334@parisc-linux.org>
	<4761821F.3050602@rtr.ca>
	<20071213192633.GD10104@kernel.dk>
	<4761883A.7050908@rtr.ca>
	<476188C4.9030802@rtr.ca>
	<20071213193937.GG10104@kernel.dk>
	<47618B0B.8020203@rtr.ca>
	<20071213195350.GH10104@kernel.dk>
	<20071213200219.GI10104@kernel.dk>
	<476190BE.9010405@rtr.ca>
	<20071213200958.GK10104@kernel.dk>
	<20071213140207.111f94e2.akpm@linux-foundation.org>
	<1197584106.3154.55.camel@localhost.localdomain>
	<20071213142935.47ff19d9.akpm@linux-foundation.org>
	<4761B32A.3070201@rtr.ca>
	<4761BCB4.1060601@rtr.ca>
	<4761C8E4.2010900@rtr.ca>
	<4761CE88.9070406@rtr.ca>
	<20071213163726.3bb601fa.akpm@linux-foundation.org>
	<4761D160.7060603@rtr.ca>
	<4761D279.6050500@rtr.ca>
	<1197593849.3154.62.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: liml@rtr.ca, jens.axboe@oracle.com, lkml@rtr.ca, matthew@wil.cx, linux-ide@vger.kernel.org, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Thu, 13 Dec 2007 19:57:29 -0500
James Bottomley <James.Bottomley@HansenPartnership.com> wrote:

> 
> On Thu, 2007-12-13 at 19:46 -0500, Mark Lord wrote:
> > "Improved version", more similar to the 2.6.23 code:
> > 
> > Fix page allocator to give better chance of larger contiguous segments (again).
> > 
> > Signed-off-by: Mark Lord <mlord@pobox.com
> > ---
> > 
> > --- old/mm/page_alloc.c	2007-12-13 19:25:15.000000000 -0500
> > +++ linux-2.6/mm/page_alloc.c	2007-12-13 19:43:07.000000000 -0500
> > @@ -760,7 +760,7 @@
> >  		struct page *page = __rmqueue(zone, order, migratetype);
> >  		if (unlikely(page == NULL))
> >  			break;
> > -		list_add(&page->lru, list);
> > +		list_add_tail(&page->lru, list);
> 
> Could we put a big comment above this explaining to the would be vm
> tweakers why this has to be a list_add_tail, so we don't end up back in
> this position after another two years?
> 

Already done ;)

--- a/mm/page_alloc.c~fix-page_alloc-for-larger-i-o-segments-fix
+++ a/mm/page_alloc.c
@@ -847,6 +847,10 @@ static int rmqueue_bulk(struct zone *zon
 		struct page *page = __rmqueue(zone, order, migratetype);
 		if (unlikely(page == NULL))
 			break;
+		/*
+		 * Doing a list_add_tail() here helps us to hand out pages in
+		 * ascending physical-address order.
+		 */
 		list_add_tail(&page->lru, list);
 		set_page_private(page, migratetype);
 	}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
