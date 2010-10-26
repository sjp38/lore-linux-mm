Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D39126B004A
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 22:52:41 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9Q2qc9U031007
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 26 Oct 2010 11:52:38 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8436245DE50
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 11:52:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5677B45DE52
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 11:52:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3276AE18002
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 11:52:38 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id ADA1BE18006
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 11:52:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: vmscan: Do not run shrinkers for zones other than ZONE_NORMAL
In-Reply-To: <alpine.DEB.2.00.1010251000480.7461@router.home>
References: <20101025101009.915D.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1010251000480.7461@router.home>
Message-Id: <20101026111025.B7B2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 26 Oct 2010 11:52:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

> On Mon, 25 Oct 2010, KOSAKI Motohiro wrote:
> 
> > > The per zone approach seems to be at variance with how objects are tracked
> > > at the slab layer. There is no per zone accounting there. So attempts to
> > > do expiration of caches etc at that layer would not work right.
> >
> > Please define your 'right' behavior ;-)
> 
> Right here meant not excessive shrink calls for a particular node.

Ok, I believe nobody object this.


> > If we need to discuss 'right' thing, we also need to define how behavior
> > is right, I think. slab API itself don't have zone taste. but it implictly
> > depend on a zone because buddy and reclaim are constructed on zones and
> > slab is constructed on buddy. IOW, every slab object have a home zone.
> 
> True every page has a zone. However, per cpu caching and NUMA distances
> only work per node (or per cache sharing domain which may just be a
> fraction of a "node"). The slab allocators attempt to keep objects on
> queues that are cache hot. For that purpose only the node matters not the
> zone.

True.

But, I have one question. Do you want to keep per-cpu cache although
reclaim running? If my remember is correct, your unified slab allocator
patch series drop percpu slab cache if memory reclaim occur.

I mean I'd like to know how much important slab percpu cache is. can
you please explain your ideal cache dropping behavior of slab?



> > So, which workload or usecause make a your head pain?
> 
> The head pain is because of the conflict of object tracking in the page
> allocator per zone and in the slabs per node.

True. that's annoying.


> In general per zone object tracking in the page allocators percpu lists is
> not optimal since at variance with how the cpu caches actually work.
> 
> - Cpu caches exist typically per node or per sharing domain (which is not
>   reflected in the page allocators at all)

True.

> 
> - NUMA distance effects only change for per node allocations.

This can be solved easily, I think. two zones in the same node is definitely
nearest distance than other. so we can make artificial nearest distance
internally.


> The concept of a "zone" is for the benefit of certain legacy drivers that
> have limitations for the memory range on which they can performa DMA
> operations. With the IOMMUs and other modern technology this should no
> longer be an issue.

IOMMU is certenary modern. but it's still costly a bit. So I'm not sure
all desktop devices will equip IOMMU. At least, we still have 32bit limitation
drivers in kernel tree. At least, desktop pc of this year still have PCI slot.

Another interesting example, KVM is one of user __GFP_DMA32. it is
necessary to implement 32bit cpu emulation (i.e. 32bit guest).

I'm not sure destroying zone is good idea. I can only say that it still has
user even nowaday..


> An Mel used it to attach a side car (ZONE_MOVABLE) to the VM ...

Hehe, yes, ZONE_MOVABLE is another one of annoying source :-)


So again, I was thinking a reclaim should drop both page allocator pcp
cache and slab cpu cache. Am I wrong? if so, why do you disagree?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
