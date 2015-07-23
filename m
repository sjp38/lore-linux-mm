Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8642B9003C7
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 12:16:49 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so740623wib.1
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 09:16:49 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTPS id k1si31580304wif.77.2015.07.23.09.16.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 23 Jul 2015 09:16:48 -0700 (PDT)
Date: Thu, 23 Jul 2015 17:16:45 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm: Flush the TLB for a single address in a huge page
Message-ID: <20150723161644.GG27052@e104818-lin.cambridge.arm.com>
References: <1437585214-22481-1-git-send-email-catalin.marinas@arm.com>
 <alpine.DEB.2.10.1507221436350.21468@chino.kir.corp.google.com>
 <CAHkRjk7=VMG63VfZdWbZqYu8FOa9M+54Mmdro661E2zt3WToog@mail.gmail.com>
 <55B021B1.5020409@intel.com>
 <20150723104938.GA27052@e104818-lin.cambridge.arm.com>
 <20150723141303.GB23799@redhat.com>
 <55B0FD14.8050501@intel.com>
MIME-Version: 1.0
In-Reply-To: <55B0FD14.8050501@intel.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jul 23, 2015 at 03:41:24PM +0100, Dave Hansen wrote:
> On 07/23/2015 07:13 AM, Andrea Arcangeli wrote:
> > On Thu, Jul 23, 2015 at 11:49:38AM +0100, Catalin Marinas wrote:
> >> On Thu, Jul 23, 2015 at 12:05:21AM +0100, Dave Hansen wrote:
> >>> On 07/22/2015 03:48 PM, Catalin Marinas wrote:
> >>>> You are right, on x86 the tlb_single_page_flush_ceiling seems to be
> >>>> 33, so for an HPAGE_SIZE range the code does a local_flush_tlb()
> >>>> always. I would say a single page TLB flush is more efficient than a
> >>>> whole TLB flush but I'm not familiar enough with x86.
> >>>
> >>> The last time I looked, the instruction to invalidate a single page i=
s
> >>> more expensive than the instruction to flush the entire TLB.=20
> >>
> >> I was thinking of the overall cost of re-populating the TLB after bein=
g
> >> nuked rather than the instruction itself.
> >=20
> > Unless I'm not aware about timing differences in flushing 2MB TLB
> > entries vs flushing 4kb TLB entries with invlpg, the benchmarks that
> > have been run to tune the optimal tlb_single_page_flush_ceiling value,
> > should already guarantee us that this is a valid optimization (as we
> > just got one entry, we're not even close to the 33 ceiling that makes
> > it more a grey area).
>=20
> We had a discussion about this a few weeks ago:
>=20
> =09https://lkml.org/lkml/2015/6/25/666
>=20
> The argument is that the CPU is so good at refilling the TLB that it
> rarely waits on it, so the "cost" can be very very low.

Interesting thread. I can see from Ingo's benchmarks that invlpg is much
more expensive than the cr3 write but I can't really comment on the
refill cost (it may be small with page table caching in L1/L2). The
problem with small/targeted benchmarks is that you don't see the overall
impact.

On ARM, most recent CPUs can cache intermediate page table levels in the
TLB (usually as VA->pte translation). ARM64 introduces a new TLB
flushing instruction that only touches the last level (pte, huge pmd).
In theory this should be cheaper overall since the CPU doesn't need to
refill intermediate levels. In practice, it's probably lost in the
noise.

Anyway, if you want to keep the option of a full TLB flush for x86 on
huge pages, I'm happy to repost a v2 with a separate
flush_tlb_pmd_huge_page that arch code can define as it sees fit.

--=20
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
