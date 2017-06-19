Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 27AEF6B0279
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 12:00:15 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a3so12182168wma.12
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 09:00:15 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id 92si10840517wrp.138.2017.06.19.09.00.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 09:00:13 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id d64so17260952wmf.2
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 09:00:13 -0700 (PDT)
Date: Mon, 19 Jun 2017 19:00:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 1/3] x86/mm: Provide pmdp_establish() helper
Message-ID: <20170619160005.wgj4nymtj2nntfll@node.shutemov.name>
References: <20170615145224.66200-1-kirill.shutemov@linux.intel.com>
 <20170615145224.66200-2-kirill.shutemov@linux.intel.com>
 <20170619152228.GE3024@e104818-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170619152228.GE3024@e104818-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Jun 19, 2017 at 04:22:29PM +0100, Catalin Marinas wrote:
> Hi Kirill,
> 
> On Thu, Jun 15, 2017 at 05:52:22PM +0300, Kirill A. Shutemov wrote:
> > We need an atomic way to setup pmd page table entry, avoiding races with
> > CPU setting dirty/accessed bits. This is required to implement
> > pmdp_invalidate() that doesn't loose these bits.
> > 
> > On PAE we have to use cmpxchg8b as we cannot assume what is value of new pmd and
> > setting it up half-by-half can expose broken corrupted entry to CPU.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Ingo Molnar <mingo@kernel.org>
> > Cc: H. Peter Anvin <hpa@zytor.com>
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> 
> I'll look at this from the arm64 perspective. It would be good if we can
> have a generic atomic implementation based on cmpxchg64 but I need to
> look at the details first.

Unfortunately, I'm not sure it's possbile.

The format of a page table is defined per-arch. We cannot assume much about
it in generic code.

I guess we could make it compile by casting to 'unsigned long', but is it
useful?
Every architecture manintainer still has to validate that this assumption
is valid for the architecture.

> > +static inline pmd_t pmdp_establish(pmd_t *pmdp, pmd_t pmd)
> > +{
> > +	pmd_t old;
> > +
> > +	/*
> > +	 * We cannot assume what is value of pmd here, so there's no easy way
> > +	 * to set if half by half. We have to fall back to cmpxchg64.
> > +	 */
> > +	{
> 
> BTW, you are missing a "do" here (and it probably compiles just fine
> without it, though different behaviour).

Ouch. Thanks.

Hm, what is semantics of the construct without a "do"?

> 
> > +		old = *pmdp;
> > +	} while (cmpxchg64(&pmdp->pmd, old.pmd, pmd.pmd) != old.pmd);
> > +
> > +	return old;
> > +}
> 
> -- 
> Catalin
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
