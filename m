Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 50CCF6B0069
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 10:32:16 -0400 (EDT)
Date: Thu, 14 Jun 2012 15:31:49 +0100
From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: bugs in page colouring code
Message-ID: <20120614143149.GE12068@linux-mips.org>
References: <20120613152936.363396d5@cuia.bos.redhat.com>
 <20120614103627.GA25940@aftab.osrc.amd.com>
 <4FD9DFCE.1070609@redhat.com>
 <20120614132007.GC25940@aftab.osrc.amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120614132007.GC25940@aftab.osrc.amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@amd64.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sjhill@mips.com, "H. Peter Anvin" <hpa@linux.intel.com>, Rob Herring <rob.herring@calxeda.com>, Russell King <rmk+kernel@arm.linux.org.uk>, Nicolas Pitre <nico@linaro.org>

On Thu, Jun 14, 2012 at 03:20:07PM +0200, Borislav Petkov wrote:

> > However, I expect that on x86 many applications expect
> > MAP_FIXED to just work, and enforcing that would be
> > more trouble than it's worth.
> 
> Right, but if MAP_FIXED mappings succeed, then all processes sharing
> that mapping will have it at the same virtual address, correct? And
> if so, then we don't have the aliasing issue either so MAP_FIXED is a
> don't-care from that perspective.

Once upon a time every real program carried its own malloc around.  I'm
sure many of these malloc implementations rely on MAP_FIXED.

These days the big user of MAP_FIXED is glibc's dynamic loader.  It
doesn't use MAP_FIXED for the first segment, only for all subsequent
segments and the addresses are chosen such this will succeed.  ld(1)
has the necessary knowledge about alignment.

Problem: If you raise the alignment for mappings you want to make damn
sure that any non-broken executable ever created uses sufficient alignment
or bad things may happen.

MIPS used to use a very large alignment in ld linker scripts allowing
for up to 1MB page size.  Then somebody clueless who shall smoulder in
hell reduced it to a very small value, something like 4k or 16k.  When
we went for bigger page size (MIPS allows 64K page size) all binaries
created with the broken linker had to be rebuilt.

So you probably want to do a little dumpster diving in very old binutils
before doing anything that raises alignment of file mappings.

> > >Linus said that without this we are probably breaking old userspace
> > >which can't stomach ASLR so we had to respect such userspace which
> > >clears that flag.
> > 
> > I wonder if that is true, since those userspace programs
> > probably run fine on ARM, MIPS and other architectures...
> 
> Well, I'm too young to know that :) Reportedly, those were some obscure
> old binaries and we added the PF_RANDOMIZE check out of caution, so as
> to not break them, if at all.

See above - ld linker scripts are a big part of why things are working :)
I'm however not aware of any breakage caused by PF_RANDOMIZE.

  Ralf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
