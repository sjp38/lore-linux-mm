Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id ACFAF6B0005
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 20:13:59 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v25-v6so4544868pfm.11
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 17:13:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u1-v6si5376235plk.97.2018.07.09.17.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 17:13:58 -0700 (PDT)
Date: Mon, 9 Jul 2018 17:13:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mm,tlb: revert 4647706ebeee?
Message-Id: <20180709171356.87d834e125f06e0cdaa72f85@linux-foundation.org>
In-Reply-To: <20180708012538.51b2c672@roar.ozlabs.ibm.com>
References: <1530896635.5350.25.camel@surriel.com>
	<20180708012538.51b2c672@roar.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Rik van Riel <riel@surriel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, "kirill.shutemov" <kirill.shutemov@linux.intel.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, kernel-team <kernel-team@fb.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Nadav Amit <nadav.amit@gmail.com>

On Sun, 8 Jul 2018 01:25:38 +1000 Nicholas Piggin <npiggin@gmail.com> wrote:

> On Fri, 06 Jul 2018 13:03:55 -0400
> Rik van Riel <riel@surriel.com> wrote:
> 
> > Hello,
> > 
> > It looks like last summer, there were 2 sets of patches
> > in flight to fix the issue of simultaneous mprotect/madvise
> > calls unmapping PTEs, and some pages not being flushed from
> > the TLB before returning to userspace.
> > 
> > Minchan posted these patches:
> > 56236a59556c ("mm: refactor TLB gathering API")
> > 99baac21e458 ("mm: fix MADV_[FREE|DONTNEED] TLB flush miss problem")
> > 
> > Around the same time, Mel posted:
> > 4647706ebeee ("mm: always flush VMA ranges affected by zap_page_range")
> > 
> > They both appear to solve the same bug.
> > 
> > Only one of the two solutions is needed.
> > 
> > However, 4647706ebeee appears to introduce extra TLB
> > flushes - one per VMA, instead of one over the entire
> > range unmapped, and also extra flushes when there are
> > no simultaneous unmappers of the same mm.
> > 
> > For that reason, it seems like we should revert
> > 4647706ebeee and keep only Minchan's solution in
> > the kernel.
> > 
> > Am I overlooking any reason why we should not revert
> > 4647706ebeee?
> 
> Yes I think so. Discussed here recently:
> 
> https://marc.info/?l=linux-mm&m=152878780528037&w=2

Unclear if that was an ack ;)

> Actually we realized that powerpc does not implement the mmu
> gather flushing quite right so it needs a fix before this
> revert. But I propose the revert for next merge window.

Yes, I have Rik's patch for 4.19-rc1.  I added yourself, Aneesh and
Nadav to cc so you'll see it fly past.  If poss, please do get this all
tested before the time comes and let me know?
