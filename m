Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 262C26B02B4
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 10:51:10 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id k133so12754377ita.3
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 07:51:10 -0700 (PDT)
Received: from mail-it0-x232.google.com (mail-it0-x232.google.com. [2607:f8b0:4001:c0b::232])
        by mx.google.com with ESMTPS id f87si5540214iod.231.2017.06.08.07.51.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jun 2017 07:51:09 -0700 (PDT)
Received: by mail-it0-x232.google.com with SMTP id m47so20454771iti.0
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 07:51:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170608132859.GE5765@leverpostej>
References: <20170608113548.24905-1-ard.biesheuvel@linaro.org>
 <20170608125946.GD5765@leverpostej> <20170608132859.GE5765@leverpostej>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 8 Jun 2017 14:51:08 +0000
Message-ID: <CAKv+Gu8FuRE5fMunqOw9XgpPJK1uPRAJdY8y20+OszjsM1QOWQ@mail.gmail.com>
Subject: Re: [PATCH v3] mm: huge-vmap: fail gracefully on unexpected huge vmap mappings
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Michal Hocko <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Zhong Jiang <zhongjiang@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Laura Abbott <labbott@fedoraproject.org>

On 8 June 2017 at 13:28, Mark Rutland <mark.rutland@arm.com> wrote:
> On Thu, Jun 08, 2017 at 01:59:46PM +0100, Mark Rutland wrote:
>> On Thu, Jun 08, 2017 at 11:35:48AM +0000, Ard Biesheuvel wrote:
>> > @@ -287,10 +288,10 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
>> >     if (p4d_none(*p4d))
>> >             return NULL;
>> >     pud = pud_offset(p4d, addr);
>> > -   if (pud_none(*pud))
>> > +   if (pud_none(*pud) || WARN_ON_ONCE(pud_huge(*pud)))
>> >             return NULL;
>> >     pmd = pmd_offset(pud, addr);
>> > -   if (pmd_none(*pmd))
>> > +   if (pmd_none(*pmd) || WARN_ON_ONCE(pmd_huge(*pmd)))
>> >             return NULL;
>>
>> I think it might be better to use p*d_bad() here, since that doesn't
>> depend on CONFIG_HUGETLB_PAGE.
>>
>> While the cross-arch semantics are a little fuzzy, my understanding is
>> those should return true if an entry is not a pointer to a next level of
>> table (so pXd_huge(p) implies pXd_bad(p)).
>
> Ugh; it turns out this isn't universally true.
>
> I see that at least arch/hexagon's pmd_bad() always returns 0, and they
> support CONFIG_HUGETLB_PAGE.
>

Well, the comment in arch/hexagon/include/asm/pgtable.h suggests otherwise:

/*  HUGETLB not working currently  */


> So I guess there isn't an arch-neutral, always-available way of checking
> this. Sorry for having mislead you.
>
> For arm64, p*d_bad() would still be preferable, so maybe we should check
> both?
>

I am primarily interested in hardening architectures that define
CONFIG_HAVE_ARCH_HUGE_VMAP, given that they intentionally create huge
mappings in the VMALLOC area which this code may choke on. So whether
pmd_bad() always returns 0 on an arch that does not define
CONFIG_HAVE_ARCH_HUGE_VMAP does not really matter, because it simply
nullifies this change for that particular architecture.

So as long as x86 and arm64 [which are the only ones to define
CONFIG_HAVE_ARCH_HUGE_VMAP atm] work correctly with pXd_bad(), I think
we should use it instead of pXd_huge(),

-- 
Ard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
