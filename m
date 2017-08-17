Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4DA416B02FD
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 05:17:10 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id o8so11807471wrg.11
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 02:17:10 -0700 (PDT)
Received: from mail-wr0-x241.google.com (mail-wr0-x241.google.com. [2a00:1450:400c:c0c::241])
        by mx.google.com with ESMTPS id y28si2870518edi.306.2017.08.17.02.17.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 02:17:08 -0700 (PDT)
Received: by mail-wr0-x241.google.com with SMTP id n88so7310091wrb.0
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 02:17:08 -0700 (PDT)
Date: Thu, 17 Aug 2017 11:17:05 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv4 11/14] x86/mm: Replace compile-time checks for 5-level
 with runtime-time
Message-ID: <20170817091705.5np3utcqeia5em4x@gmail.com>
References: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
 <20170808125415.78842-12-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808125415.78842-12-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -459,7 +459,7 @@ static noinline int vmalloc_fault(unsigned long address)
>  	if (pgd_none(*pgd)) {
>  		set_pgd(pgd, *pgd_ref);
>  		arch_flush_lazy_mmu_mode();
> -	} else if (CONFIG_PGTABLE_LEVELS > 4) {
> +	} else if (!p4d_folded) {

BTW: the new name is worse I think, not just the cryptic 'p4d' acronym that will 
generally be much less well known than '5 level page tables', but also the logic 
inversion from common usage patterns that generally want to do something if the 
'fifth level is not folded' i.e. if 'the fifth level is enabled'.

How about calling it 'pgtable_l5_enabled'? The switch tells us that the fifth 
level of our page tables is enabled. Harmonizes with '5 level paging support'. It 
also won't have the logic inversion but can be used directly:

	} else if (pgtable_l5_enabled) {

( In theory we could use that nomenclature for PAE as well, 'pgtable_l3_enabled', 
  or so - although PAE is special in more ways than just one more level, so it 
  might not be practical. )

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
