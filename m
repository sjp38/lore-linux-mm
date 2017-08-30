Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CFCAD6B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 12:47:27 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id r133so13266990pgr.6
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 09:47:27 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f15sor4878885pln.9.2017.08.30.09.47.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Aug 2017 09:47:26 -0700 (PDT)
Date: Wed, 30 Aug 2017 09:47:24 -0700
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [kernel-hardening] [PATCH v5 04/10] arm64: Add __flush_tlb_one()
Message-ID: <20170830164724.m6bbogd46ix4qp4o@docker>
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-5-tycho@docker.com>
 <20170812112603.GB16374@remoulade>
 <20170814163536.6njceqc3dip5lrlu@smitten>
 <20170814165047.GB23428@leverpostej>
 <20170823165842.k5lbxom45avvd7g2@smitten>
 <20170823170443.GD12567@leverpostej>
 <2428d66f-3c31-fa73-0d6a-c16fafa99455@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2428d66f-3c31-fa73-0d6a-c16fafa99455@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juerg Haefliger <juerg.haefliger@canonical.com>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>

On Wed, Aug 30, 2017 at 07:31:25AM +0200, Juerg Haefliger wrote:
> 
> 
> On 08/23/2017 07:04 PM, Mark Rutland wrote:
> > On Wed, Aug 23, 2017 at 10:58:42AM -0600, Tycho Andersen wrote:
> >> Hi Mark,
> >>
> >> On Mon, Aug 14, 2017 at 05:50:47PM +0100, Mark Rutland wrote:
> >>> That said, is there any reason not to use flush_tlb_kernel_range()
> >>> directly?
> >>
> >> So it turns out that there is a difference between __flush_tlb_one() and
> >> flush_tlb_kernel_range() on x86: flush_tlb_kernel_range() flushes all the TLBs
> >> via on_each_cpu(), where as __flush_tlb_one() only flushes the local TLB (which
> >> I think is enough here).
> > 
> > That sounds suspicious; I don't think that __flush_tlb_one() is
> > sufficient.
> > 
> > If you only do local TLB maintenance, then the page is left accessible
> > to other CPUs via the (stale) kernel mappings. i.e. the page isn't
> > exclusively mapped by userspace.
> 
> We flush all CPUs to get rid of stale entries when a new page is
> allocated to userspace that was previously allocated to the kernel.
> Is that the scenario you were thinking of?

I think there are two cases, the one you describe above, where the
pages are first allocated, and a second one, where e.g. the pages are
mapped into the kernel because of DMA or whatever. In the case you
describe above, I think we're doing the right thing (which is why my
test worked correctly, because it tested this case).

In the second case, when the pages are unmapped (i.e. the kernel is
done doing DMA), do we need to flush the other CPUs TLBs? I think the
current code is not quite correct, because if multiple tasks (CPUs)
map the pages, only the TLB of the last one is flushed when the
mapping is cleared, because the tlb is only flushed when ->mapcount
drops to zero, leaving stale entries in the other TLBs. It's not clear
to me what to do about this case.

Thoughts?

Tycho

> ...Juerg
> 
> 
> > Thanks,
> > Mark.
> > 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
