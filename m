Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id A47006B0031
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 17:55:23 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id r20so1497973wiv.8
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 14:55:23 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ey4si4317882wid.15.2014.06.20.14.55.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 14:55:22 -0700 (PDT)
Date: Fri, 20 Jun 2014 17:55:14 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [mmotm:master 130/230] mm/swap.c:719:2: error: implicit
 declaration of function 'TestSetPageMlocked'
Message-ID: <20140620215514.GK7331@cmpxchg.org>
References: <53a397d7.WKpm75H8yvJSkNsS%fengguang.wu@intel.com>
 <20140620141416.1f6930c591190557ff62416d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140620141416.1f6930c591190557ff62416d@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

On Fri, Jun 20, 2014 at 02:14:16PM -0700, Andrew Morton wrote:
> On Fri, 20 Jun 2014 10:09:27 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> 
> > tree:   git://git.cmpxchg.org/linux-mmotm.git master
> > head:   df25ba7db0775d87018e2cd92f26b9b087093840
> > commit: 8d72d7b20fab14a779df2f7ea7632d4ee223dfcc [130/230] mm: memcontrol: rewrite charge API
> > config: make ARCH=m32r m32104ut_defconfig
> > 
> > All error/warnings:
> > 
> >    mm/swap.c: In function 'lru_cache_add_active_or_unevictable':
> > >> mm/swap.c:719:2: error: implicit declaration of function 'TestSetPageMlocked' [-Werror=implicit-function-declaration]
> >    cc1: some warnings being treated as errors
> > 
> > vim +/TestSetPageMlocked +719 mm/swap.c
> > 
> >    713		if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED)) {
> >    714			SetPageActive(page);
> >    715			lru_cache_add(page);
> >    716			return;
> >    717		}
> >    718	
> >  > 719		if (!TestSetPageMlocked(page)) {
> >    720			/*
> >    721			 * We use the irq-unsafe __mod_zone_page_stat because this
> >    722			 * counter is not modified from interrupt context, and the pte
> > 
> 
> hm, I can't think of anything very smart here.
> 
> --- a/mm/swap.c~mm-memcontrol-rewrite-charge-api-fix-2
> +++ a/mm/swap.c
> @@ -716,6 +716,7 @@ void lru_cache_add_active_or_unevictable
>  		return;
>  	}
>  
> +#ifdef CONFIG_MMU
>  	if (!TestSetPageMlocked(page)) {
>  		/*
>  		 * We use the irq-unsafe __mod_zone_page_stat because this
> @@ -726,6 +727,7 @@ void lru_cache_add_active_or_unevictable
>  				    hpage_nr_pages(page));
>  		count_vm_event(UNEVICTABLE_PGMLOCKED);
>  	}
> +#else
>  	add_page_to_unevictable_list(page);
>  }

We can define TestSetPageMlocked() for !MMU configurations.  I don't
have a suitable toolchain available right now, so this is untested.

---
