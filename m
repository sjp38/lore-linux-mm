Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1FA2B6B0390
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 09:18:18 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id n129so6730810pga.22
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 06:18:18 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p4si2094684pga.204.2017.04.05.06.18.16
        for <linux-mm@kvack.org>;
        Wed, 05 Apr 2017 06:18:17 -0700 (PDT)
Date: Wed, 5 Apr 2017 14:17:54 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] mm/usercopy: Drop extra is_vmalloc_or_module check
Message-ID: <20170405131754.GB10833@leverpostej>
References: <1491340140-18238-1-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1491340140-18238-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Tue, Apr 04, 2017 at 02:09:00PM -0700, Laura Abbott wrote:
> virt_addr_valid was previously insufficient to validate if virt_to_page
> could be called on an address on arm64. This has since been fixed up
> so there is no need for the extra check. Drop it.
> 
> Signed-off-by: Laura Abbott <labbott@redhat.com>
> ---
> I've given this some testing on my machine and haven't seen any problems
> (e.g. random crashes without the check) and the fix has been in for long
> enough now. I'm in no rush to have this merged so I'm okay if this sits in
> a tree somewhere to get more testing.

This looks good to me, given your fix for virt_add_valid() in mainline.
FWIW:

Acked-by: Mark Rutland <mark.rutland@arm.com>

Mark.

> ---
>  mm/usercopy.c | 11 -----------
>  1 file changed, 11 deletions(-)
> 
> diff --git a/mm/usercopy.c b/mm/usercopy.c
> index d155e12563b1..4d23a0e0e232 100644
> --- a/mm/usercopy.c
> +++ b/mm/usercopy.c
> @@ -206,17 +206,6 @@ static inline const char *check_heap_object(const void *ptr, unsigned long n,
>  {
>  	struct page *page;
>  
> -	/*
> -	 * Some architectures (arm64) return true for virt_addr_valid() on
> -	 * vmalloced addresses. Work around this by checking for vmalloc
> -	 * first.
> -	 *
> -	 * We also need to check for module addresses explicitly since we
> -	 * may copy static data from modules to userspace
> -	 */
> -	if (is_vmalloc_or_module_addr(ptr))
> -		return NULL;
> -
>  	if (!virt_addr_valid(ptr))
>  		return NULL;
>  
> -- 
> 2.12.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
