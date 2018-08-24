Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 661696B2E88
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 03:49:05 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k16-v6so361851ede.6
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 00:49:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x22-v6si156289edr.318.2018.08.24.00.49.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 00:49:04 -0700 (PDT)
Date: Fri, 24 Aug 2018 09:49:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] xen/gntdev: fix up blockable calls to mn_invl_range_start
Message-ID: <20180824074902.GY29735@dhcp22.suse.cz>
References: <20180823120707.10998-1-mhocko@kernel.org>
 <07c7ead4-334d-9b25-f588-25e9b46bbea0@i-love.sakura.ne.jp>
 <20180823135151.GM29735@dhcp22.suse.cz>
 <9d2d11eb-7fe1-b836-056c-7886d6fc56e5@oracle.com>
 <20180823190933.GP29735@dhcp22.suse.cz>
 <2afe2559-78ad-2d5b-41aa-1988f941759b@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2afe2559-78ad-2d5b-41aa-1988f941759b@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, xen-devel@lists.xenproject.org, LKML <linux-kernel@vger.kernel.org>

On Fri 24-08-18 07:03:28, Juergen Gross wrote:
> On 23/08/18 21:09, Michal Hocko wrote:
> > On Thu 23-08-18 10:06:53, Boris Ostrovsky wrote:
> >> On 08/23/2018 09:51 AM, Michal Hocko wrote:
> >>> On Thu 23-08-18 22:44:07, Tetsuo Handa wrote:
> >>>> On 2018/08/23 21:07, Michal Hocko wrote:
> >>>>> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> >>>>> index 57390c7666e5..e7d8bb1bee2a 100644
> >>>>> --- a/drivers/xen/gntdev.c
> >>>>> +++ b/drivers/xen/gntdev.c
> >>>>> @@ -519,21 +519,20 @@ static int mn_invl_range_start(struct mmu_notifier *mn,
> >>>>>  	struct gntdev_grant_map *map;
> >>>>>  	int ret = 0;
> >>>>>  
> >>>>> -	/* TODO do we really need a mutex here? */
> >>>>>  	if (blockable)
> >>>>>  		mutex_lock(&priv->lock);
> >>>>>  	else if (!mutex_trylock(&priv->lock))
> >>>>>  		return -EAGAIN;
> >>>>>  
> >>>>>  	list_for_each_entry(map, &priv->maps, next) {
> >>>>> -		if (in_range(map, start, end)) {
> >>>>> +		if (!blockable && in_range(map, start, end)) {
> >>>> This still looks strange. Prior to 93065ac753e4, in_range() test was
> >>>> inside unmap_if_in_range(). But this patch removes in_range() test
> >>>> if blockable == true. That is, unmap_if_in_range() will unconditionally
> >>>> unmap if blockable == true, which seems to be an unexpected change.
> >>> You are right. I completely forgot I've removed in_range there. Does
> >>> this look any better?
> >>>
> >>> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> >>> index e7d8bb1bee2a..30f81004ea63 100644
> >>> --- a/drivers/xen/gntdev.c
> >>> +++ b/drivers/xen/gntdev.c
> >>> @@ -525,14 +525,20 @@ static int mn_invl_range_start(struct mmu_notifier *mn,
> >>>  		return -EAGAIN;
> >>>  
> >>>  	list_for_each_entry(map, &priv->maps, next) {
> >>> -		if (!blockable && in_range(map, start, end)) {
> >>> +		if (in_range(map, start, end)) {
> >>> +			if (blockable)
> >>> +				continue;
> >>> +
> >>>  			ret = -EAGAIN;
> >>>  			goto out_unlock;
> >>>  		}
> >>>  		unmap_if_in_range(map, start, end);
> >>
> >>
> >> (I obviously missed that too with my R-b).
> >>
> >> This will never get anything done either. How about
> > 
> > Yeah. I was half way out and posted a complete garbage. Sorry about
> > that!
> > 
> > Michal repeat after me
> > Never post patches when in hurry! Never post patches when in hurry!
> > Never post patches when in hurry! Never post patches when in hurry!
> > Never post patches when in hurry! Never post patches when in hurry!
> > Never post patches when in hurry! Never post patches when in hurry!
> > Never post patches when in hurry! Never post patches when in hurry! 
> > 
> > What I really meant was this
> > 
> > diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> > index e7d8bb1bee2a..6fcc5a44f29d 100644
> > --- a/drivers/xen/gntdev.c
> > +++ b/drivers/xen/gntdev.c
> > @@ -525,17 +525,25 @@ static int mn_invl_range_start(struct mmu_notifier *mn,
> >  		return -EAGAIN;
> >  
> >  	list_for_each_entry(map, &priv->maps, next) {
> > -		if (!blockable && in_range(map, start, end)) {
> > +		if (!in_range(map, start, end))
> > +			continue;
> > +
> > +		if (!blockable) {
> >  			ret = -EAGAIN;
> >  			goto out_unlock;
> >  		}
> > +
> >  		unmap_if_in_range(map, start, end);
> >  	}
> >  	list_for_each_entry(map, &priv->freeable_maps, next) {
> > -		if (!blockable && in_range(map, start, end)) {
> > +		if (!in_range(map, start, end))
> > +			continue;
> > +
> > +		if (!blockable) {
> >  			ret = -EAGAIN;
> >  			goto out_unlock;
> >  		}
> > +
> >  		unmap_if_in_range(map, start, end);
> >  	}
> >  
> > 
> 
> I liked the general structure before 93065ac753e4 better.
> 
> Why don't you return to that, add blockable parameter to
> unmap_if_in_range() and let unmap_if_in_range() return a value (0 or
> -EAGAIN)? This will avoid repeating the very same code.

I can do that if that is your preference of course. I have even
considered that but then I have got to this...

> @@ -508,6 +504,8 @@ static void unmap_if_in_range(struct
> gntdev_grant_map *map,
>                                 (mstart - map->vma->vm_start) >> PAGE_SHIFT,
>                                 (mend - mstart) >> PAGE_SHIFT);
>         WARN_ON(err);
> +
> +       return 0;
>  }

and I really didn't know what to do about that. On one hand the error
has been ignored already, on the other hand it is just too ugly to
ignore it when we do provide a return value. Moreover I can see how
somebody would like to clean that up later and I am not sure what are we
going to do about it in callers.

But by all means, I will go the way you maintainers prefer.
-- 
Michal Hocko
SUSE Labs
