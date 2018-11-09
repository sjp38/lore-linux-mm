Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A79D36B06E2
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 05:53:00 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id n22-v6so1209481pff.2
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 02:53:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 92-v6sor8367104pli.10.2018.11.09.02.52.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 02:52:59 -0800 (PST)
Date: Fri, 9 Nov 2018 21:52:55 +1100
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: UBSAN: Undefined behaviour in mm/page_alloc.c
Message-ID: <20181109105255.GF9042@350D>
References: <CAEAjamseRRHu+TaTkd1TwpLNm8mtDGP=2K0WKLF0wH-3iLcW_w@mail.gmail.com>
 <20181109084353.GA5321@dhcp22.suse.cz>
 <b51aae15-eb5d-47f0-1222-bfc1ef21e06c@I-love.SAKURA.ne.jp>
 <20181109095604.GC5321@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181109095604.GC5321@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Kyungtae Kim <kt0755@gmail.com>, akpm@linux-foundation.org, pavel.tatashin@microsoft.com, vbabka@suse.cz, osalvador@suse.de, rppt@linux.vnet.ibm.com, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, alexander.h.duyck@linux.intel.com, mgorman@techsingularity.net, lifeasageek@gmail.com, threeearcat@gmail.com, syzkaller@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On Fri, Nov 09, 2018 at 10:56:04AM +0100, Michal Hocko wrote:
> On Fri 09-11-18 18:41:53, Tetsuo Handa wrote:
> > On 2018/11/09 17:43, Michal Hocko wrote:
> > > @@ -4364,6 +4353,17 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
> > >  	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
> > >  	struct alloc_context ac = { };
> > >  
> > > +	/*
> > > +	 * In the slowpath, we sanity check order to avoid ever trying to
> > 
> > Please keep the comment up to dated.
> 
> Does this following look better?
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9fc10a1029cf..bf9aecba4222 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4354,10 +4354,8 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
>  	struct alloc_context ac = { };
>  
>  	/*
> -	 * In the slowpath, we sanity check order to avoid ever trying to
> -	 * reclaim >= MAX_ORDER areas which will never succeed. Callers may
> -	 * be using allocators in order of preference for an area that is
> -	 * too large.
> +	 * There are several places where we assume that the order value is sane
> +	 * so bail out early if the request is out of bound.
>  	 */
>  	if (order >= MAX_ORDER) {
>  		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));

if (unlikely()) might help

> 
> > I don't like that comments in OOM code is outdated.
> > 
> > > +	 * reclaim >= MAX_ORDER areas which will never succeed. Callers may
> > > +	 * be using allocators in order of preference for an area that is
> > > +	 * too large.
> > > +	 */
> > > +	if (order >= MAX_ORDER) {
> > 
> > Also, why not to add BUG_ON(gfp_mask & __GFP_NOFAIL); here?
> 
> Because we do not want to blow up the kernel just because of a stupid
> usage of the allocator. Can you think of an example where it would
> actually make any sense?
> 
> I would argue that such a theoretical abuse would blow up on an
> unchecked NULL ptr access. Isn't that enough?
> -- 

Balbir Singh.
