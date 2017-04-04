Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A5046B0397
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 17:10:05 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id y22so71898253ioe.9
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 14:10:05 -0700 (PDT)
Received: from mail-it0-x234.google.com (mail-it0-x234.google.com. [2607:f8b0:4001:c0b::234])
        by mx.google.com with ESMTPS id b130si15675807itb.21.2017.04.04.14.10.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 14:10:04 -0700 (PDT)
Received: by mail-it0-x234.google.com with SMTP id y18so68083045itc.1
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 14:10:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1491340140-18238-1-git-send-email-labbott@redhat.com>
References: <1491340140-18238-1-git-send-email-labbott@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 4 Apr 2017 14:10:03 -0700
Message-ID: <CAGXu5j+TD4Aq2OkJ4hRSc-QFWwRhAx56_iZgH805MD5Ha6rHBw@mail.gmail.com>
Subject: Re: [PATCH] mm/usercopy: Drop extra is_vmalloc_or_module check
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Mark Rutland <mark.rutland@arm.com>

On Tue, Apr 4, 2017 at 2:09 PM, Laura Abbott <labbott@redhat.com> wrote:
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

Awesome, thanks! I'll get it into my usercopy branch for -next.

-Kees

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
>         struct page *page;
>
> -       /*
> -        * Some architectures (arm64) return true for virt_addr_valid() on
> -        * vmalloced addresses. Work around this by checking for vmalloc
> -        * first.
> -        *
> -        * We also need to check for module addresses explicitly since we
> -        * may copy static data from modules to userspace
> -        */
> -       if (is_vmalloc_or_module_addr(ptr))
> -               return NULL;
> -
>         if (!virt_addr_valid(ptr))
>                 return NULL;
>
> --
> 2.12.1
>



-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
