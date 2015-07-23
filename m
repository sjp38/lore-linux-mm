Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 18D309003C7
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 12:49:26 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so2020108wib.1
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 09:49:25 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTPS id d2si9496298wjw.157.2015.07.23.09.49.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 23 Jul 2015 09:49:24 -0700 (PDT)
Date: Thu, 23 Jul 2015 17:49:21 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm: Flush the TLB for a single address in a huge page
Message-ID: <20150723164921.GH27052@e104818-lin.cambridge.arm.com>
References: <1437585214-22481-1-git-send-email-catalin.marinas@arm.com>
 <alpine.DEB.2.10.1507221436350.21468@chino.kir.corp.google.com>
 <CAHkRjk7=VMG63VfZdWbZqYu8FOa9M+54Mmdro661E2zt3WToog@mail.gmail.com>
 <55B021B1.5020409@intel.com>
 <20150723104938.GA27052@e104818-lin.cambridge.arm.com>
 <20150723141303.GB23799@redhat.com>
MIME-Version: 1.0
In-Reply-To: <20150723141303.GB23799@redhat.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Thu, Jul 23, 2015 at 03:13:03PM +0100, Andrea Arcangeli wrote:
> On Thu, Jul 23, 2015 at 11:49:38AM +0100, Catalin Marinas wrote:
> > On Thu, Jul 23, 2015 at 12:05:21AM +0100, Dave Hansen wrote:
> > > On 07/22/2015 03:48 PM, Catalin Marinas wrote:
> > > > You are right, on x86 the tlb_single_page_flush_ceiling seems to be
> > > > 33, so for an HPAGE_SIZE range the code does a local_flush_tlb()
> > > > always. I would say a single page TLB flush is more efficient than =
a
> > > > whole TLB flush but I'm not familiar enough with x86.
> > >=20
> > > The last time I looked, the instruction to invalidate a single page i=
s
> > > more expensive than the instruction to flush the entire TLB.=20
[...]
> > Another question is whether flushing a single address is enough for a
> > huge page. I assumed it is since tlb_remove_pmd_tlb_entry() only adjust=
s
[...]
> > the mmu_gather range by PAGE_SIZE (rather than HPAGE_SIZE) and
> > no-one complained so far. AFAICT, there are only 3 architectures
> > that don't use asm-generic/tlb.h but they all seem to handle this
> > case:
>=20
> Agreed that archs using the generic tlb.h that sets the tlb->end to
> address+PAGE_SIZE should be fine with the flush_tlb_page.
>=20
> > arch/arm: it implements tlb_remove_pmd_tlb_entry() in a similar way to
> > the generic one
> >=20
> > arch/s390: tlb_remove_pmd_tlb_entry() is a no-op
>=20
> I guess s390 is fine too but I'm not convinced that the fact it won't
> adjust the tlb->start/end is a guarantees that flush_tlb_page is
> enough when a single 2MB TLB has to be invalidated (not during range
> zapping).
>=20
> For the range zapping, could the arch decide to unconditionally flush
> the whole TLB without doing the tlb->start/end tracking by overriding
> tlb_gather_mmu in a way that won't call __tlb_reset_range? There seems
> to be quite some flexibility in the per-arch tlb_gather_mmu setup in
> order to unconditionally set tlb->start/end to the total range zapped,
> without actually narrowing it down during the pagetable walk.

You are right, looking at the s390 code, tlb_finish_mmu() flushes the
whole TLB, so the ranges don't seem to matter. I'm cc'ing the s390
maintainers to confirm whether this patch affects them in any way:

https://lkml.org/lkml/2015/7/22/521

IIUC, all the functions touched by this patch are implemented by s390 in
its specific way, so I don't think it makes any difference:

pmdp_set_access_flags
pmdp_clear_flush_young
pmdp_huge_clear_flush
pmdp_splitting_flush
pmdp_invalidate

--=20
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
