Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id D810B6B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 13:24:17 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ao6so262488317pac.2
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 10:24:17 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id tm9si25186378pab.108.2016.06.14.10.24.17
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 10:24:17 -0700 (PDT)
Subject: Re: [PATCH v2] Linux VM workaround for Knights Landing A/D leak
References: <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com>
 <1465923672-14232-1-git-send-email-lukasz.anaczkowski@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <57603DC0.9070607@linux.intel.com>
Date: Tue, 14 Jun 2016 10:24:16 -0700
MIME-Version: 1.0
In-Reply-To: <1465923672-14232-1-git-send-email-lukasz.anaczkowski@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org, hpa@zytor.com
Cc: harish.srinivasappa@intel.com, lukasz.odzioba@intel.com, grzegorz.andrejczuk@intel.com, lukasz.daniluk@intel.com

On 06/14/2016 10:01 AM, Lukasz Anaczkowski wrote:
> v2 (Lukasz Anaczkowski):
>     () fixed compilation breakage
...

By unconditionally defining the workaround code, even on kernels where
there is no chance of ever hitting this bug.  I think that's a pretty
poor way to do it.

Can we please stick this in one of the intel.c files, so it's only
present on CPU_SUP_INTEL builds?

Which reminds me...

> --- a/arch/x86/include/asm/pgtable_64.h
> +++ b/arch/x86/include/asm/pgtable_64.h
> @@ -178,6 +178,12 @@ extern void cleanup_highmap(void);
>  extern void init_extra_mapping_uc(unsigned long phys, unsigned long size);
>  extern void init_extra_mapping_wb(unsigned long phys, unsigned long size);
>  
> +#define ARCH_HAS_NEEDS_SWAP_PTL 1
> +static inline bool arch_needs_swap_ptl(void)
> +{
> +       return boot_cpu_has_bug(X86_BUG_PTE_LEAK);
> +}

Does this *REALLY* only affect 64-bit kernels?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
