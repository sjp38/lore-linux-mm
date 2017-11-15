Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3B0576B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 11:21:03 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id o7so24092950pgc.23
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 08:21:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f24sor6476405pfd.80.2017.11.15.08.21.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Nov 2017 08:21:01 -0800 (PST)
Date: Wed, 15 Nov 2017 08:20:57 -0800
From: Tycho Andersen <tycho@tycho.ws>
Subject: Re: [kernel-hardening] Re: [PATCH v6 03/11] mm, x86: Add support for
 eXclusive Page Frame Ownership (XPFO)
Message-ID: <20171115162057.iyufe2vg34d6fhhd@cisco>
References: <20170920223452.vam3egenc533rcta@smitten>
 <97475308-1f3d-ea91-5647-39231f3b40e5@intel.com>
 <20170921000901.v7zo4g5edhqqfabm@docker>
 <d1a35583-8225-2ab3-d9fa-273482615d09@intel.com>
 <20171110010907.qfkqhrbtdkt5y3hy@smitten>
 <7237ae6d-f8aa-085e-c144-9ed5583ec06b@intel.com>
 <2aa64bf6-fead-08cc-f4fe-bd353008ca59@intel.com>
 <20171115034430.GA24257@bombadil.infradead.org>
 <d1459463-061c-2aba-ff89-936284c138a3@intel.com>
 <20171115145835.GB319@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171115145835.GB319@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, x86@kernel.org

On Wed, Nov 15, 2017 at 06:58:35AM -0800, Matthew Wilcox wrote:
> On Tue, Nov 14, 2017 at 11:00:20PM -0800, Dave Hansen wrote:
> > On 11/14/2017 07:44 PM, Matthew Wilcox wrote:
> > > We don't need to kmap in order to access MOVABLE allocations.  kmap is
> > > only needed for HIGHMEM allocations.  So there's nothing wrong with ext4
> > > or set_bh_page().
> > 
> > Yeah, it's definitely not _buggy_.
> > 
> > Although, I do wonder what we should do about these for XPFO.  Should we
> > just stick a kmap() in there and comment it?  What we really need is a
> > mechanism to say "use this as a kernel page" and "stop using this as a
> > kernel page".  kmap() does that... kinda.  It's not a perfect fit, but
> > it's pretty close.
> 
> It'd be kind of funny if getting XPFO working better means improving
> how well Linux runs on 32-bit machines with HIGHMEM.  I think there's
> always going to be interest in those -- ARM developed 36 bit physmem
> before biting the bullet and going to arm64.  Maybe OpenRISC will do
> that next ;-)

Oh, sorry, I didn't realize that this wasn't a bug. In any case, this
seems like sort of an uphill battle -- lots of places are going to do
stuff like this since it's legal, adding code to work around it just
for XPFO seems like a lot of burden on the kernel. (Of course, I'm
open to convincing :)

How common are these MOVABLE allocations that the kernel does? What if
we did some hybrid approach, where we re-map the lists based on
MOVABLE/UNMOVABLE, but then check the actual GFP flags on allocation
to see if they match what we set when populating the free list, and
re-map accordingly if they don't.

Or is there some other way?

Cheers,

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
