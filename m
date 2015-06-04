Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id E82BF900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 23:14:51 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so20923252pdb.2
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 20:14:51 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id qo6si3708221pac.151.2015.06.03.20.14.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 20:14:51 -0700 (PDT)
Received: by pabqy3 with SMTP id qy3so19875016pab.3
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 20:14:50 -0700 (PDT)
Date: Thu, 4 Jun 2015 12:15:14 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH 03/10] zsmalloc: introduce zs_can_compact() function
Message-ID: <20150604031514.GE1951@swordfish>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1432911928-14654-4-git-send-email-sergey.senozhatsky@gmail.com>
 <20150604025533.GE2241@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150604025533.GE2241@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (06/04/15 11:55), Minchan Kim wrote:
> > [ 3303.108960] class-3072 objs:24652 inuse:24628 objs-per-page:4 pages-tofree:6
> 
>                                                    maxobjs-per-zspage?
> 

yeah, I shortened it to be more of less "80 chars" friendly.


[..]

> > +	 * calculate how many unused allocated objects we
> 
>            c should be captital.
> 
> I hope you will fix all of english grammer in next spin
> because someone(like me) who is not a native will learn the
> wrong english. :)

sure, will fix. yeah, I'm a native broken english speaker :-)

> > +	 * have and see if we can free any zspages. otherwise,
> > +	 * compaction can just move objects back and forth w/o
> > +	 * any memory gain.
> > +	 */
> > +	unsigned long ret = zs_stat_get(class, OBJ_ALLOCATED) -
> > +		zs_stat_get(class, OBJ_USED);
> > +
> 
> I prefer obj_wasted to "ret".

ok.

I'm still thinking how good it should be.

for automatic compaction we don't want to uselessly move objects between
pages and I tend to think that it's better to compact less, than to waste
more cpu cycless.


on the other hand, this policy will miss cases like:

-- free objects in class: 5 (free-objs class capacity)
-- page1: inuse 2
-- page2: inuse 2
-- page3: inuse 3
-- page4: inuse 2

so total "insuse" is greater than free-objs class capacity. but, it's
surely possible to compact this class. partial inuse summ <= free-objs class
capacity (a partial summ is a ->inuse summ of any two of class pages:
page1 + page2, page2 + page3, etc.).

otoh, these partial sums will badly affect performance. may be for automatic
compaction (the one that happens w/o user interaction) we can do zs_can_compact()
and for manual compaction (the one that has been triggered by a user) we can
old "full-scan".

anyway, zs_can_compact() looks like something that we can optimize
independently later.

	-ss

> > +	ret /= get_maxobj_per_zspage(class->size,
> > +			class->pages_per_zspage);
> > +	return ret > 0;
> > +}
> > +
> >  static unsigned long __zs_compact(struct zs_pool *pool,
> >  				struct size_class *class)
> >  {
> > @@ -1686,6 +1708,9 @@ static unsigned long __zs_compact(struct zs_pool *pool,
> >  
> >  		BUG_ON(!is_first_page(src_page));
> >  
> > +		if (!zs_can_compact(class))
> > +			break;
> > +
> >  		cc.index = 0;
> >  		cc.s_page = src_page;
> >  
> > -- 
> > 2.4.2.337.gfae46aa
> > 
> 
> -- 
> Kind regards,
> Minchan Kim
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
