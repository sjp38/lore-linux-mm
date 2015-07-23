Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4066B0254
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 06:49:44 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so18207166wic.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 03:49:43 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTPS id ft10si22807275wib.100.2015.07.23.03.49.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 23 Jul 2015 03:49:42 -0700 (PDT)
Date: Thu, 23 Jul 2015 11:49:38 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm: Flush the TLB for a single address in a huge page
Message-ID: <20150723104938.GA27052@e104818-lin.cambridge.arm.com>
References: <1437585214-22481-1-git-send-email-catalin.marinas@arm.com>
 <alpine.DEB.2.10.1507221436350.21468@chino.kir.corp.google.com>
 <CAHkRjk7=VMG63VfZdWbZqYu8FOa9M+54Mmdro661E2zt3WToog@mail.gmail.com>
 <55B021B1.5020409@intel.com>
MIME-Version: 1.0
In-Reply-To: <55B021B1.5020409@intel.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

On Thu, Jul 23, 2015 at 12:05:21AM +0100, Dave Hansen wrote:
> On 07/22/2015 03:48 PM, Catalin Marinas wrote:
> > You are right, on x86 the tlb_single_page_flush_ceiling seems to be
> > 33, so for an HPAGE_SIZE range the code does a local_flush_tlb()
> > always. I would say a single page TLB flush is more efficient than a
> > whole TLB flush but I'm not familiar enough with x86.
>=20
> The last time I looked, the instruction to invalidate a single page is
> more expensive than the instruction to flush the entire TLB.=20

I was thinking of the overall cost of re-populating the TLB after being
nuked rather than the instruction itself.

> We also don't bother doing ranged flushes _ever_ for hugetlbfs TLB
> invalidations, but that was just because the work done around commit
> e7b52ffd4 didn't see any benefit.

For huge pages, there are indeed fewer page table levels to fetch, so I
guess the impact is not significant. With virtualisation/nested pages,
at least on ARM, refilling the TLB for guest would take longer (though
it's highly dependent on the microarchitecture implementation, whether
it caches the guest PA to host PA separately).

> That said, I can't imagine this will hurt anything.  We also have TLBs
> that can mix 2M and 4k pages and I don't think we did back when we put
> that code in originally.

Another question is whether flushing a single address is enough for a
huge page. I assumed it is since tlb_remove_pmd_tlb_entry() only adjusts
the mmu_gather range by PAGE_SIZE (rather than HPAGE_SIZE) and no-one
complained so far. AFAICT, there are only 3 architectures that don't use
asm-generic/tlb.h but they all seem to handle this case:

arch/arm: it implements tlb_remove_pmd_tlb_entry() in a similar way to
the generic one

arch/s390: tlb_remove_pmd_tlb_entry() is a no-op

arch/ia64: does not support THP

--=20
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
