Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 728B06B0120
	for <linux-mm@kvack.org>; Wed, 27 May 2015 00:24:25 -0400 (EDT)
Received: by pdea3 with SMTP id a3so108093778pde.2
        for <linux-mm@kvack.org>; Tue, 26 May 2015 21:24:25 -0700 (PDT)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com. [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id o5si24060251pap.50.2015.05.26.21.24.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 21:24:24 -0700 (PDT)
Received: by pdfh10 with SMTP id h10so108039282pdf.3
        for <linux-mm@kvack.org>; Tue, 26 May 2015 21:24:24 -0700 (PDT)
Date: Wed, 27 May 2015 13:24:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH 2/2] arm64: Implement vmalloc based thread_info
 allocator
Message-ID: <20150527042416.GC11609@blaptop>
References: <1432483340-23157-1-git-send-email-jungseoklee85@gmail.com>
 <5992243.NYDGjLH37z@wuerfel>
 <B873B881-4972-4524-B1D9-4BB05D7248A4@gmail.com>
 <20150525145857.GF14922@blaptop>
 <BA18E3D0-A487-4E74-8DCA-49F36A4F08E2@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BA18E3D0-A487-4E74-8DCA-49F36A4F08E2@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jungseok Lee <jungseoklee85@gmail.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, Catalin Marinas <catalin.marinas@arm.com>, barami97@gmail.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 26, 2015 at 09:10:11PM +0900, Jungseok Lee wrote:
> On May 25, 2015, at 11:58 PM, Minchan Kim wrote:
> > On Mon, May 25, 2015 at 07:01:33PM +0900, Jungseok Lee wrote:
> >> On May 25, 2015, at 2:49 AM, Arnd Bergmann wrote:
> >>> On Monday 25 May 2015 01:02:20 Jungseok Lee wrote:
> >>>> Fork-routine sometimes fails to get a physically contiguous region for
> >>>> thread_info on 4KB page system although free memory is enough. That is,
> >>>> a physically contiguous region, which is currently 16KB, is not available
> >>>> since system memory is fragmented.
> >>>> 
> >>>> This patch tries to solve the problem as allocating thread_info memory
> >>>> from vmalloc space, not 1:1 mapping one. The downside is one additional
> >>>> page allocation in case of vmalloc. However, vmalloc space is large enough,
> >>>> around 240GB, under a combination of 39-bit VA and 4KB page. Thus, it is
> >>>> not a big tradeoff for fork-routine service.
> >>> 
> >>> vmalloc has a rather large runtime cost. I'd argue that failing to allocate
> >>> thread_info structures means something has gone very wrong.
> >> 
> >> That is why the feature is marked "N" by default.
> >> I focused on fork-routine stability rather than performance.
> > 
> > If VM has trouble with order-2 allocation, your system would be
> > trouble soon although fork at the moment manages to be successful
> > because such small high-order(ex, order <= PAGE_ALLOC_COSTLY_ORDER)
> > allocation is common in the kernel so VM should handle it smoothly.
> > If VM didn't, it means we should fix VM itself, not a specific
> > allocation site. Fork is one of victim by that.
> 
> A problem I observed is an user space, not a kernel side. As user applications
> fail to create threads in order to distribute their jobs properly, they are getting
> in trouble slowly and then gone.
> 
> Yes, fork is one of victim, but damages user applications seriously.
> At this snapshot, free memory is enough.

Yes, it's the one you found.

        *Free memory is enough but why forking was failed*

You should find the exact reason for it rather than papering over by
hiding forking fail.

1. Investigate how many of movable/unmovable page ratio at the moment
2. Investigate why compaction doesn't work
3. Investigate why reclaim couldn't make order-2 page


> 
> >> Could you give me an idea how to evaluate performance degradation?
> >> Running some benchmarks would be helpful, but I would like to try to
> >> gather data based on meaningful methodology.
> >> 
> >>> Can you describe the scenario that leads to fragmentation this bad?
> >> 
> >> Android, but I could not describe an exact reproduction procedure step
> >> by step since it's behaved and reproduced randomly. As reading the following
> >> thread from mm mailing list, a similar symptom is observed on other systems. 
> >> 
> >> https://lkml.org/lkml/2015/4/28/59
> >> 
> >> Although I do not know the details of a system mentioned in the thread,
> >> even order-2 page allocation is not smoothly operated due to fragmentation on
> >> low memory system.
> > 
> > What Joonsoo have tackle is generic fragmentation problem, not *a* fork fail,
> > which is more right approach to handle small high-order allocation problem.
> 
> I totally agree with that point. One of the best ways is to figure out a generic
> anti-fragmentation with VM system improvement. Reducing the stack size to 8KB is also
> a really great approach. My intention is not to overlook them or figure out a workaround.
> 
> IMHO, vmalloc would be a different option in case of ARM64 on low memory systems since
> *fork failure from fragmentation* is a nontrivial issue.
> 
> Do you think the patch set doesn't need to be considered?

I don't know because the changelog doesn't have full description
about your problem. You just wrote "forking was failed so we want
to avoid that by vmalloc because forking is important".
It seems to me it is just bandaid.

What you should provide for description is

" Forking was failed although there were lots of free pages
  so I investigated it and found root causes in somewhere
  so this patch fixes the problem"

Thanks.


> 
> Best Regards
> Jungseok Lee

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
