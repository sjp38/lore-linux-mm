Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id D24C36B0009
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 06:02:15 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id x65so11286104pfb.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 03:02:15 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p3si1272589pfi.200.2016.02.24.03.02.15
        for <linux-mm@kvack.org>;
        Wed, 24 Feb 2016 03:02:15 -0800 (PST)
Date: Wed, 24 Feb 2016 11:02:22 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe also
 on PowerPC and ARM)
Message-ID: <20160224110221.GF28310@arm.com>
References: <20160212154116.GA15142@node.shutemov.name>
 <56BE00E7.1010303@de.ibm.com>
 <20160212181640.4eabb85f@thinkpad>
 <20160223103221.GA1418@node.shutemov.name>
 <20160223191907.25719a4d@thinkpad>
 <20160223193345.GC21820@node.shutemov.name>
 <20160223202233.GE27281@arm.com>
 <56CD8302.9080202@de.ibm.com>
 <20160224104139.GC28310@arm.com>
 <56CD8B43.9070509@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56CD8B43.9070509@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>

On Wed, Feb 24, 2016 at 11:51:47AM +0100, Christian Borntraeger wrote:
> On 02/24/2016 11:41 AM, Will Deacon wrote:
> > On Wed, Feb 24, 2016 at 11:16:34AM +0100, Christian Borntraeger wrote:
> >> Without that fix we would clearly have stale tlb entries, no?
> > 
> > Yes, but AFAIU the sequence on arm64 is:
> > 
> > 1.  trans huge mapping (block mapping in arm64 speak)
> > 2.  faulting entry (pmd_mknotpresent)
> > 3.  tlb invalidation
> > 4.  table entry mapping the same pages as (1).
> > 
> > so if the microarchitecture we're on can tolerate a mixture of block
> > mappings and page mappings mapping the same VA to the same PA, then the
> > lack of TLB maintenance would go unnoticed. There are certainly systems
> > where that could cause an issue, but I believe the one I've been testing
> > on would be ok.
> 
> So in essence you say it does not matter that you flush the wrong range in 
> flush_pmd_tlb_range as long as it will be flushed later on when the pages
> really go away. Yes, then it really might be ok for arm64.

Indeed, although that's a property of the microarchitecture I'm using
rather than an architectural guarantee so the code should certainly be
fixed!

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
