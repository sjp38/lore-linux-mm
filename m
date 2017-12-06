Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5DE0D6B03A1
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 04:27:34 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q186so2223623pga.23
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 01:27:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e17si1747978pfd.398.2017.12.06.01.27.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Dec 2017 01:27:28 -0800 (PST)
Date: Wed, 6 Dec 2017 10:27:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: introduce MAP_FIXED_SAFE
Message-ID: <20171206092724.GH16386@dhcp22.suse.cz>
References: <20171129144219.22867-1-mhocko@kernel.org>
 <20171129144219.22867-2-mhocko@kernel.org>
 <87tvx4e8sz.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87tvx4e8sz.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-api@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>

On Wed 06-12-17 16:15:24, Michael Ellerman wrote:
> Hi Michal,
> 
> Some comments below.
> 
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > From: Michal Hocko <mhocko@suse.com>
> >
> > MAP_FIXED is used quite often to enforce mapping at the particular
> > range. The main problem of this flag is, however, that it is inherently
> > dangerous because it unmaps existing mappings covered by the requested
> > range. This can cause silent memory corruptions. Some of them even with
> > serious security implications. While the current semantic might be
> > really desiderable in many cases there are others which would want to
> > enforce the given range but rather see a failure than a silent memory
> > corruption on a clashing range. Please note that there is no guarantee
> > that a given range is obeyed by the mmap even when it is free - e.g.
> > arch specific code is allowed to apply an alignment.
> 
> I don't think this last sentence is correct. Or maybe I don't understand
> what you're referring to.
> 
> If you specifiy MAP_FIXED on a page boundary then the mapping must be
> made at that address, I don't think arch code is allowed to add any
> extra alignment.

The last sentence doesn't talk about MAP_FIXED. It talks about a hint
based mmap without MAP_FIXED ("there are others which would want to
enforce the given range but rather see a failure").
 
[...]
> > diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
> > index 6bf730063e3f..ef3770262925 100644
> > --- a/arch/alpha/include/uapi/asm/mman.h
> > +++ b/arch/alpha/include/uapi/asm/mman.h
> > @@ -32,6 +32,8 @@
> >  #define MAP_STACK	0x80000		/* give out an address that is best suited for process/thread stacks */
> >  #define MAP_HUGETLB	0x100000	/* create a huge page mapping */
> >  
> > +#define MAP_FIXED_SAFE	0x200000	/* MAP_FIXED which doesn't unmap underlying mapping */
> > +
> 
> Why the new line before MAP_FIXED_SAFE? It should sit with the others.

will remove the empty line

> You're using a different value to other arches here, but that's OK, and
> alpha doesn't use asm-generic/mman.h or mman-common.h
> 
> > diff --git a/arch/powerpc/include/uapi/asm/mman.h b/arch/powerpc/include/uapi/asm/mman.h
> > index e63bc37e33af..3ffd284e7160 100644
> > --- a/arch/powerpc/include/uapi/asm/mman.h
> > +++ b/arch/powerpc/include/uapi/asm/mman.h
> > @@ -29,5 +29,6 @@
> >  #define MAP_NONBLOCK	0x10000		/* do not block on IO */
> >  #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
> >  #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
> > +#define MAP_FIXED_SAFE	0x800000	/* MAP_FIXED which doesn't unmap underlying mapping */
> 
> Why did you pick 0x800000?
> 
> I don't see any reason you can't use 0x8000 on powerpc.

Copy&paste I guess, will update it.

[...]

> >  #ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
> >  # define MAP_UNINITIALIZED 0x4000000	/* For anonymous mmap, memory could be
> >  					 * uninitialized */
> > @@ -63,6 +64,7 @@
> >  # define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
> >  #endif
> >  
> > +
> 
> Stray new line.

will remove

> >  /*
> >   * Flags for msync
> >   */
> > diff --git a/include/uapi/asm-generic/mman.h b/include/uapi/asm-generic/mman.h
> > index 2dffcbf705b3..56cde132a80a 100644
> > --- a/include/uapi/asm-generic/mman.h
> > +++ b/include/uapi/asm-generic/mman.h
> > @@ -13,6 +13,7 @@
> >  #define MAP_NONBLOCK	0x10000		/* do not block on IO */
> >  #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
> >  #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
> > +#define MAP_FIXED_SAFE	0x80000		/* MAP_FIXED which doesn't unmap underlying mapping */
> 
> So I think I proved above that all the arches that are using 0x80000 are
> also using mman-common.h, and vice-versa.
> 
> So you can put this in mman-common.h can't you?

Yes it seems I can. I would have to double check. It is true that
defining the new flag closer to MAP_FIXED makes some sense

[...]
> So it would be more accurate to say something like:
> 
> 	/*
> 	 * Internal to the kernel MAP_FIXED_SAFE is a superset of
> 	 * MAP_FIXED, so set MAP_FIXED in flags if MAP_FIXED_SAFE was
> 	 * set by the caller. This avoids all the arch code having to
> 	 * check for MAP_FIXED and MAP_FIXED_SAFE.
> 	 */
> 	if (flags & MAP_FIXED_SAFE)
> 		flags |= MAP_FIXED;

OK, I will use this wording.

Thanks for your review! Finally something that doesn't try to beat the
name to death ;)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
