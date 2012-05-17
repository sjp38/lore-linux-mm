Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 9109F6B0083
	for <linux-mm@kvack.org>; Thu, 17 May 2012 10:07:35 -0400 (EDT)
Date: Thu, 17 May 2012 09:07:32 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] SL[AUO]B common code 5/9] slabs: Common definition for
 boot state of the slab allocators
In-Reply-To: <4FB4C71C.6040906@parallels.com>
Message-ID: <alpine.DEB.2.00.1205170905350.5144@router.home>
References: <20120514201544.334122849@linux.com> <20120514201611.710540961@linux.com> <4FB36318.30600@parallels.com> <alpine.DEB.2.00.1205160928490.25603@router.home> <4FB4C71C.6040906@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

On Thu, 17 May 2012, Glauber Costa wrote:

> On 05/16/2012 06:31 PM, Christoph Lameter wrote:
> > > There are a couple of places where that test seems to be okay (I remember
> > > 1 in
> > > >  the slub), but at least for the "FULL" test here, we should be
> > > testing>=
> > > >  FULL.
> > > >
> > > >  Also, I don't like the name FULL too much, since I do intend to add a
> > > new one
> > > >  soon (MEMCG, as you can see in my series)
> > Ok. Why would memcg need an additional state?
>
> Please refer to my patchset for the full story.
> I add state both to the slab and to the slub for that.
>
> But in summary, it is not unlike the "SYSFS" state: we depend on something
> else outside of the slab domain to be ready before we can proceed.
>
> Specifically, we need to register each cache with an index. And for that, we
> use idr/ida. When it is ready, we run code to register indexes for all caches
> that are already available. After that, we just grab an index right away -
> much like sysfs state for aliases.

Why can this processing not be done when sysfs has just been initialized?

> > > >  Since we are using slab-specific states like PARTIAL_L3 here, maybe we
> > > can use
> > > >  slub's like SYSFS here with no problem.
> > Sure. I thought there would only be special states before UP.
> >
> > > >  If we stick to>= and<= whenever needed, that should reflect a lot
> > > better
> > > >  what the algorithm is really doing
> > How so?
>
> In the sense that we very rarely want to do some action *at a specific
> moment*. Most of the time we want to separate the world into before and after
> a state. We test == instead of <= and >=, and it happens to work because of
> the specific order of things, which are subject to change in a rework or
> another...

The reason to use == is because we want things to happen only at a
particular stage of things. The == SYSFS means we will only do an action
if the slab system is fully functional. Such things will have to be
reevaluated if the number of states change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
