Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 950606B0038
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 04:02:41 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id z14so1439993wrb.12
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 01:02:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l63si1086101edl.104.2017.11.20.01.02.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Nov 2017 01:02:40 -0800 (PST)
Date: Mon, 20 Nov 2017 10:02:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm: introduce MAP_FIXED_SAFE
Message-ID: <20171120090239.zsm5jmgn6bvo62kg@dhcp22.suse.cz>
References: <20171116101900.13621-1-mhocko@kernel.org>
 <20171116101900.13621-2-mhocko@kernel.org>
 <be5c9478-3e03-9a1d-525c-31c904b667d8@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <be5c9478-3e03-9a1d-525c-31c904b667d8@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-api@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org

On Fri 17-11-17 00:37:18, John Hubbard wrote:
> On 11/16/2017 02:18 AM, Michal Hocko wrote:
[...]
> > diff --git a/arch/powerpc/include/uapi/asm/mman.h b/arch/powerpc/include/uapi/asm/mman.h
> > index 03c06ba7464f..d97342ca25b1 100644
> > --- a/arch/powerpc/include/uapi/asm/mman.h
> > +++ b/arch/powerpc/include/uapi/asm/mman.h
> > @@ -28,5 +28,6 @@
> >  #define MAP_NONBLOCK	0x10000		/* do not block on IO */
> >  #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
> >  #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
> > +#define MAP_FIXED_SAFE	0x800000	/* MAP_FIXED which doesn't unmap underlying mapping */
>  
> 
> Hi Michal,
> 
> 1. The powerpc change, above, has one too many zeroes. It should be 0x80000, 
> not 0x800000.

OK, I will fix it. It shouldn't matter much, because we only care about
non-clashing address but I agree that we should consume them from bottom
bits.

> 2. For the one-line comments, if you phrase them like this:
> 
> /* Like MAP_FIXED, except that it doesn't unmap pre-existing mappings */
> 
> ...I think that would be a little clearer.

I do not have any strong preference here.
[...]
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index 680506faceae..89af0b5839a5 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -1342,6 +1342,10 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
> >  		if (!(file && path_noexec(&file->f_path)))
> >  			prot |= PROT_EXEC;
> >  
> > +	/* force arch specific MAP_FIXED handling in get_unmapped_area */
> > +	if (flags & MAP_FIXED_SAFE)
> > +		flags |= MAP_FIXED;
> 
> Hooking in at this point is a nice way to solve the problem. :)
> 
> For the naming and implementation, I see a couple of things that might improve
> it slightly:
> 
> a) Change MAP_FIXED_SAFE to MAP_NO_CLOBBER (as per Kees' idea), but keep the
> new flag independent, by omitting the above two lines. Instead of forcing
> MAP_FIXED as a result of the new flag, you could simply fail to take any action
> on MAP_NO_CLOBBER *unless* MAP_FIXED is set.
> 
> This is a bit easier to explain and reason about, as compared to a flag that
> auto-sets another flag. I like this approach best.

As I've exaplained in other email I do not think we can make this a
modifier.
 
>   or
> 
> b) Change MAP_FIXED_SAFE to MAP_FIXED_NO_CLOBBER (also a variation on Kees' name
> idea, but a little longer, a bit uglier, and clearer), and leave the implementation
> the same.

I do not have a _strong_ preference on the name itself. But I think that
_SAFE reflects the behavior slightly better because _NO_CLOBBER is not
very specific _when_ and _what_ we do not clobber while _SAFE is clear
on that it doesn't perform any unsafe operations.

But if the majority think that _NO_CLOBBER is better i will change it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
