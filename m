Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id D2BF56B0390
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 17:52:23 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id a205so1888964itd.21
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 14:52:23 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id s189si11342297pgc.85.2017.04.21.14.52.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 14:52:23 -0700 (PDT)
Subject: Re: [PATCH v5 09/32] x86/mm: Provide general kernel support for
 memory encryption
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211754.10190.25082.stgit@tlendack-t1.amdoffice.net>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <0106e3fc-9780-e872-2274-fecf79c28923@intel.com>
Date: Fri, 21 Apr 2017 14:52:21 -0700
MIME-Version: 1.0
In-Reply-To: <20170418211754.10190.25082.stgit@tlendack-t1.amdoffice.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 04/18/2017 02:17 PM, Tom Lendacky wrote:
> @@ -55,7 +57,7 @@ static inline void copy_user_page(void *to, void *from, unsigned long vaddr,
>  	__phys_addr_symbol(__phys_reloc_hide((unsigned long)(x)))
>  
>  #ifndef __va
> -#define __va(x)			((void *)((unsigned long)(x)+PAGE_OFFSET))
> +#define __va(x)			((void *)(__sme_clr(x) + PAGE_OFFSET))
>  #endif

It seems wrong to be modifying __va().  It currently takes a physical
address, and this modifies it to take a physical address plus the SME bits.

How does that end up ever happening?  If we are pulling physical
addresses out of the page tables, we use p??_phys().  I'd expect *those*
to be masking off the SME bits.

Is it these cases?

	pgd_t *base = __va(read_cr3());

For those, it seems like we really want to create two modes of reading
cr3.  One that truly reads CR3 and another that reads the pgd's physical
address out of CR3.  Then you only do the SME masking on the one
fetching a physical address, and the SME bits never leak into __va().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
