Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6F3FC6B0069
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 06:46:51 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id p66so12083291pga.4
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 03:46:51 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f5si19125120pgh.37.2016.12.06.03.46.50
        for <linux-mm@kvack.org>;
        Tue, 06 Dec 2016 03:46:50 -0800 (PST)
Date: Tue, 6 Dec 2016 11:46:44 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCHv4 05/10] arm64: Use __pa_symbol for kernel symbols
Message-ID: <20161206114644.GA16701@e104818-lin.cambridge.arm.com>
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
 <1480445729-27130-6-git-send-email-labbott@redhat.com>
 <72eb08c8-4f2c-6cb9-1e23-0860fd153a2e@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <72eb08c8-4f2c-6cb9-1e23-0860fd153a2e@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Cc: Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>

On Mon, Dec 05, 2016 at 04:50:33PM -0800, Florian Fainelli wrote:
> On 11/29/2016 10:55 AM, Laura Abbott wrote:
> > __pa_symbol is technically the marco that should be used for kernel
> > symbols. Switch to this as a pre-requisite for DEBUG_VIRTUAL which
> > will do bounds checking. As part of this, introduce lm_alias, a
> > macro which wraps the __va(__pa(...)) idiom used a few places to
> > get the alias.
> > 
> > Signed-off-by: Laura Abbott <labbott@redhat.com>
> > ---
> > v4: Stop calling __va early, conversion of a few more sites. I decided against
> > wrapping the __p*d_populate calls into new functions since the call sites
> > should be limited.
> > ---
> 
> 
> > -	pud_populate(&init_mm, pud, bm_pmd);
> > +	if (pud_none(*pud))
> > +		__pud_populate(pud, __pa_symbol(bm_pmd), PMD_TYPE_TABLE);
> >  	pmd = fixmap_pmd(addr);
> > -	pmd_populate_kernel(&init_mm, pmd, bm_pte);
> > +	__pmd_populate(pmd, __pa_symbol(bm_pte), PMD_TYPE_TABLE);
> 
> Is there a particular reason why pmd_populate_kernel() is not changed to
> use __pa_symbol() instead of using __pa()? The other users in the arm64
> kernel is arch/arm64/kernel/hibernate.c which seems to call this against
> kernel symbols as well?

create_safe_exec_page() may allocate a pte from the linear map and
passes such pointer to pmd_populate_kernel(). The copy_pte() function
does something similar. In addition, we have the generic
__pte_alloc_kernel() in mm/memory.c using linear addresses.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
