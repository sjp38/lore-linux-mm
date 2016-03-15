Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 82B96828DF
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 02:40:37 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id 124so15466194pfg.0
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 23:40:37 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id u10si1850847pfa.179.2016.03.14.23.40.36
        for <linux-mm@kvack.org>;
        Mon, 14 Mar 2016 23:40:36 -0700 (PDT)
Date: Tue, 15 Mar 2016 15:41:26 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 09/19] zsmalloc: keep max_object in size_class
Message-ID: <20160315064126.GA2808@bbox>
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
 <1457681423-26664-10-git-send-email-minchan@kernel.org>
 <20160315062824.GE1464@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160315062824.GE1464@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>

On Tue, Mar 15, 2016 at 03:28:24PM +0900, Sergey Senozhatsky wrote:
> On (03/11/16 16:30), Minchan Kim wrote:
> > Every zspage in a size_class has same number of max objects so
> > we could move it to a size_class.
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  mm/zsmalloc.c | 29 ++++++++++++++---------------
> >  1 file changed, 14 insertions(+), 15 deletions(-)
> > 
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index b4fb11831acb..ca663c82c1fc 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -32,8 +32,6 @@
> >   *	page->freelist: points to the first free object in zspage.
> >   *		Free objects are linked together using in-place
> >   *		metadata.
> > - *	page->objects: maximum number of objects we can store in this
> > - *		zspage (class->zspage_order * PAGE_SIZE / class->size)
> >   *	page->lru: links together first pages of various zspages.
> >   *		Basically forming list of zspages in a fullness group.
> >   *	page->mapping: class index and fullness group of the zspage
> > @@ -211,6 +209,7 @@ struct size_class {
> >  	 * of ZS_ALIGN.
> >  	 */
> >  	int size;
> > +	int objs_per_zspage;
> >  	unsigned int index;
> 
> struct page ->objects "comes for free". now we don't use it, instead
> every size_class grows by 4 bytes? is there any reason for this?

It is union with _mapcount and it is used by checking non-lru movable
page in this patchset.
> 
> 	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
