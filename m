Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 69E74829A8
	for <linux-mm@kvack.org>; Fri, 22 May 2015 11:23:55 -0400 (EDT)
Received: by obbea2 with SMTP id ea2so15410027obb.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 08:23:55 -0700 (PDT)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id nq4si1536687oeb.18.2015.05.22.08.23.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 08:23:54 -0700 (PDT)
Message-ID: <1432307070.3184.19.camel@misato.fc.hp.com>
Subject: Re: [PATCH v9 7/10] x86, mm, asm: Add WT support to
 set_page_memtype()
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 22 May 2015 09:04:30 -0600
In-Reply-To: <alpine.DEB.2.11.1505220919070.5457@nanos>
References: <1431551151-19124-1-git-send-email-toshi.kani@hp.com>
	 <1431551151-19124-8-git-send-email-toshi.kani@hp.com>
	 <alpine.DEB.2.11.1505220919070.5457@nanos>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@ml01.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de

On Fri, 2015-05-22 at 09:35 +0200, Thomas Gleixner wrote:
> On Wed, 13 May 2015, Toshi Kani wrote:
> > + * X86 PAT uses page flags arch_1 and uncached together to keep track of
> > + * memory type of pages that have backing page struct. X86 PAT supports 4
> > + * different memory types, _PAGE_CACHE_MODE_WT, _PAGE_CACHE_MODE_WC,
> > + * _PAGE_CACHE_MODE_UC_MINUS and _PAGE_CACHE_MODE_WB where page's memory
> > + * type has not been changed from its default.
> 
> This is a horrible sentence.
> 
>  * X86 PAT supports 4 different memory types:
>  *  - _PAGE_CACHE_MODE_WB
>  *  - _PAGE_CACHE_MODE_WC
>  *  - _PAGE_CACHE_MODE_UC_MINUS
>  *  - _PAGE_CACHE_MODE_WT
>  *
>  * _PAGE_CACHE_MODE_WB is the default type.
>  */
> Hmm?

Sounds good. I will update as suggested.

> >   * Note we do not support _PAGE_CACHE_MODE_UC here.
> 
> This can be removed as it is completely redundant.

Will remove this sentence.

> >   */
> >  
> > -#define _PGMT_DEFAULT		0
> > +#define _PGMT_WB		0	/* default */
> 
> We just established two lines above that this is the default

Will remove this comment as well.

> >  #define _PGMT_WC		(1UL << PG_arch_1)
> >  #define _PGMT_UC_MINUS		(1UL << PG_uncached)
> > -#define _PGMT_WB		(1UL << PG_uncached | 1UL << PG_arch_1)
> > +#define _PGMT_WT		(1UL << PG_uncached | 1UL << PG_arch_1)
> >  #define _PGMT_MASK		(1UL << PG_uncached | 1UL << PG_arch_1)
> >  #define _PGMT_CLEAR_MASK	(~_PGMT_MASK)
> >  
> > @@ -88,14 +88,14 @@ static inline enum page_cache_mode get_page_memtype(struct page *pg)
> >  {
> >  	unsigned long pg_flags = pg->flags & _PGMT_MASK;
> >  
> > -	if (pg_flags == _PGMT_DEFAULT)
> > -		return -1;
> > +	if (pg_flags == _PGMT_WB)
> > +		return _PAGE_CACHE_MODE_WB;
> >  	else if (pg_flags == _PGMT_WC)
> >  		return _PAGE_CACHE_MODE_WC;
> >  	else if (pg_flags == _PGMT_UC_MINUS)
> >  		return _PAGE_CACHE_MODE_UC_MINUS;
> >  	else
> > -		return _PAGE_CACHE_MODE_WB;
> > +		return _PAGE_CACHE_MODE_WT;
> >  }
> >  
> >  static inline void set_page_memtype(struct page *pg,
> > @@ -112,11 +112,12 @@ static inline void set_page_memtype(struct page *pg,
> >  	case _PAGE_CACHE_MODE_UC_MINUS:
> >  		memtype_flags = _PGMT_UC_MINUS;
> >  		break;
> > -	case _PAGE_CACHE_MODE_WB:
> > -		memtype_flags = _PGMT_WB;
> > +	case _PAGE_CACHE_MODE_WT:
> > +		memtype_flags = _PGMT_WT;
> >  		break;
> > +	case _PAGE_CACHE_MODE_WB:
> >  	default:
> > -		memtype_flags = _PGMT_DEFAULT;
> > +		memtype_flags = _PGMT_WB;	/* default */
> 
> What's the value of that  comment?
> 
>        default:
> 		 /* default */

I was trying to preserve the original name of "_PGMT_DEFAULT" with the
comment because _PGMT_WB takes the place of _PGMT_DEFAULT with this
change.  But I agree that this may be redundant.  I will remove this
comment as well.

> Aside of the, please do not use tail comments. They make code harder
> to parse.

Got it.

> >  /*
> >   * For RAM pages, we use page flags to mark the pages with appropriate type.
> > - * The page flags are limited to three types, WB, WC and UC-.
> > - * WT and WP requests fail with -EINVAL, and UC gets redirected to UC-.
> > + * The page flags are limited to four types, WB (default), WC, WT and UC-.
> > + * WP request fails with -EINVAL, and UC gets redirected to UC-.
> 
> > + * A new memtype can only be set to the default memtype WB.
> 
> I have no idea what that line means.

I will change it to "Setting a new memory type is only allowed to a page
mapped with the default WB type."

> > @@ -582,13 +583,6 @@ static enum page_cache_mode lookup_memtype(u64 paddr)
> >  		struct page *page;
> >  		page = pfn_to_page(paddr >> PAGE_SHIFT);
> >  		rettype = get_page_memtype(page);
> 
> 		return get_page_memtype(page);
> 
> And while you are at it please add the missing newline between the
> variable declaration and code.

Will do.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
