Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 685976B006E
	for <linux-mm@kvack.org>; Mon, 13 Oct 2014 07:44:37 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id h11so3457897wiw.1
        for <linux-mm@kvack.org>; Mon, 13 Oct 2014 04:44:36 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id cq6si12381906wib.34.2014.10.13.04.44.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Oct 2014 04:44:35 -0700 (PDT)
Received: by mail-wi0-f179.google.com with SMTP id d1so7180755wiv.6
        for <linux-mm@kvack.org>; Mon, 13 Oct 2014 04:44:35 -0700 (PDT)
Date: Mon, 13 Oct 2014 12:44:28 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATCH V4 1/6] mm: Introduce a general RCU get_user_pages_fast.
Message-ID: <20141013114428.GA28113@linaro.org>
References: <1411740233-28038-2-git-send-email-steve.capper@linaro.org>
 <20141002121902.GA2342@redhat.com>
 <87d29w1rf7.fsf@linux.vnet.ibm.com>
 <20141013.012146.992477977260812742.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141013.012146.992477977260812742.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, aneesh.kumar@linux.vnet.ibm.com
Cc: aarcange@redhat.com, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-arch@vger.kernel.org, linux-mm@kvack.org, will.deacon@arm.com, gary.robertson@linaro.org, christoffer.dall@linaro.org, peterz@infradead.org, anders.roxell@linaro.org, akpm@linux-foundation.org, dann.frazier@canonical.com, mark.rutland@arm.com, mgorman@suse.de, hughd@google.com

On Mon, Oct 13, 2014 at 01:21:46AM -0400, David Miller wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Date: Mon, 13 Oct 2014 10:45:24 +0530
> 
> > Andrea Arcangeli <aarcange@redhat.com> writes:
> > 
> >> Hi Steve,
> >>
> >> On Fri, Sep 26, 2014 at 03:03:48PM +0100, Steve Capper wrote:
> >>> This patch provides a general RCU implementation of get_user_pages_fast
> >>> that can be used by architectures that perform hardware broadcast of
> >>> TLB invalidations.
> >>> 
> >>> It is based heavily on the PowerPC implementation by Nick Piggin.
> >>
> >> It'd be nice if you could also at the same time apply it to sparc and
> >> powerpc in this same patchset to show the effectiveness of having a
> >> generic version. Because if it's not a trivial drop-in replacement,
> >> then this should go in arch/arm* instead of mm/gup.c...
> > 
> > on ppc64 we have one challenge, we do need to support hugepd. At the pmd
> > level we can have hugepte, normal pmd pointer or a pointer to hugepage
> > directory which is used in case of some sub-architectures/platforms. ie,
> > the below part of gup implementation in ppc64
> > 
> > else if (is_hugepd(pmdp)) {
> > 	if (!gup_hugepd((hugepd_t *)pmdp, PMD_SHIFT,
> > 			addr, next, write, pages, nr))
> > 		return 0;
> 
> Sparc has to deal with the same issue.

Hi Aneesh, David,

Could we add some helpers to mm/gup.c to deal with the hugepage
directory cases? If my understanding is correct, this arises for
HugeTLB pages rather than THP? (I should have listed under the
assumptions made that HugeTLB and THP have the same page table
entries).

For Sparc, if the huge pte case were to be separated out from the
normal pte case we could use page_cache_add_speculative rather than
make repeated calls to page_cache_get_speculative?

Also, as a heads up for Sparc. I don't see any definition of
__get_user_pages_fast. Does this mean that a futex on THP tail page
can cause an infinite loop?

I don't have the means to thoroughly test patches for PowerPC and Sparc
(nor do I have enough knowledge to safely write them). I was going to
ask if you could please have a go at enabling this for PowerPC and
Sparc and I could check the ARM side and help out with mm/gup.c?

Cheers,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
