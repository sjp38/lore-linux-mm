Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: MM patches against 2.5.31
Date: Thu, 29 Aug 2002 00:04:46 +0200
References: <3D644C70.6D100EA5@zip.com.au> <E17k9dO-0002tR-00@starship> <3D6D3AA4.31A4AD3A@zip.com.au>
In-Reply-To: <3D6D3AA4.31A4AD3A@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17kAvf-0002tx-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Christian Ehrhardt <ehrhardt@mathematik.uni-ulm.de>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 28 August 2002 23:03, Andrew Morton wrote:
> Daniel Phillips wrote:
> > 
> > Going right back to basics, what do you suppose is wrong with the 2.4
> > strategy of always doing the lru removal in free_pages_ok?
> 
> That's equivalent to what we have at present, which is:
> 
> 	if (put_page_testzero(page)) {
> 		/* window here */
> 		lru_cache_del(page);
> 		__free_pages_ok(page, 0);
> 	}
> 
> versus:
> 
> 	spin_lock(lru lock);
> 	page = list_entry(lru, ...);
> 	if (page_count(page) == 0)
> 		continue;
> 	/* window here */
> 	page_cache_get(page);
> 	page_cache_release(page);	/* double-free */

Indeed it is.  In 2.4.19 we have:

(vmscan.c: shrink_cache)                        (page_alloc.c: __free_pages)

365       if (unlikely(!page_count(page)))
366               continue;
					        444         if (!PageReserved(page) && put_page_testzero(page))
          [many twisty paths, all different]
511       /* effectively free the page here */
512       page_cache_release(page);
					        445                 __free_pages_ok(page, order);
                                                [free it again just to make sure]

So there's no question that the race is lurking in 2.4.  I noticed several
more paths besides the one above that look suspicious as well.  The bottom
line is, 2.4 needs a fix along the lines of my suggestion or Christian's,
something that can actually be proved.

It's a wonder that this problem manifests so rarely in practice.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
