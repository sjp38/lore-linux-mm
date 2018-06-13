Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 32DE76B0271
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 14:43:10 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id a5-v6so1887324plp.8
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 11:43:10 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id c14-v6si3328979pls.32.2018.06.13.11.43.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 11:43:09 -0700 (PDT)
Subject: Re: [PATCHv3 16/17] x86/mm: Handle encrypted memory in page_to_virt()
 and __pa()
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-17-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <f8b9da42-1f7b-529c-bfdd-e82f669f6fe8@intel.com>
Date: Wed, 13 Jun 2018 11:43:08 -0700
MIME-Version: 1.0
In-Reply-To: <20180612143915.68065-17-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
> index efc0d4bb3b35..d6edcabacfc7 100644
> --- a/arch/x86/include/asm/mktme.h
> +++ b/arch/x86/include/asm/mktme.h
> @@ -43,6 +43,9 @@ void mktme_disable(void);
>  void setup_direct_mapping_size(void);
>  int sync_direct_mapping(void);
>  
> +#define page_to_virt(x) \
> +	(__va(PFN_PHYS(page_to_pfn(x))) + page_keyid(x) * direct_mapping_size)

This looks like a super important memory management function being
defined in some obscure Intel-specific feature header.  How does that work?

>  #else
>  #define mktme_keyid_mask	((phys_addr_t)0)
>  #define mktme_nr_keyids		0
> diff --git a/arch/x86/include/asm/page_64.h b/arch/x86/include/asm/page_64.h
> index 53c32af895ab..ffad496aadad 100644
> --- a/arch/x86/include/asm/page_64.h
> +++ b/arch/x86/include/asm/page_64.h
> @@ -23,7 +23,7 @@ static inline unsigned long __phys_addr_nodebug(unsigned long x)
>  	/* use the carry flag to determine if x was < __START_KERNEL_map */
>  	x = y + ((x > y) ? phys_base : (__START_KERNEL_map - PAGE_OFFSET));
>  
> -	return x;
> +	return x % direct_mapping_size;
>  }

What are the performance implications of this patch?
