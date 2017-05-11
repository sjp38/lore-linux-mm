Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D246F6B02C4
	for <linux-mm@kvack.org>; Thu, 11 May 2017 13:41:38 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q77so7668905wmg.13
        for <linux-mm@kvack.org>; Thu, 11 May 2017 10:41:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r28si1330548eda.267.2017.05.11.10.41.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 May 2017 10:41:37 -0700 (PDT)
Date: Thu, 11 May 2017 19:41:28 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC 01/10] x86/mm: Reimplement flush_tlb_page() using
 flush_tlb_mm_range()
Message-ID: <20170511174128.rp7dwckpci4gqsxy@pd.tnic>
References: <cover.1494160201.git.luto@kernel.org>
 <dbe03b624fb5e785d33ca71c98f113f05d7b12df.1494160201.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <dbe03b624fb5e785d33ca71c98f113f05d7b12df.1494160201.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>

On Sun, May 07, 2017 at 05:38:30AM -0700, Andy Lutomirski wrote:
> flush_tlb_page() was very similar to flush_tlb_mm_range() except that
> it had a couple of issues:
> 
>  - It was missing an smp_mb() in the case where
>    current->active_mm != mm.  (This is a longstanding bug reported by
>    Nadav Amit.)
> 
>  - It was missing tracepoints and vm counter updates.
> 
> The only reason that I can see for keeping it at as a separate
> function is that it could avoid a few branches that
> flush_tlb_mm_range() needs to decide to flush just one page.  This
> hardly seems worthwhile.  If we decide we want to get rid of those
> branches again, a better way would be to introduce an
> __flush_tlb_mm_range() helper and make both flush_tlb_page() and
> flush_tlb_mm_range() use it.
> 
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Nadav Amit <namit@vmware.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  arch/x86/include/asm/tlbflush.h |  6 +++++-
>  arch/x86/mm/tlb.c               | 27 ---------------------------
>  2 files changed, 5 insertions(+), 28 deletions(-)
> 
> diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
> index 6ed9ea469b48..5ed64cdaf536 100644
> --- a/arch/x86/include/asm/tlbflush.h
> +++ b/arch/x86/include/asm/tlbflush.h
> @@ -307,11 +307,15 @@ static inline void flush_tlb_kernel_range(unsigned long start,
>  		flush_tlb_mm_range(vma->vm_mm, start, end, vma->vm_flags)
>  
>  extern void flush_tlb_all(void);
> -extern void flush_tlb_page(struct vm_area_struct *, unsigned long);
>  extern void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
>  				unsigned long end, unsigned long vmflag);
>  extern void flush_tlb_kernel_range(unsigned long start, unsigned long end);
>  
> +static inline void flush_tlb_page(struct vm_area_struct *vma, unsigned long a)
> +{
> +	flush_tlb_mm_range(vma->vm_mm, a, a + PAGE_SIZE, 0);

							 VM_NONE);

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
