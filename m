Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CE6056B0003
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 13:45:26 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id j10-v6so1139147pgv.6
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 10:45:26 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id x3-v6si2860890pgt.88.2018.06.13.10.45.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 10:45:25 -0700 (PDT)
Subject: Re: [PATCHv3 01/17] mm: Do no merge VMAs with different encryption
 KeyIDs
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-2-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <090170d5-44a7-9bd6-2287-c1f9f87f536f@intel.com>
Date: Wed, 13 Jun 2018 10:45:24 -0700
MIME-Version: 1.0
In-Reply-To: <20180612143915.68065-2-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/12/2018 07:38 AM, Kirill A. Shutemov wrote:
> VMAs with different KeyID do not mix together. Only VMAs with the same
> KeyID are compatible.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  include/linux/mm.h | 7 +++++++
>  mm/mmap.c          | 3 ++-
>  2 files changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 02a616e2f17d..1c3c15f37ed6 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1492,6 +1492,13 @@ static inline bool vma_is_anonymous(struct vm_area_struct *vma)
>  	return !vma->vm_ops;
>  }
>  
> +#ifndef vma_keyid
> +static inline int vma_keyid(struct vm_area_struct *vma)
> +{
> +	return 0;
> +}
> +#endif

I'm generally not a fan of this #ifdef'ing method.  It makes it hard to
figure out who is supposed to define it, and it's also substantially
more fragile in the face of #include ordering.

I'd much rather see some Kconfig involvement, like
CONFIG_ARCH_HAS_MEM_ENCRYPTION or something.
