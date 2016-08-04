Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id EFED96B025F
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 04:59:11 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p85so129368461lfg.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 01:59:11 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id z206si5177224lfa.415.2016.08.04.01.51.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 01:51:04 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id l89so14011248lfi.2
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 01:51:04 -0700 (PDT)
Date: Thu, 4 Aug 2016 14:50:55 +0600
From: Alexnader Kuleshov <kuleshovmail@gmail.com>
Subject: Re: [PATCH] fs:Fix kmemleak leak warning in getname_flags about
 working on unitialized memory
Message-ID: <20160804085055.GB2509@localhost>
References: <1470260896-31767-1-git-send-email-xerofoify@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1470260896-31767-1-git-send-email-xerofoify@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Krause <xerofoify@gmail.com>
Cc: viro@zeniv.linux.org.uk, akpm@linux-foundation.org, msalter@redhat.com, kuleshovmail@gmail.com, david.vrabel@citrix.com, vbabka@suse.cz, ard.biesheuvel@linaro.org, jgross@suse.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08-03-16, Nicholas Krause wrote:
> This fixes a kmemleak leak warning complaining about working on
> unitializied memory as found in the function, getname_flages. Seems

s/getname_flages/getname_flags

> that we are indeed working on unitialized memory, as the filename
> char pointer is never made to point to the filname structure's result
> member for holding it's name, fix this by using memcpy to copy the
> filname structure pointer's, name to the char pointer passed to this
> function.
> 
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

Why?

>  	return (__force void *)__early_ioremap(phys_addr, size,
>  					       FIXMAP_PAGE_NORMAL);
>  }
> -- 
> 2.7.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
