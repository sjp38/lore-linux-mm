Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 213B5C43140
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:18:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E5D9120650
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:18:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5D9120650
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95D0F6B0003; Fri,  6 Sep 2019 11:18:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90D376B0006; Fri,  6 Sep 2019 11:18:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8229D6B000D; Fri,  6 Sep 2019 11:18:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0108.hostedemail.com [216.40.44.108])
	by kanga.kvack.org (Postfix) with ESMTP id 5E00C6B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 11:18:43 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 111B1824CA3E
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:18:43 +0000 (UTC)
X-FDA: 75904852926.29.son75_11ddc858ddb16
X-HE-Tag: son75_11ddc858ddb16
X-Filterd-Recvd-Size: 4110
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:18:42 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A95341576;
	Fri,  6 Sep 2019 08:18:41 -0700 (PDT)
Received: from [10.1.196.105] (unknown [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 8B82E3F59C;
	Fri,  6 Sep 2019 08:18:38 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: Re: [PATCH v3 07/17] arm64, hibernate: move page handling function to
 new trans_pgd.c
To: Pavel Tatashin <pasha.tatashin@soleen.com>
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
 <20190821183204.23576-8-pasha.tatashin@soleen.com>
Cc: jmorris@namei.org, sashal@kernel.org, ebiederm@xmission.com,
 kexec@lists.infradead.org, linux-kernel@vger.kernel.org, corbet@lwn.net,
 catalin.marinas@arm.com, will@kernel.org,
 linux-arm-kernel@lists.infradead.org, marc.zyngier@arm.com,
 vladimir.murzin@arm.com, matthias.bgg@gmail.com, bhsharma@redhat.com,
 linux-mm@kvack.org, mark.rutland@arm.com
Message-ID: <f1db863a-de57-2d1a-6bec-6020b2130964@arm.com>
Date: Fri, 6 Sep 2019 16:18:37 +0100
User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190821183204.23576-8-pasha.tatashin@soleen.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Pavel,

On 21/08/2019 19:31, Pavel Tatashin wrote:
> Now, that we abstracted the required functions move them to a new home.
> Later, we will generalize these function in order to be useful outside
> of hibernation.

> diff --git a/arch/arm64/mm/trans_pgd.c b/arch/arm64/mm/trans_pgd.c
> new file mode 100644
> index 000000000000..00b62d8640c2
> --- /dev/null
> +++ b/arch/arm64/mm/trans_pgd.c
> @@ -0,0 +1,211 @@
> +// SPDX-License-Identifier: GPL-2.0
> +
> +/*
> + * Copyright (c) 2019, Microsoft Corporation.
> + * Pavel Tatashin <patatash@linux.microsoft.com>

Hmmm, while line-count isn't a useful metric: this file contains 41% of the code that was
in hibernate.c, but has stripped the substantial copyright-pedigree that the hibernate
code had built up over the years.
(counting lines identified by 'cloc' as code, not comments or blank)

If you are copying or moving a non trivial quantity of code, you need to preserve the
copyright. Something like 'Derived from the arm64 hibernate support which has:'....


> + */
> +
> +/*
> + * Transitional tables are used during system transferring from one world to
> + * another: such as during hibernate restore, and kexec reboots. During these
> + * phases one cannot rely on page table not being overwritten.

I think you need to mention that hibernate and kexec are rewriting memory, and may
overwrite the live page tables, therefore ...


> + *
> + */
> +
> +#include <asm/trans_pgd.h>
> +#include <asm/pgalloc.h>
> +#include <asm/pgtable.h>
> +#include <linux/suspend.h>

#include <linux/bug.h>
#include <linux/mm.h>
#include <linux/mmzone.h>


> +static void _copy_pte(pte_t *dst_ptep, pte_t *src_ptep, unsigned long addr)
> +{
> +	pte_t pte = READ_ONCE(*src_ptep);
> +

> +	if (pte_valid(pte)) {

> +		/*
> +		 * Resume will overwrite areas that may be marked
> +		 * read only (code, rodata). Clear the RDONLY bit from
> +		 * the temporary mappings we use during restore.
> +		 */
> +		set_pte(dst_ptep, pte_mkwrite(pte));

> +	} else if (debug_pagealloc_enabled() && !pte_none(pte)) {

> +		/*
> +		 * debug_pagealloc will removed the PTE_VALID bit if
> +		 * the page isn't in use by the resume kernel. It may have
> +		 * been in use by the original kernel, in which case we need
> +		 * to put it back in our copy to do the restore.
> +		 *
> +		 * Before marking this entry valid, check the pfn should
> +		 * be mapped.
> +		 */

> +		BUG_ON(!pfn_valid(pte_pfn(pte)));


Thanks,

James

