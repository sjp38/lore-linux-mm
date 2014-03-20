Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id C29B76B01A7
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 05:50:36 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id hr14so5998276wib.3
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 02:50:36 -0700 (PDT)
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
        by mx.google.com with ESMTPS id j3si12161480wiz.14.2014.03.20.02.50.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 02:50:35 -0700 (PDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so396788wgh.27
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 02:50:34 -0700 (PDT)
Date: Thu, 20 Mar 2014 09:50:27 +0000
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [RESEND PATCH] mm: hugetlb: Introduce
 huge_pte_{page,present,young}
Message-ID: <20140320095027.GA23180@linaro.org>
References: <1395082318-7703-1-git-send-email-steve.capper@linaro.org>
 <20140317150730.156a3325ff96dfc6e1352902@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140317150730.156a3325ff96dfc6e1352902@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com

On Mon, Mar 17, 2014 at 03:07:30PM -0700, Andrew Morton wrote:
> On Mon, 17 Mar 2014 18:51:58 +0000 Steve Capper <steve.capper@linaro.org> wrote:
> 
> > Introduce huge pte versions of pte_page, pte_present and pte_young.
> > This allows ARM (without LPAE) to use alternative pte processing logic
> > for huge ptes.
> > 
> > Where these functions are not defined by architectural code they
> > fallback to the standard functions.
> > 
> > Signed-off-by: Steve Capper <steve.capper@linaro.org>
> > ---
> > Hi,
> > I'm resending this patch to provoke some discussion.
> > 
> > We already have some huge_pte_ style functions, and this patch adds a
> > few more (that simplify to the pte_ equivalents where unspecified).
> > 
> > Having separate hugetlb versions of pte_page, present and mkyoung
> > allows for a greatly simplified huge page implementation for ARM with
> > the classical MMU (which has a different bit layout for huge ptes).
> 
> Looks OK to me.  One thing...
> 
> > --- a/include/linux/hugetlb.h
> > +++ b/include/linux/hugetlb.h
> > @@ -353,6 +353,18 @@ static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
> >  }
> >  #endif
> >  
> > +#ifndef huge_pte_page
> > +#define huge_pte_page(pte)	pte_page(pte)
> > +#endif
> 
> This #ifndef x #define x thing works well, but it is 100% unclear which
> arch header file is supposed to define x if it wishes to override the
> definition.  We've had problems with that in the past where different
> architectures put it in different files and various breakages ensued.
> 
> So can we decide which arch header file is responsible for defining
> these, then document that right here in a comment and add an explicit
> #include <asm/that-file.h>?

Thanks Andrew,
Yes I see your point, this could quickly become unstable.
I'll see how these look in include/asm-generic/hugetlb.h instead.

Cheers,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
