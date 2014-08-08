Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id EBEAF6B0035
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 11:55:00 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id i50so6061314qgf.20
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 08:55:00 -0700 (PDT)
Received: from qmta01.emeryville.ca.mail.comcast.net (qmta01.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:16])
        by mx.google.com with ESMTP id x10si7144600qar.30.2014.08.08.08.54.59
        for <linux-mm@kvack.org>;
        Fri, 08 Aug 2014 08:55:00 -0700 (PDT)
Date: Fri, 8 Aug 2014 10:54:57 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH for v3.17-rc1] Revert "slab: remove BAD_ALIEN_MAGIC"
In-Reply-To: <CAMuHMdVZdaVeYY=A=eVEC67GGyQNq2XZ8wN3fk0+ywtkoa6EmA@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1408081049400.24610@gentwo.org>
References: <1407481239-7572-1-git-send-email-iamjoonsoo.kim@lge.com> <alpine.DEB.2.11.1408080943280.16459@gentwo.org> <CAMuHMdVZdaVeYY=A=eVEC67GGyQNq2XZ8wN3fk0+ywtkoa6EmA@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Vladimir Davydov <vdavydov@parallels.com>

On Fri, 8 Aug 2014, Geert Uytterhoeven wrote:

> On Fri, Aug 8, 2014 at 4:44 PM, Christoph Lameter <cl@linux.com> wrote:
> > On Fri, 8 Aug 2014, Joonsoo Kim wrote:
> >
> >> This reverts commit a640616822b2 ("slab: remove BAD_ALIEN_MAGIC").
> >
> > Lets hold off on this one. I am bit confused as to why a non NUMA system
> > would have multiple NUMA nodes.
>
> DISCONTIGMEM
>
> mm/Kconfig:
>
> #
> # Both the NUMA code and DISCONTIGMEM use arrays of pg_data_t's
> # to represent different areas of memory.  This variable allows
> # those dependencies to exist individually.
> #
> config NEED_MULTIPLE_NODES
>         def_bool y
>         depends on DISCONTIGMEM || NUMA

Uhhh... And how does one access memory when the node is != 0 given that
zone_to_nid always returns 0 in the !CONFIG_NUMA case? AFAICT there are
numerous of these node == 0 assumptions in the kernel for !NUMA.

include/linux/mmzone.h:

#ifdef CONFIG_NUMA
#define pfn_to_nid(pfn)                                                 \
({                                                                      \
        unsigned long __pfn_to_nid_pfn = (pfn);                         \
        page_to_nid(pfn_to_page(__pfn_to_nid_pfn));                     \
})
#else
#define pfn_to_nid(pfn)         (0)
#endif


How can this work at all????




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
