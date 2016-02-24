Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6774B6B0254
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 05:41:34 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id yy13so10715043pab.3
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 02:41:34 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g24si4163791pfj.184.2016.02.24.02.41.33
        for <linux-mm@kvack.org>;
        Wed, 24 Feb 2016 02:41:33 -0800 (PST)
Date: Wed, 24 Feb 2016 10:41:40 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe also
 on PowerPC and ARM)
Message-ID: <20160224104139.GC28310@arm.com>
References: <20160211190942.GA10244@node.shutemov.name>
 <20160211205702.24f0d17a@thinkpad>
 <20160212154116.GA15142@node.shutemov.name>
 <56BE00E7.1010303@de.ibm.com>
 <20160212181640.4eabb85f@thinkpad>
 <20160223103221.GA1418@node.shutemov.name>
 <20160223191907.25719a4d@thinkpad>
 <20160223193345.GC21820@node.shutemov.name>
 <20160223202233.GE27281@arm.com>
 <56CD8302.9080202@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56CD8302.9080202@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>

On Wed, Feb 24, 2016 at 11:16:34AM +0100, Christian Borntraeger wrote:
> On 02/23/2016 09:22 PM, Will Deacon wrote:
> > On Tue, Feb 23, 2016 at 10:33:45PM +0300, Kirill A. Shutemov wrote:
> >> On Tue, Feb 23, 2016 at 07:19:07PM +0100, Gerald Schaefer wrote:
> >>> I'll check with Martin, maybe it is actually trivial, then we can
> >>> do a quick test it to rule that one out.
> >>
> >> Oh. I found a bug in __split_huge_pmd_locked(). Although, not sure if it's
> >> _the_ bug.
> >>
> >> pmdp_invalidate() is called for the wrong address :-/
> >> I guess that can be destructive on the architecture, right?
> > 
> > FWIW, arm64 ignores the address parameter for set_pmd_at, so this would
> > only result in the TLBI nuking the wrong entries, which is going to be
> > tricky to observe in practice given that we install a table entry
> > immediately afterwards that maps the same pages. If s390 does more here
> > (I see some magic asm using the address), that could be the answer...
> 
> This patch does not change the address for set_pmd_at, it does that for the 
> pmdp_invalidate here (by keeping haddr at the start of the pmd)
> 
> --->    pmdp_invalidate(vma, haddr, pmd);
>         pmd_populate(mm, pmd, pgtable);

On arm64, pmdp_invalidate looks like:

void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
		     pmd_t *pmdp)
{
	pmd_t entry = *pmdp;
	set_pmd_at(vma->vm_mm, address, pmdp, pmd_mknotpresent(entry));
	flush_pmd_tlb_range(vma, address, address + hpage_pmd_size);
}

so that's the set_pmd_at call I was referring to.

On s390, that address ends up in __pmdp_idte[_local], but I don't know
what .insn rrf,0xb98e0000,%2,%3,0,{0,1} do ;)

> Without that fix we would clearly have stale tlb entries, no?

Yes, but AFAIU the sequence on arm64 is:

1.  trans huge mapping (block mapping in arm64 speak)
2.  faulting entry (pmd_mknotpresent)
3.  tlb invalidation
4.  table entry mapping the same pages as (1).

so if the microarchitecture we're on can tolerate a mixture of block
mappings and page mappings mapping the same VA to the same PA, then the
lack of TLB maintenance would go unnoticed. There are certainly systems
where that could cause an issue, but I believe the one I've been testing
on would be ok.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
