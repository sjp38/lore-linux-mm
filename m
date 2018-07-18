Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C399B6B0006
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 19:12:01 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u16-v6so2994876pfm.15
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 16:12:01 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id t137-v6si4565706pgb.528.2018.07.18.16.12.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 16:12:00 -0700 (PDT)
Subject: Re: [PATCHv5 06/19] mm/khugepaged: Handle encrypted pages
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-7-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <ad4c704f-fdda-7e75-60ec-3fbc8a4bb0ba@intel.com>
Date: Wed, 18 Jul 2018 16:11:57 -0700
MIME-Version: 1.0
In-Reply-To: <20180717112029.42378-7-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
> khugepaged allocates page in advance, before we found a VMA for
> collapse. We don't yet know which KeyID to use for the allocation.

That's not really true.  We have the VMA and the address in the caller
(khugepaged_scan_pmd()), but we drop the lock and have to revalidate the
VMA.


> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 5ae34097aed1..d116f4ebb622 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1056,6 +1056,16 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	 */
>  	anon_vma_unlock_write(vma->anon_vma);
>  
> +	/*
> +	 * At this point new_page is allocated as non-encrypted.
> +	 * If VMA's KeyID is non-zero, we need to prepare it to be encrypted
> +	 * before coping data.
> +	 */
> +	if (vma_keyid(vma)) {
> +		prep_encrypted_page(new_page, HPAGE_PMD_ORDER,
> +				vma_keyid(vma), false);
> +	}

I guess this isn't horribly problematic now, but if we ever keep pools
of preassigned-keyids, this won't work any more.
