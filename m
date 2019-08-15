Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A705C3A59C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 18:11:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF9502064A
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 18:11:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF9502064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75F6F6B0306; Thu, 15 Aug 2019 14:11:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E9B86B0307; Thu, 15 Aug 2019 14:11:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FF606B0308; Thu, 15 Aug 2019 14:11:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0078.hostedemail.com [216.40.44.78])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB856B0306
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 14:11:21 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id DB9A668A3
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 18:11:20 +0000 (UTC)
X-FDA: 75825454320.27.ghost11_62fa0d89b5633
X-HE-Tag: ghost11_62fa0d89b5633
X-Filterd-Recvd-Size: 4558
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 18:11:19 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id DCD94360;
	Thu, 15 Aug 2019 11:11:18 -0700 (PDT)
Received: from [10.1.196.105] (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id DD89B3F694;
	Thu, 15 Aug 2019 11:11:16 -0700 (PDT)
Subject: Re: [PATCH v1 2/8] arm64, mm: transitional tables
To: Pavel Tatashin <pasha.tatashin@soleen.com>
References: <20190801152439.11363-1-pasha.tatashin@soleen.com>
 <20190801152439.11363-3-pasha.tatashin@soleen.com>
From: James Morse <james.morse@arm.com>
Cc: jmorris@namei.org, sashal@kernel.org, ebiederm@xmission.com,
 kexec@lists.infradead.org, linux-kernel@vger.kernel.org, corbet@lwn.net,
 catalin.marinas@arm.com, will@kernel.org,
 linux-arm-kernel@lists.infradead.org, marc.zyngier@arm.com,
 vladimir.murzin@arm.com, matthias.bgg@gmail.com, bhsharma@redhat.com,
 linux-mm@kvack.org
Message-ID: <e00455af-a9f6-82e1-4c0d-78fae01ae00a@arm.com>
Date: Thu, 15 Aug 2019 19:11:15 +0100
User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190801152439.11363-3-pasha.tatashin@soleen.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Pavel,

On 01/08/2019 16:24, Pavel Tatashin wrote:
> There are cases where normal kernel pages tables, i.e. idmap_pg_dir
> and swapper_pg_dir are not sufficient because they may be overwritten.
> 
> This happens when we transition from one world to another: for example
> during kexec kernel relocation transition, and also during hibernate
> kernel restore transition.
> 
> In these cases, if MMU is needed, the page table memory must be allocated
> from a safe place. Transitional tables is intended to allow just that.

> diff --git a/arch/arm64/include/asm/pgtable-hwdef.h b/arch/arm64/include/asm/pgtable-hwdef.h
> index db92950bb1a0..dcb4f13c7888 100644
> --- a/arch/arm64/include/asm/pgtable-hwdef.h
> +++ b/arch/arm64/include/asm/pgtable-hwdef.h
> @@ -110,6 +110,7 @@
>  #define PUD_TABLE_BIT		(_AT(pudval_t, 1) << 1)
>  #define PUD_TYPE_MASK		(_AT(pudval_t, 3) << 0)
>  #define PUD_TYPE_SECT		(_AT(pudval_t, 1) << 0)
> +#define PUD_SECT_RDONLY		(_AT(pudval_t, 1) << 7)		/* AP[2] */

This shouldn't be needed. As far as I'm aware, we only get read-only pages in the linear
map from debug-pagealloc, and the module aliases. Both of which require the linear map to
be made of page-size mappings.

Where are you seeing these?


> diff --git a/arch/arm64/include/asm/trans_table.h b/arch/arm64/include/asm/trans_table.h
> new file mode 100644
> index 000000000000..c7aef70587a1
> --- /dev/null
> +++ b/arch/arm64/include/asm/trans_table.h
> @@ -0,0 +1,68 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +
> +/*
> + * Copyright (c) 2019, Microsoft Corporation.
> + * Pavel Tatashin <patatash@linux.microsoft.com>
> + */
> +
> +#ifndef _ASM_TRANS_TABLE_H
> +#define _ASM_TRANS_TABLE_H
> +
> +#include <linux/bits.h>
> +#include <asm/pgtable-types.h>
> +
> +/*
> + * trans_alloc_page
> + *	- Allocator that should return exactly one uninitilaized page, if this
> + *	 allocator fails, trans_table returns -ENOMEM error.
> + *
> + * trans_alloc_arg
> + *	- Passed to trans_alloc_page as an argument
> + *
> + * trans_flags
> + *	- bitmap with flags that control how page table is filled.
> + *	  TRANS_MKWRITE: during page table copy make PTE, PME, and PUD page
> + *			 writeable by removing RDONLY flag from PTE.
> + *	  TRANS_MKVALID: during page table copy, if PTE present, but not valid,
> + *			 make it valid.
> + *	  TRANS_CHECKPFN: During page table copy, for every PTE entry check that
> + *			  PFN that this PTE points to is valid. Otherwise return
> + *			  -ENXIO

Adding top-level global knobs to manipulate the copied linear map is going to lead to
bugs. The existing code will only change the PTE in specific circumstances, that it tests
for, that only happen at the PTE level.


> + *	  TRANS_FORCEMAP: During page map, if translation exists, force
> + *			  overwrite it. Otherwise -ENXIO may be returned by
> + *			  trans_table_map_* functions if conflict is detected.

This one, sounds like a very bad idea.


Thanks,

James

