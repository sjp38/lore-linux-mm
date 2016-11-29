Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B128F6B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 12:13:36 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u144so45668851wmu.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 09:13:36 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id 15si3435637wml.145.2016.11.29.09.13.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 09:13:35 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id a20so25475375wme.2
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 09:13:35 -0800 (PST)
Date: Tue, 29 Nov 2016 18:13:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] block,blkcg: use __GFP_NOWARN for best-effort
 allocations in blkcg
Message-ID: <20161129171333.GE9796@dhcp22.suse.cz>
References: <20161121215639.GF13371@merlins.org>
 <20161121230332.GA3767@htj.duckdns.org>
 <7189b1f6-98c3-9a36-83c1-79f2ff4099af@suse.cz>
 <20161122164822.GA5459@htj.duckdns.org>
 <CA+55aFwEik1Q-D0d4pRTNq672RS2eHpT2ULzGfttaSWW69Tajw@mail.gmail.com>
 <3e8eeadb-8dde-2313-f6e3-ef7763832104@suse.cz>
 <20161128171907.GA14754@htj.duckdns.org>
 <20161129072507.GA31671@dhcp22.suse.cz>
 <20161129163807.GB19454@htj.duckdns.org>
 <d50f16b5-296f-9c30-b61a-288aaef49e7e@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d50f16b5-296f-9c30-b61a-288aaef49e7e@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Marc MERLIN <marc@merlins.org>

On Tue 29-11-16 17:57:08, Vlastimil Babka wrote:
> On 11/29/2016 05:38 PM, Tejun Heo wrote:
> > On Tue, Nov 29, 2016 at 08:25:07AM +0100, Michal Hocko wrote:
> > > --- a/include/linux/gfp.h
> > > +++ b/include/linux/gfp.h
> > > @@ -246,7 +246,7 @@ struct vm_area_struct;
> > >  #define GFP_ATOMIC	(__GFP_HIGH|__GFP_ATOMIC|__GFP_KSWAPD_RECLAIM)
> > >  #define GFP_KERNEL	(__GFP_RECLAIM | __GFP_IO | __GFP_FS)
> > >  #define GFP_KERNEL_ACCOUNT (GFP_KERNEL | __GFP_ACCOUNT)
> > > -#define GFP_NOWAIT	(__GFP_KSWAPD_RECLAIM)
> > > +#define GFP_NOWAIT	(__GFP_KSWAPD_RECLAIM|__GFP_NOWARN)
> > >  #define GFP_NOIO	(__GFP_RECLAIM)
> > >  #define GFP_NOFS	(__GFP_RECLAIM | __GFP_IO)
> > >  #define GFP_TEMPORARY	(__GFP_RECLAIM | __GFP_IO | __GFP_FS | \
> > > 
> > > this will not catch users who are doing gfp & ~__GFP_DIRECT_RECLAIM but
> > > I would rather not make warn_alloc() even more cluttered with checks.
> > 
> > Yeah, FWIW, looks good to me.
> 
> Me too. Just don't forget to update the comment describing GFP_NOWAIT and
> check the existing users if duplicite __GFP_NOWARN can be removed, and if
> they really want to be doing GFP_NOWAIT and not GFP_ATOMIC.

How does this look like?
---
