Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4F2496B0031
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 18:53:50 -0500 (EST)
Received: by mail-ee0-f49.google.com with SMTP id c41so548455eek.36
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 15:53:49 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si62003eeo.86.2013.12.12.15.53.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 15:53:49 -0800 (PST)
Date: Thu, 12 Dec 2013 23:53:46 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/3] x86: mm: Clean up inconsistencies when flushing TLB
 ranges
Message-ID: <20131212235237.GK11295@suse.de>
References: <1386849309-22584-1-git-send-email-mgorman@suse.de>
 <1386849309-22584-2-git-send-email-mgorman@suse.de>
 <52A9C145.9050706@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <52A9C145.9050706@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@linaro.org>
Cc: H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Dec 12, 2013 at 09:59:33PM +0800, Alex Shi wrote:
> On 12/12/2013 07:55 PM, Mel Gorman wrote:
> > NR_TLB_LOCAL_FLUSH_ALL is not always accounted for correctly and the
> > comparison with total_vm is done before taking tlb_flushall_shift into
> > account. Clean it up.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> Reviewed-by: Alex Shi

Thanks.

> > ---
> >  arch/x86/mm/tlb.c | 12 ++++++------
> >  1 file changed, 6 insertions(+), 6 deletions(-)
> > 
> > diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
> > index ae699b3..09b8cb8 100644
> > --- a/arch/x86/mm/tlb.c
> > +++ b/arch/x86/mm/tlb.c
> > @@ -189,6 +189,7 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
> >  {
> >  	unsigned long addr;
> >  	unsigned act_entries, tlb_entries = 0;
> > +	unsigned long nr_base_pages;
> >  
> >  	preempt_disable();
> >  	if (current->active_mm != mm)
> > @@ -210,18 +211,17 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
> >  		tlb_entries = tlb_lli_4k[ENTRIES];
> >  	else
> >  		tlb_entries = tlb_lld_4k[ENTRIES];
> > +
> >  	/* Assume all of TLB entries was occupied by this task */
> 
> the benchmark break this assumption?

No, but it's a small benchmark with very little else running at the
time. It's an assumption that would only hold true on dedicated machines
to a single application. It would not hold true on desktops, multi-tier
server applications etc.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
