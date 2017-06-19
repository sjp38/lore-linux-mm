Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 27C2D6B02C3
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 17:57:42 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x23so18668013wrb.6
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 14:57:42 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id k51si11278368wrc.370.2017.06.19.14.57.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 14:57:40 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id d64so19309072wmf.2
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 14:57:40 -0700 (PDT)
Date: Tue, 20 Jun 2017 00:57:37 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 1/3] x86/mm: Provide pmdp_establish() helper
Message-ID: <20170619215737.hmjb23oafasig6rf@node.shutemov.name>
References: <20170615145224.66200-1-kirill.shutemov@linux.intel.com>
 <20170615145224.66200-2-kirill.shutemov@linux.intel.com>
 <D16802A9-161A-4074-A2C6-DCEA73E2E608@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <D16802A9-161A-4074-A2C6-DCEA73E2E608@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Jun 19, 2017 at 10:11:35AM -0700, Nadav Amit wrote:
> Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
> 
> > We need an atomic way to setup pmd page table entry, avoiding races with
> > CPU setting dirty/accessed bits. This is required to implement
> > pmdp_invalidate() that doesn't loose these bits.
> > 
> > On PAE we have to use cmpxchg8b as we cannot assume what is value of new pmd and
> > setting it up half-by-half can expose broken corrupted entry to CPU.
> 
> ...
> 
> > 
> > +#ifndef pmdp_establish
> > +#define pmdp_establish pmdp_establish
> > +static inline pmd_t pmdp_establish(pmd_t *pmdp, pmd_t pmd)
> > +{
> > +	if (IS_ENABLED(CONFIG_SMP)) {
> > +		return xchg(pmdp, pmd);
> > +	} else {
> > +		pmd_t old = *pmdp;
> > +		*pmdp = pmd;
> 
> I think you may want to use WRITE_ONCE() here - otherwise nobody guarantees
> that the compiler will not split writes to *pmdp. Although the kernel uses
> similar code to setting PTEs and PMDs, I think that it is best to start
> fixing it. Obviously, you might need a different code path for 32-bit
> kernels.

This code is for 2-level pageing on 32-bit machines and for 4-level paging
on 64-bit machine. In both cases sizeof(pmd_t) == sizeof(unsigned long).
Sane compiler can't screw up anything here -- store of long is one shot.

Compiler still can issue duplicate of store, but there's no harm.
It guaranteed to be stable once ptl is released and CPU can't the entry
half-updated.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
