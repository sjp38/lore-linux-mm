Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4BEC96B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 10:10:29 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id na2so4349774lbb.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 07:10:29 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id gg9si1743076wjb.19.2016.06.08.07.10.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 07:10:28 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n184so3323779wmn.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 07:10:27 -0700 (PDT)
Date: Wed, 8 Jun 2016 16:10:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, memcg: use consistent gfp flags during readahead
Message-ID: <20160608141026.GL22570@dhcp22.suse.cz>
References: <1465301556-26431-1-git-send-email-mhocko@kernel.org>
 <20160608135900.GB30465@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160608135900.GB30465@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 08-06-16 16:59:00, Vladimir Davydov wrote:
> On Tue, Jun 07, 2016 at 02:12:36PM +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Vladimir has noticed that we might declare memcg oom even during
> > readahead because read_pages only uses GFP_KERNEL (with mapping_gfp
> > restriction) while __do_page_cache_readahead uses
> > page_cache_alloc_readahead which adds __GFP_NORETRY to prevent from
> > OOMs. This gfp mask discrepancy is really unfortunate and easily
> > fixable. Drop page_cache_alloc_readahead() which only has one user
> > and outsource the gfp_mask logic into readahead_gfp_mask and propagate
> > this mask from __do_page_cache_readahead down to read_pages.
> > 
> > This alone would have only very limited impact as most filesystems
> > are implementing ->readpages and the common implementation
> > mpage_readpages does GFP_KERNEL (with mapping_gfp restriction) again.
> > We can tell it to use readahead_gfp_mask instead as this function is
> > called only during readahead as well. The same applies to
> > read_cache_pages.
> > 
> > ext4 has its own ext4_mpage_readpages but the path which has pages !=
> > NULL can use the same gfp mask.
> > Btrfs, cifs, f2fs and orangefs are doing a very similar pattern to
> > mpage_readpages so the same can be applied to them as well.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> > 
> > Hi,
> > an alternative solution for ->readpages part would be add the gfp mask
> > as a new argument. This would be a larger change and I am not even sure
> > it would be so much better. An explicit usage of the readahead gfp mask
> > sounds like easier to track. If there is a general agreement this is a
> > proper way to go I can rework the patch to do so, of course.
> > 
> > Does this make sense?
> ...
> > diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
> > index dc54a4b60eba..c75b66a64982 100644
> > --- a/fs/ext4/readpage.c
> > +++ b/fs/ext4/readpage.c
> > @@ -166,7 +166,7 @@ int ext4_mpage_readpages(struct address_space *mapping,
> >  			page = list_entry(pages->prev, struct page, lru);
> >  			list_del(&page->lru);
> >  			if (add_to_page_cache_lru(page, mapping, page->index,
> > -				  mapping_gfp_constraint(mapping, GFP_KERNEL)))
> > +				  readahead_gfp_mask(mapping)))
> >  				goto next_page;
> >  		}
> >  
> 
> ext4 (at least) might issue other allocations in ->readpages, e.g.
> bio_alloc with GFP_KERNEL.

That is true but the primary point of this patch is to put page cache
and memcg charge into sync. bio_alloc shouldn't get to the memcg code
path AFAICS. That being said it is not nice that ext4 can go OOM during
readahead but fixing that would be out of scope of this patch IMHO.

> I wonder if it would be better to set GFP_NOFS context on task_struct in
> read_pages() and handle it in alloc_pages. You've been planning doing
> something like this anyway, haven't you?

I have no idea whether ext4 can safely do GFP_FS allocation from this
request. Ext4 doesn't clear GFP_FS in the mapping gfp mask so it does
GFP_FS charge by default.

You are right that I would love to see scope GFP_NOFS contexts used by
FS. I plan to repost my patches to add the API hopefully soon but there
are other things to settle down before I can do that.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
