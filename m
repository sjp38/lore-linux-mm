Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B5CFF6B005D
	for <linux-mm@kvack.org>; Mon, 25 May 2009 07:29:42 -0400 (EDT)
Date: Mon, 25 May 2009 12:30:05 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Use integer fields lookup for gfp_zone and check for
	errors in flags passed to the page allocator
Message-ID: <20090525113004.GD12160@csn.ul.ie>
References: <alpine.DEB.1.10.0905221438120.5515@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0905221438120.5515@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, npiggin@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, May 22, 2009 at 02:42:32PM -0400, Christoph Lameter wrote:
> 
> Subject: Use integer fields lookup for gfp_zone and check for errors in flags passed to the page allocator
> 
> This simplifies the code in gfp_zone() and also keeps the ability of the
> compiler to use constant folding to get rid of gfp_zone processing.
> 
> The lookup of the zone is done using a bitfield stored in an integer. So
> the code in gfp_zone is a simple extraction of bits from a constant bitfield.
> The compiler is generating a load of a constant into a register and then
> performs a shift and mask operation to get the zone from a gfp_t.
> 
> No cachelines are touched and no branches have to be predicted by the
> compiler.
> 
> We are doing some macro tricks here to convince the compiler to always do the
> constant folding if possible.
> 
> Tested on:
> i386 (kvm), x86_64(native)
> 

How was this tested? This patch boots on x86 for example, but when I
patched further to validate that gfp_zone() returned sensible values, I got
mismatches for GFP_HIGHUSER. These were the results I got for common GFP
flags on three architectures

x86
[    0.000000] mminit::gfp_zone GFP_DMA              PASS
[    0.000000] mminit::gfp_zone GFP_DMA32            FAIL 1 != 0
[    0.000000] mminit::gfp_zone GFP_NOIO             PASS
[    0.000000] mminit::gfp_zone GFP_NOFS             PASS
[    0.000000] mminit::gfp_zone GFP_KERNEL           PASS
[    0.000000] mminit::gfp_zone GFP_TEMPORARY        PASS
[    0.000000] mminit::gfp_zone GFP_USER             PASS
[    0.000000] mminit::gfp_zone GFP_HIGHUSER         FAIL 2 != 1
[    0.000000] mminit::gfp_zone GFP_HIGHUSER_MOVABLE PASS

I expect that the machine would start running into reclaim issues with
enough uptime because it'll not be using Highmem as it should. Similarly,
the GFP_DMA32 may also be a problem as the new implementation is going
ZONE_DMA when ZONE_NORMAL would have been ok in this case.

x86-64
[    0.000000] mminit::gfp_zone GFP_DMA              PASS
[    0.000000] mminit::gfp_zone GFP_DMA32            PASS
[    0.000000] mminit::gfp_zone GFP_NOIO             PASS
[    0.000000] mminit::gfp_zone GFP_NOFS             PASS
[    0.000000] mminit::gfp_zone GFP_KERNEL           PASS
[    0.000000] mminit::gfp_zone GFP_TEMPORARY        PASS
[    0.000000] mminit::gfp_zone GFP_USER             PASS
[    0.000000] mminit::gfp_zone GFP_HIGHUSER         PASS
[    0.000000] mminit::gfp_zone GFP_HIGHUSER_MOVABLE PASS

Happy days on x86-64.

ppc64
[    0.000000] mminit::gfp_zone GFP_DMA              PASS
[    0.000000] mminit::gfp_zone GFP_DMA32            FAIL 1 != 0
[    0.000000] mminit::gfp_zone GFP_NOIO             PASS
[    0.000000] mminit::gfp_zone GFP_NOFS             PASS
[    0.000000] mminit::gfp_zone GFP_KERNEL           PASS
[    0.000000] mminit::gfp_zone GFP_TEMPORARY        PASS
[    0.000000] mminit::gfp_zone GFP_USER             PASS
[    0.000000] mminit::gfp_zone GFP_HIGHUSER         PASS
[    0.000000] mminit::gfp_zone GFP_HIGHUSER_MOVABLE PASS

This mismatch on GFP_DMA32 is similar to x86. However, on ppc64 this error
is harmless as ZONE_NORMAL is never populated anyway so GFP_DMA32 going to
ZONE_DMA is just fine.

This is similar difficulty that earlier versions of the patch ran into although
this version is much closer to being correct. I'll look again tomorrow to
see can it be repaired. In the meantime, here is the patch I used to validate
your gfp_zone() implementation and maybe you'll spot the problem faster.

==== CUT HERE ====
