Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A1DDC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 02:59:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 144BB2070D
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 02:59:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 144BB2070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80EA88E0003; Sun, 28 Jul 2019 22:59:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C0EE8E0002; Sun, 28 Jul 2019 22:59:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D6908E0003; Sun, 28 Jul 2019 22:59:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1BA568E0002
	for <linux-mm@kvack.org>; Sun, 28 Jul 2019 22:59:20 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e9so26308799edv.18
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 19:59:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=fRR3kVzigphVvftyXTJVxw53b+1d8Z1nXzk5NhGQEtk=;
        b=YXGtnPsE0IYAL+JgdQj0s5GDUcM+It55Oyondn+inOnyOqHwAzeasPkhxOS3pHzDr0
         ihhV+fataYcWxiQMOzB2kEAlj3zTC4hfZSSPLoBULqwlcywro26JQ65FDtnL5WMxUNSk
         v2AkB64RcaxQ2r4lIXDkMOM8AkdXk6T9/5IBTR6+EmzgRi8QP8wqUVGu9a+wlvzahJ3f
         YlJcJv3LhSKo6ERmBPn1sLfOheVwJwspuoB7VVWPPC3Ms7Gl4W0MzdVVe9DESh6qlAuh
         KbhU65vgNFBVxsctV52qoQvRTf9WHeHogXxonVH71Hp1NDEtWIvfgzldaFOz+S13+Zu6
         zunA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVbzxmsatHRAtDrgNZUg7sWWnIi/DN6oFXh4CpuToeO/bzT5TQX
	Vs1Ng1JRMxcF0iHqwygt6TxWSNooEFYkgY4TsfCNp9TneyVeH7p7U5T+iLnmfibFigDPOGghW/c
	+nAeWdKIcPk7uyyK1NLlaYm4cduy+ZcqhY+kxu4DMJpQKxR3vAFoNXKJVVYT1o2jhvQ==
X-Received: by 2002:a50:fb86:: with SMTP id e6mr93866073edq.203.1564369159640;
        Sun, 28 Jul 2019 19:59:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAa/PZO12ZG5GxBuIVvtSlaAZ0I+m5eTzckXyd1XKWRDDqlaqQ4gB0wtRY729By0CRLXW7
X-Received: by 2002:a50:fb86:: with SMTP id e6mr93866030edq.203.1564369158522;
        Sun, 28 Jul 2019 19:59:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564369158; cv=none;
        d=google.com; s=arc-20160816;
        b=ikqEwtLAqw9Ywyms7H/bBvqdeBRxCGaLv5772Bqogztlljk5xCe/kJs8RC4GWW/wDF
         YGRes0v3mXCvdtnS6FSPuPvXiCpy8OWs08CpyQWN6nNCvg7McuNbtuKyZtk3POGrX+33
         UnfrvRgfob+eRMmMS27rPoLmBCipPBsbNoGCkx8zgbsYWGydpJDRzVNwPgz5Vh+w541O
         fd+mPVapZhusjHNblaN5US5Fsn+Q4XOgkWrtDRUnLJePFkDQByfkWIZZj0NWuz/6jbNd
         IN0Tu9c+eu6wiy4LL7rKExuLVb6wj2614yih0aWvPM8Ji/l/hOj7oiSjF/rInxo29tYV
         ZEiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=fRR3kVzigphVvftyXTJVxw53b+1d8Z1nXzk5NhGQEtk=;
        b=ZRqjlvVQycSZklW5ZDFo8qDrTpi9HKTKBXlV1kW1UGy6GXMWvDTwydFWaP+YtP6Hzp
         qkxSi2kBd4fZ+AAK8BPR/frEspTaYoqA7FM4BLyYiKQWYwW7TX/PN6me336UtdMvimYH
         r3aYe+G1OIVaBwg1KMG+yWc5FkSHc4LRWrH0lZ/5Z3gLsTJyKVF6BNExvfUoTgpSl59N
         PJfT1DMiXFHonFum/+nf8O7fesr6CJdv7O1EOQchcgGYn23wpR/VyZ8Y7ElM44zVu4LO
         Ie54i6LBPoRXpAcwdc3Fci3D3RjrZ/cHtB5S+D1J4g02Fpz+6IKEkBC/JVisw74sadbX
         eaSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id x7si16508653edm.177.2019.07.28.19.59.17
        for <linux-mm@kvack.org>;
        Sun, 28 Jul 2019 19:59:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1313E344;
	Sun, 28 Jul 2019 19:59:17 -0700 (PDT)
Received: from [10.162.40.126] (p8cg001049571a15.blr.arm.com [10.162.40.126])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 92A103F694;
	Sun, 28 Jul 2019 19:59:10 -0700 (PDT)
Subject: Re: [PATCH v9 19/21] mm: Add generic ptdump
To: Steven Price <steven.price@arm.com>, linux-mm@kvack.org
Cc: Andy Lutomirski <luto@kernel.org>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>, Arnd Bergmann <arnd@arndb.de>,
 Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>,
 James Morse <james.morse@arm.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
 Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>,
 x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 Mark Rutland <Mark.Rutland@arm.com>, "Liang, Kan"
 <kan.liang@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
References: <20190722154210.42799-1-steven.price@arm.com>
 <20190722154210.42799-20-steven.price@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <f8444b1f-c886-9bfd-4873-3ed9068d3c44@arm.com>
Date: Mon, 29 Jul 2019 08:29:50 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190722154210.42799-20-steven.price@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 07/22/2019 09:12 PM, Steven Price wrote:
> Add a generic version of page table dumping that architectures can
> opt-in to
> 
> Signed-off-by: Steven Price <steven.price@arm.com>
> ---
>  include/linux/ptdump.h |  19 +++++
>  mm/Kconfig.debug       |  21 ++++++
>  mm/Makefile            |   1 +
>  mm/ptdump.c            | 161 +++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 202 insertions(+)
>  create mode 100644 include/linux/ptdump.h
>  create mode 100644 mm/ptdump.c
> 
> diff --git a/include/linux/ptdump.h b/include/linux/ptdump.h
> new file mode 100644
> index 000000000000..eb8e78154be3
> --- /dev/null
> +++ b/include/linux/ptdump.h
> @@ -0,0 +1,19 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +
> +#ifndef _LINUX_PTDUMP_H
> +#define _LINUX_PTDUMP_H
> +
> +struct ptdump_range {
> +	unsigned long start;
> +	unsigned long end;
> +};
> +
> +struct ptdump_state {
> +	void (*note_page)(struct ptdump_state *st, unsigned long addr,
> +			  int level, unsigned long val);
> +	const struct ptdump_range *range;
> +};
> +
> +void ptdump_walk_pgd(struct ptdump_state *st, struct mm_struct *mm);
> +
> +#endif /* _LINUX_PTDUMP_H */
> diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
> index 82b6a20898bd..7ad939b7140f 100644
> --- a/mm/Kconfig.debug
> +++ b/mm/Kconfig.debug
> @@ -115,3 +115,24 @@ config DEBUG_RODATA_TEST
>      depends on STRICT_KERNEL_RWX
>      ---help---
>        This option enables a testcase for the setting rodata read-only.
> +
> +config GENERIC_PTDUMP
> +	bool
> +
> +config PTDUMP_CORE
> +	bool
> +
> +config PTDUMP_DEBUGFS
> +	bool "Export kernel pagetable layout to userspace via debugfs"
> +	depends on DEBUG_KERNEL
> +	depends on DEBUG_FS
> +	depends on GENERIC_PTDUMP
> +	select PTDUMP_CORE

So PTDUMP_DEBUGFS depends on GENERIC_PTDUMP but selects PTDUMP_CORE. So any arch
subscribing this new generic PTDUMP by selecting GENERIC_PTDUMP needs to provide
some functions for PTDUMP_DEBUGFS which does not really have any code in generic
MM. Also ptdump_walk_pgd() is wrapped in PTDUMP_CORE not GENERIC_PTDUMP. Then what
does PTDUMP_GENERIC really indicate ? Bit confusing here.

The new ptdump_walk_pgd() symbol needs to be wrapped in a config symbol for sure
which should be selected in all platforms wishing to use it. GENERIC_PTDUMP can
be that config.

PTDUMP_DEBUGFS will require a full implementation (i.e PTDUMP_CORE) irrespective
of whether the platform subscribes GENERIC_PTDUMP or not. It should be something
like this.

config PTDUMP_DEBUGFS
	bool "Export kernel pagetable layout to userspace via debugfs"
	depends on DEBUG_KERNEL
	depends on DEBUG_FS
	select PTDUMP_CORE

PTDUMP_DEBUGFS need not depend on GENERIC_PTDUMP. All it requires is a PTDUMP_CORE
implementation which can optionally use ptdump_walk_pgd() through GENERIC_PTDUMP.
s/GENERIC_PTDUMP/PTDUMP_GENERIC to match and group with other configs.

DEBUG_WX can also be moved to generic MM like PTDUMP_DEBUGFS ?

> +	help
> +	  Say Y here if you want to show the kernel pagetable layout in a
> +	  debugfs file. This information is only useful for kernel developers
> +	  who are working in architecture specific areas of the kernel.
> +	  It is probably not a good idea to enable this feature in a production
> +	  kernel.
> +
> +	  If in doubt, say N.
> diff --git a/mm/Makefile b/mm/Makefile
> index 338e528ad436..750a4c12d5da 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -104,3 +104,4 @@ obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
>  obj-$(CONFIG_PERCPU_STATS) += percpu-stats.o
>  obj-$(CONFIG_HMM_MIRROR) += hmm.o
>  obj-$(CONFIG_MEMFD_CREATE) += memfd.o
> +obj-$(CONFIG_PTDUMP_CORE) += ptdump.o

Should be GENERIC_PTDUMP instead ?

> diff --git a/mm/ptdump.c b/mm/ptdump.c
> new file mode 100644
> index 000000000000..39befc9088b8
> --- /dev/null
> +++ b/mm/ptdump.c
> @@ -0,0 +1,161 @@
> +// SPDX-License-Identifier: GPL-2.0
> +
> +#include <linux/mm.h>
> +#include <linux/ptdump.h>
> +#include <linux/kasan.h>
> +
> +static int ptdump_pgd_entry(pgd_t *pgd, unsigned long addr,
> +			    unsigned long next, struct mm_walk *walk)
> +{
> +	struct ptdump_state *st = walk->private;
> +	pgd_t val = READ_ONCE(*pgd);
> +
> +	if (pgd_leaf(val))
> +		st->note_page(st, addr, 1, pgd_val(val));
> +
> +	return 0;
> +}
> +
> +static int ptdump_p4d_entry(p4d_t *p4d, unsigned long addr,
> +			    unsigned long next, struct mm_walk *walk)
> +{
> +	struct ptdump_state *st = walk->private;
> +	p4d_t val = READ_ONCE(*p4d);
> +
> +	if (p4d_leaf(val))
> +		st->note_page(st, addr, 2, p4d_val(val));
> +
> +	return 0;
> +}
> +
> +static int ptdump_pud_entry(pud_t *pud, unsigned long addr,
> +			    unsigned long next, struct mm_walk *walk)
> +{
> +	struct ptdump_state *st = walk->private;
> +	pud_t val = READ_ONCE(*pud);
> +
> +	if (pud_leaf(val))
> +		st->note_page(st, addr, 3, pud_val(val));
> +
> +	return 0;
> +}
> +
> +static int ptdump_pmd_entry(pmd_t *pmd, unsigned long addr,
> +			    unsigned long next, struct mm_walk *walk)
> +{
> +	struct ptdump_state *st = walk->private;
> +	pmd_t val = READ_ONCE(*pmd);
> +
> +	if (pmd_leaf(val))
> +		st->note_page(st, addr, 4, pmd_val(val));
> +
> +	return 0;
> +}
> +
> +static int ptdump_pte_entry(pte_t *pte, unsigned long addr,
> +			    unsigned long next, struct mm_walk *walk)
> +{
> +	struct ptdump_state *st = walk->private;
> +
> +	st->note_page(st, addr, 5, pte_val(READ_ONCE(*pte)));
> +
> +	return 0;
> +}
> +
> +#ifdef CONFIG_KASAN
> +/*
> + * This is an optimization for KASAN=y case. Since all kasan page tables
> + * eventually point to the kasan_early_shadow_page we could call note_page()
> + * right away without walking through lower level page tables. This saves
> + * us dozens of seconds (minutes for 5-level config) while checking for
> + * W+X mapping or reading kernel_page_tables debugfs file.
> + */
> +static inline bool kasan_page_table(struct ptdump_state *st, void *pt,
> +				    unsigned long addr)
> +{
> +	if (__pa(pt) == __pa(kasan_early_shadow_pmd) ||
> +#ifdef CONFIG_X86
> +	    (pgtable_l5_enabled() &&
> +			__pa(pt) == __pa(kasan_early_shadow_p4d)) ||
> +#endif
> +	    __pa(pt) == __pa(kasan_early_shadow_pud)) {
> +		st->note_page(st, addr, 5, pte_val(kasan_early_shadow_pte[0]));
> +		return true;
> +	}
> +	return false;
> +}
> +#else
> +static inline bool kasan_page_table(struct ptdump_state *st, void *pt,
> +				    unsigned long addr)
> +{
> +	return false;
> +}
> +#endif
> +
> +static int ptdump_test_p4d(unsigned long addr, unsigned long next,
> +			   p4d_t *p4d, struct mm_walk *walk)
> +{
> +	struct ptdump_state *st = walk->private;
> +
> +	if (kasan_page_table(st, p4d, addr))
> +		return 1;
> +	return 0;
> +}
> +
> +static int ptdump_test_pud(unsigned long addr, unsigned long next,
> +			   pud_t *pud, struct mm_walk *walk)
> +{
> +	struct ptdump_state *st = walk->private;
> +
> +	if (kasan_page_table(st, pud, addr))
> +		return 1;
> +	return 0;
> +}
> +
> +static int ptdump_test_pmd(unsigned long addr, unsigned long next,
> +			   pmd_t *pmd, struct mm_walk *walk)
> +{
> +	struct ptdump_state *st = walk->private;
> +
> +	if (kasan_page_table(st, pmd, addr))
> +		return 1;
> +	return 0;
> +}
> +
> +static int ptdump_hole(unsigned long addr, unsigned long next,
> +		       struct mm_walk *walk)
> +{
> +	struct ptdump_state *st = walk->private;
> +
> +	st->note_page(st, addr, -1, 0);
> +
> +	return 0;
> +}
> +
> +void ptdump_walk_pgd(struct ptdump_state *st, struct mm_struct *mm)
> +{
> +	struct mm_walk walk = {
> +		.mm		= mm,
> +		.pgd_entry	= ptdump_pgd_entry,
> +		.p4d_entry	= ptdump_p4d_entry,
> +		.pud_entry	= ptdump_pud_entry,
> +		.pmd_entry	= ptdump_pmd_entry,
> +		.pte_entry	= ptdump_pte_entry,
> +		.test_p4d	= ptdump_test_p4d,
> +		.test_pud	= ptdump_test_pud,
> +		.test_pmd	= ptdump_test_pmd,
> +		.pte_hole	= ptdump_hole,
> +		.private	= st
> +	};
> +	const struct ptdump_range *range = st->range;
> +
> +	down_read(&mm->mmap_sem);
> +	while (range->start != range->end) {
> +		walk_page_range(range->start, range->end, &walk);
> +		range++;
> +	}
> +	up_read(&mm->mmap_sem);

Does walk_page_range() really needed here when it is definitely walking a
kernel page table. Why not directly use walk_pgd_range() instead which can
save some cycles avoiding going over VMAs, checking for HugeTLB, taking the
mmap_sem lock etc. AFAICS only thing it will miss is the opportunity to call
walk->test_walk() via walk_page_test(). IIUC test_walk() callback is primarily
for testing a VMA for it's eligibility and for kernel page table now there are
test callbacks like p?d_test() for individual levels anyway.

