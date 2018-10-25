Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id AFA236B028F
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 08:00:28 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id f13-v6so7776343wrr.4
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 05:00:28 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id k4-v6si7472981wrh.191.2018.10.25.05.00.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 05:00:26 -0700 (PDT)
Date: Thu, 25 Oct 2018 13:00:06 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 1/2] mm/zsmalloc.c: check encoded object value overflow
 for PAE
Message-ID: <20181025120006.GY30658@n2100.armlinux.org.uk>
References: <20181025012745.20884-1-rafael.tinoco@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181025012745.20884-1-rafael.tinoco@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael David Tinoco <rafael.tinoco@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Mark Brown <broonie@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>

On Wed, Oct 24, 2018 at 10:27:44PM -0300, Rafael David Tinoco wrote:
> On 32-bit systems, zsmalloc uses HIGHMEM and, when PAE is enabled, the
> physical frame number might be so big that zsmalloc obj encoding (to
> location) will break IF architecture does not re-define
> MAX_PHYSMEM_BITS, causing:

I think there's a deeper problem here - a misunderstanding of what
MAX_PHYSMEM_BITS is.

MAX_PHYSMEM_BITS is a definition for sparsemem, and is only visible
when sparsemem is enabled.  When sparsemem is disabled, asm/sparsemem.h
is not included (and should not be included) which means there is no
MAX_PHYSMEM_BITS definition.

I don't think zsmalloc.c should be (ab)using MAX_PHYSMEM_BITS, and
your description above makes it sound like you expect it to always be
defined.

If we want to have a definition for this, we shouldn't be playing
fragile games like:

#ifndef MAX_POSSIBLE_PHYSMEM_BITS
#ifdef MAX_PHYSMEM_BITS
#define MAX_POSSIBLE_PHYSMEM_BITS MAX_PHYSMEM_BITS
#else
/*
 * If this definition of MAX_PHYSMEM_BITS is used, OBJ_INDEX_BITS will just
 * be PAGE_SHIFT
 */
#define MAX_POSSIBLE_PHYSMEM_BITS BITS_PER_LONG
#endif
#endif

but instead insist that MAX_PHYSMEM_BITS is defined _everywhere_.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up
