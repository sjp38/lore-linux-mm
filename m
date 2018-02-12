Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 26E3E6B0003
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 04:50:22 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id v14so2518220wmd.3
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 01:50:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i33si6012855wri.110.2018.02.12.01.50.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Feb 2018 01:50:20 -0800 (PST)
Date: Mon, 12 Feb 2018 10:50:19 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Regression after commit 19809c2da28a ("mm, vmalloc: use
 __GFP_HIGHMEM implicitly")
Message-ID: <20180212095019.GX21609@dhcp22.suse.cz>
References: <627DA40A-D0F6-41C1-BB5A-55830FBC9800@canonical.com>
 <20180208130649.GA15846@bombadil.infradead.org>
 <20180208232004.GA21027@bombadil.infradead.org>
 <20180211092652.GV21609@dhcp22.suse.cz>
 <20180211112808.GA4551@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180211112808.GA4551@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Kai Heng Feng <kai.heng.feng@canonical.com>, Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

[I am crawling over a large backlog after vacation so I will get to
 other emails in this thread later. Let's just fix the regression
 first. The patch with the full changelog is at the end of this email.
 CC Andrew - the original report is http://lkml.kernel.org/r/627DA40A-D0F6-41C1-BB5A-55830FBC9800@canonical.com]

On Sun 11-02-18 03:28:08, Matthew Wilcox wrote:
> On Sun, Feb 11, 2018 at 10:26:52AM +0100, Michal Hocko wrote:
> > On Thu 08-02-18 15:20:04, Matthew Wilcox wrote:
> > > ... nevertheless, 19809c2da28a does in fact break vmalloc_32 on 32-bit.  Look:
> > > 
> > > #if defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA32)
> > > #define GFP_VMALLOC32 GFP_DMA32 | GFP_KERNEL
> > > #elif defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA)
> > > #define GFP_VMALLOC32 GFP_DMA | GFP_KERNEL
> > > #else
> > > #define GFP_VMALLOC32 GFP_KERNEL
> > > #endif
> > > 
> > > So we pass in GFP_KERNEL to __vmalloc_node, which calls __vmalloc_node_range
> > > which calls __vmalloc_area_node, which ORs in __GFP_HIGHMEM.
> > 
> > Dohh. I have missed this. I was convinced that we always add GFP_DMA32
> > when doing vmalloc_32. Sorry about that. The above definition looks
> > quite weird to be honest. First of all do we have any 64b system without
> > both DMA and DMA32 zones? If yes, what is the actual semantic of
> > vmalloc_32? Or is there any magic forcing GFP_KERNEL into low 32b?
> 
> mmzone.h has the following, which may be inaccurate / out of date:
> 
>          * parisc, ia64, sparc  <4G
>          * s390                 <2G
>          * arm                  Various
>          * alpha                Unlimited or 0-16MB.
>          *
>          * i386, x86_64 and multiple other arches
>          *                      <16M.
> 
> It claims ZONE_DMA32 is x86-64 only, which is incorrect; it's now used
> by arm64, ia64, mips, powerpc, tile.

yes, nobody seem to keep this one in sync.

> > Also I would expect that __GFP_DMA32 should do the right thing on 32b
> > systems. So something like the below should do the trick
> 
> Oh, I see.  Because we have:
> 
> #ifdef CONFIG_ZONE_DMA32
> #define OPT_ZONE_DMA32 ZONE_DMA32
> #else
> #define OPT_ZONE_DMA32 ZONE_NORMAL
> #endif
> 
> we'll end up allocating from ZONE_NORMAL if a non-DMA32 architecture asks
> for GFP_DMA32 memory.  Thanks; I missed that.

yep

> I'd recommend this instead then:
> 
> #if defined(CONFIG_64BIT) && !defined(CONFIG_ZONE_DMA32)
> #define GFP_VMALLOC32 GFP_DMA | GFP_KERNEL
> #else
> #define GFP_VMALLOC32 GFP_DMA32 | GFP_KERNEL
> #endif
> 
> I think it's clearer than the three-way #if.

I do not have a strong opinion here. I just wanted the change to be
obvious without meddling with the 64b ifdefs much. Follow up cleanups
are certainly possible.

> Now, longer-term, perhaps we should do the following:
> 
> #ifdef CONFIG_ZONE_DMA32
> #define OPT_ZONE_DMA32	ZONE_DMA32
> #elif defined(CONFIG_64BIT)
> #define OPT_ZONE_DMA	OPT_ZONE_DMA
> #else
> #define OPT_ZONE_DMA32 ZONE_NORMAL
> #endif
> 
> Then we wouldn't need the ifdef here and could always use GFP_DMA32
> | GFP_KERNEL.  Would need to audit current users and make sure they
> wouldn't be broken by such a change.

I am pretty sure improvements are possible.

> I noticed a mistake in 704b862f9efd;
> 
> -               pages = __vmalloc_node(array_size, 1, nested_gfp|__GFP_HIGHMEM,
> +               pages = __vmalloc_node(array_size, 1, nested_gfp|highmem_mask,
> 
> We should unconditionally use __GFP_HIGHMEM here instead of highmem_mask
> because this is where we allocate the array to hold the struct page
> pointers.  This can be allocated from highmem, and does not need to be
> allocated from ZONE_NORMAL.

You seem to be right. nested_gfp doesn't include zone modifiers. Care to
send a patch?

> Similarly,
> 
> -               if (gfpflags_allow_blocking(gfp_mask))
> +               if (gfpflags_allow_blocking(gfp_mask|highmem_mask))
> 
> is not needed (it's not *wrong*, it was just an unnecessary change).

yes. highmem_mask has no influence on the blocking behavior.

The fix for the regressions should be
