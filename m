Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2ECFF6B0003
	for <linux-mm@kvack.org>; Sat,  7 Jul 2018 11:25:47 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 31-v6so6652926plf.19
        for <linux-mm@kvack.org>; Sat, 07 Jul 2018 08:25:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 124-v6sor3116259pfg.142.2018.07.07.08.25.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 07 Jul 2018 08:25:45 -0700 (PDT)
Date: Sun, 8 Jul 2018 01:25:38 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: mm,tlb: revert 4647706ebeee?
Message-ID: <20180708012538.51b2c672@roar.ozlabs.ibm.com>
In-Reply-To: <1530896635.5350.25.camel@surriel.com>
References: <1530896635.5350.25.camel@surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "kirill.shutemov" <kirill.shutemov@linux.intel.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, kernel-team <kernel-team@fb.com>

On Fri, 06 Jul 2018 13:03:55 -0400
Rik van Riel <riel@surriel.com> wrote:

> Hello,
> 
> It looks like last summer, there were 2 sets of patches
> in flight to fix the issue of simultaneous mprotect/madvise
> calls unmapping PTEs, and some pages not being flushed from
> the TLB before returning to userspace.
> 
> Minchan posted these patches:
> 56236a59556c ("mm: refactor TLB gathering API")
> 99baac21e458 ("mm: fix MADV_[FREE|DONTNEED] TLB flush miss problem")
> 
> Around the same time, Mel posted:
> 4647706ebeee ("mm: always flush VMA ranges affected by zap_page_range")
> 
> They both appear to solve the same bug.
> 
> Only one of the two solutions is needed.
> 
> However, 4647706ebeee appears to introduce extra TLB
> flushes - one per VMA, instead of one over the entire
> range unmapped, and also extra flushes when there are
> no simultaneous unmappers of the same mm.
> 
> For that reason, it seems like we should revert
> 4647706ebeee and keep only Minchan's solution in
> the kernel.
> 
> Am I overlooking any reason why we should not revert
> 4647706ebeee?

Yes I think so. Discussed here recently:

https://marc.info/?l=linux-mm&m=152878780528037&w=2

Actually we realized that powerpc does not implement the mmu
gather flushing quite right so it needs a fix before this
revert. But I propose the revert for next merge window.

Thanks,
Nick
