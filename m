Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7C0A26B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 04:38:37 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v13so9462475pgq.1
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 01:38:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e17si1203678pfb.181.2017.10.03.01.38.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 01:38:36 -0700 (PDT)
Date: Tue, 3 Oct 2017 10:38:34 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 10/15] mm: Use pagevec_lookup_range_tag() in
 __filemap_fdatawait_range()
Message-ID: <20171003083834.GF11879@quack2.suse.cz>
References: <20170927160334.29513-1-jack@suse.cz>
 <20170927160334.29513-11-jack@suse.cz>
 <20170927221902.GG10621@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170927221902.GG10621@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu 28-09-17 08:19:02, Dave Chinner wrote:
> On Wed, Sep 27, 2017 at 06:03:29PM +0200, Jan Kara wrote:
> > Use pagevec_lookup_range_tag() in __filemap_fdatawait_range() as it is
> > interested only in pages from given range. Remove unnecessary code
> > resulting from this.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  mm/filemap.c | 9 ++-------
> >  1 file changed, 2 insertions(+), 7 deletions(-)
> > 
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index fe20329c83cd..479fc54b7cd1 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -421,18 +421,13 @@ static void __filemap_fdatawait_range(struct address_space *mapping,
> >  
> >  	pagevec_init(&pvec, 0);
> >  	while ((index <= end) &&
> > -			(nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
> > -			PAGECACHE_TAG_WRITEBACK,
> > -			min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1)) != 0) {
> > +			(nr_pages = pagevec_lookup_range_tag(&pvec, mapping,
> > +			&index, end, PAGECACHE_TAG_WRITEBACK, PAGEVEC_SIZE))) {
> 
> While touching this, can we clean this up by moving the lookup
> outside the while condition? i.e:
> 
> 	while (index <= end) {
> 		unsigned i;
> 
> 		nr_pages = pagevec_lookup_range_tag(&pvec, mapping, &index,
> 				end, PAGECACHE_TAG_WRITEBACK, PAGEVEC_SIZE);
> 		if (!nr_pages)
> 			break;

Yeah, that makes sense. I'll update it.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
