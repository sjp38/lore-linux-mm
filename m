Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id BAD576B0069
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 06:36:07 -0400 (EDT)
Date: Thu, 14 Jun 2012 12:36:27 +0200
From: Borislav Petkov <bp@amd64.org>
Subject: Re: bugs in page colouring code
Message-ID: <20120614103627.GA25940@aftab.osrc.amd.com>
References: <20120613152936.363396d5@cuia.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120613152936.363396d5@cuia.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sjhill@mips.com, ralf@linux-mips.org, "H. Peter Anvin" <hpa@linux.intel.com>, Rob Herring <rob.herring@calxeda.com>, Russell King <rmk+kernel@arm.linux.org.uk>, Nicolas Pitre <nico@linaro.org>

On Wed, Jun 13, 2012 at 03:29:36PM -0400, Rik van Riel wrote:
> The page colouring code on x86-64, align_addr in sys_x86_64.c is
> slightly more amusing.

This was done with the reviewers' fun level in mind from the very start.

:-)

> For one, there are separate kernel boot arguments to control whether
> 32 and 64 bit processes need to have their addresses aligned for
> page colouring.
> 
> Do we really need that?

Yes.

Mind you, this is only enabled on AMD F15h - all other x86 simply can't
tweak it without code change.

> Would it be a problem if I discarded that code, in order to get to one
> common cache colouring implementation?

Sorry, but, we'd like to keep it in.

> Secondly, MAP_FIXED never checks for page colouring alignment. I
> assume the cache aliasing on AMD Bulldozer is merely a performance
> issue, and we can simply ignore page colouring for MAP_FIXED?

Right, AFAICR, MAP_FIXED is not generally used for shared libs (correct
me if I'm wrong here, my memory is very fuzzy about it) and since we see
the perf issue with shared libs, this was fine.

> That will be easy to get right in an architecture-independent
> implementation.
> 
> 
> A third issue is this:
> 
>         if (!(current->flags & PF_RANDOMIZE))
>                 return addr;
> 
> Do we really want to skip page colouring merely because the 
> application does not have PF_RANDOMIZE set?  What is this
> conditional supposed to do?

Linus said that without this we are probably breaking old userspace
which can't stomach ASLR so we had to respect such userspace which
clears that flag.

> When an app calls mmap with address 0, what breaks by giving it a
> properly page coloured address, instead of the first suitable address
> we find?

Look at dfb09f9b7ab03fd367740e541a5caf830ed56726.

We need bits slice [12:14] in the virtual address to be the same
across all processes mapping the same physical memory otherwise, the
cross-invalidations happen.

Thanks.

-- 
Regards/Gruss,
Boris.

Advanced Micro Devices GmbH
Einsteinring 24, 85609 Dornach
GM: Alberto Bozzo
Reg: Dornach, Landkreis Muenchen
HRB Nr. 43632 WEEE Registernr: 129 19551

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
