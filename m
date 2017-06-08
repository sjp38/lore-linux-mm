Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2F0D26B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 12:38:34 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id b13so17292270pgn.4
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 09:38:34 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x89si4755795pff.412.2017.06.08.09.38.32
        for <linux-mm@kvack.org>;
        Thu, 08 Jun 2017 09:38:33 -0700 (PDT)
Date: Thu, 8 Jun 2017 17:37:48 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v3] mm: huge-vmap: fail gracefully on unexpected huge
 vmap mappings
Message-ID: <20170608163747.GB19643@leverpostej>
References: <20170608113548.24905-1-ard.biesheuvel@linaro.org>
 <20170608125946.GD5765@leverpostej>
 <20170608132859.GE5765@leverpostej>
 <CAKv+Gu8FuRE5fMunqOw9XgpPJK1uPRAJdY8y20+OszjsM1QOWQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu8FuRE5fMunqOw9XgpPJK1uPRAJdY8y20+OszjsM1QOWQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Michal Hocko <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Zhong Jiang <zhongjiang@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Laura Abbott <labbott@fedoraproject.org>

On Thu, Jun 08, 2017 at 02:51:08PM +0000, Ard Biesheuvel wrote:
> On 8 June 2017 at 13:28, Mark Rutland <mark.rutland@arm.com> wrote:
> > On Thu, Jun 08, 2017 at 01:59:46PM +0100, Mark Rutland wrote:
> >> On Thu, Jun 08, 2017 at 11:35:48AM +0000, Ard Biesheuvel wrote:
> >> > @@ -287,10 +288,10 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
> >> >     if (p4d_none(*p4d))
> >> >             return NULL;
> >> >     pud = pud_offset(p4d, addr);
> >> > -   if (pud_none(*pud))
> >> > +   if (pud_none(*pud) || WARN_ON_ONCE(pud_huge(*pud)))
> >> >             return NULL;
> >> >     pmd = pmd_offset(pud, addr);
> >> > -   if (pmd_none(*pmd))
> >> > +   if (pmd_none(*pmd) || WARN_ON_ONCE(pmd_huge(*pmd)))
> >> >             return NULL;
> >>
> >> I think it might be better to use p*d_bad() here, since that doesn't
> >> depend on CONFIG_HUGETLB_PAGE.
> >>
> >> While the cross-arch semantics are a little fuzzy, my understanding is
> >> those should return true if an entry is not a pointer to a next level of
> >> table (so pXd_huge(p) implies pXd_bad(p)).
> >
> > Ugh; it turns out this isn't universally true.
> >
> > I see that at least arch/hexagon's pmd_bad() always returns 0, and they
> > support CONFIG_HUGETLB_PAGE.
> >
> 
> Well, the comment in arch/hexagon/include/asm/pgtable.h suggests otherwise:
> 
> /*  HUGETLB not working currently  */

Ah; I missed that.

> > So I guess there isn't an arch-neutral, always-available way of checking
> > this. Sorry for having mislead you.
> >
> > For arm64, p*d_bad() would still be preferable, so maybe we should check
> > both?
> 
> I am primarily interested in hardening architectures that define
> CONFIG_HAVE_ARCH_HUGE_VMAP, given that they intentionally create huge
> mappings in the VMALLOC area which this code may choke on. So whether
> pmd_bad() always returns 0 on an arch that does not define
> CONFIG_HAVE_ARCH_HUGE_VMAP does not really matter, because it simply
> nullifies this change for that particular architecture.
> 
> So as long as x86 and arm64 [which are the only ones to define
> CONFIG_HAVE_ARCH_HUGE_VMAP atm] work correctly with pXd_bad(), I think
> we should use it instead of pXd_huge(),

Sure; that sounds good to me.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
