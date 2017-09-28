Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 473386B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 04:10:38 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v109so297820wrc.0
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 01:10:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i55sor350122wra.81.2017.09.28.01.10.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 01:10:37 -0700 (PDT)
Date: Thu, 28 Sep 2017 10:10:34 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv7 02/19] mm/zsmalloc: Prepare to variable MAX_PHYSMEM_BITS
Message-ID: <20170928081034.g3k3sz7pue7jnzvi@gmail.com>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
 <20170918105553.27914-3-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170918105553.27914-3-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> With boot-time switching between paging mode we will have variable
> MAX_PHYSMEM_BITS.
> 
> Let's use the maximum variable possible for CONFIG_X86_5LEVEL=y
> configuration to define zsmalloc data structures.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
> ---
>  mm/zsmalloc.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 7c38e850a8fc..fe22661f2fe5 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -93,7 +93,13 @@
>  #define MAX_PHYSMEM_BITS BITS_PER_LONG
>  #endif
>  #endif
> +
> +#ifdef CONFIG_X86_5LEVEL
> +/* MAX_PHYSMEM_BITS is variable, use maximum value here */
> +#define _PFN_BITS		(52 - PAGE_SHIFT)
> +#else
>  #define _PFN_BITS		(MAX_PHYSMEM_BITS - PAGE_SHIFT)
> +#endif

This is a totally ugly hack, polluting generic MM code with an x86-ism and an 
arbitrary hard-coded constant that would silently lose validity when x86 paging 
gets extended again ...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
