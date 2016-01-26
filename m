Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4666B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 01:40:06 -0500 (EST)
Received: by mail-oi0-f53.google.com with SMTP id w75so102557465oie.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 22:40:06 -0800 (PST)
Received: from mail-ob0-x243.google.com (mail-ob0-x243.google.com. [2607:f8b0:4003:c01::243])
        by mx.google.com with ESMTPS id tj10si20934988obc.72.2016.01.25.22.40.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 22:40:05 -0800 (PST)
Received: by mail-ob0-x243.google.com with SMTP id x5so10893240obg.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 22:40:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1453740953-18109-3-git-send-email-labbott@fedoraproject.org>
References: <1453740953-18109-1-git-send-email-labbott@fedoraproject.org> <1453740953-18109-3-git-send-email-labbott@fedoraproject.org>
From: Jianyu Zhan <nasa4836@gmail.com>
Date: Tue, 26 Jan 2016 14:39:26 +0800
Message-ID: <CAHz2CGXc6=r_D1L6nUTj7A_bbX7GeUFb5+0TZWh55UUA6hiQ7w@mail.gmail.com>
Subject: Re: [RFC][PATCH 2/3] mm/page_poison.c: Enable PAGE_POISONING as a
 separate option
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>

On Tue, Jan 26, 2016 at 12:55 AM, Laura Abbott
<labbott@fedoraproject.org> wrote:
> --- a/mm/debug-pagealloc.c
> +++ b/mm/debug-pagealloc.c
> @@ -8,11 +8,5 @@
>
>  void __kernel_map_pages(struct page *page, int numpages, int enable)
>  {
> -       if (!page_poisoning_enabled())
> -               return;
> -
> -       if (enable)
> -               unpoison_pages(page, numpages);
> -       else
> -               poison_pages(page, numpages);
> +       kernel_poison_pages(page, numpages, enable);
>  }
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 63358d9..c733421 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1002,6 +1002,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
>                                            PAGE_SIZE << order);
>         }
>         arch_free_page(page, order);
> +       kernel_poison_pages(page, 1 << order, 0);
>         kernel_map_pages(page, 1 << order, 0);
>
>         return true;
> @@ -1396,6 +1397,7 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
>         set_page_refcounted(page);
>
>         arch_alloc_page(page, order);
> +       kernel_poison_pages(page, 1 << order, 1);
>         kernel_map_pages(page, 1 << order, 1);
>         kasan_alloc_pages(page, order);
>

kernel_map_pages() will fall back to page poisoning scheme for
!ARCH_SUPPORTS_DEBUG_PAGEALLOC.

IIUC,  calling kernel_poison_pages() before kernel_map_pages() will be
equivalent to call kernel_poison_pages()
twice?!




Thanks,
Jianyu Zhan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
