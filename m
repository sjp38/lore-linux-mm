Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id A46FF6B0039
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 10:40:55 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so1010977pbb.10
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 07:40:55 -0700 (PDT)
Received: by mail-ob0-f180.google.com with SMTP id wn1so688632obc.11
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 07:40:52 -0700 (PDT)
Date: Wed, 9 Oct 2013 09:40:45 -0500
From: Seth Jennings <spartacus06@gmail.com>
Subject: Re: [PATCH] frontswap: enable call to invalidate area on swapoff
Message-ID: <20131009144045.GA5406@variantweb.net>
References: <1381159541-13981-1-git-send-email-k.kozlowski@samsung.com>
 <20131007150338.1fdee18b536bb1d9fe41a07b@linux-foundation.org>
 <1381220000.16135.10.camel@AMDC1943>
 <20131008130853.96139b79a0a4d3aaacc79ed2@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131008130853.96139b79a0a4d3aaacc79ed2@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>, linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, Shaohua Li <shli@fusionio.com>, Minchan Kim <minchan@kernel.org>

On Tue, Oct 08, 2013 at 01:08:53PM -0700, Andrew Morton wrote:
> On Tue, 08 Oct 2013 10:13:20 +0200 Krzysztof Kozlowski <k.kozlowski@samsung.com> wrote:
> 
> > On pon, 2013-10-07 at 15:03 -0700, Andrew Morton wrote:
> > > On Mon, 07 Oct 2013 17:25:41 +0200 Krzysztof Kozlowski <k.kozlowski@samsung.com> wrote:
> > > 
> > > > During swapoff the frontswap_map was NULL-ified before calling
> > > > frontswap_invalidate_area(). However the frontswap_invalidate_area()
> > > > exits early if frontswap_map is NULL. Invalidate was never called during
> > > > swapoff.
> > > > 
> > > > This patch moves frontswap_map_set() in swapoff just after calling
> > > > frontswap_invalidate_area() so outside of locks
> > > > (swap_lock and swap_info_struct->lock). This shouldn't be a problem as
> > > > during swapon the frontswap_map_set() is called also outside of any
> > > > locks.
> > > > 
> > > 
> > > Ahem.  So there's a bunch of code in __frontswap_invalidate_area()
> > > which hasn't ever been executed and nobody noticed it.  So perhaps that
> > > code isn't actually needed?
> > > 
> > > More seriously, this patch looks like it enables code which hasn't been
> > > used or tested before.  How well tested was this?
> > > 
> > > Are there any runtime-visible effects from this change?
> > 
> > I tested zswap on x86 and x86-64 and there was no difference. This is
> > good as there shouldn't be visible anything because swapoff is unusing
> > all pages anyway:
> > 	try_to_unuse(type, false, 0); /* force all pages to be unused */
> > 
> > I haven't tested other frontswap users.
> 
> So is that code in __frontswap_invalidate_area() unneeded?

Yes, to expand on what Bob said, __frontswap_invalidate_area() is still
needed to let any frontswap backend free per-swaptype resources.

__frontswap_invalidate_area() is _not_ for freeing structures associated
with individual swapped out pages since all of the pages should be
brought back into memory by try_to_unuse() before
__frontswap_invalidate_area() is called.

The reason we never noticed this for zswap is that zswap has no
dynamically allocated per-type resources.  In the expected case,
where all of the pages have been drained from zswap,
zswap_frontswap_invalidate_area() is a no-op.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
