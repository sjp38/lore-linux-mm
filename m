Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id CEDD96B026E
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 06:49:28 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id an2so39008375wjc.3
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:49:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p198si26317814wmb.10.2017.01.26.03.49.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 03:49:27 -0800 (PST)
Date: Thu, 26 Jan 2017 12:49:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6 v3] kvmalloc
Message-ID: <20170126114925.GH6590@dhcp22.suse.cz>
References: <CAADnVQ+iGPFwTwQ03P1Ga2qM1nt14TfA+QO8-npkEYzPD+vpdw@mail.gmail.com>
 <588907AA.1020704@iogearbox.net>
 <20170126074354.GB8456@dhcp22.suse.cz>
 <5889C331.7020101@iogearbox.net>
 <20170126100802.GF6590@dhcp22.suse.cz>
 <20170126103216.GG6590@dhcp22.suse.cz>
 <5889D7AD.5030103@iogearbox.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5889D7AD.5030103@iogearbox.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, marcelo.leitner@gmail.com

On Thu 26-01-17 12:04:13, Daniel Borkmann wrote:
> On 01/26/2017 11:32 AM, Michal Hocko wrote:
> > On Thu 26-01-17 11:08:02, Michal Hocko wrote:
> > > On Thu 26-01-17 10:36:49, Daniel Borkmann wrote:
> > > > On 01/26/2017 08:43 AM, Michal Hocko wrote:
> > > > > On Wed 25-01-17 21:16:42, Daniel Borkmann wrote:
> > > [...]
> > > > > > I assume that kvzalloc() is still the same from [1], right? If so, then
> > > > > > it would unfortunately (partially) reintroduce the issue that was fixed.
> > > > > > If you look above at flags, they're also passed to __vmalloc() to not
> > > > > > trigger OOM in these situations I've experienced.
> > > > > 
> > > > > Pushing __GFP_NORETRY to __vmalloc doesn't have the effect you might
> > > > > think it would. It can still trigger the OOM killer becauset the flags
> > > > > are no propagated all the way down to all allocations requests (e.g.
> > > > > page tables). This is the same reason why GFP_NOFS is not supported in
> > > > > vmalloc.
> > > > 
> > > > Ok, good to know, is that somewhere clearly documented (like for the
> > > > case with kmalloc())?
> > > 
> > > I am afraid that we really suck on this front. I will add something.
> > 
> > So I have folded the following to the patch 1. It is in line with
> > kvmalloc and hopefully at least tell more than the current code.
> > ---
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > index d89034a393f2..6c1aa2c68887 100644
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -1741,6 +1741,13 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
> >    *	Allocate enough pages to cover @size from the page level
> >    *	allocator with @gfp_mask flags.  Map them into contiguous
> >    *	kernel virtual space, using a pagetable protection of @prot.
> > + *
> > + *	Reclaim modifiers in @gfp_mask - __GFP_NORETRY, __GFP_REPEAT
> > + *	and __GFP_NOFAIL are not supported
> 
> We could probably also mention that __GFP_ZERO in @gfp_mask is
> supported, though.

There are others which would be supported so I would rather stay with
explicit unsupported.

> 
> > + *	Any use of gfp flags outside of GFP_KERNEL should be consulted
> > + *	with mm people.
> 
> Just a question: should that read 'GFP_KERNEL | __GFP_HIGHMEM' as
> that is what vmalloc() resp. vzalloc() and others pass as flags?

yes, even though I think that specifying __GFP_HIGHMEM shouldn't be
really necessary. Are there any users who would really insist on vmalloc
pages in lowmem? Anyway this made me recheck kvmalloc_node
implementation and I am not adding this flags which would mean a
regression from the current state. Will fix it up.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
