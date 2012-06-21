Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 3E0CD6B00C7
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 08:38:37 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout4.samsung.com [203.254.224.34])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M5Y0086MWG2I040@mailout4.samsung.com> for
 linux-mm@kvack.org; Thu, 21 Jun 2012 21:38:34 +0900 (KST)
Received: from AMDC159 ([106.116.147.30])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M5Y00KIQWFTUF30@mmp1.samsung.com> for linux-mm@kvack.org;
 Thu, 21 Jun 2012 21:38:34 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
References: <1339585306-7147-1-git-send-email-m.szyprowski@samsung.com>
 <1339585306-7147-3-git-send-email-m.szyprowski@samsung.com>
 <4FE2DCE7.80102@kernel.org>
In-reply-to: <4FE2DCE7.80102@kernel.org>
Subject: RE: [PATCHv3 2/3] mm: vmalloc: add VM_DMA flag to indicate areas used
 by dma-mapping framework
Date: Thu, 21 Jun 2012 14:38:15 +0200
Message-id: <020601cd4faa$bfbad6e0$3f3084a0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: pl
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'Konrad Rzeszutek Wilk' <konrad.wilk@oracle.com>, 'Hiroshi Doyu' <hdoyu@nvidia.com>, 'Subash Patel' <subashrp@gmail.com>, 'KOSAKI Motohiro' <kosaki.motohiro@gmail.com>, 'Andrew Morton' <akpm@linux-foundation.org>

Hi,

On Thursday, June 21, 2012 10:36 AM Minchan Kim wrote:

> On 06/13/2012 08:01 PM, Marek Szyprowski wrote:
> 
> > Add new type of vm_area intented to be used for mappings created by
> > dma-mapping framework.
> >
> > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>
> > ---
> >  include/linux/vmalloc.h |    1 +
> >  mm/vmalloc.c            |    3 +++
> >  2 files changed, 4 insertions(+), 0 deletions(-)
> >
> > diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> > index 2e28f4d..e725b7b 100644
> > --- a/include/linux/vmalloc.h
> > +++ b/include/linux/vmalloc.h
> > @@ -14,6 +14,7 @@ struct vm_area_struct;		/* vma defining user mapping in
> mm_types.h */
> >  #define VM_USERMAP	0x00000008	/* suitable for remap_vmalloc_range */
> >  #define VM_VPAGES	0x00000010	/* buffer for pages was vmalloc'ed */
> >  #define VM_UNLIST	0x00000020	/* vm_struct is not listed in vmlist */
> > +#define VM_DMA		0x00000040	/* used by dma-mapping framework */
> >  /* bits [20..32] reserved for arch specific ioremap internals */
> >
> >  /*
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > index 11308f0..e04d59b 100644
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -2575,6 +2575,9 @@ static int s_show(struct seq_file *m, void *p)
> >  	if (v->flags & VM_IOREMAP)
> >  		seq_printf(m, " ioremap");
> >
> > +	if (v->flags & VM_DMA)
> > +		seq_printf(m, " dma");
> > +
> >  	if (v->flags & VM_ALLOC)
> >  		seq_printf(m, " vmalloc");
> >
> 
> 
> I still don't make sure that we should add new type for only ARM arch.
> I remember you said "It would be used for other architectures once we add" and
> Paul said he has a plan for SH. So at least, you should add such comment in changelog
> for persuading grumpy maintainers. :)
> 
> Frankly speaking, I could add my Reviewed-by but I think it wouldn't carry much weight
> because code is very tiny so you need Acked-by rather than Reviewed-by.
> IMHO, This problem is the thing only maintainer should decide.
> So I will toss the decision to akpm. Ccing akpm.(Ccing KOSAKI because he had a concern about
> this).
> 
> If anyone have a question to me, I'm Acked-by iff other architecture will use it.

Ok, if this flag is so controversial, I can change it to arch specific VM flag and utilize
'bits [20..32] reserved for arch specific ioremap internals'. Later, when other architectures 
start using similar flag, one can unify them and add such generic flag.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
