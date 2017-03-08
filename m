Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 458D9831D3
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 04:27:02 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id b140so9302566wme.3
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 01:27:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y103si3560925wrc.102.2017.03.08.01.27.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 01:27:01 -0800 (PST)
Date: Wed, 8 Mar 2017 10:26:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmalloc: use __GFP_HIGHMEM implicitly
Message-ID: <20170308092659.GD11028@dhcp22.suse.cz>
References: <20170307141020.29107-1-mhocko@kernel.org>
 <a984cf7d-221d-6106-e91d-6258b4e1d03c@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a984cf7d-221d-6106-e91d-6258b4e1d03c@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Cristopher Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 08-03-17 08:33:58, Vlastimil Babka wrote:
> On 03/07/2017 03:10 PM, Michal Hocko wrote:
[...]
> > index dece26f119d4..a804a4107fbc 100644
> > --- a/drivers/block/drbd/drbd_bitmap.c
> > +++ b/drivers/block/drbd/drbd_bitmap.c
> > @@ -409,7 +409,7 @@ static struct page **bm_realloc_pages(struct drbd_bitmap *b, unsigned long want)
> >  	new_pages = kzalloc(bytes, GFP_NOIO | __GFP_NOWARN);
> >  	if (!new_pages) {
> >  		new_pages = __vmalloc(bytes,
> > -				GFP_NOIO | __GFP_HIGHMEM | __GFP_ZERO,
> > +				GFP_NOIO | __GFP_ZERO,
> 
> This should be converted to memalloc_noio_save(), right? And then
> kvmalloc? Unless that happens in your other series :)

yeah, that would be for a separate patch(es).

[...]
> > diff --git a/fs/btrfs/free-space-tree.c b/fs/btrfs/free-space-tree.c
> > index dd7fb22a955a..fc0bd8406758 100644
> > --- a/fs/btrfs/free-space-tree.c
> > +++ b/fs/btrfs/free-space-tree.c
> > @@ -167,8 +167,7 @@ static u8 *alloc_bitmap(u32 bitmap_size)
> >  	if (mem)
> >  		return mem;
> >  
> > -	return __vmalloc(bitmap_size, GFP_NOFS | __GFP_HIGHMEM | __GFP_ZERO,
> > -			 PAGE_KERNEL);
> > +	return __vmalloc(bitmap_size, GFP_NOFS | __GFP_ZERO, PAGE_KERNEL);
> 
> memalloc_nofs_save() and plain vzalloc()?

I would really prefer to check whether GFP_NOFS is really needed here
and if yes then place memalloc_nofs_save where the locking really
requires it so this would become plan vmalloc as a side effect
 
> > diff --git a/mm/nommu.c b/mm/nommu.c
> > index a80411d258fc..fc184f597d59 100644
> > --- a/mm/nommu.c
> > +++ b/mm/nommu.c
> > @@ -246,8 +246,7 @@ void *vmalloc_user(unsigned long size)
> >  {
> >  	void *ret;
> >  
> > -	ret = __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
> > -			PAGE_KERNEL);
> > +	ret = __vmalloc(size, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
> 
> vzalloc()?

after some code moving in mm/nommu.c yes. But I am not sure this is a
huge win

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
