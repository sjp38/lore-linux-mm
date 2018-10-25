Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id D46D06B029D
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 09:43:59 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id v2-v6so8067211wrn.0
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 06:43:59 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id t186-v6si1107989wma.80.2018.10.25.06.43.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 06:43:58 -0700 (PDT)
Date: Thu, 25 Oct 2018 14:43:44 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 1/2] mm/zsmalloc.c: check encoded object value overflow
 for PAE
Message-ID: <20181025134344.GZ30658@n2100.armlinux.org.uk>
References: <20181025012745.20884-1-rafael.tinoco@linaro.org>
 <20181025120006.GY30658@n2100.armlinux.org.uk>
 <CABdQkv_cC4ixEFr91zyg-S21O5_7U8FV7=g7ZMRqGcQyhrwzaQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABdQkv_cC4ixEFr91zyg-S21O5_7U8FV7=g7ZMRqGcQyhrwzaQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael David Tinoco <rafael.tinoco@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Mark Brown <broonie@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>

On Thu, Oct 25, 2018 at 09:37:59AM -0300, Rafael David Tinoco wrote:
> Is it okay to propose using only MAX_PHYSMEM_BITS for zsmalloc (like
> it was before commit 02390b87) instead, and make sure *at least* ARM
> 32/64 and x86/x64, for now, have it defined outside sparsemem headers
> as well ?

It looks to me like this has been broken on ARM for quite some time,
predating that commit.  The original was:

#ifndef MAX_PHYSMEM_BITS
#ifdef CONFIG_HIGHMEM64G
#define MAX_PHYSMEM_BITS 36
#else /* !CONFIG_HIGHMEM64G */
#define MAX_PHYSMEM_BITS BITS_PER_LONG
#endif
#endif
#define _PFN_BITS              (MAX_PHYSMEM_BITS - PAGE_SHIFT)

On ARM, CONFIG_HIGHMEM64G is never defined (it's an x86 private symbol)
which means that the above sets MAX_PHYSMEM_BITS to 32 on non-sparsemem
ARM LPAE platforms.  So commit 02390b87 hasn't really changed anything
as far as ARM LPAE is concerned - and this looks to be a bug that goes
all the way back to when zsmalloc.c was moved out of staging in 2014.

Digging further back, it seems this brokenness was introduced with:

commit 6e00ec00b1a76a199b8c0acae401757b795daf57
Author: Seth Jennings <sjenning@linux.vnet.ibm.com>
Date:   Mon Mar 5 11:33:22 2012 -0600

    staging: zsmalloc: calculate MAX_PHYSMEM_BITS if not defined

    This patch provides a way to determine or "set a
    reasonable value for" MAX_PHYSMEM_BITS in the case that
    it is not defined (i.e. !SPARSEMEM)

    Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
    Acked-by: Nitin Gupta <ngupta@vflare.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

which, at the time, realised the problem with SPARSEMEM, but decided
that in the absense of SPARSEMEM, that MAX_PHYSMEM_BITS shall be
BITS_PER_LONG which seems absurd (see below.)

> This way I can WARN_ONCE(), instead of BUG(), when specific
> arch does not define it - enforcing behavior - showing BITS_PER_LONG
> is being used instead of MAX_PHYSMEM_BITS (warning, at least once, for
> the possibility of an overflow, like the issue showed in here).

Assuming that the maximum number of physical memory bits are
BITS_PER_LONG in the absense of MAX_POSSIBLE_PHYSMEM_BITS is a nonsense
- we have had the potential for PAE systems for a long time, and to
introduce new code that makes this assumption was plainly wrong.

We know when there's the potential for PAE, and thus more than
BITS_PER_LONG bits of physical memory address, through
CONFIG_PHYS_ADDR_T_64BIT.  So if we have the situation where
MAX_POSSIBLE_PHYSMEM_BITS (or the older case of MAX_PHYSMEM_BITS) not
being defined, but CONFIG_PHYS_ADDR_T_64BIT set, we should've been
erroring or something based on not knowing how many physical memory
bits are possible - it would be more than BITS_PER_LONG but less
than some unknown number of bits.

This is why I think any fallback here to BITS_PER_LONG is wrong.

What I suggested is to not fall back to BITS_PER_LONG in any case, but
always define MAX_PHYSMEM_BITS.  However, I now see that won't work for
x86 because MAX_PHYSMEM_BITS is not a constant anymore.

So I suggest everything that uses zsmalloc.c should instead define
MAX_POSSIBLE_PHYSMEM_BITS.

Note that there should _also_ be some protection in zsmalloc.c against
MAX_POSSIBLE_PHYSMEM_BITS being too large:

#define OBJ_INDEX_BITS  (BITS_PER_LONG - _PFN_BITS - OBJ_TAG_BITS)
#define OBJ_TAG_BITS 1
#define _PFN_BITS               (MAX_POSSIBLE_PHYSMEM_BITS - PAGE_SHIFT)

which means there's an implicit limitation on _PFN_BITS being less than
BITS_PER_LONG - OBJ_TAG_BITS (where, if it's equal to this, and hence
OBJ_INDEX_BITS will be zero.)  This imples that MAX_POSSIBLE_PHYSMEM_BITS
must be smaller than BITS_PER_LONG + PAGE_SHIFT - OBJ_TAG_BITS, or
43 bits on a 32 bit system.  If you want to guarantee a minimum number
of objects, then that limitation needs to be reduced further.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up
