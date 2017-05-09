Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B376E2806D7
	for <linux-mm@kvack.org>; Tue,  9 May 2017 10:40:04 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k57so646410wrk.6
        for <linux-mm@kvack.org>; Tue, 09 May 2017 07:40:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z185si1173430wmz.73.2017.05.09.07.40.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 07:40:03 -0700 (PDT)
Date: Tue, 9 May 2017 15:39:59 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC 03/10] x86/mm: Make the batched unmap TLB flush API more
 generic
Message-ID: <20170509143959.u5e5vryzo26pdse4@suse.de>
References: <cover.1494160201.git.luto@kernel.org>
 <983c5ee661d8fe8a70c596c4e77076d11ce3f80a.1494160201.git.luto@kernel.org>
 <d36207ef-a4b3-24ef-40e4-9e6a22b092cb@intel.com>
 <CALCETrXO2etzB55ZYk9xy4=8bWQC1+mv877tJHg-tOUpWGk6qw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CALCETrXO2etzB55ZYk9xy4=8bWQC1+mv877tJHg-tOUpWGk6qw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Sasha Levin <sasha.levin@oracle.com>

On Tue, May 09, 2017 at 06:02:49AM -0700, Andrew Lutomirski wrote:
> On Mon, May 8, 2017 at 8:34 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> > On 05/07/2017 05:38 AM, Andy Lutomirski wrote:
> >> diff --git a/mm/rmap.c b/mm/rmap.c
> >> index f6838015810f..2e568c82f477 100644
> >> --- a/mm/rmap.c
> >> +++ b/mm/rmap.c
> >> @@ -579,25 +579,12 @@ void page_unlock_anon_vma_read(struct anon_vma *anon_vma)
> >>  void try_to_unmap_flush(void)
> >>  {
> >>       struct tlbflush_unmap_batch *tlb_ubc = &current->tlb_ubc;
> >> -     int cpu;
> >>
> >>       if (!tlb_ubc->flush_required)
> >>               return;
> >>
> >> -     cpu = get_cpu();
> >> -
> >> -     if (cpumask_test_cpu(cpu, &tlb_ubc->cpumask)) {
> >> -             count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
> >> -             local_flush_tlb();
> >> -             trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
> >> -     }
> >> -
> >> -     if (cpumask_any_but(&tlb_ubc->cpumask, cpu) < nr_cpu_ids)
> >> -             flush_tlb_others(&tlb_ubc->cpumask, NULL, 0, TLB_FLUSH_ALL);
> >> -     cpumask_clear(&tlb_ubc->cpumask);
> >>       tlb_ubc->flush_required = false;
> >>       tlb_ubc->writable = false;
> >> -     put_cpu();
> >>  }
> >>
> >>  /* Flush iff there are potentially writable TLB entries that can race with IO */
> >> @@ -613,7 +600,7 @@ static void set_tlb_ubc_flush_pending(struct mm_struct *mm, bool writable)
> >>  {
> >>       struct tlbflush_unmap_batch *tlb_ubc = &current->tlb_ubc;
> >>
> >> -     cpumask_or(&tlb_ubc->cpumask, &tlb_ubc->cpumask, mm_cpumask(mm));
> >> +     arch_tlbbatch_add_mm(&tlb_ubc->arch, mm);
> >>       tlb_ubc->flush_required = true;
> >>
> >>       /*
> >
> > Looking at this patch in isolation, how can this be safe?  It removes
> > TLB flushes from the generic code.  Do other patches in the series fix
> > this up?
> 
> Hmm?  Unless I totally screwed this up, this patch just moves the
> flushes around -- it shouldn't remove any flushes.

I think he's asking when or how arch_tlbbatch_flush gets called because
it doesn't happen in try_to_unmap_flush().

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
