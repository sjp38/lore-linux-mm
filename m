Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id D1B806B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 11:15:39 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id r94so299506483ioe.7
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 08:15:39 -0800 (PST)
Received: from mail1.merlins.org (magic.merlins.org. [209.81.13.136])
        by mx.google.com with ESMTPS id e80si2650326itb.89.2016.11.29.08.15.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Nov 2016 08:15:39 -0800 (PST)
Date: Tue, 29 Nov 2016 08:15:29 -0800
From: Marc MERLIN <marc@merlins.org>
Message-ID: <20161129161529.wyvuxd3fpsxitag7@merlins.org>
References: <20161121154336.GD19750@merlins.org>
 <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
 <20161121215639.GF13371@merlins.org>
 <20161122160629.uzt2u6m75ash4ved@merlins.org>
 <48061a22-0203-de54-5a44-89773bff1e63@suse.cz>
 <CA+55aFweND3KoV=00onz0Y5W9ViFedd-nvfCuB+phorc=75tpQ@mail.gmail.com>
 <20161123063410.GB2864@dhcp22.suse.cz>
 <20161128072315.GC14788@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161128072315.GC14788@dhcp22.suse.cz>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Mon, Nov 28, 2016 at 08:23:15AM +0100, Michal Hocko wrote:
> Marc, could you try this patch please? I think it should be pretty clear
> it should help you but running it through your use case would be more
> than welcome before I ask Greg to take this to the 4.8 stable tree.
> 
> Thanks!
> 
> On Wed 23-11-16 07:34:10, Michal Hocko wrote:
> [...]
> > commit b2ccdcb731b666aa28f86483656c39c5e53828c7
> > Author: Michal Hocko <mhocko@suse.com>
> > Date:   Wed Nov 23 07:26:30 2016 +0100
> > 
> >     mm, oom: stop pre-mature high-order OOM killer invocations
> >     
> >     31e49bfda184 ("mm, oom: protect !costly allocations some more for
> >     !CONFIG_COMPACTION") was an attempt to reduce chances of pre-mature OOM
> >     killer invocation for high order requests. It seemed to work for most
> >     users just fine but it is far from bullet proof and obviously not
> >     sufficient for Marc who has reported pre-mature OOM killer invocations
> >     with 4.8 based kernels. 4.9 will all the compaction improvements seems
> >     to be behaving much better but that would be too intrusive to backport
> >     to 4.8 stable kernels. Instead this patch simply never declares OOM for
> >     !costly high order requests. We rely on order-0 requests to do that in
> >     case we are really out of memory. Order-0 requests are much more common
> >     and so a risk of a livelock without any way forward is highly unlikely.
> >     
> >     Reported-by: Marc MERLIN <marc@merlins.org>
> >     Signed-off-by: Michal Hocko <mhocko@suse.com>

Tested-by: Marc MERLIN <marc@merlins.org>

Marc

> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index a2214c64ed3c..7401e996009a 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3161,6 +3161,16 @@ should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_fla
> >  	if (!order || order > PAGE_ALLOC_COSTLY_ORDER)
> >  		return false;
> >  
> > +#ifdef CONFIG_COMPACTION
> > +	/*
> > +	 * This is a gross workaround to compensate a lack of reliable compaction
> > +	 * operation. We cannot simply go OOM with the current state of the compaction
> > +	 * code because this can lead to pre mature OOM declaration.
> > +	 */
> > +	if (order <= PAGE_ALLOC_COSTLY_ORDER)
> > +		return true;
> > +#endif
> > +
> >  	/*
> >  	 * There are setups with compaction disabled which would prefer to loop
> >  	 * inside the allocator rather than hit the oom killer prematurely.
> > -- 
> > Michal Hocko
> > SUSE Labs
> 
> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/                         | PGP 1024R/763BE901

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
