Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 318036B0083
	for <linux-mm@kvack.org>; Thu, 24 May 2012 08:26:18 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=utf-8
Received: from euspt2 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M4J00FOX186GT50@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 24 May 2012 13:26:30 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M4J00EMZ17P4D@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 24 May 2012 13:26:14 +0100 (BST)
Date: Thu, 24 May 2012 14:26:12 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv2 3/4] mm: vmalloc: add VM_DMA flag to indicate areas used
 by dma-mapping framework
In-reply-to: <4FBB3B41.8010102@kernel.org>
Message-id: <01e501cd39a8$67f34ea0$37d9ebe0$%szyprowski@samsung.com>
Content-language: pl
References: <1337252085-22039-1-git-send-email-m.szyprowski@samsung.com>
 <1337252085-22039-4-git-send-email-m.szyprowski@samsung.com>
 <4FBB3B41.8010102@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'Konrad Rzeszutek Wilk' <konrad.wilk@oracle.com>, 'Hiroshi Doyu' <hdoyu@nvidia.com>, 'Subash Patel' <subashrp@gmail.com>, 'Nick Piggin' <npiggin@gmail.com>

Hi Minchan,

On Tuesday, May 22, 2012 9:08 AM Minchan Kim wrote:

> On 05/17/2012 07:54 PM, Marek Szyprowski wrote:
> 
> > Add new type of vm_area intented to be used for consisten mappings
> > created by dma-mapping framework.
> >
> > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>
> > ---
> >  include/linux/vmalloc.h |    1 +
> >  mm/vmalloc.c            |    3 +++
> >  2 files changed, 4 insertions(+)
> >
> > diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> > index 6071e91..8a9555a 100644
> > --- a/include/linux/vmalloc.h
> > +++ b/include/linux/vmalloc.h
> > @@ -14,6 +14,7 @@ struct vm_area_struct;		/* vma defining user mapping in
> mm_types.h */
> >  #define VM_USERMAP	0x00000008	/* suitable for remap_vmalloc_range */
> >  #define VM_VPAGES	0x00000010	/* buffer for pages was vmalloc'ed */
> >  #define VM_UNLIST	0x00000020	/* vm_struct is not listed in vmlist */
> > +#define VM_DMA		0x00000040	/* used by dma-mapping framework */
> >  /* bits [20..32] reserved for arch specific ioremap internals */
> 
> >
> 
> >  /*
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > index 8cb7f22..9c13bab 100644
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -2582,6 +2582,9 @@ static int s_show(struct seq_file *m, void *p)
> >  	if (v->flags & VM_IOREMAP)
> >  		seq_printf(m, " ioremap");
> >
> > +	if (v->flags & VM_DMA)
> > +		seq_printf(m, " dma");
> > +
>
> Hmm, VM_DMA would become generic flag?
> AFAIU, maybe VM_DMA would be used only on ARM arch.

Right now yes, it will be used only on ARM architecture, but maybe other architecture will
start using it once it is available.

> Of course, it isn't performance sensitive part but there in no reason to check it, either
> in other architecture except ARM.
> 
> I suggest following as
> 
> #ifdef CONFIG_ARM
> #define VM_DMA	0x00000040
> #else
> #define VM_DMA	0x0
> #end
> 
> Maybe it could remove check code at compile time.

I've been told to avoid such #ifdef construction if there is no really good reason for it.
The only justification was significant impact on the performance, otherwise it would be 
just a good example of typical over-engineering.

> >  	if (v->flags & VM_ALLOC)
> >  		seq_printf(m, " vmalloc");

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
