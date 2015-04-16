Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id A19656B0038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 15:35:00 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so92028102wgy.2
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 12:35:00 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q9si17487770wiy.19.2015.04.16.12.34.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Apr 2015 12:34:59 -0700 (PDT)
Date: Thu, 16 Apr 2015 20:34:54 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/4] mm: migrate: Batch TLB flushing when unmapping pages
 for migration
Message-ID: <20150416193454.GT14842@suse.de>
References: <1429179766-26711-1-git-send-email-mgorman@suse.de>
 <1429179766-26711-5-git-send-email-mgorman@suse.de>
 <alpine.LSU.2.11.1504161148270.17733@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1504161148270.17733@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Apr 16, 2015 at 11:57:15AM -0700, Hugh Dickins wrote:
> > @@ -1098,6 +1098,8 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
> >  	if (!swapwrite)
> >  		current->flags |= PF_SWAPWRITE;
> >  
> > +	alloc_tlb_ubc();
> > +
> >  	for(pass = 0; pass < 10 && retry; pass++) {
> >  		retry = 0;
> >  
> > @@ -1144,6 +1146,8 @@ out:
> >  	if (!swapwrite)
> >  		current->flags &= ~PF_SWAPWRITE;
> >  
> > +	try_to_unmap_flush();
> 
> This is the right place to aim to flush, but I think you have to make
> more changes before it is safe to do so here.
> 
> The putback_lru_page(page) in unmap_and_move() is commented "A page
> that has been migrated has all references removed and will be freed".
> 
> If you leave TLB flushing until after the page has been freed, then
> there's a risk that userspace will see, not the data it expects at
> whatever virtual address, but data placed in there by the next user
> of this freed page.
> 
> So you'll need to do a little restructuring first.
> 

Well spotted. I believe you are correct and it almost certainly applies to
patch 2 as well for similar reasons. It also impacts the maximum reasonable
batch size that can be managed while maintaing safety. I'll do the necessary
shuffling tomorrow or Monday.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
