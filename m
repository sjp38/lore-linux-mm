Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 769D56B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 20:42:58 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so103672519pdb.1
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 17:42:58 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id fz4si6567120pdb.47.2015.06.29.17.42.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jun 2015 17:42:57 -0700 (PDT)
Received: by pactm7 with SMTP id tm7so112571939pac.2
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 17:42:57 -0700 (PDT)
Date: Tue, 30 Jun 2015 09:42:46 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCHv3 2/7] zsmalloc: partial page ordering within a
 fullness_list
Message-ID: <20150630004246.GA13493@blaptop>
References: <1434628004-11144-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1434628004-11144-3-git-send-email-sergey.senozhatsky@gmail.com>
 <20150629065218.GC13179@bbox>
 <20150629234124.GB7301@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150629234124.GB7301@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jun 30, 2015 at 08:41:24AM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> Sorry for long reply.
> 
> On (06/29/15 15:52), Minchan Kim wrote:
> [..]
> > >  	head = &class->fullness_list[fullness];
> > > -	if (*head)
> > > -		list_add_tail(&page->lru, &(*head)->lru);
> > > +	if (*head) {
> > > +		/*
> > > +		 * We want to see more ZS_FULL pages and less almost
> > > +		 * empty/full. Put pages with higher ->inuse first.
> > > +		 */
> > > +		if (page->inuse < (*head)->inuse)
> > > +			list_add_tail(&page->lru, &(*head)->lru);
> > > +		else
> > > +			list_add(&page->lru, &(*head)->lru);
> > > +	}
> > 
> > >  
> > >  	*head = page;
> > 
> > Why do you want to always put @page in the head?
> > How about this?
> 
> 
> Yeah, right. Looks OK to me. How do we want to handle it? Do you want
> to submit it with Suggested-by: ss (I'm fine) or you want me to submit
> it later today with Suggested-by: Minchan Kim?

Hi Sergey,

Thanks for considering the credit.
However, it was just review so no need my sign. :)

I really appreciate your good works.
Thanks.


> 
> 	-ss
> 
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index e8cb31c..1c5fde9 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -658,21 +658,25 @@ static void insert_zspage(struct page *page, struct size_class *class,
> >         if (fullness >= _ZS_NR_FULLNESS_GROUPS)
> >                 return;
> > 
> > +       zs_stat_inc(class, fullness == ZS_ALMOST_EMPTY ?
> > +                       CLASS_ALMOST_EMPTY : CLASS_ALMOST_FULL, 1);
> > +
> >         head = &class->fullness_list[fullness];
> > -       if (*head) {
> > -               /*
> > -                * We want to see more ZS_FULL pages and less almost
> > -                * empty/full. Put pages with higher ->inuse first.
> > -                */
> > -               if (page->inuse < (*head)->inuse)
> > -                       list_add_tail(&page->lru, &(*head)->lru);
> > -               else
> > -                       list_add(&page->lru, &(*head)->lru);
> > +       if (!*head) {
> > +               *head = page;
> > +               return;
> >         }
> > 
> > -       *head = page;
> > -       zs_stat_inc(class, fullness == ZS_ALMOST_EMPTY ?
> > -                       CLASS_ALMOST_EMPTY : CLASS_ALMOST_FULL, 1);
> > +       /*
> > +        * We want to see more ZS_FULL pages and less almost
> > +        * empty/full. Put pages with higher ->inuse first.
> > +        */
> > +       list_add_tail(&page->lru, &(*head)->lru);
> > +       if (page->inuse >= (*head)->inuse)
> > +               *head = page;
> >  }

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
