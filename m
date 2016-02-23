Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id F23706B0005
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:47:14 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fy10so114467993pac.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:47:14 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b8si210657pas.137.2016.02.23.10.47.14
        for <linux-mm@kvack.org>;
        Tue, 23 Feb 2016 10:47:14 -0800 (PST)
Date: Tue, 23 Feb 2016 18:47:14 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe also
 on PowerPC and ARM)
Message-ID: <20160223184658.GA27281@arm.com>
References: <20160211192223.4b517057@thinkpad>
 <20160211190942.GA10244@node.shutemov.name>
 <20160211205702.24f0d17a@thinkpad>
 <20160212154116.GA15142@node.shutemov.name>
 <56BE00E7.1010303@de.ibm.com>
 <20160212181640.4eabb85f@thinkpad>
 <20160223103221.GA1418@node.shutemov.name>
 <20160223191907.25719a4d@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160223191907.25719a4d@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Christian Borntraeger <borntraeger@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, steve.capper@arm.com

[adding Steve, since he worked on THP for 32-bit ARM]

On Tue, Feb 23, 2016 at 07:19:07PM +0100, Gerald Schaefer wrote:
> On Tue, 23 Feb 2016 13:32:21 +0300
> "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> > The theory is that the splitting bit effetely masked bogus pmd_present():
> > we had pmd_trans_splitting() in all code path and that prevented mm from
> > touching the pmd. Once pmd_trans_splitting() has gone, mm proceed with the
> > pmd where it shouldn't and here's a boom.
> 
> Well, I don't think pmd_present() == true is bogus for a trans_huge pmd under
> splitting, after all there is a page behind the the pmd. Also, if it was
> bogus, and it would need to be false, why should it be marked !pmd_present()
> only at the pmdp_invalidate() step before the pmd_populate()? It clearly
> is pmd_present() before that, on all architectures, and if there was any
> problem/race with that, setting it to !pmd_present() at this stage would
> only (marginally) reduce the race window.
> 
> BTW, PowerPC and Sparc seem to do the same thing in pmdp_invalidate(),
> i.e. they do not set pmd_present() == false, only mark it so that it would
> not generate a new TLB entry, just like on s390. After all, the function
> is called pmdp_invalidate(), and I think the comment in mm/huge_memory.c
> before that call is just a little ambiguous in its wording. When it says
> "mark the pmd notpresent" it probably means "mark it so that it will not
> generate a new TLB entry", which is also what the comment is really about:
> prevent huge and small entries in the TLB for the same page at the same
> time.
> 
> FWIW, and since the ARM arch-list is already on cc, I think there is
> an issue with pmdp_invalidate() on ARM, since it also seems to clear
> the trans_huge (and formerly trans_splitting) bit, which actually makes
> the pmd !pmd_present(), but it violates the other requirement from the
> comment:
> "the pmd_trans_huge and pmd_trans_splitting must remain set at all times
> on the pmd until the split is complete for this pmd"

I've only been testing this for arm64 (where I'm yet to see a problem),
but we use the generic pmdp_invalidate implementation from
mm/pgtable-generic.c there. On arm64, pmd_trans_huge will return true
after pmd_mknotpresent. On arm, it does look to be buggy, since it nukes
the entire entry... Steve?

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
