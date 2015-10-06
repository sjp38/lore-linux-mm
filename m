Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id BE30182FAC
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 23:35:51 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so195129901pab.3
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 20:35:51 -0700 (PDT)
Received: from mgwym01.jp.fujitsu.com (mgwym01.jp.fujitsu.com. [211.128.242.40])
        by mx.google.com with ESMTPS id zg9si45319598pac.171.2015.10.05.20.35.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Oct 2015 20:35:50 -0700 (PDT)
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by yt-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 6A29CAC0105
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 12:35:46 +0900 (JST)
Subject: Re: [PATCH 03/11] x86/mm/hotplug: Don't remove PGD entries in
 remove_pagetable()
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
 <1442903021-3893-4-git-send-email-mingo@kernel.org>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <56134169.1070500@jp.fujitsu.com>
Date: Tue, 6 Oct 2015 12:35:05 +0900
MIME-Version: 1.0
In-Reply-To: <1442903021-3893-4-git-send-email-mingo@kernel.org>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?UTF-8?B?SXNoaW1hdHN1LCBZYXN1YWtpL+efs+adviDpnZbnq6A=?= <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>, =?UTF-8?B?SXp1bWksIFRha3Uv5rOJIOaLkw==?= <izumi.taku@jp.fujitsu.com>

On 2015/09/22 15:23, Ingo Molnar wrote:
> So when memory hotplug removes a piece of physical memory from pagetable
> mappings, it also frees the underlying PGD entry.
> 
> This complicates PGD management, so don't do this. We can keep the
> PGD mapped and the PUD table all clear - it's only a single 4K page
> per 512 GB of memory hotplugged.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: Brian Gerst <brgerst@gmail.com>
> Cc: Denys Vlasenko <dvlasenk@redhat.com>
> Cc: H. Peter Anvin <hpa@zytor.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Waiman Long <Waiman.Long@hp.com>
> Cc: linux-mm@kvack.org
> Signed-off-by: Ingo Molnar <mingo@kernel.org>

Ishimatsu-san, Tang-san, please check.

Doesn't this patch affects the issues of 
 5255e0a79fcc0ff47b387af92bd9ef5729b1b859
 9661d5bcd058fe15b4138a00d96bd36516134543

?

-Kame

> ---
>   arch/x86/mm/init_64.c | 27 ---------------------------
>   1 file changed, 27 deletions(-)
> 
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 7129e7647a76..60b0cc3f2819 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -780,27 +780,6 @@ static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud)
>   	spin_unlock(&init_mm.page_table_lock);
>   }
>   
> -/* Return true if pgd is changed, otherwise return false. */
> -static bool __meminit free_pud_table(pud_t *pud_start, pgd_t *pgd)
> -{
> -	pud_t *pud;
> -	int i;
> -
> -	for (i = 0; i < PTRS_PER_PUD; i++) {
> -		pud = pud_start + i;
> -		if (pud_val(*pud))
> -			return false;
> -	}
> -
> -	/* free a pud table */
> -	free_pagetable(pgd_page(*pgd), 0);
> -	spin_lock(&init_mm.page_table_lock);
> -	pgd_clear(pgd);
> -	spin_unlock(&init_mm.page_table_lock);
> -
> -	return true;
> -}
> -
>   static void __meminit
>   remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
>   		 bool direct)
> @@ -992,7 +971,6 @@ remove_pagetable(unsigned long start, unsigned long end, bool direct)
>   	unsigned long addr;
>   	pgd_t *pgd;
>   	pud_t *pud;
> -	bool pgd_changed = false;
>   
>   	for (addr = start; addr < end; addr = next) {
>   		next = pgd_addr_end(addr, end);
> @@ -1003,13 +981,8 @@ remove_pagetable(unsigned long start, unsigned long end, bool direct)
>   
>   		pud = (pud_t *)pgd_page_vaddr(*pgd);
>   		remove_pud_table(pud, addr, next, direct);
> -		if (free_pud_table(pud, pgd))
> -			pgd_changed = true;
>   	}
>   
> -	if (pgd_changed)
> -		sync_global_pgds(start, end - 1, 1);
> -
>   	flush_tlb_all();
>   }
>   
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
