Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 805606B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 09:26:05 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id c41so4606067eek.8
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 06:26:04 -0700 (PDT)
Received: from mail-ee0-x22b.google.com (mail-ee0-x22b.google.com [2a00:1450:4013:c00::22b])
        by mx.google.com with ESMTPS id d5si59719981eei.328.2014.04.22.06.26.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 06:26:04 -0700 (PDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so4642418eek.2
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 06:26:03 -0700 (PDT)
Date: Tue, 22 Apr 2014 15:25:59 +0200
From: Andreas Herrmann <herrmann.der.user@googlemail.com>
Subject: Re: [PATCH 3/6] mips: call find_vma with the mmap_sem held
Message-ID: <20140422132559.GD10997@alberich>
References: <1397960791-16320-1-git-send-email-davidlohr@hp.com>
 <1397960791-16320-4-git-send-email-davidlohr@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1397960791-16320-4-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: akpm@linux-foundation.org, zeus@gnu.org, aswin@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org

On Sat, Apr 19, 2014 at 07:26:28PM -0700, Davidlohr Bueso wrote:
> Performing vma lookups without taking the mm->mmap_sem is asking
> for trouble. While doing the search, the vma in question can be
> modified or even removed before returning to the caller. Take the
> lock (exclusively) in order to avoid races while iterating through
> the vmacache and/or rbtree.
> 
> Updates two functions:
>   - process_fpemu_return()
>   - cteon_flush_cache_sigtramp()
> 
> This patch is completely *untested*.
> 
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> Cc: Ralf Baechle <ralf@linux-mips.org>
> Cc: linux-mips@linux-mips.org

Tested-by: Andreas Herrmann <andreas.herrmann@caviumnetworks.com>


Thanks,

Andreas

> ---
>  arch/mips/kernel/traps.c | 2 ++
>  arch/mips/mm/c-octeon.c  | 2 ++
>  2 files changed, 4 insertions(+)
> 
> diff --git a/arch/mips/kernel/traps.c b/arch/mips/kernel/traps.c
> index 074e857..c51bd20 100644
> --- a/arch/mips/kernel/traps.c
> +++ b/arch/mips/kernel/traps.c
> @@ -712,10 +712,12 @@ int process_fpemu_return(int sig, void __user *fault_addr)
>  		si.si_addr = fault_addr;
>  		si.si_signo = sig;
>  		if (sig == SIGSEGV) {
> +			down_read(&current->mm->mmap_sem);
>  			if (find_vma(current->mm, (unsigned long)fault_addr))
>  				si.si_code = SEGV_ACCERR;
>  			else
>  				si.si_code = SEGV_MAPERR;
> +			up_read(&current->mm->mmap_sem);
>  		} else {
>  			si.si_code = BUS_ADRERR;
>  		}
> diff --git a/arch/mips/mm/c-octeon.c b/arch/mips/mm/c-octeon.c
> index f41a5c5..05b1d7c 100644
> --- a/arch/mips/mm/c-octeon.c
> +++ b/arch/mips/mm/c-octeon.c
> @@ -137,8 +137,10 @@ static void octeon_flush_cache_sigtramp(unsigned long addr)
>  {
>  	struct vm_area_struct *vma;
>  
> +	down_read(&current->mm->mmap_sem);
>  	vma = find_vma(current->mm, addr);
>  	octeon_flush_icache_all_cores(vma);
> +	up_read(&current->mm->mmap_sem);
>  }
>  
>  
> -- 
> 1.8.1.4
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
