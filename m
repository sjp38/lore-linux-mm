Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 000666B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 03:45:21 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id jl1so17057584obb.2
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 00:45:21 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 85si25862311iot.1.2016.04.19.00.45.20
        for <linux-mm@kvack.org>;
        Tue, 19 Apr 2016 00:45:21 -0700 (PDT)
Date: Tue, 19 Apr 2016 16:46:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 10/16] zsmalloc: factor page chain functionality out
Message-ID: <20160419074615.GC18448@bbox>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-11-git-send-email-minchan@kernel.org>
 <20160418003305.GA5882@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160418003305.GA5882@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

On Mon, Apr 18, 2016 at 09:33:05AM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> On (03/30/16 16:12), Minchan Kim wrote:
> > @@ -1421,7 +1434,6 @@ static unsigned long obj_malloc(struct size_class *class,
> >  	unsigned long m_offset;
> >  	void *vaddr;
> >  
> > -	handle |= OBJ_ALLOCATED_TAG;
> 
> a nitpick, why did you replace this ALLOCATED_TAG assignment
> with 2 'handle | OBJ_ALLOCATED_TAG'?

I thought this handle variable in here is pure handle but OBJ_ALLOCATED_TAG
should live in head(i.e., link->handle), not pure handle, itself.

> 
> 	-ss
> 
> >  	obj = get_freeobj(first_page);
> >  	objidx_to_page_and_offset(class, first_page, obj,
> >  				&m_page, &m_offset);
> > @@ -1431,10 +1443,10 @@ static unsigned long obj_malloc(struct size_class *class,
> >  	set_freeobj(first_page, link->next >> OBJ_ALLOCATED_TAG);
> >  	if (!class->huge)
> >  		/* record handle in the header of allocated chunk */
> > -		link->handle = handle;
> > +		link->handle = handle | OBJ_ALLOCATED_TAG;
> >  	else
> >  		/* record handle in first_page->private */
> > -		set_page_private(first_page, handle);
> > +		set_page_private(first_page, handle | OBJ_ALLOCATED_TAG);
> >  	kunmap_atomic(vaddr);
> >  	mod_zspage_inuse(first_page, 1);
> >  	zs_stat_inc(class, OBJ_USED, 1);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
