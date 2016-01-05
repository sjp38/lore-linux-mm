Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8833C6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 10:26:08 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id f206so34372231wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 07:26:08 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id av1si152858028wjc.216.2016.01.05.07.26.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Jan 2016 07:26:07 -0800 (PST)
Date: Tue, 5 Jan 2016 15:26:02 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] free_pages stuff
Message-ID: <20160105152602.GR9938@ZenIV.linux.org.uk>
References: <20151221234615.GW20997@ZenIV.linux.org.uk>
 <CA+55aFwp4iy4rtX2gE2WjBGFL=NxMVnoFeHqYa2j1dYOMMGqxg@mail.gmail.com>
 <20151222010403.GX20997@ZenIV.linux.org.uk>
 <CA+55aFy9NrV_RnziN9z3p5O6rv1A0mirhLD0hL7Wrb77+YyBeg@mail.gmail.com>
 <20151222022226.GY20997@ZenIV.linux.org.uk>
 <CAMuHMdUGkVcUOH4VUXiuoa6eGVQEA+QRDEop3GrEOEWz8GeNig@mail.gmail.com>
 <20151222210435.GB20997@ZenIV.linux.org.uk>
 <20160105135903.GA15594@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160105135903.GA15594@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Jan 05, 2016 at 02:59:03PM +0100, Michal Hocko wrote:

> > 3) vmalloc() is for large allocations.  They will be page-aligned,
> > but *not* physically contiguous.  OTOH, large physically contiguous
> > allocations are generally a bad idea.  Unlike other allocators, there's
> > no variant that could be used in interrupt; freeing is possible there,
> > but allocation is not.  Note that non-blocking variant *does* exist -
> > __vmalloc(size, GFP_ATOMIC, PAGE_KERNEL) can be used in atomic
> > contexts; it's the interrupt ones that are no-go.

The last sentence I'd put into that part was complete crap...

> It is also hardcoded GFP_KERNEL context so a usage from NOFS context
> needs a special treatment.

... in part because of this.  GFP_ATOMIC __vmalloc() will be anything but,
and the only caller passing that is almost certainly bogus.  As for NOFS/NOIO,
I wonder if we should apply that special treatment inside __vmalloc_area_node
rather than in callers; see the current thread on linux-mm for details...

Another interesting issue is __GFP_HIGHMEM meaning for kmalloc and __vmalloc
resp. (should never be passed to kmalloc, should almost always be passed
to __vmalloc - the former needs pages mapped in kernel space, the latter
probably never needs a separate kernel alias for the data pages, to such
degree that I'm not sure if we shouldn't _force_ __GFP_HIGHMEM for data pages
allocation in __vmalloc_area_node())

> > 4) if it's very early in bootstrap, alloc_bootmem() and friends
> > may be the only option.  Rule of the thumb: if it's already printed
> > Memory: ...../..... available.....
> > you shouldn't be using that one.  Allocations are physically contiguous
> > and at that point large physically contiguous allocations are still OK.

Probably needs at least some discussion of memblock vs. bootmem APIs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
