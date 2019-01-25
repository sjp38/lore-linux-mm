Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 40EC48E00BD
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 13:44:57 -0500 (EST)
Received: by mail-vs1-f71.google.com with SMTP id y139so3874247vsc.14
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 10:44:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g21sor14447910vsi.3.2019.01.25.10.44.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 Jan 2019 10:44:56 -0800 (PST)
Received: from mail-ua1-f50.google.com (mail-ua1-f50.google.com. [209.85.222.50])
        by smtp.gmail.com with ESMTPSA id a6sm14950866vse.30.2019.01.25.10.44.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 10:44:53 -0800 (PST)
Received: by mail-ua1-f50.google.com with SMTP id d21so3574735uap.9
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 10:44:52 -0800 (PST)
MIME-Version: 1.0
References: <20190125173827.2658-1-willy@infradead.org>
In-Reply-To: <20190125173827.2658-1-willy@infradead.org>
From: Kees Cook <keescook@chromium.org>
Date: Sat, 26 Jan 2019 07:44:40 +1300
Message-ID: <CAGXu5jJ=yHXC_S_o6V4QQ+DCV4w2T-tw_BiUXDAW2a8rZDhZJg@mail.gmail.com>
Subject: Re: [PATCH] mm: Prevent mapping slab pages to userspace
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@surriel.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Michael Ellerman <mpe@ellerman.id.au>

On Sat, Jan 26, 2019 at 6:38 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> It's never appropriate to map a page allocated by SLAB into userspace.
> A buggy device driver might try this, or an attacker might be able to
> find a way to make it happen.
>
> Signed-off-by: Matthew Wilcox <willy@infradead.org>
> ---
>  mm/memory.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/memory.c b/mm/memory.c
> index e11ca9dd823f..ce8c90b752be 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1451,7 +1451,7 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
>         spinlock_t *ptl;
>
>         retval = -EINVAL;
> -       if (PageAnon(page))
> +       if (PageAnon(page) || PageSlab(page))

Are there other types that should not get mapped? (Or better yet, is
there a whitelist of those that are okay to be mapped?)

Either way, this sounds good. :)

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

>                 goto out;
>         retval = -ENOMEM;
>         flush_dcache_page(page);
> --
> 2.20.1
>


-- 
Kees Cook
