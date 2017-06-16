Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id AB7EC6B0279
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 09:36:05 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id u51so35450795qte.15
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 06:36:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i66si2012711qkd.164.2017.06.16.06.36.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 06:36:04 -0700 (PDT)
Date: Fri, 16 Jun 2017 15:36:00 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCHv2 1/3] x86/mm: Provide pmdp_establish() helper
Message-ID: <20170616133600.GE11676@redhat.com>
References: <20170615145224.66200-1-kirill.shutemov@linux.intel.com>
 <20170615145224.66200-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170615145224.66200-2-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

Hello Krill,

On Thu, Jun 15, 2017 at 05:52:22PM +0300, Kirill A. Shutemov wrote:
> +static inline pmd_t pmdp_establish(pmd_t *pmdp, pmd_t pmd)
> +{
> +	pmd_t old;
> +
> +	/*
> +	 * We cannot assume what is value of pmd here, so there's no easy way
> +	 * to set if half by half. We have to fall back to cmpxchg64.
> +	 */
> +	{
> +		old = *pmdp;
> +	} while (cmpxchg64(&pmdp->pmd, old.pmd, pmd.pmd) != old.pmd);
> +
> +	return old;
> +}

I see further margin for optimization here (although it's only for PAE
x32..).

pmd is stable so we could do:

if (!(pmd & _PAGE_PRESENT)) {
   cast to split_pmd and use xchg on pmd_low like
   native_pmdp_get_and_clear and copy pmd_high non atomically
} else {
  the above cmpxchg64 loop
}

Now thinking about the above I had a second thought if pmdp_establish
is the right interface and if we shouldn't replace pmdp_establish with
pmdp_mknotpresent instead to skip the pmd & _PAGE_PRESENT check that
will always be true in practice, so pmdp_mknotpresent will call
internally pmd_mknotpresent and it won't have to check for pmd &
_PAGE_PRESENT and it would have no cons on x86-64.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
