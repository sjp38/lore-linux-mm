Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D0C0C7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 13:56:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1371820578
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 13:56:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1371820578
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CE078E0003; Mon, 29 Jul 2019 09:56:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9578C8E0002; Mon, 29 Jul 2019 09:56:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D16B8E0003; Mon, 29 Jul 2019 09:56:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 258188E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 09:56:48 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f19so38317330edv.16
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 06:56:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=kmGvG0H8k3x54BowLkI+MomFoXzpLMLkVcmW8uyRQ5c=;
        b=R1a5SRlkB929DW3p1jg6e1Jq9HYbOPhLhx20Nr29FJZrgKmyKAj63gdmBDINDmiNwL
         fcXbx532vi/a8cNRBL/5JCGPQDF2Lnkdztet8AvssIk1AgwFCof2M4ZxXz1hgDQUkW15
         TqWhojYyclhiJyjnuum6oNDiE9NEa/xeVoL/tbIj+I9Hicfm7KNUe8lHKHXLRI9yExZ5
         /MUI1SNKT62IZylpt2obK7M3O1z8WhIPY4fRtiN8OwuarkhhlPN1Rx9Qg1ZZWRoSJd73
         7czC9ki/WAk5x5Lbl4lDt/MTvb2uNQfFlMHMgDznnse7legpRzXFVHyXV+QyjadQWhpB
         WoMg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUnxx3ippcG9iXgk0hglPnOVYwSqwWE0uamZvF6umfupIedn9Co
	FHp0F4dB7i27SQqclvEe709/O1cehXf9ad+O1OnAMI14O3WHyFlR+xNaHQpABS4IpEPeAuJrHlx
	fIxgn5BVILh3NzGw7fFl1JKEEZrcDv8Il5GEwf6KD0MzGgKKmU5LS9zktI04ha3RcSg==
X-Received: by 2002:aa7:cdc6:: with SMTP id h6mr95590215edw.5.1564408607680;
        Mon, 29 Jul 2019 06:56:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXZCTLyKTRsV4zNCbR8T0XHPd+ZeqPdTu22akEckIkaxr3giZHjfpioo1QRn1SzRQk0az7
X-Received: by 2002:aa7:cdc6:: with SMTP id h6mr95590139edw.5.1564408606682;
        Mon, 29 Jul 2019 06:56:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564408606; cv=none;
        d=google.com; s=arc-20160816;
        b=WU5QoyDX/zboZyEByAQ4KanKSdeV9PWDvRMedvkElemYi3u+X4AIS2TUvUKB7wWehB
         2r+YUYFHYjcYI0NGZjiVbwgWXwPpKkAWdjYt+MytSzISFuoRpHWd1ke5wlDCbhZsB95N
         GoBxMQsdLmLR72XrAyfBEoPNwRKsFbnZTbRnH5mq4V3S1hdCspn57U8IeCl+HpLA0e/Q
         +jp6UCpMKh/ML5fVqFRgTiCMjfZimhxkMHHr5Dect3acEOHxR0eL7NP2nmSOjegTDZrx
         JMMTCJ/TJXoF4NCMAorbOe5AXQuZNKmQgegniPqRMYvWJqiC5suKutyxpzCsNJMcQfxG
         nBow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=kmGvG0H8k3x54BowLkI+MomFoXzpLMLkVcmW8uyRQ5c=;
        b=0JI1DAg7WPV1CqDQ93sDoqJfkxiLadJgLrNeZ/mTmshY9qY939HLrCgV5rGDJHwZvb
         mLPRRivcWErDoyYBzE6WTrgEKbz9PIHFwld23qbXsLSfgSr999zSEDhucE02hT1bXr2Q
         wOXhGagxgj2DvfcKDiR+LLaIJlsuCXYFyCUL9snmensFJqUdKOvoQSFQnk5mm0p1fJsj
         qcI3bILltXb5t56TDnqnCKQQmSlpcWQabRoAC4qX/FSgmlxIlNfJqnMaamN/8btJ2m8R
         w6gqqmNGMTZIiCiA8pWg7XVWNeyTPw22P3vg1j9EmqgQ2Y3IHaNEJmxaMmuDwnmVlqan
         TlsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id 11si14771052ejy.102.2019.07.29.06.56.46
        for <linux-mm@kvack.org>;
        Mon, 29 Jul 2019 06:56:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2BD2028;
	Mon, 29 Jul 2019 06:56:45 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 912203F71F;
	Mon, 29 Jul 2019 06:56:42 -0700 (PDT)
Subject: Re: [PATCH v9 19/21] mm: Add generic ptdump
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 Will Deacon <will@kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190722154210.42799-1-steven.price@arm.com>
 <20190722154210.42799-20-steven.price@arm.com>
 <f8444b1f-c886-9bfd-4873-3ed9068d3c44@arm.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <75e314f2-b4e6-0a5f-20f0-ad5f56ce77f6@arm.com>
Date: Mon, 29 Jul 2019 14:56:41 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <f8444b1f-c886-9bfd-4873-3ed9068d3c44@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 29/07/2019 03:59, Anshuman Khandual wrote:
> 
> On 07/22/2019 09:12 PM, Steven Price wrote:
>> Add a generic version of page table dumping that architectures can
>> opt-in to
>>
>> Signed-off-by: Steven Price <steven.price@arm.com>
>> ---
>>  include/linux/ptdump.h |  19 +++++
>>  mm/Kconfig.debug       |  21 ++++++
>>  mm/Makefile            |   1 +
>>  mm/ptdump.c            | 161 +++++++++++++++++++++++++++++++++++++++++
>>  4 files changed, 202 insertions(+)
>>  create mode 100644 include/linux/ptdump.h
>>  create mode 100644 mm/ptdump.c
>>
>> diff --git a/include/linux/ptdump.h b/include/linux/ptdump.h
>> new file mode 100644
>> index 000000000000..eb8e78154be3
>> --- /dev/null
>> +++ b/include/linux/ptdump.h
>> @@ -0,0 +1,19 @@
>> +/* SPDX-License-Identifier: GPL-2.0 */
>> +
>> +#ifndef _LINUX_PTDUMP_H
>> +#define _LINUX_PTDUMP_H
>> +
>> +struct ptdump_range {
>> +	unsigned long start;
>> +	unsigned long end;
>> +};
>> +
>> +struct ptdump_state {
>> +	void (*note_page)(struct ptdump_state *st, unsigned long addr,
>> +			  int level, unsigned long val);
>> +	const struct ptdump_range *range;
>> +};
>> +
>> +void ptdump_walk_pgd(struct ptdump_state *st, struct mm_struct *mm);
>> +
>> +#endif /* _LINUX_PTDUMP_H */
>> diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
>> index 82b6a20898bd..7ad939b7140f 100644
>> --- a/mm/Kconfig.debug
>> +++ b/mm/Kconfig.debug
>> @@ -115,3 +115,24 @@ config DEBUG_RODATA_TEST
>>      depends on STRICT_KERNEL_RWX
>>      ---help---
>>        This option enables a testcase for the setting rodata read-only.
>> +
>> +config GENERIC_PTDUMP
>> +	bool
>> +
>> +config PTDUMP_CORE
>> +	bool
>> +
>> +config PTDUMP_DEBUGFS
>> +	bool "Export kernel pagetable layout to userspace via debugfs"
>> +	depends on DEBUG_KERNEL
>> +	depends on DEBUG_FS
>> +	depends on GENERIC_PTDUMP
>> +	select PTDUMP_CORE
> 
> So PTDUMP_DEBUGFS depends on GENERIC_PTDUMP but selects PTDUMP_CORE. So any arch
> subscribing this new generic PTDUMP by selecting GENERIC_PTDUMP needs to provide
> some functions for PTDUMP_DEBUGFS which does not really have any code in generic
> MM. Also ptdump_walk_pgd() is wrapped in PTDUMP_CORE not GENERIC_PTDUMP. Then what
> does PTDUMP_GENERIC really indicate ? Bit confusing here.

The intention is:

* PTDUMP_DEBUGFS: Controls if the debugfs file is available. This
enables arch specific code which creates the debugfs file (as the files
available vary between architectures).

* GENERIC_PTDUMP: Architecture is opting in to the generic ptdump
infrastructure. The arch code is expected to provide the debugfs code
for PTDUMP_DBEUGFS.

* PTDUMP_CORE: The core page table walker is enabled. This code is used
by both PTDUMP_DEBUGFS as well as the DEBUG_WX ("Warn on W+X mappings at
boot"). x86 also has EFI_PGT_DUMP which uses the core.

> The new ptdump_walk_pgd() symbol needs to be wrapped in a config symbol for sure
> which should be selected in all platforms wishing to use it. GENERIC_PTDUMP can
> be that config.

The intention is that GENERIC_PTDUMP is signalling that the architecture
supports PTDUMP_DEBUGFS. PTDUMP_CORE is the configuration which chooses
whether ptdump_walk_pgd() is built - selected by the options that
require it.

> PTDUMP_DEBUGFS will require a full implementation (i.e PTDUMP_CORE) irrespective
> of whether the platform subscribes GENERIC_PTDUMP or not. It should be something
> like this.
> 
> config PTDUMP_DEBUGFS
> 	bool "Export kernel pagetable layout to userspace via debugfs"
> 	depends on DEBUG_KERNEL
> 	depends on DEBUG_FS
> 	select PTDUMP_CORE
> 
> PTDUMP_DEBUGFS need not depend on GENERIC_PTDUMP. All it requires is a PTDUMP_CORE
> implementation which can optionally use ptdump_walk_pgd() through GENERIC_PTDUMP.
> s/GENERIC_PTDUMP/PTDUMP_GENERIC to match and group with other configs.

The intention here is to hide PTDUMP_DEBUGFS on architectures that
haven't migrated to it. Because the generic code isn't responsible for
creating the debugfs entries if we don't hide it then it will compile
but nothing will appear in debugfs.

> DEBUG_WX can also be moved to generic MM like PTDUMP_DEBUGFS ?

Well the DEBUG_WX requires some arch specific code (separate from
PTDUMP_DEBUGFS), so while the config option could be moved you would
then require a "ARCH_HAS_DEBUG_WX" to hide it on the architectures that
don't support it. I'm not sure that's worth doing when only 3
architectures support it, and I would argue it's separate to this patch
series so can be done at a different time.

>> +	help
>> +	  Say Y here if you want to show the kernel pagetable layout in a
>> +	  debugfs file. This information is only useful for kernel developers
>> +	  who are working in architecture specific areas of the kernel.
>> +	  It is probably not a good idea to enable this feature in a production
>> +	  kernel.
>> +
>> +	  If in doubt, say N.
>> diff --git a/mm/Makefile b/mm/Makefile
>> index 338e528ad436..750a4c12d5da 100644
>> --- a/mm/Makefile
>> +++ b/mm/Makefile
>> @@ -104,3 +104,4 @@ obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
>>  obj-$(CONFIG_PERCPU_STATS) += percpu-stats.o
>>  obj-$(CONFIG_HMM_MIRROR) += hmm.o
>>  obj-$(CONFIG_MEMFD_CREATE) += memfd.o
>> +obj-$(CONFIG_PTDUMP_CORE) += ptdump.o
> 
> Should be GENERIC_PTDUMP instead ?

No - GENERIC_PTDUMP is just signalling the architecture support it, we
don't want to compile in the code unless it is used.

>> diff --git a/mm/ptdump.c b/mm/ptdump.c
>> new file mode 100644
>> index 000000000000..39befc9088b8
>> --- /dev/null
>> +++ b/mm/ptdump.c
>> @@ -0,0 +1,161 @@
>> +// SPDX-License-Identifier: GPL-2.0
>> +
>> +#include <linux/mm.h>
>> +#include <linux/ptdump.h>
>> +#include <linux/kasan.h>
>> +
>> +static int ptdump_pgd_entry(pgd_t *pgd, unsigned long addr,
>> +			    unsigned long next, struct mm_walk *walk)
>> +{
>> +	struct ptdump_state *st = walk->private;
>> +	pgd_t val = READ_ONCE(*pgd);
>> +
>> +	if (pgd_leaf(val))
>> +		st->note_page(st, addr, 1, pgd_val(val));
>> +
>> +	return 0;
>> +}
>> +
>> +static int ptdump_p4d_entry(p4d_t *p4d, unsigned long addr,
>> +			    unsigned long next, struct mm_walk *walk)
>> +{
>> +	struct ptdump_state *st = walk->private;
>> +	p4d_t val = READ_ONCE(*p4d);
>> +
>> +	if (p4d_leaf(val))
>> +		st->note_page(st, addr, 2, p4d_val(val));
>> +
>> +	return 0;
>> +}
>> +
>> +static int ptdump_pud_entry(pud_t *pud, unsigned long addr,
>> +			    unsigned long next, struct mm_walk *walk)
>> +{
>> +	struct ptdump_state *st = walk->private;
>> +	pud_t val = READ_ONCE(*pud);
>> +
>> +	if (pud_leaf(val))
>> +		st->note_page(st, addr, 3, pud_val(val));
>> +
>> +	return 0;
>> +}
>> +
>> +static int ptdump_pmd_entry(pmd_t *pmd, unsigned long addr,
>> +			    unsigned long next, struct mm_walk *walk)
>> +{
>> +	struct ptdump_state *st = walk->private;
>> +	pmd_t val = READ_ONCE(*pmd);
>> +
>> +	if (pmd_leaf(val))
>> +		st->note_page(st, addr, 4, pmd_val(val));
>> +
>> +	return 0;
>> +}
>> +
>> +static int ptdump_pte_entry(pte_t *pte, unsigned long addr,
>> +			    unsigned long next, struct mm_walk *walk)
>> +{
>> +	struct ptdump_state *st = walk->private;
>> +
>> +	st->note_page(st, addr, 5, pte_val(READ_ONCE(*pte)));
>> +
>> +	return 0;
>> +}
>> +
>> +#ifdef CONFIG_KASAN
>> +/*
>> + * This is an optimization for KASAN=y case. Since all kasan page tables
>> + * eventually point to the kasan_early_shadow_page we could call note_page()
>> + * right away without walking through lower level page tables. This saves
>> + * us dozens of seconds (minutes for 5-level config) while checking for
>> + * W+X mapping or reading kernel_page_tables debugfs file.
>> + */
>> +static inline bool kasan_page_table(struct ptdump_state *st, void *pt,
>> +				    unsigned long addr)
>> +{
>> +	if (__pa(pt) == __pa(kasan_early_shadow_pmd) ||
>> +#ifdef CONFIG_X86
>> +	    (pgtable_l5_enabled() &&
>> +			__pa(pt) == __pa(kasan_early_shadow_p4d)) ||
>> +#endif
>> +	    __pa(pt) == __pa(kasan_early_shadow_pud)) {
>> +		st->note_page(st, addr, 5, pte_val(kasan_early_shadow_pte[0]));
>> +		return true;
>> +	}
>> +	return false;
>> +}
>> +#else
>> +static inline bool kasan_page_table(struct ptdump_state *st, void *pt,
>> +				    unsigned long addr)
>> +{
>> +	return false;
>> +}
>> +#endif
>> +
>> +static int ptdump_test_p4d(unsigned long addr, unsigned long next,
>> +			   p4d_t *p4d, struct mm_walk *walk)
>> +{
>> +	struct ptdump_state *st = walk->private;
>> +
>> +	if (kasan_page_table(st, p4d, addr))
>> +		return 1;
>> +	return 0;
>> +}
>> +
>> +static int ptdump_test_pud(unsigned long addr, unsigned long next,
>> +			   pud_t *pud, struct mm_walk *walk)
>> +{
>> +	struct ptdump_state *st = walk->private;
>> +
>> +	if (kasan_page_table(st, pud, addr))
>> +		return 1;
>> +	return 0;
>> +}
>> +
>> +static int ptdump_test_pmd(unsigned long addr, unsigned long next,
>> +			   pmd_t *pmd, struct mm_walk *walk)
>> +{
>> +	struct ptdump_state *st = walk->private;
>> +
>> +	if (kasan_page_table(st, pmd, addr))
>> +		return 1;
>> +	return 0;
>> +}
>> +
>> +static int ptdump_hole(unsigned long addr, unsigned long next,
>> +		       struct mm_walk *walk)
>> +{
>> +	struct ptdump_state *st = walk->private;
>> +
>> +	st->note_page(st, addr, -1, 0);
>> +
>> +	return 0;
>> +}
>> +
>> +void ptdump_walk_pgd(struct ptdump_state *st, struct mm_struct *mm)
>> +{
>> +	struct mm_walk walk = {
>> +		.mm		= mm,
>> +		.pgd_entry	= ptdump_pgd_entry,
>> +		.p4d_entry	= ptdump_p4d_entry,
>> +		.pud_entry	= ptdump_pud_entry,
>> +		.pmd_entry	= ptdump_pmd_entry,
>> +		.pte_entry	= ptdump_pte_entry,
>> +		.test_p4d	= ptdump_test_p4d,
>> +		.test_pud	= ptdump_test_pud,
>> +		.test_pmd	= ptdump_test_pmd,
>> +		.pte_hole	= ptdump_hole,
>> +		.private	= st
>> +	};
>> +	const struct ptdump_range *range = st->range;
>> +
>> +	down_read(&mm->mmap_sem);
>> +	while (range->start != range->end) {
>> +		walk_page_range(range->start, range->end, &walk);
>> +		range++;
>> +	}
>> +	up_read(&mm->mmap_sem);
> 
> Does walk_page_range() really needed here when it is definitely walking a
> kernel page table. Why not directly use walk_pgd_range() instead which can
> save some cycles avoiding going over VMAs, checking for HugeTLB, taking the
> mmap_sem lock etc. AFAICS only thing it will miss is the opportunity to call
> walk->test_walk() via walk_page_test(). IIUC test_walk() callback is primarily
> for testing a VMA for it's eligibility and for kernel page table now there are
> test callbacks like p?d_test() for individual levels anyway.

Well it's a debug interface so saving a few cycles is largely
irrelevant. I'm reluctant to export walk_pgd_range() in case it gets
used to walk real VMAs. Having just one interface is cleanest. But I
agree for kernel mappings all the extra work in walk_page_range() isn't
needed.

Steve

