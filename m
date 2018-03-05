Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B1F526B0008
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 14:09:25 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id a5-v6so8517229plp.0
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 11:09:25 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id x4-v6si9645491plw.297.2018.03.05.11.09.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 11:09:24 -0800 (PST)
Subject: Re: [RFC, PATCH 16/22] x86/mm: Preserve KeyID on pte_modify() and
 pgprot_modify()
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-17-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <774c1251-46d9-534e-24c2-ca04f1e0a8bb@intel.com>
Date: Mon, 5 Mar 2018 11:09:23 -0800
MIME-Version: 1.0
In-Reply-To: <20180305162610.37510-17-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/05/2018 08:26 AM, Kirill A. Shutemov wrote:
> + * It includes full range of PFN bits regardless if they were claimed for KeyID
> + * or not: we want to preserve KeyID on pte_modify() and pgprot_modify().
>   */
> -#define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
> +#define PTE_PFN_MASK_MAX \
> +	(((signed long)PAGE_MASK) & ((1UL << __PHYSICAL_MASK_SHIFT) - 1))
> +#define _PAGE_CHG_MASK	(PTE_PFN_MASK_MAX | _PAGE_PCD | _PAGE_PWT |		\
>  			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
>  			 _PAGE_SOFT_DIRTY)

Is there a way to make this:

#define _PAGE_CHG_MASK	(PTE_PFN_MASK | PTE_KEY_MASK...? | _PAGE_PCD |

That would be a lot more understandable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
