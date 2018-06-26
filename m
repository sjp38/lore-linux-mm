Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B71916B0006
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 12:38:27 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y26-v6so9011266pfn.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 09:38:27 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id e16-v6si2060986plj.76.2018.06.26.09.38.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 09:38:24 -0700 (PDT)
Subject: Re: [PATCHv4 17/18] x86/mm: Handle encrypted memory in page_to_virt()
 and __pa()
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
 <20180626142245.82850-18-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <1609f2b4-4638-8b9d-4dc7-fcb3303739cd@intel.com>
Date: Tue, 26 Jun 2018 09:38:23 -0700
MIME-Version: 1.0
In-Reply-To: <20180626142245.82850-18-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
> index ba83fba4f9b3..dbfbd955da98 100644
> --- a/arch/x86/include/asm/mktme.h
> +++ b/arch/x86/include/asm/mktme.h
> @@ -29,6 +29,9 @@ void arch_free_page(struct page *page, int order);
>  
>  int sync_direct_mapping(void);
>  
> +#define page_to_virt(x) \
> +	(__va(PFN_PHYS(page_to_pfn(x))) + page_keyid(x) * direct_mapping_size)

Please put this in a generic header so that this hunk represents the
*default* x86 implementation that is used universally on x86.  Then,
please do

#ifndef CONFIG_MKTME_WHATEVER
#define page_keyid(x) (0)
#endif

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

There are almost *surely* performance implications from this that affect
anyone with this compile option turned on.  There's now a 64-bit integer
division operation which is used in places like kfree().

That's a show-stopper for me until we've done some pretty comprehensive
performance analysis of this, which means much more than one kernel
compile test on one system.
