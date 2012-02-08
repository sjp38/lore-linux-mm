Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 908226B13F0
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 09:45:11 -0500 (EST)
Date: Wed, 8 Feb 2012 14:45:06 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 02/15] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve
 pages
Message-ID: <20120208144506.GI5938@suse.de>
References: <1328568978-17553-1-git-send-email-mgorman@suse.de>
 <1328568978-17553-3-git-send-email-mgorman@suse.de>
 <alpine.DEB.2.00.1202071025050.30652@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1202071025050.30652@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue, Feb 07, 2012 at 10:27:56AM -0600, Christoph Lameter wrote:
> On Mon, 6 Feb 2012, Mel Gorman wrote:
> 
> > Pages allocated from the reserve are returned with page->pfmemalloc
> > set and it is up to the caller to determine how the page should be
> > protected.  SLAB restricts access to any page with page->pfmemalloc set
> 
> pfmemalloc sounds like a page flag. If you would use one then the
> preservation of the flag by copying it elsewhere may not be necessary and
> the patches would be less invasive.

Using a page flag would simplify parts of the patch. The catch of course
is that it requires a page flag which are in tight supply and I do not
want to tie this to being 32-bit unnecessarily.

> Also you would not need to extend
> and modify many of the structures.
> 
 
Lets see;

o struct page size would be unaffected
o struct kmem_cache_cpu could be left alone even though it's a small saving
o struct slab also be left alone
o struct array_cache could be left alone although I would point out that
  it would make no difference in size as touched is changed to a bool to
  fit pfmemalloc in
o It would still be necessary to do the object pointer tricks in slab.c
  to avoid doing an excessive number of page lookups which is where much
  of the complexity is
o The virt_to_slab could be replaced by looking up the page flag instead
  and avoiding a level of indirection that would be pleasing
  to an int and placed with struct kmem_cache

I agree that parts of the patch would be simplier although the
complexity of storing pfmemalloc within the obj pointer would probably
remain. However, the downside of requiring a page flag is very high. In
the event we increase the number of page flags - great, I'll use one but
right now I do not think the use of page flag is justified.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
