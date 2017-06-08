Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id BA8F36B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 09:29:45 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 204so3394316wmy.1
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 06:29:45 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v2si5209180wra.152.2017.06.08.06.29.44
        for <linux-mm@kvack.org>;
        Thu, 08 Jun 2017 06:29:44 -0700 (PDT)
Date: Thu, 8 Jun 2017 14:28:59 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v3] mm: huge-vmap: fail gracefully on unexpected huge
 vmap mappings
Message-ID: <20170608132859.GE5765@leverpostej>
References: <20170608113548.24905-1-ard.biesheuvel@linaro.org>
 <20170608125946.GD5765@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170608125946.GD5765@leverpostej>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: mhocko@suse.com, linux-mm@kvack.org, akpm@linux-foundation.org, zhongjiang@huawei.com, linux-arm-kernel@lists.infradead.org, labbott@fedoraproject.org

On Thu, Jun 08, 2017 at 01:59:46PM +0100, Mark Rutland wrote:
> On Thu, Jun 08, 2017 at 11:35:48AM +0000, Ard Biesheuvel wrote:
> > @@ -287,10 +288,10 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
> >  	if (p4d_none(*p4d))
> >  		return NULL;
> >  	pud = pud_offset(p4d, addr);
> > -	if (pud_none(*pud))
> > +	if (pud_none(*pud) || WARN_ON_ONCE(pud_huge(*pud)))
> >  		return NULL;
> >  	pmd = pmd_offset(pud, addr);
> > -	if (pmd_none(*pmd))
> > +	if (pmd_none(*pmd) || WARN_ON_ONCE(pmd_huge(*pmd)))
> >  		return NULL;
> 
> I think it might be better to use p*d_bad() here, since that doesn't
> depend on CONFIG_HUGETLB_PAGE.
> 
> While the cross-arch semantics are a little fuzzy, my understanding is
> those should return true if an entry is not a pointer to a next level of
> table (so pXd_huge(p) implies pXd_bad(p)).

Ugh; it turns out this isn't universally true.

I see that at least arch/hexagon's pmd_bad() always returns 0, and they
support CONFIG_HUGETLB_PAGE.

So I guess there isn't an arch-neutral, always-available way of checking
this. Sorry for having mislead you.

For arm64, p*d_bad() would still be preferable, so maybe we should check
both?

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
