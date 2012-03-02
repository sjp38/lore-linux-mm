Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 07A556B007E
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 11:31:24 -0500 (EST)
Date: Fri, 2 Mar 2012 10:13:29 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -next] slub: set PG_slab on all of slab pages
In-Reply-To: <4F5072F4.3030505@lge.com>
Message-ID: <alpine.DEB.2.00.1203021013180.15125@router.home>
References: <1330505674-31610-1-git-send-email-namhyung.kim@lge.com>  <alpine.DEB.2.00.1202290922210.32268@router.home> <1330587031.1762.46.camel@leonhard> <alpine.DEB.2.00.1203010901020.5004@router.home> <4F5072F4.3030505@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung.kim@lge.com>
Cc: Namhyung Kim <namhyung@gmail.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2 Mar 2012, Namhyung Kim wrote:

> > ?? One generally passed a struct page pointer to the page allocator. Slab
> > allocator takes pointers to object. The calls that take a pointer to an
> > object must have a page aligned value.
> >
>
> Please see free_pages(). It converts the pointer using virt_to_page().

Sure. As I said you still need a page aligned value. If you were
successful in doing what you claim then there is a bug in the page
allocator because it allowed the freeing of a tail page out of a compound
page.


> > Adding PG_tail to the flags checked on free should do the trick (at least
> > for 64 bit).
> >
>
> Yeah, but doing it requires to change free path of compound pages. It seems
> freeing normal compound pages would not clear PG_head/tail bits before
> free_pages_check() called. I guess moving destroy_compound_page() into
> free_pages_prepare() will solved this issue but I want to make sure it's the
> right approach since I have no idea how it affects huge page behaviors.

Freeing a tail page should cause a BUG() or some form of error handling.
It should not work.

> Besides, as it has no effect on 32 bit kernels I still want add the PG_slab
> flag to those pages. If you care about the performance of hot path, how about
> adding it under debug configurations at least?

One reason to *not* do the marking of each page is that it impacts the
allocation and free paths in the allocator.

The basic notion of compound pages is that the flags in the head page are
valid for all the pages in the compound. PG_slab is set already in the
head page. So the compound is marked as a slab page. Consulting
page->firstpage->flags and not page->flags will yield the correct result.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
