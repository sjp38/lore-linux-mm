Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E7EEC6B0008
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 18:37:12 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f66-v6so5466017plb.10
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 15:37:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t89-v6si9750544pfe.59.2018.07.06.15.37.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 15:37:11 -0700 (PDT)
Date: Fri, 6 Jul 2018 15:37:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND PATCH v10 2/6] mm: page_alloc: remain
 memblock_next_valid_pfn() on arm/arm64
Message-Id: <20180706153709.6bcc76b0245f239f1d1dcc8a@linux-foundation.org>
In-Reply-To: <1530867675-9018-3-git-send-email-hejianet@gmail.com>
References: <1530867675-9018-1-git-send-email-hejianet@gmail.com>
	<1530867675-9018-3-git-send-email-hejianet@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jia He <jia.he@hxt-semitech.com>

On Fri,  6 Jul 2018 17:01:11 +0800 Jia He <hejianet@gmail.com> wrote:

> From: Jia He <jia.he@hxt-semitech.com>
> 
> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
> where possible") optimized the loop in memmap_init_zone(). But it causes
> possible panic bug. So Daniel Vacek reverted it later.
> 
> But as suggested by Daniel Vacek, it is fine to using memblock to skip
> gaps and finding next valid frame with CONFIG_HAVE_ARCH_PFN_VALID.
> Daniel said:
> "On arm and arm64, memblock is used by default. But generic version of
> pfn_valid() is based on mem sections and memblock_next_valid_pfn() does
> not always return the next valid one but skips more resulting in some
> valid frames to be skipped (as if they were invalid). And that's why
> kernel was eventually crashing on some !arm machines."
> 
> About the performance consideration:
> As said by James in b92df1de5,
> "I have tested this patch on a virtual model of a Samurai CPU
> with a sparse memory map.  The kernel boot time drops from 109 to
> 62 seconds."
> 
> Thus it would be better if we remain memblock_next_valid_pfn on arm/arm64.
> 

We're making a bit of a mess here.  mmzone.h:

...
#ifndef CONFIG_HAVE_ARCH_PFN_VALID
...
#define next_valid_pfn(pfn)	(pfn + 1)
#endif
...
#ifdef CONFIG_HAVE_MEMBLOCK_PFN_VALID
#define next_valid_pfn(pfn)	memblock_next_valid_pfn(pfn)
...
#else
...
#ifndef next_valid_pfn
#define next_valid_pfn(pfn)	(pfn + 1)
#endif

I guess it works OK, since CONFIG_HAVE_MEMBLOCK_PFN_VALID depends on
CONFIG_HAVE_ARCH_PFN_VALID.  But it could all do with some cleanup and
modernization.

- Perhaps memblock_next_valid_pfn() should just be called
  pfn_valid().  So the header file's responsibility is to provide
  pfn_valid() and next_valid_pfn().

- CONFIG_HAVE_ARCH_PFN_VALID should go away.  The current way of
  doing such thnigs is for the arch (or some Kconfig combination) to
  define pfn_valid() and next_valid_pfn() in some fashion and to then
  ensure that one of them is #defined to something, to indicate that
  both of these have been set up.  Or something like that.


Secondly, in memmap_init_zone()

> -		if (!early_pfn_valid(pfn))
> +		if (!early_pfn_valid(pfn)) {
> +			pfn = next_valid_pfn(pfn) - 1;
> 			continue;
> +		}
> +

This is weird-looking.  next_valid_pfn(pfn) is usually (pfn+1) so it's
a no-op.  Sometimes we're calling memblock_next_valid_pfn() and then
backing up one, presumably because the `for' loop ends in `pfn++'.  Or
something.  Can this please be fully commented or cleaned up?
