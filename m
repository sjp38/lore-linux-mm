Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 202186B0260
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:16:28 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id xr1so35705103wjb.7
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:16:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d76si3519299wma.50.2016.12.16.06.16.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Dec 2016 06:16:22 -0800 (PST)
From: Andreas Schwab <schwab@suse.de>
Subject: Re: jemalloc testsuite stalls in memset
References: <mvmmvfy37g1.fsf@hawking.suse.de> <20161214235031.GA2912@bbox>
	<mvm4m2535pc.fsf@hawking.suse.de> <20161216063940.GA1334@bbox>
Date: Fri, 16 Dec 2016 15:16:20 +0100
In-Reply-To: <20161216063940.GA1334@bbox> (Minchan Kim's message of "Fri, 16
	Dec 2016 15:39:40 +0900")
Message-ID: <87d1gshscr.fsf@suse.de>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, mbrugger@suse.de, linux-mm@kvack.org, Jason Evans <je@fb.com>

On Dez 16 2016, Minchan Kim <minchan@kernel.org> wrote:

> Below helps?
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index e10a4fe..dc37c9a 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1611,6 +1611,7 @@ int madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  			tlb->fullmm);
>  		orig_pmd = pmd_mkold(orig_pmd);
>  		orig_pmd = pmd_mkclean(orig_pmd);
> +		orig_pmd = pmd_wrprotect(orig_pmd);
>  
>  		set_pmd_at(mm, addr, pmd, orig_pmd);
>  		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);

Thanks, this fixes the issue (tested with 4.9).

Andreas.

-- 
Andreas Schwab, SUSE Labs, schwab@suse.de
GPG Key fingerprint = 0196 BAD8 1CE9 1970 F4BE  1748 E4D4 88E3 0EEA B9D7
"And now for something completely different."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
