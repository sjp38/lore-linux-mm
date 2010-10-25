Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4FAE68D0001
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 11:08:03 -0400 (EDT)
Date: Mon, 25 Oct 2010 10:07:59 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: vmscan: Do not run shrinkers for zones other than ZONE_NORMAL
In-Reply-To: <20101025101009.915D.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1010251000480.7461@router.home>
References: <20101022103620.53A9.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1010220859080.19498@router.home> <20101025101009.915D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Mon, 25 Oct 2010, KOSAKI Motohiro wrote:

> > The per zone approach seems to be at variance with how objects are tracked
> > at the slab layer. There is no per zone accounting there. So attempts to
> > do expiration of caches etc at that layer would not work right.
>
> Please define your 'right' behavior ;-)

Right here meant not excessive shrink calls for a particular node.

> If we need to discuss 'right' thing, we also need to define how behavior
> is right, I think. slab API itself don't have zone taste. but it implictly
> depend on a zone because buddy and reclaim are constructed on zones and
> slab is constructed on buddy. IOW, every slab object have a home zone.

True every page has a zone. However, per cpu caching and NUMA distances
only work per node (or per cache sharing domain which may just be a
fraction of a "node"). The slab allocators attempt to keep objects on
queues that are cache hot. For that purpose only the node matters not the
zone.

> So, which workload or usecause make a your head pain?

The head pain is because of the conflict of object tracking in the page
allocator per zone and in the slabs per node.

In general per zone object tracking in the page allocators percpu lists is
not optimal since at variance with how the cpu caches actually work.

- Cpu caches exist typically per node or per sharing domain (which is not
  reflected in the page allocators at all)

- NUMA distance effects only change for per node allocations.

The concept of a "zone" is for the benefit of certain legacy drivers that
have limitations for the memory range on which they can performa DMA
operations. With the IOMMUs and other modern technology this should no
longer be an issue.

An Mel used it to attach a side car (ZONE_MOVABLE) to the VM ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
