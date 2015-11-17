Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 57A096B0038
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 11:30:10 -0500 (EST)
Received: by wmec201 with SMTP id c201so34368272wme.1
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 08:30:10 -0800 (PST)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id t2si19083422wjx.60.2015.11.17.08.30.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Nov 2015 08:30:09 -0800 (PST)
Received: by wmww144 with SMTP id w144so33731119wmw.0
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 08:30:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1447777222-13396-1-git-send-email-aryabinin@virtuozzo.com>
References: <1447777222-13396-1-git-send-email-aryabinin@virtuozzo.com>
From: Catalin Marinas <catalin.marinas@gmail.com>
Date: Tue, 17 Nov 2015 16:29:49 +0000
Message-ID: <CAHkRjk7_2udHhf-MmsF4uvusYR+b17jLGoL=5OzOdDXQAiC_9w@mail.gmail.com>
Subject: Re: [PATCH] kasan: fix kmemleak false-positive in kasan_module_alloc()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 17 November 2015 at 16:20, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> kasan_module_alloc() allocates shadow memory for module and frees it on module
> unloading. It doesn't store the pointer to allocated shadow memory because
> it could be calculated from the shadowed address, i.e. kasan_mem_to_shadow(addr).
> Since kmemleak cannot find pointer to allocated shadow, it thinks that memory leaked.
> We should tell kmemleak that this is not a leak.
[...]
> @@ -444,6 +445,7 @@ int kasan_module_alloc(void *addr, size_t size)
>
>         if (ret) {
>                 find_vm_area(addr)->flags |= VM_KASAN;
> +               kmemleak_not_leak(ret);
>                 return 0;
>         }

If such memory does not contain any pointers to other objects, you
could use kmemleak_ignore() which would make kmemleak not scan it at
all (slight performance improvement).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
