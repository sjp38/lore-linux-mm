Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id CE2606B009A
	for <linux-mm@kvack.org>; Wed,  4 Feb 2015 12:47:13 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id n4so2198055qaq.12
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 09:47:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c2si2650736qar.131.2015.02.04.09.47.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Feb 2015 09:47:13 -0800 (PST)
Date: Wed, 4 Feb 2015 12:47:05 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH] hugetlb, x86: register 1G page size if we can allocate
 them runtime
Message-ID: <20150204124705.21f669bd@redhat.com>
In-Reply-To: <1423050871-122636-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423050871-122636-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <ak@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On Wed,  4 Feb 2015 13:54:31 +0200
"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> After commit 944d9fec8d7a we can allocate 1G pages runtime if CMA is
> enabled.
> 
> Let's register 1G pages into hugetlb even if user hasn't requested them
> explicitly at boot time with hugepagesz=1G.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Luiz Capitulino <lcapitulino@redhat.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Andi Kleen <ak@linux.intel.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> ---
>  arch/x86/mm/hugetlbpage.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> index 9161f764121e..42982b26e32b 100644
> --- a/arch/x86/mm/hugetlbpage.c
> +++ b/arch/x86/mm/hugetlbpage.c
> @@ -172,4 +172,15 @@ static __init int setup_hugepagesz(char *opt)
>  	return 1;
>  }
>  __setup("hugepagesz=", setup_hugepagesz);
> +
> +#ifdef CONFIG_CMA
> +static __init int gigantic_pages_init(void)
> +{
> +	/* With CMA we can allocate gigantic pages at runtime */
> +	if (cpu_has_gbpages && !size_to_hstate(1UL << PUD_SHIFT))
> +		hugetlb_add_hstate(PUD_SHIFT - PAGE_SHIFT);
> +	return 0;
> +}
> +arch_initcall(gigantic_pages_init);
> +#endif
>  #endif

Very nice! I was thinking about this for a long time but I don't
think my implementation would be that simple:

Reviewed-by: Luiz Capitulino <lcapitulino@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
