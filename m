Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id BB1769003C8
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 19:05:22 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so145783826pdr.2
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 16:05:22 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id pj10si6948430pac.162.2015.07.22.16.05.21
        for <linux-mm@kvack.org>;
        Wed, 22 Jul 2015 16:05:21 -0700 (PDT)
Message-ID: <55B021B1.5020409@intel.com>
Date: Wed, 22 Jul 2015 16:05:21 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Flush the TLB for a single address in a huge page
References: <1437585214-22481-1-git-send-email-catalin.marinas@arm.com> <alpine.DEB.2.10.1507221436350.21468@chino.kir.corp.google.com> <CAHkRjk7=VMG63VfZdWbZqYu8FOa9M+54Mmdro661E2zt3WToog@mail.gmail.com>
In-Reply-To: <CAHkRjk7=VMG63VfZdWbZqYu8FOa9M+54Mmdro661E2zt3WToog@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, David Rientjes <rientjes@google.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

On 07/22/2015 03:48 PM, Catalin Marinas wrote:
> You are right, on x86 the tlb_single_page_flush_ceiling seems to be
> 33, so for an HPAGE_SIZE range the code does a local_flush_tlb()
> always. I would say a single page TLB flush is more efficient than a
> whole TLB flush but I'm not familiar enough with x86.

The last time I looked, the instruction to invalidate a single page is
more expensive than the instruction to flush the entire TLB.  We also
don't bother doing ranged flushes _ever_ for hugetlbfs TLB
invalidations, but that was just because the work done around commit
e7b52ffd4 didn't see any benefit.

That said, I can't imagine this will hurt anything.  We also have TLBs
that can mix 2M and 4k pages and I don't think we did back when we put
that code in originally.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
