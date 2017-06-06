Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 39D1D6B02F4
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 15:50:18 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id i206so198611391ita.10
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 12:50:18 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id f15si35851358iof.208.2017.06.06.12.50.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 12:50:17 -0700 (PDT)
References: <20170606173512.7378-1-jglisse@redhat.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <7b8534ee-8d07-8a9a-5b80-c16725033ee9@deltatee.com>
Date: Tue, 6 Jun 2017 13:50:14 -0600
MIME-Version: 1.0
In-Reply-To: <20170606173512.7378-1-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH] x86/mm/hotplug: fix BUG_ON() after hotremove
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

Thanks Jerome! This indeed fixes the bug I reported.

Tested-by: Logan Gunthorpe <logang@deltatee.com>

Logan


On 06/06/17 11:35 AM, JA(C)rA'me Glisse wrote:
> With commit af2cf278ef4f we no longer free pud so that we
> do not have synchronize all pgd on hotremove/vfree. But the
> new 5 level page table code re-added that code f2a6a705 and
> thus we now trigger a BUG_ON() l128 in sync_global_pgds()
> 
> This patch remove free_pud() like in af2cf278ef4f
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> ---
>  arch/x86/mm/init_64.c | 19 -------------------
>  1 file changed, 19 deletions(-)
> 
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index a8a9972..8cf7e99 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -772,24 +772,6 @@ static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud)
>  	spin_unlock(&init_mm.page_table_lock);
>  }
>  
> -static void __meminit free_pud_table(pud_t *pud_start, p4d_t *p4d)
> -{
> -	pud_t *pud;
> -	int i;
> -
> -	for (i = 0; i < PTRS_PER_PUD; i++) {
> -		pud = pud_start + i;
> -		if (!pud_none(*pud))
> -			return;
> -	}
> -
> -	/* free a pud talbe */
> -	free_pagetable(p4d_page(*p4d), 0);
> -	spin_lock(&init_mm.page_table_lock);
> -	p4d_clear(p4d);
> -	spin_unlock(&init_mm.page_table_lock);
> -}
> -
>  static void __meminit
>  remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
>  		 bool direct)
> @@ -991,7 +973,6 @@ remove_p4d_table(p4d_t *p4d_start, unsigned long addr, unsigned long end,
>  
>  		pud_base = pud_offset(p4d, 0);
>  		remove_pud_table(pud_base, addr, next, direct);
> -		free_pud_table(pud_base, p4d);
>  	}
>  
>  	if (direct)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
