Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 385EE5F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 09:30:52 -0400 (EDT)
Date: Wed, 8 Apr 2009 08:31:15 -0500
From: Russ Anderson <rja@sgi.com>
Subject: Re: [PATCH 1/2] Avoid putting a bad page back on the LRU
Message-ID: <20090408133115.GB11041@sgi.com>
Reply-To: Russ Anderson <rja@sgi.com>
References: <20090408001133.GB27170@sgi.com> <200904080543.16454.ioe-lkml@rameria.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200904080543.16454.ioe-lkml@rameria.de>
Sender: owner-linux-mm@kvack.org
To: Ingo Oeser <ioe-lkml@rameria.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Andi Kleen <andi@firstfloor.org>, rja@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, Apr 08, 2009 at 05:43:15AM +0200, Ingo Oeser wrote:
> Hi Russ,
> 
> On Wednesday 08 April 2009, Russ Anderson wrote:
> > --- linux-next.orig/mm/migrate.c	2009-04-07 18:32:12.781949840 -0500
> > +++ linux-next/mm/migrate.c	2009-04-07 18:34:19.169736260 -0500
> > @@ -693,6 +696,26 @@ unlock:
> >   		 * restored.
> >   		 */
> >   		list_del(&page->lru);
> > +#ifdef CONFIG_MEMORY_FAILURE
> > +		if (PagePoison(page)) {
> > +			if (rc == 0)
> > +				/*
> > +				 * A page with a memory error that has
> > +				 * been migrated will not be moved to
> > +				 * the LRU.
> > +				 */
> > +				goto move_newpage;
> > +			else
> > +				/*
> > +				 * The page failed to migrate and will not
> > +				 * be added to the bad page list.  Clearing
> > +				 * the error bit will allow another attempt
> > +				 * to migrate if it gets another correctable
> > +				 * error.
> > +				 */
> > +				ClearPagePoison(page);
> 
> Clearing the flag doesn't change the fact, that this page is representing 
> permanently bad RAM.

Yes, but this is intended for corrected memory errors (meaning there is
an underlying RAM error, but has not reached the point of losing data).

After talking with Andi, it is clear the intent of the Poison flag
(uncorrectable memory error) is different from my intent (corrected
memory error).  I'll go back to using a different page flag to avoid
confusing the two issues.
 
> What about removing it from the LRU and adding it to a bad RAM list in every case?

That is what happens when the page migrates (the normal case).  The else case 
s when the page could not be migrated.  My intent was to wait for the next
corrected error on that page and try migrating again.

> After hot swapping the physical RAM banks it could be moved back, not before.

As soon as the code is written.  :-)

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
