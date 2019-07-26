Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E378C76190
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 05:10:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAEFA21951
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 05:10:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAEFA21951
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 674796B0003; Fri, 26 Jul 2019 01:10:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 624206B0005; Fri, 26 Jul 2019 01:10:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 515458E0002; Fri, 26 Jul 2019 01:10:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id F313D6B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 01:09:59 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b33so33374715edc.17
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 22:09:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=ukdl75qIlAlS2yucnh1fpz0rOLcRdyxT2AakdL/c580=;
        b=JxpBVYb3U3QvwAx0Epc4wOeswFloPTeuqE6nss5osqRTMmLJaVgHzb65Qg31r0niTi
         wRgy+EDulPQl9MZOkr9XFdCMC6PQwYsR4Z6+xRWuXdIzLHg1bHYmDZS5Oxo5vQsb6lTU
         eFy2+8tNjhTQ4h3AVtG8eNKOJ4fnzjEk2lhnHdwr8Yfd6vhMJ24BzisHj7xXm/LwYrte
         HO7Vmq/GviAjJzq+kO9DhS7JYPy105gBjOEmxUVylgN2usDXYOLlr3RtmZmmGNWVb6jZ
         UtekrHzDmI6Vs6FGzkfD8endeBQoQlFbIXSbEuNsTc3N7f1myIn/fQ3uT8aH44bkLoud
         tgFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXjZ+13hm2tRxXbS2G6z7VMahrGKDYiIpgkMlRN1y/XhIe6lDeZ
	7WSc3/q0DssTXhikwzQ/nuRy39zBN8udJuAr1p5/v3zGfo559FCgg5KxqPD/wx0fnZXxJNhfZ8y
	6Q3K5oW6T/yspnetTPqFpVt4UsDQVOxZcgaxqXofPiUtwlHYHoTfP8/+4MS2XEmQzPA==
X-Received: by 2002:a17:906:95a:: with SMTP id j26mr15834550ejd.148.1564117799510;
        Thu, 25 Jul 2019 22:09:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9QHgoSuNMIDNYGi+X7WWGVqeWMSB2UKWxIoDZpdxxlb/ojThNnW5KAWoE3rocj9bonKj7
X-Received: by 2002:a17:906:95a:: with SMTP id j26mr15834511ejd.148.1564117798496;
        Thu, 25 Jul 2019 22:09:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564117798; cv=none;
        d=google.com; s=arc-20160816;
        b=oQUNID6s359ATPqOipdBtHlgyOgLcaSt+RqPagJuBRelgTD6BGanoICxaer/6ljc4m
         O+YuXKA1q2u+LaTfXBHrIbWXeLF1tmqM4Uq2T/M/7iQANAniDswR5o6X+HEbv9G4DVZL
         uzVRkdEB5dKo0u0R72p3dqWzsbCVem6bqgTUsSF3YenaakcmGUfmPXDFb386cPczpgnc
         AO7F4nFpqdOw0CLBQgqTfG70SDFtUTzOuZNZBXtFEg9imFu1AoEDvvhsqZn4s+FohL2H
         0+9EsBGwEyes/mIutt7kIVylBCDmoVTB5Zq+6CKMZSTBMugMmays5S6kdPrZx3wwOnWC
         AreQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=ukdl75qIlAlS2yucnh1fpz0rOLcRdyxT2AakdL/c580=;
        b=xJGpI3dcXNSUOwKoS6axQ5hZioeXa/o4h/Aa9pHEp2RPaCuTF2ygLJmnigdsWvhem+
         712psiv7YeGpKVxrYSHzTEmz2vzyY4x6ABmarG7vZCMB3wNAKdB1AQn9/BqWZrZ/hhcc
         NytS7eOdncKWgzuexAZSMPvSPkX5fM7MuJdXSTMdv4xl+ENEViPIlZ7fxzF+tB7082M8
         COt7se4HmP7EtlYi3TZZ1evGtLvXG6jqbgqlrTvVCk/5Fb3T4Le9c5tPDf1CGr5xpvMF
         WWcUmfUXIcYVK/hB7S8uOhnzk+DubCwLSYwFi8dvThOIcRae05RQ3C+Cw6ZTagWVApsL
         3bug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id c57si11992738edc.169.2019.07.25.22.09.58
        for <linux-mm@kvack.org>;
        Thu, 25 Jul 2019 22:09:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7E00C337;
	Thu, 25 Jul 2019 22:09:57 -0700 (PDT)
Received: from [10.163.1.197] (unknown [10.163.1.197])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 818A13F694;
	Thu, 25 Jul 2019 22:11:55 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [RFC] mm/pgtable/debug: Add test validating architecture page
 table helpers
To: Russell King - ARM Linux admin <linux@armlinux.org.uk>
Cc: linux-mm@kvack.org, Mark Rutland <mark.rutland@arm.com>, x86@kernel.org,
 Kees Cook <keescook@chromium.org>,
 Sri Krishna chowdary <schowdary@nvidia.com>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org,
 Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Mark Brown <Mark.Brown@arm.com>, Andrew Morton <akpm@linux-foundation.org>,
 Steven Price <Steven.Price@arm.com>, linux-arm-kernel@lists.infradead.org
References: <1564037723-26676-1-git-send-email-anshuman.khandual@arm.com>
 <1564037723-26676-2-git-send-email-anshuman.khandual@arm.com>
 <20190725215427.GL1330@shell.armlinux.org.uk>
Message-ID: <1f64ba59-af68-7daa-44bf-6ac1f8f796a8@arm.com>
Date: Fri, 26 Jul 2019 10:40:28 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190725215427.GL1330@shell.armlinux.org.uk>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/26/2019 03:24 AM, Russell King - ARM Linux admin wrote:
> On Thu, Jul 25, 2019 at 12:25:23PM +0530, Anshuman Khandual wrote:
>> This adds a test module which will validate architecture page table helpers
>> and accessors regarding compliance with generic MM semantics expectations.
>> This will help various architectures in validating changes to the existing
>> page table helpers or addition of new ones.
>>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: Mark Rutland <mark.rutland@arm.com>
>> Cc: Mark Brown <Mark.Brown@arm.com>
>> Cc: Steven Price <Steven.Price@arm.com>
>> Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>> Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
>> Cc: Kees Cook <keescook@chromium.org>
>> Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
>> Cc: Matthew Wilcox <willy@infradead.org>
>> Cc: Sri Krishna chowdary <schowdary@nvidia.com>
>> Cc: Dave Hansen <dave.hansen@intel.com>
>> Cc: linux-arm-kernel@lists.infradead.org
>> Cc: x86@kernel.org
>> Cc: linux-kernel@vger.kernel.org
>>
>> Suggested-by: Catalin Marinas <catalin.marinas@arm.com>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
>>  lib/Kconfig.debug       |  14 +++
>>  lib/Makefile            |   1 +
>>  lib/test_arch_pgtable.c | 290 ++++++++++++++++++++++++++++++++++++++++++++++++
>>  3 files changed, 305 insertions(+)
>>  create mode 100644 lib/test_arch_pgtable.c
>>
>> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
>> index 5960e29..a27fe8d 100644
>> --- a/lib/Kconfig.debug
>> +++ b/lib/Kconfig.debug
>> @@ -1719,6 +1719,20 @@ config TEST_SORT
>>  
>>  	  If unsure, say N.
>>  
>> +config TEST_ARCH_PGTABLE
>> +	tristate "Test arch page table helpers for semantics compliance"
>> +	depends on MMUpte/pmd/pud/p4d/pgd 
>> +	depends on DEBUG_KERNEL || m
>> +	help
>> +	  This options provides a kernel module which can be used to test
>> +	  architecture page table helper functions on various platform in
>> +	  verifing if they comply with expected generic MM semantics. This
>> +	  will help architectures code in making sure that any changes or
>> +	  new additions of these helpers will still conform to generic MM
>> +	  expeted semantics.
>> +
>> +	  If unsure, say N.
>> +
>>  config KPROBES_SANITY_TEST
>>  	bool "Kprobes sanity tests"
>>  	depends on DEBUG_KERNEL
>> diff --git a/lib/Makefile b/lib/Makefile
>> index 095601c..0806d61 100644
>> --- a/lib/Makefile
>> +++ b/lib/Makefile
>> @@ -76,6 +76,7 @@ obj-$(CONFIG_TEST_VMALLOC) += test_vmalloc.o
>>  obj-$(CONFIG_TEST_OVERFLOW) += test_overflow.o
>>  obj-$(CONFIG_TEST_RHASHTABLE) += test_rhashtable.o
>>  obj-$(CONFIG_TEST_SORT) += test_sort.o
>> +obj-$(CONFIG_TEST_ARCH_PGTABLE) += test_arch_pgtable.o
>>  obj-$(CONFIG_TEST_USER_COPY) += test_user_copy.o
>>  obj-$(CONFIG_TEST_STATIC_KEYS) += test_static_keys.o
>>  obj-$(CONFIG_TEST_STATIC_KEYS) += test_static_key_base.o
>> diff --git a/lib/test_arch_pgtable.c b/lib/test_arch_pgtable.c
>> new file mode 100644
>> index 0000000..1396664
>> --- /dev/null
>> +++ b/lib/test_arch_pgtable.c
>> @@ -0,0 +1,290 @@
>> +// SPDX-License-Identifier: GPL-2.0-only
>> +/*
>> + * This kernel module validates architecture page table helpers &
>> + * accessors and helps in verifying their continued compliance with
>> + * generic MM semantics.
>> + *
>> + * Copyright (C) 2019 ARM Ltd.
>> + *
>> + * Author: Anshuman Khandual <anshuman.khandual@arm.com>
>> + */
>> +#define pr_fmt(fmt) "test_arch_pgtable: %s " fmt, __func__
>> +
>> +#include <linux/kernel.h>
>> +#include <linux/hugetlb.h>
>> +#include <linux/mm.h>
>> +#include <linux/mman.h>
>> +#include <linux/mm_types.h>
>> +#include <linux/module.h>
>> +#include <linux/printk.h>
>> +#include <linux/swap.h>
>> +#include <linux/swapops.h>
>> +#include <linux/pfn_t.h>
>> +#include <linux/gfp.h>
>> +#include <asm/pgalloc.h>
>> +#include <asm/pgtable.h>
>> +
>> +/*
>> + * Basic operations
>> + *
>> + * mkold(entry)			= An old and not an young entry
>> + * mkyoung(entry)		= An young and not an old entry
>> + * mkdirty(entry)		= A dirty and not a clean entry
>> + * mkclean(entry)		= A clean and not a dirty entry
>> + * mkwrite(entry)		= An write and not an write protected entry
>> + * wrprotect(entry)		= An write protected and not an write entry
>> + * pxx_bad(entry)		= A mapped and non-table entry
>> + * pxx_same(entry1, entry2)	= Both entries hold the exact same value
>> + */
>> +#define VMA_TEST_FLAGS (VM_READ|VM_WRITE|VM_EXEC)
>> +
>> +static struct vm_area_struct vma;
>> +static struct mm_struct mm;
>> +static struct page *page;
>> +static pgprot_t prot;
>> +static unsigned long pfn, addr;
>> +
>> +static void pte_basic_tests(void)
>> +{
>> +	pte_t pte;
>> +
>> +	pte = mk_pte(page, prot);
>> +	WARN_ON(!pte_same(pte, pte));
>> +	WARN_ON(!pte_young(pte_mkyoung(pte)));
>> +	WARN_ON(!pte_dirty(pte_mkdirty(pte)));
>> +	WARN_ON(!pte_write(pte_mkwrite(pte)));
>> +	WARN_ON(pte_young(pte_mkold(pte)));
>> +	WARN_ON(pte_dirty(pte_mkclean(pte)));
>> +	WARN_ON(pte_write(pte_wrprotect(pte)));
>> +}
>> +
>> +#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE
>> +static void pmd_basic_tests(void)
>> +{
>> +	pmd_t pmd;
>> +
>> +	pmd = mk_pmd(page, prot);
> 
> mk_pmd() is provided on 32-bit ARM LPAE, which also sets
> HAVE_ARCH_TRANSPARENT_HUGEPAGE, so this should be fine.

Okay.

> 
>> +	WARN_ON(!pmd_same(pmd, pmd));
>> +	WARN_ON(!pmd_young(pmd_mkyoung(pmd)));
>> +	WARN_ON(!pmd_dirty(pmd_mkdirty(pmd)));
>> +	WARN_ON(!pmd_write(pmd_mkwrite(pmd)));
>> +	WARN_ON(pmd_young(pmd_mkold(pmd)));
>> +	WARN_ON(pmd_dirty(pmd_mkclean(pmd)));
>> +	WARN_ON(pmd_write(pmd_wrprotect(pmd)));
>> +	/*
>> +	 * A huge page does not point to next level page table
>> +	 * entry. Hence this must qualify as pmd_bad().
>> +	 */
>> +	WARN_ON(!pmd_bad(pmd_mkhuge(pmd)));
>> +}
>> +#else
>> +static void pmd_basic_tests(void) { }
>> +#endif
>> +
>> +#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
>> +static void pud_basic_tests(void)
>> +{
>> +	pud_t pud;
>> +
>> +	pud = pfn_pud(pfn, prot);
>> +	WARN_ON(!pud_same(pud, pud));
>> +	WARN_ON(!pud_young(pud_mkyoung(pud)));
>> +	WARN_ON(!pud_write(pud_mkwrite(pud)));
>> +	WARN_ON(pud_write(pud_wrprotect(pud)));
>> +	WARN_ON(pud_young(pud_mkold(pud)));
>> +
>> +#if !defined(__PAGETABLE_PMD_FOLDED) && !defined(__ARCH_HAS_4LEVEL_HACK)
>> +	/*
>> +	 * A huge page does not point to next level page table
>> +	 * entry. Hence this must qualify as pud_bad().
>> +	 */
>> +	WARN_ON(!pud_bad(pud_mkhuge(pud)));
>> +#endif
>> +}
>> +#else
>> +static void pud_basic_tests(void) { }
>> +#endif
>> +
>> +static void p4d_basic_tests(void)
>> +{
>> +	pte_t pte;
>> +	p4d_t p4d;
>> +
>> +	pte = mk_pte(page, prot);
>> +	p4d = (p4d_t) { (pte_val(pte)) };
>> +	WARN_ON(!p4d_same(p4d, p4d));
> 
> If the intention is to test p4d_same(), is this really a sufficient test?

p4d_same() just tests if two p4d entries have the same value. Hence any non-zero
value in there should be able to achieve that. Besides p4d does not have much
common helpers (as it gets often folded) to operate on an entry in order to create
other real world values. But if you have suggestions to make this better I am happy
to incorporate.

> 
>> +}
>> +
>> +static void pgd_basic_tests(void)
>> +{
>> +	pte_t pte;
>> +	pgd_t pgd;
>> +
>> +	pte = mk_pte(page, prot);
>> +	pgd = (pgd_t) { (pte_val(pte)) };
>> +	WARN_ON(!pgd_same(pgd, pgd));
> 
> If the intention is to test pgd_same(), is this really a sufficient test?

Same as above.

> 
>> +}
>> +
>> +#if !defined(__PAGETABLE_PMD_FOLDED) && !defined(__ARCH_HAS_4LEVEL_HACK)
>> +static void pud_clear_tests(void)
>> +{
>> +	pud_t pud;
>> +
>> +	pud_clear(&pud);
>> +	WARN_ON(!pud_none(pud));
>> +}
>> +
>> +static void pud_populate_tests(void)
>> +{
>> +	pmd_t pmd;
>> +	pud_t pud;
>> +
>> +	/*
>> +	 * This entry points to next level page table page.
>> +	 * Hence this must not qualify as pud_bad().
>> +	 */
>> +	pmd_clear(&pmd);
> 
> 32-bit ARM sets __PAGETABLE_PMD_FOLDED so this is not a concern.

Okay.

> 
>> +	pud_clear(&pud);
>> +	pud_populate(&mm, &pud, &pmd);
>> +	WARN_ON(pud_bad(pud));
>> +}
>> +#else
>> +static void pud_clear_tests(void) { }
>> +static void pud_populate_tests(void) { }
>> +#endif
>> +
>> +#if !defined(__PAGETABLE_PUD_FOLDED) && !defined(__ARCH_HAS_5LEVEL_HACK)
>> +static void p4d_clear_tests(void)
>> +{
>> +	p4d_t p4d;
>> +
>> +	p4d_clear(&p4d);
>> +	WARN_ON(!p4d_none(p4d));
>> +}
>> +
>> +static void p4d_populate_tests(void)
>> +{
>> +	pud_t pud;
>> +	p4d_t p4d;
>> +
>> +	/*
>> +	 * This entry points to next level page table page.
>> +	 * Hence this must not qualify as p4d_bad().
>> +	 */
>> +	pud_clear(&pud);
>> +	p4d_clear(&p4d);
>> +	p4d_populate(&mm, &p4d, &pud);
>> +	WARN_ON(p4d_bad(p4d));
>> +}
>> +#else
>> +static void p4d_clear_tests(void) { }
>> +static void p4d_populate_tests(void) { }
>> +#endif
>> +
>> +#ifndef __PAGETABLE_P4D_FOLDED
>> +static void pgd_clear_tests(void)
>> +{
>> +	pgd_t pgd;
>> +
>> +	pgd_clear(&pgd);
>> +	WARN_ON(!pgd_none(pgd));
>> +}
>> +
>> +static void pgd_populate_tests(void)
>> +{
>> +	pgd_t p4d;
>> +	pgd_t pgd;
>> +
>> +	/*
>> +	 * This entry points to next level page table page.
>> +	 * Hence this must not qualify as pgd_bad().
>> +	 */
>> +	p4d_clear(&p4d);
>> +	pgd_clear(&pgd);
>> +	pgd_populate(&mm, &pgd, &p4d);
>> +	WARN_ON(pgd_bad(pgd));
>> +}
>> +#else
>> +static void pgd_clear_tests(void) { }
>> +static void pgd_populate_tests(void) { }
>> +#endif
>> +
>> +static void pxx_clear_tests(void)
>> +{
>> +	pte_t pte;
>> +	pmd_t pmd;
>> +
>> +	pte_clear(NULL, 0, &pte);
>> +	WARN_ON(!pte_none(pte));
>> +
>> +	pmd_clear(&pmd);
> 
> This really isn't going to be happy on 32-bit non-LPAE ARM.  Here, a
> PMD is a 32-bit entry which is expected to be _within_ a proper PGD,
> where a PGD is 16K in size, consisting of pairs of PMDs.
> 
> So, pmd_clear() expects to always be called for an _even_ PMD of the
> pair, and will write to the even and following odd PMD.  Hence, the
> above will scribble over the stack of this function.

A pmd_clear() clears two consecutive 32 bit pmd_t entries not a single
one. So the stack needs to have two entries for such cases. I could see
only a single definition for pmd_none() on arm, hence pmd_none() should
be called on both the 32 bit entries cleared with pmd_clear() earlier ?

Though this could be accommodate with relevant non-LPAE ARM specific
config option but should we do that ? All the config wrappers in the test
right now are generic MM identifiable and nothing platform specific. The
primary idea is to test platform page table helpers as seen from generic
MM. Any suggestions how to incorporate this while still keeping the test
clear from platform specific details like these ?

> 
>> +	WARN_ON(!pmd_none(pmd));
>> +
>> +	pud_clear_tests();
>> +	p4d_clear_tests();
>> +	pgd_clear_tests();
>> +}
>> +
>> +static void pxx_populate_tests(void)
>> +{
>> +	pmd_t pmd;
>> +
>> +	/*
>> +	 * This entry points to next level page table page.
>> +	 * Hence this must not qualify as pmd_bad().
>> +	 */
>> +	memset(page, 0, sizeof(*page));
>> +	pmd_clear(&pmd);
> 
> This really isn't going to be happy on 32-bit non-LPAE ARM.  Here, a
> PMD is a 32-bit entry which is expected to be _within_ a proper PGD,
> where a PGD is 16K in size, consisting of pairs of PMDs.
> 
> So, pmd_clear() expects to always be called for an _even_ PMD of the
> pair, and will write to the even and following odd PMD.  Hence, the
> above will scribble over the stack of this function.

Same as above.

> 
>> +	pmd_populate(&mm, &pmd, page);
> 
> This too has the same expectations on 32-bit non-LPAE ARM.

Right this loads up both pmdp[0] and pmdp[1]. The issue is equivalent to
the one detailed above.

