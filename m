Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E329B6B006A
	for <linux-mm@kvack.org>; Sat, 31 Oct 2009 17:29:33 -0400 (EDT)
Subject: Re: RFC: Transparent Hugepage support
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20091026185130.GC4868@random.random>
References: <20091026185130.GC4868@random.random>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 01 Nov 2009 08:29:27 +1100
Message-ID: <1257024567.7907.17.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-10-26 at 19:51 +0100, Andrea Arcangeli wrote:
> Hello,
> 
> Lately I've been working to make KVM use hugepages transparently
> without the usual restrictions of hugetlbfs. Some of the restrictions
> I'd like to see removed:
> 
> 1) hugepages have to be swappable or the guest physical memory remains
>    locked in RAM and can't be paged out to swap
> 
> 2) if a hugepage allocation fails, regular pages should be allocated
>    instead and mixed in the same vma without any failure and without
>    userland noticing

This isn't possible on all architectures. Some archs have "segment"
constraints which mean only one page size per such "segment". Server
ppc's for example (segment size being either 256M or 1T depending on the
CPU).

> 3) if some task quits and more hugepages become available in the
>    buddy, guest physical memory backed by regular pages should be
>    relocated on hugepages automatically in regions under
>    madvise(MADV_HUGEPAGE) (ideally event driven by waking up the
>    kernel deamon if the order=HPAGE_SHIFT-PAGE_SHIFT list becomes not
>    null)
> 
> The first (and more tedious) part of this work requires allowing the
> VM to handle anonymous hugepages mixed with regular pages
> transparently on regular anonymous vmas. This is what this patch tries
> to achieve in the least intrusive possible way. We want hugepages and
> hugetlb to be used in a way so that all applications can benefit
> without changes (as usual we leverage the KVM virtualization design:
> by improving the Linux VM at large, KVM gets the performance boost too).
> 
> The most important design choice is: always fallback to 4k allocation
> if the hugepage allocation fails! This is the _very_ opposite of some
> large pagecache patches that failed with -EIO back then if a 64k (or
> similar) allocation failed...

Precisely because the approach cannot work on all architectures ?

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
