Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id A80BE900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 23:30:21 -0400 (EDT)
Received: by padj3 with SMTP id j3so20206749pad.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 20:30:21 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com. [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id e3si3725539pdc.240.2015.06.03.20.30.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 20:30:20 -0700 (PDT)
Received: by pdbki1 with SMTP id ki1so21124028pdb.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 20:30:20 -0700 (PDT)
Date: Thu, 4 Jun 2015 12:30:14 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH 03/10] zsmalloc: introduce zs_can_compact() function
Message-ID: <20150604033014.GG2241@blaptop>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1432911928-14654-4-git-send-email-sergey.senozhatsky@gmail.com>
 <20150604025533.GE2241@blaptop>
 <20150604031514.GE1951@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150604031514.GE1951@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 04, 2015 at 12:15:14PM +0900, Sergey Senozhatsky wrote:
> On (06/04/15 11:55), Minchan Kim wrote:
> > > [ 3303.108960] class-3072 objs:24652 inuse:24628 objs-per-page:4 pages-tofree:6
> > 
> >                                                    maxobjs-per-zspage?
> > 
> 
> yeah, I shortened it to be more of less "80 chars" friendly.
> 
> 
> [..]
> 
> > > +	 * calculate how many unused allocated objects we
> > 
> >            c should be captital.
> > 
> > I hope you will fix all of english grammer in next spin
> > because someone(like me) who is not a native will learn the
> > wrong english. :)
> 
> sure, will fix. yeah, I'm a native broken english speaker :-)
> 
> > > +	 * have and see if we can free any zspages. otherwise,
> > > +	 * compaction can just move objects back and forth w/o
> > > +	 * any memory gain.
> > > +	 */
> > > +	unsigned long ret = zs_stat_get(class, OBJ_ALLOCATED) -
> > > +		zs_stat_get(class, OBJ_USED);
> > > +
> > 
> > I prefer obj_wasted to "ret".
> 
> ok.
> 
> I'm still thinking how good it should be.
> 
> for automatic compaction we don't want to uselessly move objects between
> pages and I tend to think that it's better to compact less, than to waste
> more cpu cycless.
> 
> 
> on the other hand, this policy will miss cases like:
> 
> -- free objects in class: 5 (free-objs class capacity)
> -- page1: inuse 2
> -- page2: inuse 2
> -- page3: inuse 3
> -- page4: inuse 2

What scenario do you have a cocern?
Could you describe this example more clear?

Thanks.
> 
> so total "insuse" is greater than free-objs class capacity. but, it's
> surely possible to compact this class. partial inuse summ <= free-objs class
> capacity (a partial summ is a ->inuse summ of any two of class pages:
> page1 + page2, page2 + page3, etc.).
> 
> otoh, these partial sums will badly affect performance. may be for automatic
> compaction (the one that happens w/o user interaction) we can do zs_can_compact()
> and for manual compaction (the one that has been triggered by a user) we can
> old "full-scan".
> 
> anyway, zs_can_compact() looks like something that we can optimize
> independently later.
> 
> 	-ss
> 
> > > +	ret /= get_maxobj_per_zspage(class->size,
> > > +			class->pages_per_zspage);
> > > +	return ret > 0;
> > > +}
> > > +
> > >  static unsigned long __zs_compact(struct zs_pool *pool,
> > >  				struct size_class *class)
> > >  {
> > > @@ -1686,6 +1708,9 @@ static unsigned long __zs_compact(struct zs_pool *pool,
> > >  
> > >  		BUG_ON(!is_first_page(src_page));
> > >  
> > > +		if (!zs_can_compact(class))
> > > +			break;
> > > +
> > >  		cc.index = 0;
> > >  		cc.s_page = src_page;
> > >  
> > > -- 
> > > 2.4.2.337.gfae46aa
> > > 
> > 
> > -- 
> > Kind regards,
> > Minchan Kim
> > 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
