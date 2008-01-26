Date: Sat, 26 Jan 2008 05:56:39 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 1/4] mmu_notifier: Core code
Message-ID: <20080126115639.GQ26420@sgi.com>
References: <20080125055606.102986685@sgi.com> <20080125055801.212744875@sgi.com> <20080125183934.GO26420@sgi.com> <Pine.LNX.4.64.0801251041040.672@schroedinger.engr.sgi.com> <20080125185646.GQ3058@sgi.com> <Pine.LNX.4.64.0801251058170.3198@schroedinger.engr.sgi.com> <20080125193554.GP26420@sgi.com> <Pine.LNX.4.64.0801251206390.7856@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801251206390.7856@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

> > > 1. invalidate_all()
> > 
> > That will be fine as long as we can unregister the ops notifier and free
> > the structure.  Otherwise, we end up being called needlessly.
> 
> No you cannot do that because there are still callbacks that come later. 
> The invalidate_all may lead to invalidate_range() doing nothing for this 
> mm. The ops notifier and the freeing of the structure has to wait until 
> release().

Could you be a little more clear here?  If you are saying that the other
callbacks will need to do work?  I can assure you we will clean up those
pages and raise memory protections.  It will also be done in a much more
efficient fashion than the individual callouts.

If, on the other hand, you are saying we can not because of the way
we traverse the list, can we return a result indicating to the caller
we would like to be unregistered and then the mmu_notifier code do the
remove followed by a call to the release notifier?

> 
> > > 2. invalidate_range() for each vma
> > > 
> > > 3. release()
> > > 
> > > We cannot simply move the call up because there will be future range 
> > > callbacks on vma invalidation.
> > 
> > I am not sure what this means.  Right now, if you were to notify XPMEM
> > the process is exiting, we would take care of all the recalling of pages
> > exported by this process, clearing those pages cache lines from cache,
> > and raising memory protections.  I would assume that moving the callout
> > earlier would expect the same of every driver.
> 
> That does not sync with the current scheme of the invalidate_range() 
> hooks. We would have to do a global invalidate early and then place the 
> other invalidate_range hooks in such a way that none is called in later in 
> process exit handling.

But if the notifier is removed from the list following the invalidate_all
callout, there would be no additional callouts.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
