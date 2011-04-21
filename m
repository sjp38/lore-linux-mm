Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DC0798D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 17:07:49 -0400 (EDT)
Date: Thu, 21 Apr 2011 16:07:43 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
In-Reply-To: <1303416315.4025.36.camel@mulgrave.site>
Message-ID: <alpine.DEB.2.00.1104211553390.9496@router.home>
References: <1303337718.2587.51.camel@mulgrave.site>  <alpine.DEB.2.00.1104201530430.13948@chino.kir.corp.google.com>  <20110421221712.9184.A69D9226@jp.fujitsu.com>  <1303403847.4025.11.camel@mulgrave.site>  <alpine.DEB.2.00.1104211328000.5741@router.home>
 <1303416315.4025.36.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>, Tejun Heo <tj@kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>

On Thu, 21 Apr 2011, James Bottomley wrote:

> > Dave Hansen, Mel: Can you provide us with some help? (Its Easter and so
> > the europeans may be off for awhile)
>
> It sort of depends on your definition of easy.  The problem going from
> DISCONTIGMEM to SPARSEMEM is sorting out the section size (the minimum
> indivisible size for a sectional_mem_map array) and also deciding on
> whether you need SPARSEMEM_EXTREME (discontigmem allows arbitrarily
> different sizes for each contiguous region) or
> ARCH_HAS_HOLES_MEMORYMODEL (allows empty mem_map regions as well).  I
> suspect most architectures will want SPARSEMEM_EXTREME (it means that
> the section array isn't fully populated) because the gaps can be huge
> (we've got a 64GB gap on parisc).

Well my favorite is SPARSEMEM_VMEMMAP because it allows page level holes
and uses the TLB (via page tables) to avoid lookups in the SPARSE maps but
that is likely not going to be in an initial fix.

> However, even though I think we can do this going forwards ... I don't
> think we can backport it as a bug fix for the slub panic.

So far there seems to be no other solution that will fix the issues
cleanly since we have a clash of the notions of a node in !NUMA between
core and discontig. Which is a pretty basic thing to get wrong.

If we can avoid all the fancy stuff and Dave can just get a minimal SPARSE
config going then this may be the best solution for stable as well.

But then these configs have been broken for years and no one noticed. This
means the users of these arches likely have been running a subset of
kernel functionality. I suspect they have never freed memory from
DISCONTIG node 1 and higher without CONFIG_DEBUG_VM on. Otherwise I
cannot explain why the VM_BUG_ONs did not trigger in
mm/page_alloc.c:move_freepages() that should have been brought to the MM
developers attention.

This set of circumstances leads to the suspicion that there were only
tests run that showed that the kernel booted. Higher node memory was never
touched and the MM code was never truly exercised.

So I am not sure that there is any urgency in this matter. No one has
cared for years after all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
