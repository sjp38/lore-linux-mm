Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5F8C76B0005
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 01:04:19 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id b5-v6so11644026ple.20
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 22:04:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f3-v6sor4792052pld.40.2018.07.09.22.04.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Jul 2018 22:04:17 -0700 (PDT)
Date: Tue, 10 Jul 2018 15:04:10 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: mm,tlb: revert 4647706ebeee?
Message-ID: <20180710150410.4207bbfa@roar.ozlabs.ibm.com>
In-Reply-To: <20180709171356.87d834e125f06e0cdaa72f85@linux-foundation.org>
References: <1530896635.5350.25.camel@surriel.com>
	<20180708012538.51b2c672@roar.ozlabs.ibm.com>
	<20180709171356.87d834e125f06e0cdaa72f85@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@surriel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, "kirill.shutemov" <kirill.shutemov@linux.intel.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, kernel-team <kernel-team@fb.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Nadav Amit <nadav.amit@gmail.com>, linux-arch <linux-arch@vger.kernel.org>

On Mon, 9 Jul 2018 17:13:56 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Sun, 8 Jul 2018 01:25:38 +1000 Nicholas Piggin <npiggin@gmail.com> wrote:
> 
> > On Fri, 06 Jul 2018 13:03:55 -0400
> > Rik van Riel <riel@surriel.com> wrote:
> >   
> > > Hello,
> > > 
> > > It looks like last summer, there were 2 sets of patches
> > > in flight to fix the issue of simultaneous mprotect/madvise
> > > calls unmapping PTEs, and some pages not being flushed from
> > > the TLB before returning to userspace.
> > > 
> > > Minchan posted these patches:
> > > 56236a59556c ("mm: refactor TLB gathering API")
> > > 99baac21e458 ("mm: fix MADV_[FREE|DONTNEED] TLB flush miss problem")
> > > 
> > > Around the same time, Mel posted:
> > > 4647706ebeee ("mm: always flush VMA ranges affected by zap_page_range")
> > > 
> > > They both appear to solve the same bug.
> > > 
> > > Only one of the two solutions is needed.
> > > 
> > > However, 4647706ebeee appears to introduce extra TLB
> > > flushes - one per VMA, instead of one over the entire
> > > range unmapped, and also extra flushes when there are
> > > no simultaneous unmappers of the same mm.
> > > 
> > > For that reason, it seems like we should revert
> > > 4647706ebeee and keep only Minchan's solution in
> > > the kernel.
> > > 
> > > Am I overlooking any reason why we should not revert
> > > 4647706ebeee?  
> > 
> > Yes I think so. Discussed here recently:
> > 
> > https://marc.info/?l=linux-mm&m=152878780528037&w=2  
> 
> Unclear if that was an ack ;)
>

Sure, I'm thinking Rik's mail is a ack for my patch :)

No actually I think it's okay, but was in the middle of testing
my series when Aneesh pointed out a bit was missing from powerpc,
so I had to go off and fix that, I think that's upstream now. So
need to go back and re-test this revert.

Wouldn't hurt for other arch maintainers to have a look I guess
(cc linux-arch):

The problem powerpc had is that mmu_gather flushing will flush a
single page size based on the ptes it encounters when we zap. If
we hit a different page size, it flushes and switches to the new
size. If we have concurrent zaps on the same range, the other
thread may have cleared a large page pte so we won't see that and
will only do a small page flush for that range. Which means we can
return before the other thread invalidated our TLB for the large
pages in the range we wanted to flush.

I suspect most arches are probably okay, but if you make any TLB
flush choices based on the pte contents, then you could be exposed.
Except in the case of archs like sparc and powerpc/hash which do
the flushing in arch_leave_lazy_mmu_mode(), because that is called
under the same page table lock, so there can't be concurrent zap.

A quick look through the archs doesn't show anything obvious, but
please take a look at your arch.

And I'll try to do a bit more testing.

Thanks,
Nick
