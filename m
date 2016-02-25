Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 676776B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 16:21:09 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id hb3so22173818igb.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 13:21:09 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id 3si89661igr.80.2016.02.25.13.21.07
        for <linux-mm@kvack.org>;
        Thu, 25 Feb 2016 13:21:08 -0800 (PST)
Date: Fri, 26 Feb 2016 08:20:59 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Message-ID: <20160225212059.GB30721@dastard>
References: <CAPcyv4gTaikkXCG1fPBVT-0DE8Wst3icriUH5cbQH3thuEe-ow@mail.gmail.com>
 <56CCD54C.3010600@plexistor.com>
 <CAPcyv4iqO=Pzu_r8tV6K2G953c5HqJRdqCE1pymfDmURy8_ODw@mail.gmail.com>
 <x49egc3c8gf.fsf@segfault.boston.devel.redhat.com>
 <CAPcyv4jUkMikW_x1EOTHXH4GC5DkPieL=sGd0-ajZqmG6C7DEg@mail.gmail.com>
 <x49a8mrc7rn.fsf@segfault.boston.devel.redhat.com>
 <CAPcyv4hMJ_+o2hYU7xnKEWUcKpcPVd66e2KChwL96Qxxk2R8iQ@mail.gmail.com>
 <x49a8mqgni5.fsf@segfault.boston.devel.redhat.com>
 <20160224225623.GL14668@dastard>
 <x49y4a8iwpy.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49y4a8iwpy.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Boaz Harrosh <boaz@plexistor.com>, Christoph Hellwig <hch@infradead.org>, "Rudoff, Andy" <andy.rudoff@intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Feb 25, 2016 at 11:24:57AM -0500, Jeff Moyer wrote:
> Hi, Dave,
> 
> Dave Chinner <david@fromorbit.com> writes:
> 
> > Well, let me clarify what I said a bit here, because I feel like I'm
> > being unfairly blamed for putting data integrity as the highest
> > priority for DAX+pmem instead of falling in line and chanting
> > "Performance! Performance! Performance!" with everyone else.
> 
> It's totally fair.  ;-)
> 
> > Let me state this clearly: I'm not opposed to making optimisations
> > that change the way applications and the kernel interact. I like the
> > idea of MAP_SYNC, but I see this sort of API/behaviour change as a
> > last resort when all else fails, not a "first and only" optimisation
> > option.
> 
> So, calling it "first and only" seems a bit unfair on your part.

Maybe so, but it's a valid observation - it's being pushed as a way
of avoidning needing to make the kernel code work correctly and
fast. i.e. the argument is "new, unoptimised code is too slow, so we
want a knob to avoid it completely".

Boaz keeps saying that we can make the kernel code faster, but he's
still pushing to enable bypassing that code rather than sending
patches to make the kernel pmem infrastructure faster.  Such
bypasses lead to the situation that the kernel code isn't used by
the applications that could benefit from optimisation and
improvement of the kernel code because they don't use it anymore.
This is what I meant as "first and only" kernel optimisation.

> I
> don't think anyone asking for a MAP_SYNC option doesn't also want other
> applications to work well.  That aside, this is where your opinion
> differs from mine: I don't see MAP_SYNC as a last resort option.  And
> let me be clear, this /is/ an opinion.  I have no hard facts to back it
> up, precisely because we don't have any application we can use for a
> comparison.

Right, we have no numbers, and we don't yet have an optimised kernel
side implementation to compare against. Until we have the ability to
compare apples with apples, we should be pushing back against API
changes that are based on oranges being tastier than apples.

> But, it seems plausible to me that no matter how well you
> optimize your msync implementation, it will still be more expensive than
> an application that doesn't call msync at all.  This obviously depends
> on how the application is using the programming model, among other
> things.  I agree that we would need real data to back this up.  However,
> I don't see any reason to preclude such an implementation, or to leave
> it as a last resort.  I think it should be part of our planning process
> if it's reasonably feasible.

Essentially I see this situation/request as conceptually the same as
O_DIRECT for read/write - O_DIRECT bypasses the kernel dirty range
tracking and, as such, has nasty cache coherency issues when you mix
it with buffered IO. Nor does it play well with mmap, it has
different semantics for every filesystem and the kernel code has
been optimised to the point of fragility.

And, of course, O_DIRECT requires applications to do exactly the
right things to extract performance gains and maintain data
integrity. If they get it right, they will be faster than using the
page cache, but we know that applications often get it very wrong.
And even when they get it right, data corruption can still occur
because some thrid party accessed file in a different manner (e.g. a
backup) and triggered one of the known, fundamentally unfixable
coherency problems.

However, despite the fact we are stuck with O_DIRECT and it's
deranged monkeys (which I am one of), we should not be ignoring the
problems that bypassing the kernel infrastructure has caused us and
continues to cause us. As such, we really need to think hard about
whether we should be repeating the development of such a bypass
feature. If we do, we stand a very good chance of ending up in the
same place - a bunch of code that does not play well with others,
and a nightmare to test because it's expected to work and not
corrupt data...

We should try very hard not to repeat the biggest mistake O_DIRECT
made: we need to define and document exactly what behaviour we
guarantee, how it works and exaclty what responsisbilities the
kernel and userspace have in *great detail* /before/ we add the
mechanism to the kernel.

Think it through carefully - API changes and semantics are forever.
We don't want to add something that in a couple of years we are
wishing we never added....

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
