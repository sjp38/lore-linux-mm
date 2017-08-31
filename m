Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 316606B039F
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 17:21:47 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n7so4551959pfi.7
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 14:21:47 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b3sor435161pli.11.2017.08.31.14.21.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Aug 2017 14:21:45 -0700 (PDT)
Date: Thu, 31 Aug 2017 14:21:43 -0700
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [kernel-hardening] [PATCH v5 04/10] arm64: Add __flush_tlb_one()
Message-ID: <20170831212143.3rzgru3kmci6vnxd@docker>
References: <20170809200755.11234-5-tycho@docker.com>
 <20170812112603.GB16374@remoulade>
 <20170814163536.6njceqc3dip5lrlu@smitten>
 <20170814165047.GB23428@leverpostej>
 <20170823165842.k5lbxom45avvd7g2@smitten>
 <20170823170443.GD12567@leverpostej>
 <2428d66f-3c31-fa73-0d6a-c16fafa99455@canonical.com>
 <20170830164724.m6bbogd46ix4qp4o@docker>
 <b50951e4-0b80-6d0e-39ed-fd9d67a51db3@canonical.com>
 <20170831094726.GB15031@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170831094726.GB15031@leverpostej>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>

Hi all,

On Thu, Aug 31, 2017 at 10:47:27AM +0100, Mark Rutland wrote:
> On Thu, Aug 31, 2017 at 11:43:53AM +0200, Juerg Haefliger wrote:
> > On 08/30/2017 06:47 PM, Tycho Andersen wrote:
> > > On Wed, Aug 30, 2017 at 07:31:25AM +0200, Juerg Haefliger wrote:
> > >>
> > >>
> > >> On 08/23/2017 07:04 PM, Mark Rutland wrote:
> > >>> On Wed, Aug 23, 2017 at 10:58:42AM -0600, Tycho Andersen wrote:
> > >>>> Hi Mark,
> > >>>>
> > >>>> On Mon, Aug 14, 2017 at 05:50:47PM +0100, Mark Rutland wrote:
> > >>>>> That said, is there any reason not to use flush_tlb_kernel_range()
> > >>>>> directly?
> > >>>>
> > >>>> So it turns out that there is a difference between __flush_tlb_one() and
> > >>>> flush_tlb_kernel_range() on x86: flush_tlb_kernel_range() flushes all the TLBs
> > >>>> via on_each_cpu(), where as __flush_tlb_one() only flushes the local TLB (which
> > >>>> I think is enough here).
> > >>>
> > >>> That sounds suspicious; I don't think that __flush_tlb_one() is
> > >>> sufficient.
> > >>>
> > >>> If you only do local TLB maintenance, then the page is left accessible
> > >>> to other CPUs via the (stale) kernel mappings. i.e. the page isn't
> > >>> exclusively mapped by userspace.
> > >>
> > >> We flush all CPUs to get rid of stale entries when a new page is
> > >> allocated to userspace that was previously allocated to the kernel.
> > >> Is that the scenario you were thinking of?
> > > 
> > > I think there are two cases, the one you describe above, where the
> > > pages are first allocated, and a second one, where e.g. the pages are
> > > mapped into the kernel because of DMA or whatever. In the case you
> > > describe above, I think we're doing the right thing (which is why my
> > > test worked correctly, because it tested this case).
> > > 
> > > In the second case, when the pages are unmapped (i.e. the kernel is
> > > done doing DMA), do we need to flush the other CPUs TLBs? I think the
> > > current code is not quite correct, because if multiple tasks (CPUs)
> > > map the pages, only the TLB of the last one is flushed when the
> > > mapping is cleared, because the tlb is only flushed when ->mapcount
> > > drops to zero, leaving stale entries in the other TLBs. It's not clear
> > > to me what to do about this case.
> > 
> > For this to happen, multiple CPUs need to have the same userspace page
> > mapped at the same time. Is this a valid scenario?
> 
> I believe so. I think you could trigger that with a multi-threaded
> application running across several CPUs. All those threads would share
> the same page tables.

I played around with trying to track this per-cpu, and I'm not sure
there's a nice way to do it (see the patch below, and the comment
about correctness [never mind that this patch calls alloc_percpu from
a possibly atomic context]).

I think it may be best to just flush all the TLBs of the DMA range
when the last task unmaps it. This would leave a small exploitable
race where a task had mapped/unmapped the page, but some other page
still had it mapped.

If anyone has any better ideas please let me know, otherwise I'll just
flush all the TLBs when the use count drops to zero, and post the next
version Soon (TM).

Cheers,

Tycho
