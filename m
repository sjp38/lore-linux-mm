Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id DC2A66B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 19:33:47 -0500 (EST)
Received: by mail-ig0-f176.google.com with SMTP id hb3so2899548igb.0
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 16:33:47 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id w63si6484218iod.140.2016.02.24.16.33.46
        for <linux-mm@kvack.org>;
        Wed, 24 Feb 2016 16:33:47 -0800 (PST)
Date: Thu, 25 Feb 2016 09:34:55 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 1/2] mm: introduce page reference manipulation
 functions
Message-ID: <20160225003454.GB9723@js1304-P5Q-DELUXE>
References: <1456212078-22732-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20160223153244.83a5c3ca430c4248a4a34cc0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160223153244.83a5c3ca430c4248a4a34cc0@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Tue, Feb 23, 2016 at 03:32:44PM -0800, Andrew Morton wrote:
> On Tue, 23 Feb 2016 16:21:17 +0900 js1304@gmail.com wrote:
> 
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > Success of CMA allocation largely depends on success of migration
> > and key factor of it is page reference count. Until now, page reference
> > is manipulated by direct calling atomic functions so we cannot follow up
> > who and where manipulate it. Then, it is hard to find actual reason
> > of CMA allocation failure. CMA allocation should be guaranteed to succeed
> > so finding offending place is really important.
> > 
> > In this patch, call sites where page reference is manipulated are converted
> > to introduced wrapper function. This is preparation step to add tracepoint
> > to each page reference manipulation function. With this facility, we can
> > easily find reason of CMA allocation failure. There is no functional change
> > in this patch.
> > 
> > ...
> >
> > --- a/arch/mips/mm/gup.c
> > +++ b/arch/mips/mm/gup.c
> > @@ -64,7 +64,7 @@ static inline void get_head_page_multiple(struct page *page, int nr)
> >  {
> >  	VM_BUG_ON(page != compound_head(page));
> >  	VM_BUG_ON(page_count(page) == 0);
> > -	atomic_add(nr, &page->_count);
> > +	page_ref_add(page, nr);
> 
> Seems reasonable.  Those open-coded refcount manipulations have always
> bugged me.

I think so.

> 
> The patches will be a bit of a pain to maintain but surprisingly they
> apply OK at present.  It's possible that by the time they hit upstream,
> some direct ->_count references will still be present and it will
> require a second pass to complete the conversion.

In fact, the patch doesn't change direct ->_count reference for
*read*. That's the reason that it is surprisingly OK at present.

It's a good idea to change direct ->_count reference even for read.
How about changing it in rc2 after mering this patch in rc1?

> After that pass is completed I suggest we rename page._count to
> something else (page.ref_count_dont_use_this_directly_you_dope?).  That
> way, any attempts to later add direct page._count references will
> hopefully break, alerting the programmer to the new regime.

Agreed.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
