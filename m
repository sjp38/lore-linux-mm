Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 471BB6B0005
	for <linux-mm@kvack.org>; Mon, 16 May 2016 21:02:25 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u185so2164408oie.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 18:02:25 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id c5si517572igf.31.2016.05.16.18.02.23
        for <linux-mm@kvack.org>;
        Mon, 16 May 2016 18:02:24 -0700 (PDT)
Date: Tue, 17 May 2016 10:02:22 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v5 07/12] zsmalloc: factor page chain functionality out
Message-ID: <20160517010222.GA31335@bbox>
References: <1462760433-32357-1-git-send-email-minchan@kernel.org>
 <1462760433-32357-8-git-send-email-minchan@kernel.org>
 <20160516021420.GC504@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160516021420.GC504@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Mon, May 16, 2016 at 11:14:20AM +0900, Sergey Senozhatsky wrote:
> On (05/09/16 11:20), Minchan Kim wrote:
> > For page migration, we need to create page chain of zspage dynamically
> > so this patch factors it out from alloc_zspage.
> > 
> > Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Thanks!

> 
> [..]
> > +		page = alloc_page(flags);
> > +		if (!page) {
> > +			while (--i >= 0)
> > +				__free_page(pages[i]);
> 
> 				put_page() ?
> 
> a minor nit, put_page() here probably will be in alignment
> with __free_zspage(), which does put_page().

Normally, we use put_page in case that someone can grab a referece of
the page so we cannot free the page. Otherwise, alloc_page and
__free_page is more straight to me code readability POV.

> 
> 	-ss
> 
> > +			return NULL;
> > +		}
> > +		pages[i] = page;
> >  	}
> >  
> > +	create_page_chain(pages, class->pages_per_zspage);
> > +	first_page = pages[0];
> > +	init_zspage(class, first_page);
> > +
> >  	return first_page;
> >  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
