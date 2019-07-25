Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF333C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 21:54:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73B8B229F9
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 21:54:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=armlinux.org.uk header.i=@armlinux.org.uk header.b="y0ABmQzB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73B8B229F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=armlinux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 104B46B000A; Thu, 25 Jul 2019 17:54:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B66C8E0003; Thu, 25 Jul 2019 17:54:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBFC68E0002; Thu, 25 Jul 2019 17:54:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9E7C56B000A
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 17:54:39 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id w11so24557455wrl.7
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:54:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent:sender;
        bh=FoNhVQA0KAEXK0jitZxCyQjvTf+0+pE3OZ7E0axzQF0=;
        b=sNajGhw/J24eCZZPnNbo0u6qC0cxq9peUE7DUR6EdO3fEWdSUfqQTB5QDmqqRk8XlL
         +G/bBx87OHUhwZpryY83SjadU9WmQ0qqoMuNI96OGw4RNmjGgNcr0hbCULSBtiPSb3ej
         zMkRpzbARV8N9U5oo52V810R7tNeJvcgMvm/53S07+u9NTMrl4B3X6JdNpJBiORreKZi
         cGY9a/0+ZR0aIKkmWw3KQmOPcOCJBuv9sJqiAZglT3Pu5MsIe1djak6fZYZwV2AA3tVK
         PxUxG52bqk8J3X3SZpIe8RheOs7YMj6ieWHiEWpg1fYw8f27clsw99GuEaXm+E2x7sVP
         frtw==
X-Gm-Message-State: APjAAAWX545kzwacDisF1Uumg/For9oDGampI+s1/pTdgPQw28EaYZse
	WZ66B/sHV3iWdNm75fEln56viWSP5BoXJMJVsqewxi+swBEA14rDuFebGE4BJ5OxhFFdvBF5HzC
	9jL3LtISRdNv2ChGn3KuUP1+/0b8bq3kbmG4JWutqxxgdeGNvV7y0QucK3B7FeNUqIg==
X-Received: by 2002:adf:eb49:: with SMTP id u9mr94170143wrn.215.1564091679025;
        Thu, 25 Jul 2019 14:54:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyb7IcqJEzvjcH5AU5YmzpcUUpB8N1PIaQL+TQ1mkUMd8f84NiVXVtdNQd+ZN9WZ57UYzyd
X-Received: by 2002:adf:eb49:: with SMTP id u9mr94170120wrn.215.1564091678139;
        Thu, 25 Jul 2019 14:54:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564091678; cv=none;
        d=google.com; s=arc-20160816;
        b=L7BynOJn1p6dmDhr1RzLjLdFfGxpFvku31M9sdAdIgy52fcRo1oeZSJ9r8XcqO4WtM
         wtOntl9KS7QX4vsJ0fOR8e8K8VIRSVD1wgbFkgcTQ/54Ar8roclBXqm/+0ApE0vaucr7
         qLCxSUh94eoNIpnINnKH37879sUFpFWMfL34SI+f5T2xmBz7BA5qiaUsPlX323zwkKGo
         3Nl2gxsV1UUfxKA8SJMBwtRfb/24lQpRlKCEO4C0yhK1J0YQhruoIM34meIAb946cQI5
         2jKj9qde7RyRVLhgWFBS4xTZUTXvKfd4AMYixlaK0fv+7n92toXDeEVeQl1ZvjQ/wFP5
         NzVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date:dkim-signature;
        bh=FoNhVQA0KAEXK0jitZxCyQjvTf+0+pE3OZ7E0axzQF0=;
        b=riB2az9vTmcXm8L3zTNhhebYpJuvo+mq1m4bsDvmOlIqDokI2WouHn5oa0yedxiXPE
         ktosANS1AjwGggPH7Jup1UhK/kyI/H+ZNasJutGfKarh+0QapkSRM48d0OoC3t7hhb7s
         wPSe9LqlAiexs788q8Vi0dLfkML9RUksBHRhPCvSjTGrHZ26r4gNtYMpA9IGog6M2112
         kusGAP22Z2pzC7E6VrlZenHeaEE+RKBY8DkNtnrJ8wJkd690TSnesuApLsLXuJ97ZX2c
         M87hw6/mBCH+fsV58USqx55c1C/rNg1EaqCDfntEnl72wrnpPvaKm8RIIDvtAulQ7maA
         1pOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass (test mode) header.i=@armlinux.org.uk header.s=pandora-2019 header.b=y0ABmQzB;
       spf=pass (google.com: best guess record for domain of linux+linux-mm=kvack.org@armlinux.org.uk designates 2001:4d48:ad52:3201:214:fdff:fe10:1be6 as permitted sender) smtp.mailfrom="linux+linux-mm=kvack.org@armlinux.org.uk";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=armlinux.org.uk
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id j1si45558357wrw.311.2019.07.25.14.54.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 14:54:38 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of linux+linux-mm=kvack.org@armlinux.org.uk designates 2001:4d48:ad52:3201:214:fdff:fe10:1be6 as permitted sender) client-ip=2001:4d48:ad52:3201:214:fdff:fe10:1be6;
Authentication-Results: mx.google.com;
       dkim=pass (test mode) header.i=@armlinux.org.uk header.s=pandora-2019 header.b=y0ABmQzB;
       spf=pass (google.com: best guess record for domain of linux+linux-mm=kvack.org@armlinux.org.uk designates 2001:4d48:ad52:3201:214:fdff:fe10:1be6 as permitted sender) smtp.mailfrom="linux+linux-mm=kvack.org@armlinux.org.uk";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=armlinux.org.uk
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=armlinux.org.uk; s=pandora-2019; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=FoNhVQA0KAEXK0jitZxCyQjvTf+0+pE3OZ7E0axzQF0=; b=y0ABmQzBWsC4jUOT2EXdafQWV
	xYH4T2EFMce6MlngbPqWp1CIs3Xwv4iiT/x7Sj/ZpnFG3us4qb75NQGgXosmD6eccpR4rl6M/SQ5H
	heLTJMqr82x1UApvAMJvwnQ+YNZ4u1/9bQq8NemQcELJ0Z563FUXR5ZS/pktALBMQmIiK0yE+Ug7e
	yzdB3eq2aT2fwSmZAMcuQjzGCcZzLAxJLFPyeoDosqQFglsNh0cQm7yFfBvhIiY/evXX6OJ/zxTGd
	CY1eFMFf8OQswqfm9Xa0v1+pBasGCFgpQE5ceIRLFkms/geYpBR2jjBM39kACi0eL8qEyEY1J4iLH
	i8DtATTfg==;
Received: from shell.armlinux.org.uk ([fd8f:7570:feb6:1:5054:ff:fe00:4ec]:48798)
	by pandora.armlinux.org.uk with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.90_1)
	(envelope-from <linux@armlinux.org.uk>)
	id 1hqlh3-0002X0-8j; Thu, 25 Jul 2019 22:54:33 +0100
Received: from linux by shell.armlinux.org.uk with local (Exim 4.92)
	(envelope-from <linux@shell.armlinux.org.uk>)
	id 1hqlgx-00062h-KW; Thu, 25 Jul 2019 22:54:27 +0100
Date: Thu, 25 Jul 2019 22:54:27 +0100
From: Russell King - ARM Linux admin <linux@armlinux.org.uk>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Mark Rutland <mark.rutland@arm.com>, x86@kernel.org,
	Kees Cook <keescook@chromium.org>,
	Sri Krishna chowdary <schowdary@nvidia.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Mark Brown <Mark.Brown@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Steven Price <Steven.Price@arm.com>,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [RFC] mm/pgtable/debug: Add test validating architecture page
 table helpers
Message-ID: <20190725215427.GL1330@shell.armlinux.org.uk>
References: <1564037723-26676-1-git-send-email-anshuman.khandual@arm.com>
 <1564037723-26676-2-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1564037723-26676-2-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 12:25:23PM +0530, Anshuman Khandual wrote:
> This adds a test module which will validate architecture page table helpers
> and accessors regarding compliance with generic MM semantics expectations.
> This will help various architectures in validating changes to the existing
> page table helpers or addition of new ones.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Mark Brown <Mark.Brown@arm.com>
> Cc: Steven Price <Steven.Price@arm.com>
> Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Sri Krishna chowdary <schowdary@nvidia.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: x86@kernel.org
> Cc: linux-kernel@vger.kernel.org
> 
> Suggested-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
>  lib/Kconfig.debug       |  14 +++
>  lib/Makefile            |   1 +
>  lib/test_arch_pgtable.c | 290 ++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 305 insertions(+)
>  create mode 100644 lib/test_arch_pgtable.c
> 
> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index 5960e29..a27fe8d 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -1719,6 +1719,20 @@ config TEST_SORT
>  
>  	  If unsure, say N.
>  
> +config TEST_ARCH_PGTABLE
> +	tristate "Test arch page table helpers for semantics compliance"
> +	depends on MMU
> +	depends on DEBUG_KERNEL || m
> +	help
> +	  This options provides a kernel module which can be used to test
> +	  architecture page table helper functions on various platform in
> +	  verifing if they comply with expected generic MM semantics. This
> +	  will help architectures code in making sure that any changes or
> +	  new additions of these helpers will still conform to generic MM
> +	  expeted semantics.
> +
> +	  If unsure, say N.
> +
>  config KPROBES_SANITY_TEST
>  	bool "Kprobes sanity tests"
>  	depends on DEBUG_KERNEL
> diff --git a/lib/Makefile b/lib/Makefile
> index 095601c..0806d61 100644
> --- a/lib/Makefile
> +++ b/lib/Makefile
> @@ -76,6 +76,7 @@ obj-$(CONFIG_TEST_VMALLOC) += test_vmalloc.o
>  obj-$(CONFIG_TEST_OVERFLOW) += test_overflow.o
>  obj-$(CONFIG_TEST_RHASHTABLE) += test_rhashtable.o
>  obj-$(CONFIG_TEST_SORT) += test_sort.o
> +obj-$(CONFIG_TEST_ARCH_PGTABLE) += test_arch_pgtable.o
>  obj-$(CONFIG_TEST_USER_COPY) += test_user_copy.o
>  obj-$(CONFIG_TEST_STATIC_KEYS) += test_static_keys.o
>  obj-$(CONFIG_TEST_STATIC_KEYS) += test_static_key_base.o
> diff --git a/lib/test_arch_pgtable.c b/lib/test_arch_pgtable.c
> new file mode 100644
> index 0000000..1396664
> --- /dev/null
> +++ b/lib/test_arch_pgtable.c
> @@ -0,0 +1,290 @@
> +// SPDX-License-Identifier: GPL-2.0-only
> +/*
> + * This kernel module validates architecture page table helpers &
> + * accessors and helps in verifying their continued compliance with
> + * generic MM semantics.
> + *
> + * Copyright (C) 2019 ARM Ltd.
> + *
> + * Author: Anshuman Khandual <anshuman.khandual@arm.com>
> + */
> +#define pr_fmt(fmt) "test_arch_pgtable: %s " fmt, __func__
> +
> +#include <linux/kernel.h>
> +#include <linux/hugetlb.h>
> +#include <linux/mm.h>
> +#include <linux/mman.h>
> +#include <linux/mm_types.h>
> +#include <linux/module.h>
> +#include <linux/printk.h>
> +#include <linux/swap.h>
> +#include <linux/swapops.h>
> +#include <linux/pfn_t.h>
> +#include <linux/gfp.h>
> +#include <asm/pgalloc.h>
> +#include <asm/pgtable.h>
> +
> +/*
> + * Basic operations
> + *
> + * mkold(entry)			= An old and not an young entry
> + * mkyoung(entry)		= An young and not an old entry
> + * mkdirty(entry)		= A dirty and not a clean entry
> + * mkclean(entry)		= A clean and not a dirty entry
> + * mkwrite(entry)		= An write and not an write protected entry
> + * wrprotect(entry)		= An write protected and not an write entry
> + * pxx_bad(entry)		= A mapped and non-table entry
> + * pxx_same(entry1, entry2)	= Both entries hold the exact same value
> + */
> +#define VMA_TEST_FLAGS (VM_READ|VM_WRITE|VM_EXEC)
> +
> +static struct vm_area_struct vma;
> +static struct mm_struct mm;
> +static struct page *page;
> +static pgprot_t prot;
> +static unsigned long pfn, addr;
> +
> +static void pte_basic_tests(void)
> +{
> +	pte_t pte;
> +
> +	pte = mk_pte(page, prot);
> +	WARN_ON(!pte_same(pte, pte));
> +	WARN_ON(!pte_young(pte_mkyoung(pte)));
> +	WARN_ON(!pte_dirty(pte_mkdirty(pte)));
> +	WARN_ON(!pte_write(pte_mkwrite(pte)));
> +	WARN_ON(pte_young(pte_mkold(pte)));
> +	WARN_ON(pte_dirty(pte_mkclean(pte)));
> +	WARN_ON(pte_write(pte_wrprotect(pte)));
> +}
> +
> +#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE
> +static void pmd_basic_tests(void)
> +{
> +	pmd_t pmd;
> +
> +	pmd = mk_pmd(page, prot);

mk_pmd() is provided on 32-bit ARM LPAE, which also sets
HAVE_ARCH_TRANSPARENT_HUGEPAGE, so this should be fine.

> +	WARN_ON(!pmd_same(pmd, pmd));
> +	WARN_ON(!pmd_young(pmd_mkyoung(pmd)));
> +	WARN_ON(!pmd_dirty(pmd_mkdirty(pmd)));
> +	WARN_ON(!pmd_write(pmd_mkwrite(pmd)));
> +	WARN_ON(pmd_young(pmd_mkold(pmd)));
> +	WARN_ON(pmd_dirty(pmd_mkclean(pmd)));
> +	WARN_ON(pmd_write(pmd_wrprotect(pmd)));
> +	/*
> +	 * A huge page does not point to next level page table
> +	 * entry. Hence this must qualify as pmd_bad().
> +	 */
> +	WARN_ON(!pmd_bad(pmd_mkhuge(pmd)));
> +}
> +#else
> +static void pmd_basic_tests(void) { }
> +#endif
> +
> +#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
> +static void pud_basic_tests(void)
> +{
> +	pud_t pud;
> +
> +	pud = pfn_pud(pfn, prot);
> +	WARN_ON(!pud_same(pud, pud));
> +	WARN_ON(!pud_young(pud_mkyoung(pud)));
> +	WARN_ON(!pud_write(pud_mkwrite(pud)));
> +	WARN_ON(pud_write(pud_wrprotect(pud)));
> +	WARN_ON(pud_young(pud_mkold(pud)));
> +
> +#if !defined(__PAGETABLE_PMD_FOLDED) && !defined(__ARCH_HAS_4LEVEL_HACK)
> +	/*
> +	 * A huge page does not point to next level page table
> +	 * entry. Hence this must qualify as pud_bad().
> +	 */
> +	WARN_ON(!pud_bad(pud_mkhuge(pud)));
> +#endif
> +}
> +#else
> +static void pud_basic_tests(void) { }
> +#endif
> +
> +static void p4d_basic_tests(void)
> +{
> +	pte_t pte;
> +	p4d_t p4d;
> +
> +	pte = mk_pte(page, prot);
> +	p4d = (p4d_t) { (pte_val(pte)) };
> +	WARN_ON(!p4d_same(p4d, p4d));

If the intention is to test p4d_same(), is this really a sufficient test?

> +}
> +
> +static void pgd_basic_tests(void)
> +{
> +	pte_t pte;
> +	pgd_t pgd;
> +
> +	pte = mk_pte(page, prot);
> +	pgd = (pgd_t) { (pte_val(pte)) };
> +	WARN_ON(!pgd_same(pgd, pgd));

If the intention is to test pgd_same(), is this really a sufficient test?

> +}
> +
> +#if !defined(__PAGETABLE_PMD_FOLDED) && !defined(__ARCH_HAS_4LEVEL_HACK)
> +static void pud_clear_tests(void)
> +{
> +	pud_t pud;
> +
> +	pud_clear(&pud);
> +	WARN_ON(!pud_none(pud));
> +}
> +
> +static void pud_populate_tests(void)
> +{
> +	pmd_t pmd;
> +	pud_t pud;
> +
> +	/*
> +	 * This entry points to next level page table page.
> +	 * Hence this must not qualify as pud_bad().
> +	 */
> +	pmd_clear(&pmd);

32-bit ARM sets __PAGETABLE_PMD_FOLDED so this is not a concern.

> +	pud_clear(&pud);
> +	pud_populate(&mm, &pud, &pmd);
> +	WARN_ON(pud_bad(pud));
> +}
> +#else
> +static void pud_clear_tests(void) { }
> +static void pud_populate_tests(void) { }
> +#endif
> +
> +#if !defined(__PAGETABLE_PUD_FOLDED) && !defined(__ARCH_HAS_5LEVEL_HACK)
> +static void p4d_clear_tests(void)
> +{
> +	p4d_t p4d;
> +
> +	p4d_clear(&p4d);
> +	WARN_ON(!p4d_none(p4d));
> +}
> +
> +static void p4d_populate_tests(void)
> +{
> +	pud_t pud;
> +	p4d_t p4d;
> +
> +	/*
> +	 * This entry points to next level page table page.
> +	 * Hence this must not qualify as p4d_bad().
> +	 */
> +	pud_clear(&pud);
> +	p4d_clear(&p4d);
> +	p4d_populate(&mm, &p4d, &pud);
> +	WARN_ON(p4d_bad(p4d));
> +}
> +#else
> +static void p4d_clear_tests(void) { }
> +static void p4d_populate_tests(void) { }
> +#endif
> +
> +#ifndef __PAGETABLE_P4D_FOLDED
> +static void pgd_clear_tests(void)
> +{
> +	pgd_t pgd;
> +
> +	pgd_clear(&pgd);
> +	WARN_ON(!pgd_none(pgd));
> +}
> +
> +static void pgd_populate_tests(void)
> +{
> +	pgd_t p4d;
> +	pgd_t pgd;
> +
> +	/*
> +	 * This entry points to next level page table page.
> +	 * Hence this must not qualify as pgd_bad().
> +	 */
> +	p4d_clear(&p4d);
> +	pgd_clear(&pgd);
> +	pgd_populate(&mm, &pgd, &p4d);
> +	WARN_ON(pgd_bad(pgd));
> +}
> +#else
> +static void pgd_clear_tests(void) { }
> +static void pgd_populate_tests(void) { }
> +#endif
> +
> +static void pxx_clear_tests(void)
> +{
> +	pte_t pte;
> +	pmd_t pmd;
> +
> +	pte_clear(NULL, 0, &pte);
> +	WARN_ON(!pte_none(pte));
> +
> +	pmd_clear(&pmd);

This really isn't going to be happy on 32-bit non-LPAE ARM.  Here, a
PMD is a 32-bit entry which is expected to be _within_ a proper PGD,
where a PGD is 16K in size, consisting of pairs of PMDs.

So, pmd_clear() expects to always be called for an _even_ PMD of the
pair, and will write to the even and following odd PMD.  Hence, the
above will scribble over the stack of this function.

> +	WARN_ON(!pmd_none(pmd));
> +
> +	pud_clear_tests();
> +	p4d_clear_tests();
> +	pgd_clear_tests();
> +}
> +
> +static void pxx_populate_tests(void)
> +{
> +	pmd_t pmd;
> +
> +	/*
> +	 * This entry points to next level page table page.
> +	 * Hence this must not qualify as pmd_bad().
> +	 */
> +	memset(page, 0, sizeof(*page));
> +	pmd_clear(&pmd);

This really isn't going to be happy on 32-bit non-LPAE ARM.  Here, a
PMD is a 32-bit entry which is expected to be _within_ a proper PGD,
where a PGD is 16K in size, consisting of pairs of PMDs.

So, pmd_clear() expects to always be called for an _even_ PMD of the
pair, and will write to the even and following odd PMD.  Hence, the
above will scribble over the stack of this function.

> +	pmd_populate(&mm, &pmd, page);

This too has the same expectations on 32-bit non-LPAE ARM.

> +	WARN_ON(pmd_bad(pmd));
> +
> +	pud_populate_tests();
> +	p4d_populate_tests();
> +	pgd_populate_tests();
> +}
> +
> +static int variables_alloc(void)
> +{
> +	vma_init(&vma, &mm);
> +	prot = vm_get_page_prot(VMA_TEST_FLAGS);
> +	page = alloc_page(GFP_KERNEL | __GFP_ZERO);
> +	if (!page) {
> +		pr_err("Test struct page allocation failed\n");
> +		return 1;
> +	}
> +	pfn = page_to_pfn(page);
> +	addr = 0;
> +	return 0;
> +}
> +
> +static void variables_free(void)
> +{
> +	free_page((unsigned long)page_address(page));
> +}
> +
> +static int __init arch_pgtable_tests_init(void)
> +{
> +	int ret;
> +
> +	ret = variables_alloc();
> +	if (ret) {
> +		pr_err("Test resource initialization failed\n");
> +		return 1;
> +	}
> +
> +	pte_basic_tests();
> +	pmd_basic_tests();
> +	pud_basic_tests();
> +	p4d_basic_tests();
> +	pgd_basic_tests();
> +	pxx_clear_tests();
> +	pxx_populate_tests();
> +	variables_free();
> +	return 0;
> +}
> +
> +static void __exit arch_pgtable_tests_exit(void) { }
> +
> +module_init(arch_pgtable_tests_init);
> +module_exit(arch_pgtable_tests_exit);
> +MODULE_LICENSE("GPL v2");
> -- 
> 2.7.4
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 

-- 
RMK's Patch system: https://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up

