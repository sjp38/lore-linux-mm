Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 122DE6B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 09:31:17 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p129so146966396wmp.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 06:31:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id rb4si13628936wjb.208.2016.08.04.06.31.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Aug 2016 06:31:16 -0700 (PDT)
Subject: Re: [PATCH] fs:Fix kmemleak leak warning in getname_flags about
 working on unitialized memory
References: <1470260896-31767-1-git-send-email-xerofoify@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6b369f5c-6a9d-febf-81fe-2e1a4b408814@suse.cz>
Date: Thu, 4 Aug 2016 15:31:01 +0200
MIME-Version: 1.0
In-Reply-To: <1470260896-31767-1-git-send-email-xerofoify@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Krause <xerofoify@gmail.com>, viro@zeniv.linux.org.uk
Cc: akpm@linux-foundation.org, msalter@redhat.com, kuleshovmail@gmail.com, david.vrabel@citrix.com, ard.biesheuvel@linaro.org, jgross@suse.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/03/2016 11:48 PM, Nicholas Krause wrote:
> This fixes a kmemleak leak warning complaining about working on
> unitializied memory as found in the function, getname_flages. Seems

What exactly is the kmemleak warning saying?

> that we are indeed working on unitialized memory, as the filename
> char pointer is never made to point to the filname structure's result
> member for holding it's name, fix this by using memcpy to copy the
> filname structure pointer's, name to the char pointer passed to this
> function.

I don't understand what you're saying here. "the char pointer passed to
this function" is the source, not destination.

> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  fs/namei.c         | 1 +
>  mm/early_ioremap.c | 1 +
>  2 files changed, 2 insertions(+)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index c386a32..6b18d57 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -196,6 +196,7 @@ getname_flags(const char __user *filename, int flags, int *empty)
>  		}
>  	}
>  
> +	memcpy((char *)result->name, filename, len);

This will be wrong even with strncpy_from_user instead of memcpy. AFAICS
result->name already points to a copy of filename.
Also if you think that the above is "copy[ing] the filname structure
pointer's, name to the char pointer passed to this function" then you
are wrong.

>  	result->uptr = filename;
>  	result->aname = NULL;
>  	audit_getname(result);
> diff --git a/mm/early_ioremap.c b/mm/early_ioremap.c
> index 6d5717b..92c5235 100644
> --- a/mm/early_ioremap.c
> +++ b/mm/early_ioremap.c
> @@ -215,6 +215,7 @@ early_ioremap(resource_size_t phys_addr, unsigned long size)
>  void __init *
>  early_memremap(resource_size_t phys_addr, unsigned long size)
>  {
> +	dump_stack();
>  	return (__force void *)__early_ioremap(phys_addr, size,
>  					       FIXMAP_PAGE_NORMAL);
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
