Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4E6296B0036
	for <linux-mm@kvack.org>; Thu,  1 May 2014 17:02:03 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id fb1so4218850pad.24
        for <linux-mm@kvack.org>; Thu, 01 May 2014 14:02:02 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id ug9si21908185pab.7.2014.05.01.14.02.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 May 2014 14:02:02 -0700 (PDT)
Received: by mail-pd0-f169.google.com with SMTP id z10so2328528pdj.14
        for <linux-mm@kvack.org>; Thu, 01 May 2014 14:02:02 -0700 (PDT)
Date: Thu, 1 May 2014 14:02:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/2] mm, compaction: return failed migration target pages
 back to freelist
In-Reply-To: <5361dae9.4781e00a.74f8.ffff8c8eSMTPIN_ADDED_BROKEN@mx.google.com>
Message-ID: <alpine.DEB.2.02.1405011401040.32268@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1404301744400.8415@chino.kir.corp.google.com> <5361dae9.4781e00a.74f8.ffff8c8eSMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, vbabka@suse.cz, iamjoonsoo.kim@lge.com, gthelen@google.com, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 1 May 2014, Naoya Horiguchi wrote:

> > diff --git a/mm/compaction.c b/mm/compaction.c
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -797,6 +797,19 @@ static struct page *compaction_alloc(struct page *migratepage,
> >  }
> >  
> >  /*
> > + * This is a migrate-callback that "frees" freepages back to the isolated
> > + * freelist.  All pages on the freelist are from the same zone, so there is no
> > + * special handling needed for NUMA.
> > + */
> > +static void compaction_free(struct page *page, unsigned long data)
> > +{
> > +	struct compact_control *cc = (struct compact_control *)data;
> > +
> > +	list_add(&page->lru, &cc->freepages);
> > +	cc->nr_freepages++;
> 
> With this change, migration_page() handles cc->nr_freepages consistently, so
> we don't have to run over freelist to update this count in update_nr_listpages()?
> 

Good optimization, I'll add it!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
