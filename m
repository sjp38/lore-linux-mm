Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id B76386B0272
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 19:40:33 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id s3-v6so3365188plp.21
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 16:40:33 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id v38-v6si4389537pgn.431.2018.07.18.16.40.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 16:40:32 -0700 (PDT)
Subject: Re: [PATCHv5 11/19] x86/mm: Implement vma_keyid()
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-12-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <a204a032-5e2b-63f6-31d3-c17014f94c8b@intel.com>
Date: Wed, 18 Jul 2018 16:40:14 -0700
MIME-Version: 1.0
In-Reply-To: <20180717112029.42378-12-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> --- a/arch/x86/mm/mktme.c
> +++ b/arch/x86/mm/mktme.c
> @@ -1,3 +1,4 @@
> +#include <linux/mm.h>
>  #include <asm/mktme.h>
>  
>  phys_addr_t mktme_keyid_mask;
> @@ -37,3 +38,14 @@ struct page_ext_operations page_mktme_ops = {
>  	.need = need_page_mktme,
>  	.init = init_page_mktme,
>  };
> +
> +int vma_keyid(struct vm_area_struct *vma)
> +{
> +	pgprotval_t prot;
> +
> +	if (!mktme_enabled())
> +		return 0;
> +
> +	prot = pgprot_val(vma->vm_page_prot);
> +	return (prot & mktme_keyid_mask) >> mktme_keyid_shift;
> +}

I'm a bit surprised this isn't inlined.  Not that function calls are
expensive, but we *could* entirely avoid them using the normal pattern of:

// In the header:
static inline vma_keyid(...)
{
	if (!mktme_enabled())
		return 0;

	return __vma_keyid(...); // <- the .c file version
}
