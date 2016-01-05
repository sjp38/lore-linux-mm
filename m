Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1EBA86B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 10:42:11 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id z14so10492183igp.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 07:42:11 -0800 (PST)
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com. [209.85.223.172])
        by mx.google.com with ESMTPS id k9si6580603igx.61.2016.01.05.07.42.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 07:42:10 -0800 (PST)
Received: by mail-io0-f172.google.com with SMTP id 77so159343736ioc.2
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 07:42:10 -0800 (PST)
Date: Tue, 5 Jan 2016 16:42:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] free_pages stuff
Message-ID: <20160105154207.GF15324@dhcp22.suse.cz>
References: <20151221234615.GW20997@ZenIV.linux.org.uk>
 <CA+55aFwp4iy4rtX2gE2WjBGFL=NxMVnoFeHqYa2j1dYOMMGqxg@mail.gmail.com>
 <20151222010403.GX20997@ZenIV.linux.org.uk>
 <CA+55aFy9NrV_RnziN9z3p5O6rv1A0mirhLD0hL7Wrb77+YyBeg@mail.gmail.com>
 <20151222022226.GY20997@ZenIV.linux.org.uk>
 <CAMuHMdUGkVcUOH4VUXiuoa6eGVQEA+QRDEop3GrEOEWz8GeNig@mail.gmail.com>
 <20151222210435.GB20997@ZenIV.linux.org.uk>
 <20160105135903.GA15594@dhcp22.suse.cz>
 <20160105152602.GR9938@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160105152602.GR9938@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue 05-01-16 15:26:02, Al Viro wrote:
> On Tue, Jan 05, 2016 at 02:59:03PM +0100, Michal Hocko wrote:
> 
> > > 3) vmalloc() is for large allocations.  They will be page-aligned,
> > > but *not* physically contiguous.  OTOH, large physically contiguous
> > > allocations are generally a bad idea.  Unlike other allocators, there's
> > > no variant that could be used in interrupt; freeing is possible there,
> > > but allocation is not.  Note that non-blocking variant *does* exist -
> > > __vmalloc(size, GFP_ATOMIC, PAGE_KERNEL) can be used in atomic
> > > contexts; it's the interrupt ones that are no-go.
> 
> The last sentence I'd put into that part was complete crap...
> 
> > It is also hardcoded GFP_KERNEL context so a usage from NOFS context
> > needs a special treatment.
> 
> ... in part because of this.  GFP_ATOMIC __vmalloc() will be anything but,
> and the only caller passing that is almost certainly bogus.

Agreed as just replied in the other email thread which I have noticed
only now.

> As for NOFS/NOIO,
> I wonder if we should apply that special treatment inside __vmalloc_area_node
> rather than in callers; see the current thread on linux-mm for details...

That would make a lot of sense to me. Spreading the _special_ treatment
all over the kernel is certainly worse.
 
> Another interesting issue is __GFP_HIGHMEM meaning for kmalloc and __vmalloc
> resp. (should never be passed to kmalloc, should almost always be passed
> to __vmalloc - the former needs pages mapped in kernel space, the latter
> probably never needs a separate kernel alias for the data pages, to such
> degree that I'm not sure if we shouldn't _force_ __GFP_HIGHMEM for data pages
> allocation in __vmalloc_area_node())

I would have to think about this one some more. Let's not fragment the
discussion and continue in that email thread:
http://lkml.kernel.org/r/20160103071246.GK9938%40ZenIV.linux.org.uk

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
