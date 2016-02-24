Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 460396B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 17:56:40 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id c10so21608849pfc.2
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 14:56:40 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id h89si7763160pfh.148.2016.02.24.14.56.38
        for <linux-mm@kvack.org>;
        Wed, 24 Feb 2016 14:56:39 -0800 (PST)
Date: Thu, 25 Feb 2016 09:56:23 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Message-ID: <20160224225623.GL14668@dastard>
References: <20160223095225.GB32294@infradead.org>
 <56CC686A.9040909@plexistor.com>
 <CAPcyv4gTaikkXCG1fPBVT-0DE8Wst3icriUH5cbQH3thuEe-ow@mail.gmail.com>
 <56CCD54C.3010600@plexistor.com>
 <CAPcyv4iqO=Pzu_r8tV6K2G953c5HqJRdqCE1pymfDmURy8_ODw@mail.gmail.com>
 <x49egc3c8gf.fsf@segfault.boston.devel.redhat.com>
 <CAPcyv4jUkMikW_x1EOTHXH4GC5DkPieL=sGd0-ajZqmG6C7DEg@mail.gmail.com>
 <x49a8mrc7rn.fsf@segfault.boston.devel.redhat.com>
 <CAPcyv4hMJ_+o2hYU7xnKEWUcKpcPVd66e2KChwL96Qxxk2R8iQ@mail.gmail.com>
 <x49a8mqgni5.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49a8mqgni5.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Boaz Harrosh <boaz@plexistor.com>, Christoph Hellwig <hch@infradead.org>, "Rudoff, Andy" <andy.rudoff@intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Feb 24, 2016 at 10:02:26AM -0500, Jeff Moyer wrote:
> Dan Williams <dan.j.williams@intel.com> writes:
> 
> >> I see.  So I think your argument is that new file systems (such as Nova)
> >> can have whacky new semantics, but existing file systems should provide
> >> the more conservative semantics that they have provided since the dawn
> >> of time (even if we add a new mmap flag to control the behavior).
> >>
> >> I don't agree with that.  :)
> >>
> >
> > Fair enough.  Recall, I was pushing MAP_DAX not to long ago.  It just
> > seems like a Sisyphean effort to push an mmap flag up the XFS hill and
> > maybe that effort is better spent somewhere else.
> 
> Given Dave's last response to Boaz, I see what you mean, and I also
> understand Dave's reasoning better, now.  FWIW, I never disagreed with
> spending effort elsewhere for now.  I did think that the mmap flag was
> on the horizon, though.  From Dave's comments, I think the prospects of
> that are slim to none.  That's fine, at least we have a definite
> direction.  Time to update all of the slide decks.  =)

Well, let me clarify what I said a bit here, because I feel like I'm
being unfairly blamed for putting data integrity as the highest
priority for DAX+pmem instead of falling in line and chanting
"Performance! Performance! Performance!" with everyone else.

Let me state this clearly: I'm not opposed to making optimisations
that change the way applications and the kernel interact. I like the
idea of MAP_SYNC, but I see this sort of API/behaviour change as a
last resort when all else fails, not a "first and only" optimisation
option.

The big issue we have right now is that we haven't made the DAX/pmem
infrastructure work correctly and reliably for general use.  Hence
adding new APIs to workaround cases where we haven't yet provided
correct behaviour, let alone optimised for performance is, quite
frankly, a clear case premature optimisation.

We need a solid foundation on which to build a fast, safe pmem
storage stack. Rushing to add checkbox performance requirements or
features to demonstrate "progress" leads us down the path of btrfs -
a code base that we are forever struggling with because the
foundation didn't solve known hard problems at an early stage of
developement (e.g. ENOSPC, single tree lock, using generic RAID and
device layers, etc). This results in a code base full of entrenched
deficiencies that are almost impossible to fix and I, personally, do
not want to end up with DAX being in a similar place.

Getting fsync to work with DAX is one of these "known hard problems"
that we really need to solve before we try to optimise for
performance. Once we have solid, workable infrastructure, we'll be
in a much better place to evaluate the merits of optimisations that
reduce or eliminate dirty tracking overhead that is required for
providing data integrity.

>From this perspective, I'd much prefer that we look to generic
mapping infrastructure optimisations before we look to one-off API
additions for systems running PMEM. Yes, it's harder to do, but the
end result of such an approach is that everyone benefits, not just
some proprietary application that almost nobody uses.

Indeed, it may be that we need to revist previous work like using an
rcu-aware btree for the mapping tree instead of a radix tree, as was
prototyped way back in ~2007 by Peter Zjilstra. If we can make
infrastructure changes that mostly remove the overhead of tracking
everything in the kernel, then we don't need to add special
userspace API changes to minimise the kernel tracking overhead.

Only if we can't bring the overhead of kernel-side dirty tracking
down to a reasonable overhead should we be considering a new API
that puts the responsibility on userspace for syncing data, and even
then we'll need to be very, very careful about it.

However, such discussions are a complete distraction to the problems
we need to solve right now. i.e. we need to focus on making DAX+pmem
work safely and reliably. Once we've done that, then we can focus on
performance optimisations and, perhaps, new interfaces to userspace.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
