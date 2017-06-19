Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A084E6B03D2
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 11:22:36 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h21so104906661pfk.13
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 08:22:36 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o87si8188345pfj.483.2017.06.19.08.22.35
        for <linux-mm@kvack.org>;
        Mon, 19 Jun 2017 08:22:35 -0700 (PDT)
Date: Mon, 19 Jun 2017 16:22:29 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCHv2 1/3] x86/mm: Provide pmdp_establish() helper
Message-ID: <20170619152228.GE3024@e104818-lin.cambridge.arm.com>
References: <20170615145224.66200-1-kirill.shutemov@linux.intel.com>
 <20170615145224.66200-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170615145224.66200-2-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

Hi Kirill,

On Thu, Jun 15, 2017 at 05:52:22PM +0300, Kirill A. Shutemov wrote:
> We need an atomic way to setup pmd page table entry, avoiding races with
> CPU setting dirty/accessed bits. This is required to implement
> pmdp_invalidate() that doesn't loose these bits.
> 
> On PAE we have to use cmpxchg8b as we cannot assume what is value of new pmd and
> setting it up half-by-half can expose broken corrupted entry to CPU.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: H. Peter Anvin <hpa@zytor.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>

I'll look at this from the arm64 perspective. It would be good if we can
have a generic atomic implementation based on cmpxchg64 but I need to
look at the details first.

> +static inline pmd_t pmdp_establish(pmd_t *pmdp, pmd_t pmd)
> +{
> +	pmd_t old;
> +
> +	/*
> +	 * We cannot assume what is value of pmd here, so there's no easy way
> +	 * to set if half by half. We have to fall back to cmpxchg64.
> +	 */
> +	{

BTW, you are missing a "do" here (and it probably compiles just fine
without it, though different behaviour).

> +		old = *pmdp;
> +	} while (cmpxchg64(&pmdp->pmd, old.pmd, pmd.pmd) != old.pmd);
> +
> +	return old;
> +}

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
