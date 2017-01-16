Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CDBE26B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 04:59:28 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id t18so11750827wmt.7
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 01:59:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si1358767wrk.228.2017.01.16.01.59.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Jan 2017 01:59:27 -0800 (PST)
Date: Mon, 16 Jan 2017 10:59:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/slub: Add a dump_stack() to the unexpected GFP check
Message-ID: <20170116095925.GE13641@dhcp22.suse.cz>
References: <20170116091643.15260-1-bp@alien8.de>
 <20170116092840.GC32481@mtr-leonro.local>
 <20170116093702.tp7sbbosh23cxzng@pd.tnic>
 <20170116094851.GD32481@mtr-leonro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170116094851.GD32481@mtr-leonro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Romanovsky <leon@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 16-01-17 11:48:51, Leon Romanovsky wrote:
> On Mon, Jan 16, 2017 at 10:37:02AM +0100, Borislav Petkov wrote:
> > On Mon, Jan 16, 2017 at 11:28:40AM +0200, Leon Romanovsky wrote:
> > > On Mon, Jan 16, 2017 at 10:16:43AM +0100, Borislav Petkov wrote:
> > > > From: Borislav Petkov <bp@suse.de>
> > > >
> > > > We wanna know who's doing such a thing. Like slab.c does that.
> > > >
> > > > Signed-off-by: Borislav Petkov <bp@suse.de>
> > > > ---
> > > >  mm/slub.c | 1 +
> > > >  1 file changed, 1 insertion(+)
> > > >
> > > > diff --git a/mm/slub.c b/mm/slub.c
> > > > index 067598a00849..1b0fa7625d6d 100644
> > > > --- a/mm/slub.c
> > > > +++ b/mm/slub.c
> > > > @@ -1623,6 +1623,7 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
> > > >  		flags &= ~GFP_SLAB_BUG_MASK;
> > > >  		pr_warn("Unexpected gfp: %#x (%pGg). Fixing up to gfp: %#x (%pGg). Fix your code!\n",
> > > >  				invalid_mask, &invalid_mask, flags, &flags);
> > > > +		dump_stack();
> > >
> > > Will it make sense to change these two lines above to WARN(true, .....)?
> >
> > Should be equivalent.
> 
> Almost, except one point - pr_warn and dump_stack have different log
> levels. There is a chance that user won't see pr_warn message above, but
> dump_stack will be always present.
> 
> For WARN_XXX, users will always see message and stack at the same time.

On the other hand WARN* will taint the kernel and this sounds a bit
overreacting for something like a wrong gfp mask which is perfectly
recoverable. Not to mention users who care configured to panic on
warning.

So while I do not have a strong opinion on this I would rather stay with
the dump_stack.


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
