Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 717D36B06D2
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 05:22:39 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id m45-v6so950593edc.2
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 02:22:39 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jr1-v6si525783ejb.232.2018.11.09.02.22.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 02:22:38 -0800 (PST)
Date: Fri, 9 Nov 2018 11:22:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: UBSAN: Undefined behaviour in mm/page_alloc.c
Message-ID: <20181109102235.GD5321@dhcp22.suse.cz>
References: <CAEAjamseRRHu+TaTkd1TwpLNm8mtDGP=2K0WKLF0wH-3iLcW_w@mail.gmail.com>
 <20181109084353.GA5321@dhcp22.suse.cz>
 <b51aae15-eb5d-47f0-1222-bfc1ef21e06c@I-love.SAKURA.ne.jp>
 <20181109095604.GC5321@dhcp22.suse.cz>
 <d8757554-45f4-1240-dc8a-0f918ae0e5f3@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d8757554-45f4-1240-dc8a-0f918ae0e5f3@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Kyungtae Kim <kt0755@gmail.com>, akpm@linux-foundation.org, pavel.tatashin@microsoft.com, osalvador@suse.de, rppt@linux.vnet.ibm.com, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, alexander.h.duyck@linux.intel.com, mgorman@techsingularity.net, lifeasageek@gmail.com, threeearcat@gmail.com, syzkaller@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On Fri 09-11-18 11:10:00, Vlastimil Babka wrote:
> On 11/9/18 10:56 AM, Michal Hocko wrote:
> > On Fri 09-11-18 18:41:53, Tetsuo Handa wrote:
> >> On 2018/11/09 17:43, Michal Hocko wrote:
> >>> @@ -4364,6 +4353,17 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
> >>>  	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
> >>>  	struct alloc_context ac = { };
> >>>  
> >>> +	/*
> >>> +	 * In the slowpath, we sanity check order to avoid ever trying to
> >>
> >> Please keep the comment up to dated.
> > 
> > Does this following look better?
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 9fc10a1029cf..bf9aecba4222 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -4354,10 +4354,8 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
> >  	struct alloc_context ac = { };
> >  
> >  	/*
> > -	 * In the slowpath, we sanity check order to avoid ever trying to
> > -	 * reclaim >= MAX_ORDER areas which will never succeed. Callers may
> > -	 * be using allocators in order of preference for an area that is
> > -	 * too large.
> > +	 * There are several places where we assume that the order value is sane
> > +	 * so bail out early if the request is out of bound.
> >  	 */
> >  	if (order >= MAX_ORDER) {
> >  		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
> 
> Looks ok, but I'd add unlikely(), although it doesn't currently seem to
> make any difference.
> 
> You can add Acked-by: Vlastimil Babka <vbabka@suse.cz>

OK, I have added both. Thanks!

-- 
Michal Hocko
SUSE Labs
