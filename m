Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 57B2A6B0038
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 09:40:09 -0500 (EST)
Received: by wmec201 with SMTP id c201so73150545wme.0
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 06:40:09 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id j84si10936243wma.9.2015.11.27.06.40.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Nov 2015 06:40:08 -0800 (PST)
Received: by wmuu63 with SMTP id u63so57956156wmu.0
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 06:40:08 -0800 (PST)
Date: Fri, 27 Nov 2015 16:40:06 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: linux-next: Tree for Nov 27 (mm stuff)
Message-ID: <20151127144006.GA15674@node.shutemov.name>
References: <20151127160514.7b2022f2@canb.auug.org.au>
 <56580097.8050405@infradead.org>
 <20151127091047.GA585@swordfish>
 <20151127091739.GB585@swordfish>
 <20151127101640.GO29014@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151127101640.GO29014@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On Fri, Nov 27, 2015 at 01:16:40PM +0300, Vladimir Davydov wrote:
> On Fri, Nov 27, 2015 at 06:17:39PM +0900, Sergey Senozhatsky wrote:
> > Cc Vladimir, Kirill, Andrew
> > 
> > On (11/27/15 18:10), Sergey Senozhatsky wrote:
> > > On (11/26/15 23:04), Randy Dunlap wrote:
> > > > 
> > > > on i386:
> > > > 
> > > > mm/built-in.o: In function `page_referenced_one':
> > > > rmap.c:(.text+0x362a2): undefined reference to `pmdp_clear_flush_young'
> > > > mm/built-in.o: In function `page_idle_clear_pte_refs_one':
> > > > page_idle.c:(.text+0x4b2b8): undefined reference to `pmdp_test_and_clear_young'
> > > > 
> > > 
> > > Hello,
> > > 
> > > https://lkml.org/lkml/2015/11/24/160
> > > 
> > > corresponding patch mm-add-page_check_address_transhuge-helper-fix.patch added
> > > to -mm tree.
> > > 
> > 
> > my bad, it's in -next already.
> 
> Sigh, this fails for me too :-( Kirill was right that this hack might
> not always work.
> 
> So, we still need to check explicitly if CONFIG_TRANSPARENT_HUGEPAGE is
> enabled whenever we use page_check_address_transhuge, as Kirill proposed
> initially. The patch below does the trick. The previous "fix" is still
> useful though, because it reduces the size of kernels compiled w/o
> tranparent huge page feature.
> 
> Andrew, could you please merge this patch too?
> 
> Sorry for all the trouble.
> 
> Thanks,
> Vladimir
> ---
> diff --git a/mm/page_idle.c b/mm/page_idle.c
> index 374931f..aa7ca61 100644
> --- a/mm/page_idle.c
> +++ b/mm/page_idle.c
> @@ -66,7 +66,7 @@ static int page_idle_clear_pte_refs_one(struct page *page,
>  	if (pte) {
>  		referenced = ptep_clear_young_notify(vma, addr, pte);
>  		pte_unmap(pte);
> -	} else
> +	} else if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
>  		referenced = pmdp_clear_young_notify(vma, addr, pmd);

I would like to have yet another 'else' with warning just in case, as I
proposed initially:

https://lkml.kernel.org/g/20151124090930.GB15712@node.shutemov.name

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
