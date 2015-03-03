Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id D86896B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 18:15:13 -0500 (EST)
Received: by obbnt9 with SMTP id nt9so3246907obb.13
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 15:15:13 -0800 (PST)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id 7si1133619obr.79.2015.03.03.15.15.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Mar 2015 15:15:12 -0800 (PST)
Message-ID: <1425424472.17007.191.camel@misato.fc.hp.com>
Subject: Re: [PATCH v3 6/6] x86, mm: Support huge KVA mappings on x86
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 03 Mar 2015 16:14:32 -0700
In-Reply-To: <20150303144414.9f97ef25ad8aed7d112896bf@linux-foundation.org>
References: <1425404664-19675-1-git-send-email-toshi.kani@hp.com>
	 <1425404664-19675-7-git-send-email-toshi.kani@hp.com>
	 <20150303144414.9f97ef25ad8aed7d112896bf@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com

On Tue, 2015-03-03 at 14:44 -0800, Andrew Morton wrote:
> On Tue,  3 Mar 2015 10:44:24 -0700 Toshi Kani <toshi.kani@hp.com> wrote:
 :
> > +
> > +#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
> > +int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
> > +{
> > +	u8 mtrr;
> > +
> > +	/*
> > +	 * Do not use a huge page when the range is covered by non-WB type
> > +	 * of MTRRs.
> > +	 */
> > +	mtrr = mtrr_type_lookup(addr, addr + PUD_SIZE);
> > +	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != 0xFF))
> > +		return 0;
> 
> It would be good to notify the operator in some way when this happens. 
> Otherwise the kernel will run more slowly and there's no way of knowing
> why.  I guess slap a pr_info() in there.  Or maybe pr_warn()?

We only use 4KB mappings today, so this case will not make it run
slowly, i.e. it will be the same as today.  Also, adding a message here
can generate a lot of messages when MTRRs cover a large area.  So, I
think we are fine without a message.

> 
> > +	prot = pgprot_4k_2_large(prot);
> > +
> > +	set_pte((pte_t *)pud, pfn_pte(
> > +		(u64)addr >> PAGE_SHIFT,
> > +		__pgprot(pgprot_val(prot) | _PAGE_PSE)));
> > +
> > +	return 1;
> > +}
> > +
> > +int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot)
> > +{
> > +	u8 mtrr;
> > +
> > +	/*
> > +	 * Do not use a huge page when the range is covered by non-WB type
> > +	 * of MTRRs.
> > +	 */
> > +	mtrr = mtrr_type_lookup(addr, addr + PMD_SIZE);
> > +	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != 0xFF))
> > +		return 0;
> > +
> > +	prot = pgprot_4k_2_large(prot);
> > +
> > +	set_pte((pte_t *)pmd, pfn_pte(
> > +		(u64)addr >> PAGE_SHIFT,
> > +		__pgprot(pgprot_val(prot) | _PAGE_PSE)));
> > +
> > +	return 1;
> > +}
> >
> > +int pud_clear_huge(pud_t *pud)
> > +{
> > +	if (pud_large(*pud)) {
> > +		pud_clear(pud);
> > +		return 1;
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +int pmd_clear_huge(pmd_t *pmd)
> > +{
> > +	if (pmd_large(*pmd)) {
> > +		pmd_clear(pmd);
> > +		return 1;
> > +	}
> > +
> > +	return 0;
> > +}
> 
> I didn't see anywhere where the return values of these functions are
> documented.  It's all fairly obvious, but we could help the rearers
> a bit.

Agreed.  I will add function headers with descriptions to the new
functions.

Thanks,
-Toshi 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
