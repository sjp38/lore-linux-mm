Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5531582F99
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 04:53:27 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so23992476wic.1
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 01:53:26 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id b18si12152777wjs.105.2015.10.02.01.53.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 01:53:25 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so23342887wic.0
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 01:53:25 -0700 (PDT)
Date: Fri, 2 Oct 2015 10:53:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: linux-next: kernel BUG at mm/slub.c:1447!
Message-ID: <20151002085324.GA2927@dhcp22.suse.cz>
References: <560D59F7.4070002@roeck-us.net>
 <20151001134904.127ccc7bea14e969fbfba0d5@linux-foundation.org>
 <20151002072522.GC30354@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151002072522.GC30354@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Guenter Roeck <linux@roeck-us.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>

On Fri 02-10-15 09:25:22, Michal Hocko wrote:
> On Thu 01-10-15 13:49:04, Andrew Morton wrote:
[...]
> > Now, we could redefine mapping_gfp_mask()'s purpose (or formalize
> > stuff which has been sneaking in anyway).  Treat mapping_gfp_mask() as
> > a constraint mask - instead of it being "use this gfp for this
> > mapping", it becomes "don't use these gfp flags for this mapping".
> > 
> > Hence something like:
> > 
> > gfp_t mapping_gfp_constraint(struct address_space *mapping, gfp_t gfp_in)
> > {
> > 	return mapping_gfp_mask(mapping) & gfp_in;
> > }
> > 
> > So instead of doing this:
> > 
> > @@ -370,12 +371,13 @@ mpage_readpages(struct address_space *ma
> >  		prefetchw(&page->flags);
> >  		list_del(&page->lru);
> >  		if (!add_to_page_cache_lru(page, mapping,
> > -					page->index, GFP_KERNEL)) {
> > +					page->index,
> > +					gfp)) {
> > 
[...]
> I will post another one which
> will add mapping_gfp_constraint on top. It will surely be less error
> prone.

OK, so here we go. There are still few direct users of mapping_gfp_mask
but most of them use it unrestricted. The only exception seems to be
loop driver and luste lloop which save and restrict mapping_gfp which
didn't seem worthwhile converting.

This is on top of the current linux-next + the updated fix for the loop
hang.
---
