Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4D0916B00F2
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 14:23:44 -0500 (EST)
Received: by mail-oi0-f51.google.com with SMTP id g201so9126118oib.24
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 11:23:44 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id cr8si19112548oec.91.2014.11.03.11.23.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 11:23:43 -0800 (PST)
Message-ID: <1415041782.10958.26.camel@misato.fc.hp.com>
Subject: Re: [PATCH v4 5/7] x86, mm, pat: Refactor !pat_enabled handling
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 03 Nov 2014 12:09:42 -0700
In-Reply-To: <alpine.DEB.2.11.1411031957330.5308@nanos>
References: <1414450545-14028-1-git-send-email-toshi.kani@hp.com>
	 <1414450545-14028-6-git-send-email-toshi.kani@hp.com>
	 <alpine.DEB.2.11.1411031957330.5308@nanos>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com

On Mon, 2014-11-03 at 20:01 +0100, Thomas Gleixner wrote:
> On Mon, 27 Oct 2014, Toshi Kani wrote:
> > diff --git a/arch/x86/mm/iomap_32.c b/arch/x86/mm/iomap_32.c
> > index ee58a0b..96aa8bf 100644
> > --- a/arch/x86/mm/iomap_32.c
> > +++ b/arch/x86/mm/iomap_32.c
> > @@ -70,29 +70,23 @@ void *kmap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot)
> >  	return (void *)vaddr;
> >  }
> >  
> > -/*
> > - * Map 'pfn' using protections 'prot'
> > - */
> > -#define __PAGE_KERNEL_WC	(__PAGE_KERNEL | \
> > -				 cachemode2protval(_PAGE_CACHE_MODE_WC))
> > -
> >  void __iomem *
> >  iomap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot)
> >  {
> >  	/*
> > -	 * For non-PAT systems, promote PAGE_KERNEL_WC to PAGE_KERNEL_UC_MINUS.
> > -	 * PAGE_KERNEL_WC maps to PWT, which translates to uncached if the
> > -	 * MTRR is UC or WC.  UC_MINUS gets the real intention, of the
> > -	 * user, which is "WC if the MTRR is WC, UC if you can't do that."
> > +	 * For non-PAT systems, translate non-WB request to UC- just in
> > +	 * case the caller set the PWT bit to prot directly without using
> > +	 * pgprot_writecombine(). UC- translates to uncached if the MTRR
> > +	 * is UC or WC. UC- gets the real intention, of the user, which is
> > +	 * "WC if the MTRR is WC, UC if you can't do that."
> >  	 */
> > -	if (!pat_enabled && pgprot_val(prot) == __PAGE_KERNEL_WC)
> > +	if (!pat_enabled && pgprot2cachemode(prot) != _PAGE_CACHE_MODE_WB)
> >  		prot = __pgprot(__PAGE_KERNEL |
> >  				cachemode2protval(_PAGE_CACHE_MODE_UC_MINUS));
> >  
> >  	return (void __force __iomem *) kmap_atomic_prot_pfn(pfn, prot);
> >  }
> >  EXPORT_SYMBOL_GPL(iomap_atomic_prot_pfn);
> > -#undef __PAGE_KERNEL_WC
> 
> Rejects. Please update against Juergens latest.

Yes, I have addressed this merge conflict in my next version.  I will
submit it shortly after all other comments are addressed. :-)

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
