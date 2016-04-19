Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0547E6B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 03:40:03 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id zy2so11248734pac.1
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 00:40:02 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id rx5si8608744pab.151.2016.04.19.00.40.01
        for <linux-mm@kvack.org>;
        Tue, 19 Apr 2016 00:40:02 -0700 (PDT)
Date: Tue, 19 Apr 2016 16:40:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 06/16] zsmalloc: squeeze inuse into page->mapping
Message-ID: <20160419074059.GA18448@bbox>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-7-git-send-email-minchan@kernel.org>
 <20160417150804.GA575@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160417150804.GA575@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

On Mon, Apr 18, 2016 at 12:08:04AM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> On (03/30/16 16:12), Minchan Kim wrote:
> [..]
> > +static int get_zspage_inuse(struct page *first_page)
> > +{
> > +	struct zs_meta *m;
> > +
> > +	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
> > +
> > +	m = (struct zs_meta *)&first_page->mapping;
> ..
> > +static void set_zspage_inuse(struct page *first_page, int val)
> > +{
> > +	struct zs_meta *m;
> > +
> > +	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
> > +
> > +	m = (struct zs_meta *)&first_page->mapping;
> ..
> > +static void mod_zspage_inuse(struct page *first_page, int val)
> > +{
> > +	struct zs_meta *m;
> > +
> > +	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
> > +
> > +	m = (struct zs_meta *)&first_page->mapping;
> ..
> >  static void get_zspage_mapping(struct page *first_page,
> >  				unsigned int *class_idx,
> >  				enum fullness_group *fullness)
> >  {
> > -	unsigned long m;
> > +	struct zs_meta *m;
> > +
> >  	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
> > +	m = (struct zs_meta *)&first_page->mapping;
> ..
> >  static void set_zspage_mapping(struct page *first_page,
> >  				unsigned int class_idx,
> >  				enum fullness_group fullness)
> >  {
> > +	struct zs_meta *m;
> > +
> >  	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
> >  
> > +	m = (struct zs_meta *)&first_page->mapping;
> > +	m->fullness = fullness;
> > +	m->class = class_idx;
> >  }
> 
> 
> a nitpick: this
> 
> 	struct zs_meta *m;
> 	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
> 	m = (struct zs_meta *)&first_page->mapping;
> 
> 
> seems to be common in several places, may be it makes sense to
> factor it out and turn into a macro or a static inline helper?
> 
> other than that, looks good to me

Yeb.

> 
> Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Thanks for the review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
