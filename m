Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 65BA66B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 17:26:12 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id x16so12212395pfe.20
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 14:26:12 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0088.outbound.protection.outlook.com. [104.47.32.88])
        by mx.google.com with ESMTPS id z1-v6si6251531pln.408.2018.01.30.14.26.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 14:26:10 -0800 (PST)
Subject: Re: [PATCHv3 1/3] x86/mm/encrypt: Move page table helpers into
 separate translation unit
References: <20180124163623.61765-1-kirill.shutemov@linux.intel.com>
 <20180124163623.61765-2-kirill.shutemov@linux.intel.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <f1005ed5-c245-b64f-fe4b-64fff5790172@amd.com>
Date: Tue, 30 Jan 2018 16:26:03 -0600
MIME-Version: 1.0
In-Reply-To: <20180124163623.61765-2-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 1/24/2018 10:36 AM, Kirill A. Shutemov wrote:
> There are bunch of functions in mem_encrypt.c that operate on the
> identity mapping, which means they want virtual addresses to be equal to
> physical one, without PAGE_OFFSET shift.
> 
> We also need to avoid paravirtualizaion call there.
> 
> Getting this done is tricky. We cannot use usual page table helpers.
> It forces us to open-code a lot of things. It makes code ugly and hard
> to modify.
> 
> We can get it work with the page table helpers, but it requires few
> preprocessor tricks. These tricks may have side effects for the rest of
> the file.
> 
> Let's isolate such functions into own translation unit.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Just one minor comment at the end.  With that change:

Reviewed-by: Tom Lendacky <thomas.lendacky@amd.com>

> ---
>  arch/x86/mm/Makefile               |  14 +-
>  arch/x86/mm/mem_encrypt.c          | 578 +----------------------------------
>  arch/x86/mm/mem_encrypt_identity.c | 596 +++++++++++++++++++++++++++++++++++++
>  arch/x86/mm/mm_internal.h          |   1 +
>  4 files changed, 607 insertions(+), 582 deletions(-)
>  create mode 100644 arch/x86/mm/mem_encrypt_identity.c
> 

...

> diff --git a/arch/x86/mm/mm_internal.h b/arch/x86/mm/mm_internal.h
> index 4e1f6e1b8159..7b4fc4386d90 100644
> --- a/arch/x86/mm/mm_internal.h
> +++ b/arch/x86/mm/mm_internal.h
> @@ -19,4 +19,5 @@ extern int after_bootmem;
>  
>  void update_cache_mode_entry(unsigned entry, enum page_cache_mode cache);
>  
> +extern bool sev_enabled __section(.data);

Lets move this into arch/x86/include/asm/mem_encrypt.h and then add
#include <linux/mem_encrypt.h> to mem_encrypt_identity.c.

Thanks,
Tom

>  #endif	/* __X86_MM_INTERNAL_H */
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
