Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 064866B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 02:37:01 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so54816276wic.1
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 23:37:00 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id k1si1666127wie.76.2015.08.10.23.36.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Aug 2015 23:36:59 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so54815251wic.1
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 23:36:58 -0700 (PDT)
Date: Tue, 11 Aug 2015 08:36:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm/slub: don't wait for high-order page allocation
Message-ID: <20150811063655.GC18998@dhcp22.suse.cz>
References: <1438913403-3682-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20150807150501.GJ30785@dhcp22.suse.cz>
 <20150810004022.GC26074@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150810004022.GC26074@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Shaohua Li <shli@fb.com>, Vlastimil Babka <vbabka@suse.cz>, Eric Dumazet <edumazet@google.com>

On Mon 10-08-15 09:40:22, Joonsoo Kim wrote:
> On Fri, Aug 07, 2015 at 05:05:01PM +0200, Michal Hocko wrote:
> > On Fri 07-08-15 11:10:03, Joonsoo Kim wrote:
> > [...]
> > > diff --git a/mm/slub.c b/mm/slub.c
> > > index 257283f..52b9025 100644
> > > --- a/mm/slub.c
> > > +++ b/mm/slub.c
> > > @@ -1364,6 +1364,8 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
> > >  	 * so we fall-back to the minimum order allocation.
> > >  	 */
> > >  	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
> > > +	if ((alloc_gfp & __GFP_WAIT) && oo_order(oo) > oo_order(s->min))
> > > +		alloc_gfp = (alloc_gfp | __GFP_NOMEMALLOC) & ~__GFP_WAIT;
> > 
> > Wouldn't it be preferable to "fix" the __GFP_WAIT behavior than spilling
> > __GFP_NOMEMALLOC around the kernel? GFP flags are getting harder and
> > harder to use right and that is a signal we should thing about it and
> > unclutter the current state.
> 
> Maybe, it is preferable. Could you try that?

I will try to cook up something during the week.

> Anyway, it is separate issue so I don't want pending this patch until
> that change.

OK, fair enough, at least this one is in mm proper...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
