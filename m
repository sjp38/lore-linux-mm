Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 67F8B6B004A
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 09:10:27 -0400 (EDT)
Date: Tue, 26 Oct 2010 08:10:23 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: vmscan: Do not run shrinkers for zones other than ZONE_NORMAL
In-Reply-To: <20101026111025.B7B2.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1010260804080.813@router.home>
References: <20101025101009.915D.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1010251000480.7461@router.home> <20101026111025.B7B2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Tue, 26 Oct 2010, KOSAKI Motohiro wrote:

> But, I have one question. Do you want to keep per-cpu cache although
> reclaim running? If my remember is correct, your unified slab allocator
> patch series drop percpu slab cache if memory reclaim occur.

I modified the unified allocator to use a slab shrinker for the next
release.

> I mean I'd like to know how much important slab percpu cache is. can
> you please explain your ideal cache dropping behavior of slab?

Caches both keep state of the physical cpu caches and optimize locking
since you avoid the overhead of taking objects from slab pages and pushing
them in. Ideally they are kept as long as possible. But if the system has
other needs then they should be dropped so that pages can be freed.

> > The concept of a "zone" is for the benefit of certain legacy drivers that
> > have limitations for the memory range on which they can performa DMA
> > operations. With the IOMMUs and other modern technology this should no
> > longer be an issue.
>
> IOMMU is certenary modern. but it's still costly a bit. So I'm not sure
> all desktop devices will equip IOMMU. At least, we still have 32bit limitation
> drivers in kernel tree. At least, desktop pc of this year still have PCI slot.
>
> Another interesting example, KVM is one of user __GFP_DMA32. it is
> necessary to implement 32bit cpu emulation (i.e. 32bit guest).

Why does KVM use __GFP_DMA32? They need a physical address below 32 bit in
the 64 bit host? A 32 bit guest would only have __GFP dma and not
GFP_DMA32.

> I'm not sure destroying zone is good idea. I can only say that it still has
> user even nowaday..

Sure it does but it creates certain headaches. I like those to be reduced
as much as possible.

> So again, I was thinking a reclaim should drop both page allocator pcp
> cache and slab cpu cache. Am I wrong? if so, why do you disagree?

I agree.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
