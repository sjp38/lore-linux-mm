Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: MM patches against 2.5.31
Date: Thu, 29 Aug 2002 00:57:06 +0200
References: <3D644C70.6D100EA5@zip.com.au> <E17kAvf-0002tx-00@starship> <3D6D5128.9EE6DFDD@zip.com.au>
In-Reply-To: <3D6D5128.9EE6DFDD@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17kBkK-0002uI-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Christian Ehrhardt <ehrhardt@mathematik.uni-ulm.de>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thursday 29 August 2002 00:39, Andrew Morton wrote:
> Daniel Phillips wrote:
> > 
> > ...
> > So there's no question that the race is lurking in 2.4.  I noticed several
> > more paths besides the one above that look suspicious as well.  The bottom
> > line is, 2.4 needs a fix along the lines of my suggestion or Christian's,
> > something that can actually be proved.
> > 
> > It's a wonder that this problem manifests so rarely in practice.
> 
> I sort-of glanced through the 2.4 paths and it appears that in all of the
> places where it could do a page_cache_get/release, that would never happen
> because of other parts of the page state.
> 
> Like: it can't be in pagecache, so we won't run writepage, and
> it can't have buffers, so we won't run try_to_release_page().
> 
> Of course, I might have missed a path.  And, well, generally: ugh.

I think it is happening.  I just went sifting searching through the archives
on 'oops' and '2.4'.  The first one I found was:

   2.4.18-xfs (xfs related?) oops report

which fits the description nicely.

The race I showed actually causes the page->count to go negative, avoiding
a double free on a technicality.  That doesn't make me feel much better about
it.  Have you got a BUG_ON(!page_count(page)) in put_page_testzero?  I think
we might see some action.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
