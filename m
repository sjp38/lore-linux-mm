Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 5407D6B002C
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 10:03:19 -0500 (EST)
Date: Thu, 1 Mar 2012 09:03:16 -0600 (CST)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -next] slub: set PG_slab on all of slab pages
In-Reply-To: <1330587031.1762.46.camel@leonhard>
Message-ID: <alpine.DEB.2.00.1203010901020.5004@router.home>
References: <1330505674-31610-1-git-send-email-namhyung.kim@lge.com>  <alpine.DEB.2.00.1202290922210.32268@router.home> <1330587031.1762.46.camel@leonhard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: Namhyung Kim <namhyung.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 1 Mar 2012, Namhyung Kim wrote:

> > You cannot free a tail page of a compound higher order page independently.
> > You must free the whole compound.
> >
>
> I meant freeing a *slab object* resides in a compound page using buddy
> system API (e.g. free_pages). I know it's definitely a programming
> error. However there's no safety net to protect and/or warn such a
> misbehavior AFAICS - except for head page which has PG_slab set - when
> it happened by any chance.

?? One generally passed a struct page pointer to the page allocator. Slab
allocator takes pointers to object. The calls that take a pointer to an
object must have a page aligned value.

> Without it, it might be possible to free part of tail pages silently,
> and cause unexpected not-so-funny results some time later. It should be
> hard to find out.

Ok then fix the page allocator to BUG() on tail pages. That is an issue
with the page allocator not the slab allocator.

Adding PG_tail to the flags checked on free should do the trick (at least
for 64 bit).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
