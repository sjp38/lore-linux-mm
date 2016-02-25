Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id EAA526B0256
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 11:01:14 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id a4so33938537wme.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 08:01:14 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id m26si4754476wmh.101.2016.02.25.08.01.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 08:01:13 -0800 (PST)
Received: by mail-wm0-x229.google.com with SMTP id a4so33937516wme.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 08:01:13 -0800 (PST)
Date: Thu, 25 Feb 2016 19:01:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe also
 on PowerPC and ARM)
Message-ID: <20160225160111.GB19707@node.shutemov.name>
References: <20160211192223.4b517057@thinkpad>
 <20160211190942.GA10244@node.shutemov.name>
 <20160211205702.24f0d17a@thinkpad>
 <20160212154116.GA15142@node.shutemov.name>
 <56BE00E7.1010303@de.ibm.com>
 <20160212181640.4eabb85f@thinkpad>
 <20160223103221.GA1418@node.shutemov.name>
 <20160223191907.25719a4d@thinkpad>
 <20160223184658.GA27281@arm.com>
 <CAPvkgC3gfmgA9aCvCeqReKhjpkT5Y-qk-2fNO8puDjUs9EWzVw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPvkgC3gfmgA9aCvCeqReKhjpkT5Y-qk-2fNO8puDjUs9EWzVw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: Will Deacon <will.deacon@arm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Steve Capper <steve.capper@arm.com>

On Thu, Feb 25, 2016 at 03:49:33PM +0000, Steve Capper wrote:
> On 23 February 2016 at 18:47, Will Deacon <will.deacon@arm.com> wrote:
> > [adding Steve, since he worked on THP for 32-bit ARM]
> 
> Apologies for my late reply...
> 
> >
> > On Tue, Feb 23, 2016 at 07:19:07PM +0100, Gerald Schaefer wrote:
> >> On Tue, 23 Feb 2016 13:32:21 +0300
> >> "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> >> > The theory is that the splitting bit effetely masked bogus pmd_present():
> >> > we had pmd_trans_splitting() in all code path and that prevented mm from
> >> > touching the pmd. Once pmd_trans_splitting() has gone, mm proceed with the
> >> > pmd where it shouldn't and here's a boom.
> >>
> >> Well, I don't think pmd_present() == true is bogus for a trans_huge pmd under
> >> splitting, after all there is a page behind the the pmd. Also, if it was
> >> bogus, and it would need to be false, why should it be marked !pmd_present()
> >> only at the pmdp_invalidate() step before the pmd_populate()? It clearly
> >> is pmd_present() before that, on all architectures, and if there was any
> >> problem/race with that, setting it to !pmd_present() at this stage would
> >> only (marginally) reduce the race window.
> >>
> >> BTW, PowerPC and Sparc seem to do the same thing in pmdp_invalidate(),
> >> i.e. they do not set pmd_present() == false, only mark it so that it would
> >> not generate a new TLB entry, just like on s390. After all, the function
> >> is called pmdp_invalidate(), and I think the comment in mm/huge_memory.c
> >> before that call is just a little ambiguous in its wording. When it says
> >> "mark the pmd notpresent" it probably means "mark it so that it will not
> >> generate a new TLB entry", which is also what the comment is really about:
> >> prevent huge and small entries in the TLB for the same page at the same
> >> time.
> >>
> >> FWIW, and since the ARM arch-list is already on cc, I think there is
> >> an issue with pmdp_invalidate() on ARM, since it also seems to clear
> >> the trans_huge (and formerly trans_splitting) bit, which actually makes
> >> the pmd !pmd_present(), but it violates the other requirement from the
> >> comment:
> >> "the pmd_trans_huge and pmd_trans_splitting must remain set at all times
> >> on the pmd until the split is complete for this pmd"
> >
> > I've only been testing this for arm64 (where I'm yet to see a problem),
> > but we use the generic pmdp_invalidate implementation from
> > mm/pgtable-generic.c there. On arm64, pmd_trans_huge will return true
> > after pmd_mknotpresent. On arm, it does look to be buggy, since it nukes
> > the entire entry... Steve?
> 
> pmd_mknotpresent on arm looks inconsistent with the other
> architectures and can be changed.
> 
> Having had a look at the usage, I can't see it causing an immediate
> problem (that needs to be addressed by an emergency patch).
> We don't have a notion of splitting pmds (so there is no splitting
> information to lose), and the only usage I could see of
> pmd_mknotpresent was:
> 
> pmdp_invalidate(vma, haddr, pmd);
> pmd_populate(mm, pmd, pgtable);
> 
> In mm/huge_memory.c, around line 3588.
> 
> So we invalidate the entry (which puts down a faulting entry from
> pmd_mknotpresent and invalidates tlb), then immediately put down a
> table entry with pmd_populate.
> 
> I have run a 32-bit ARM test kernel and exacerbated THP splits (that's
> what took me time), and I didn't notice any problems with 4.5-rc5.

If I read code correctly, your pmd_mknotpresent() makes the pmd
pmd_none(), right? If yes, it's a problem.

It introduces race I've described here:

https://marc.info/?l=linux-mm&m=144723658100512&w=4

Basically, if zap_pmd_range() would see pmd_none() between
pmdp_mknotpresent() and pmd_populate(), we're screwed.

The race window is small, but it's there.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
