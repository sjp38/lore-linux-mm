Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4DA976B025E
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 21:41:20 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id p16so143263126qta.5
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 18:41:20 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v35si31845462qtb.132.2016.11.30.18.41.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 18:41:19 -0800 (PST)
Date: Thu, 1 Dec 2016 10:41:03 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCHv4 07/10] kexec: Switch to __pa_symbol
Message-ID: <20161201024103.GA32438@dhcp-128-65.nay.redhat.com>
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
 <1480445729-27130-8-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1480445729-27130-8-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Eric Biederman <ebiederm@xmission.com>, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>

Hi, Laura
On 11/29/16 at 10:55am, Laura Abbott wrote:
> 
> __pa_symbol is the correct api to get the physical address of kernel
> symbols. Switch to it to allow for better debug checking.
> 

I assume __pa_symbol is faster than __pa, but it still need some testing
on all arches which support kexec.

But seems long long ago there is a commit e3ebadd95cb in the commit log
I see below from:
"we should deprecate __pa_symbol(), and preferably __pa() too - and
 just use "virt_to_phys()" instead, which is is more readable and has
 nicer semantics."

But maybe in modern code __pa_symbol is prefered I may miss background.
virt_to_phys still sounds more readable now for me though.

> Signed-off-by: Laura Abbott <labbott@redhat.com>
> ---
> Found during review of the kernel. Untested.
> ---
>  kernel/kexec_core.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
> index 5616755..e1b625e 100644
> --- a/kernel/kexec_core.c
> +++ b/kernel/kexec_core.c
> @@ -1397,7 +1397,7 @@ void __weak arch_crash_save_vmcoreinfo(void)
>  
>  phys_addr_t __weak paddr_vmcoreinfo_note(void)
>  {
> -	return __pa((unsigned long)(char *)&vmcoreinfo_note);
> +	return __pa_symbol((unsigned long)(char *)&vmcoreinfo_note);
>  }
>  
>  static int __init crash_save_vmcoreinfo_init(void)
> -- 
> 2.7.4
> 
> 
> _______________________________________________
> kexec mailing list
> kexec@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/kexec

Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
