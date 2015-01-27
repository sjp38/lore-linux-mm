Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8F2526B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 19:17:51 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id m20so9722069qcx.4
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 16:17:51 -0800 (PST)
Received: from g6t1526.atlanta.hp.com (g6t1526.atlanta.hp.com. [15.193.200.69])
        by mx.google.com with ESMTPS id z18si15468563qge.51.2015.01.26.16.17.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 16:17:50 -0800 (PST)
Message-ID: <1422316890.2493.40.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH 3/7] mm: Change ioremap to set up huge I/O mappings
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 26 Jan 2015 17:01:30 -0700
In-Reply-To: <20150126155811.0ade183f5f3f89277d11fde6@linux-foundation.org>
References: <1422314009-31667-1-git-send-email-toshi.kani@hp.com>
	 <1422314009-31667-4-git-send-email-toshi.kani@hp.com>
	 <20150126155811.0ade183f5f3f89277d11fde6@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Mon, 2015-01-26 at 15:58 -0800, Andrew Morton wrote:
> On Mon, 26 Jan 2015 16:13:25 -0700 Toshi Kani <toshi.kani@hp.com> wrote:
> 
> > Change ioremap_pud_range() and ioremap_pmd_range() to set up
> > huge I/O mappings when their capability is enabled and their
> > conditions are met in a given request -- both virtual & physical
> > addresses are aligned and its range fufills the mapping size.
> > 
> > These changes are only enabled when both CONFIG_HUGE_IOMAP
> > and CONFIG_HAVE_ARCH_HUGE_VMAP are defined.
> > 
> > --- a/lib/ioremap.c
> > +++ b/lib/ioremap.c
> > @@ -81,6 +81,14 @@ static inline int ioremap_pmd_range(pud_t *pud, unsigned long addr,
> >  		return -ENOMEM;
> >  	do {
> >  		next = pmd_addr_end(addr, end);
> > +
> > +		if (ioremap_pmd_enabled() &&
> > +		    ((next - addr) == PMD_SIZE) &&
> > +		    !((phys_addr + addr) & (PMD_SIZE-1))) {
> 
> IS_ALIGNED might be a little neater here.

Right.  Will use IS_ALIGNED.

> > +			pmd_set_huge(pmd, phys_addr + addr, prot);
> > +			continue;
> > +		}
> > +
> >  		if (ioremap_pte_range(pmd, addr, next, phys_addr + addr, prot))
> >  			return -ENOMEM;
> >  	} while (pmd++, addr = next, addr != end);
> > @@ -99,6 +107,14 @@ static inline int ioremap_pud_range(pgd_t *pgd, unsigned long addr,
> >  		return -ENOMEM;
> >  	do {
> >  		next = pud_addr_end(addr, end);
> > +
> > +		if (ioremap_pud_enabled() &&
> > +		    ((next - addr) == PUD_SIZE) &&
> > +		    !((phys_addr + addr) & (PUD_SIZE-1))) {
> 
> And here.

Will do.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
