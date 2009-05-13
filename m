Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 40F186B012D
	for <linux-mm@kvack.org>; Wed, 13 May 2009 17:17:09 -0400 (EDT)
Date: Wed, 13 May 2009 14:16:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/6] PM/Hibernate: Rework shrinking of memory
Message-Id: <20090513141647.076b67f0.akpm@linux-foundation.org>
In-Reply-To: <200905132255.04681.rjw@sisk.pl>
References: <200905070040.08561.rjw@sisk.pl>
	<200905131039.26778.rjw@sisk.pl>
	<20090513123409.302f4307.akpm@linux-foundation.org>
	<200905132255.04681.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-pm@lists.linux-foundation.org, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, pavel@ucw.cz, nigel@tuxonice.net, rientjes@google.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 May 2009 22:55:03 +0200
"Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> On Wednesday 13 May 2009, Andrew Morton wrote:
> > On Wed, 13 May 2009 10:39:25 +0200
> > "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> > 
> > > From: Rafael J. Wysocki <rjw@sisk.pl>
> > > 
> > > Rework swsusp_shrink_memory() so that it calls shrink_all_memory()
> > > just once to make some room for the image and then allocates memory
> > > to apply more pressure to the memory management subsystem, if
> > > necessary.
> > > 
> > > Unfortunately, we don't seem to be able to drop shrink_all_memory()
> > > entirely just yet, because that would lead to huge performance
> > > regressions in some test cases.
> > > 
> > 
> > Isn't this a somewhat large problem?
> 
> Yes, it is.  The thing is 8 times slower (15 s vs 2 s) without the
> shrink_all_memory() in at least one test case.  100% reproducible.

erk.  Any ideas why?  A quick peek at a kernel profile and perhaps
the before-and-after delta in the /proc/vmstat numbers would probably
guide us there.

> > The main point (I thought) was to remove shrink_all_memory().  Instead,
> > we're retaining it and adding even more stuff?
> 
> The idea is that afterwards we can drop shrink_all_memory() once the
> performance problem has been resolved.  Also, we now allocate memory for the
> image using GFP_KERNEL instead of doing it with GFP_ATOMIC after freezing
> devices.  I'd think that's an improvement?

Dunno.  GFP_KERNEL might attempt to do writeback/swapout/etc, which
could be embarrassing if the devices are frozen.  GFP_NOIO sounds
appropriate.  

> > > +{
> > > +	unsigned long ratio = (numerator << FRACTION_SHIFT) / denominator;
> > >  
> > > -#define SHRINK_BITE	10000
> > > -static inline unsigned long __shrink_memory(long tmp)
> > > +	x *= ratio;
> > > +	return x >> FRACTION_SHIFT;
> > > +}
> > 
> > Strange function.  Would it not be simpler/clearer to do it with 64-bit
> > scalars, multiplication and do_div()?
> 
> Sure, I can do it this way too.  Is it fine to use u64 for this purpose?

I suppose so.  All/most of the implementations of do_div() are done as
macros so it's pretty hard to work out what the types are.  But
do_div() does expect a u64 rather than `unsigned long long'.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
