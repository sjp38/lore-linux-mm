Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 291C36B0100
	for <linux-mm@kvack.org>; Wed, 20 May 2015 07:55:15 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so147144248wic.0
        for <linux-mm@kvack.org>; Wed, 20 May 2015 04:55:14 -0700 (PDT)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com. [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id dc7si28876487wjc.204.2015.05.20.04.55.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 May 2015 04:55:13 -0700 (PDT)
Received: by wibt6 with SMTP id t6so57171993wib.0
        for <linux-mm@kvack.org>; Wed, 20 May 2015 04:55:12 -0700 (PDT)
Date: Wed, 20 May 2015 13:55:09 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v5 6/6] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
Message-ID: <20150520115509.GA3489@gmail.com>
References: <20150518133348.GA23618@pd.tnic>
 <1431969759.19889.5.camel@misato.fc.hp.com>
 <20150518190150.GC23618@pd.tnic>
 <1431977519.20569.15.camel@misato.fc.hp.com>
 <20150518200114.GE23618@pd.tnic>
 <1431980468.21019.11.camel@misato.fc.hp.com>
 <20150518205123.GI23618@pd.tnic>
 <1431985994.21526.12.camel@misato.fc.hp.com>
 <20150519114437.GF4641@pd.tnic>
 <20150519132307.GG4641@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150519132307.GG4641@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Toshi Kani <toshi.kani@hp.com>, akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, mcgrof@suse.com


* Borislav Petkov <bp@alien8.de> wrote:

> --- a/arch/x86/mm/pgtable.c
> +++ b/arch/x86/mm/pgtable.c
> @@ -566,19 +566,28 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
>  /**
>   * pud_set_huge - setup kernel PUD mapping
>   *
> - * MTRR can override PAT memory types with 4KiB granularity.  Therefore,
> - * this function does not set up a huge page when the range is covered
> - * by a non-WB type of MTRR.  MTRR_TYPE_INVALID indicates that MTRR are
> - * disabled.
> + * MTRRs can override PAT memory types with 4KiB granularity. Therefore, this
> + * function sets up a huge page only if any of the following conditions are met:
> + *
> + * - MTRRs are disabled, or
> + *
> + * - MTRRs are enabled and the range is completely covered by a single MTRR, or
> + *
> + * - MTRRs are enabled and the range is not completely covered by a single MTRR
> + *   but the memory type of the range is WB, even if covered by multiple MTRRs.
> + *
> + * Callers should try to decrease page size (1GB -> 2MB -> 4K) if the bigger
> + * page mapping attempt fails.

This comment should explain why it's ok in the WB case.

Also, the phrase 'the memory type of the range' is ambiguous: it might 
mean the partial MTRR's, or the memory type specified via PAT by the 
huge-pmd entry.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
