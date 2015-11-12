Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id EB3526B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 10:55:51 -0500 (EST)
Received: by wmww144 with SMTP id w144so206474752wmw.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 07:55:51 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id g18si38617974wmd.74.2015.11.12.07.55.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 07:55:50 -0800 (PST)
Received: by wmww144 with SMTP id w144so206474062wmw.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 07:55:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1447341424-11466-1-git-send-email-jmarchan@redhat.com>
References: <1447341424-11466-1-git-send-email-jmarchan@redhat.com>
Date: Thu, 12 Nov 2015 18:55:50 +0300
Message-ID: <CAPAsAGxNWhHSNHZWfaOb3NmbubSBGRd8O81L5rw1wMs-n_UgmA@mail.gmail.com>
Subject: Re: [PATCH] mm: vmalloc: don't remove inexistent guard hole in remove_vm_area()
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

2015-11-12 18:17 GMT+03:00 Jerome Marchand <jmarchan@redhat.com>:
> Commit 71394fe50146 ("mm: vmalloc: add flag preventing guard hole
> allocation") missed a spot. Currently remove_vm_area() decreases
> vm->size to remove the guard hole page, even when it isn't present.
> This patch only decreases vm->size when VM_NO_GUARD isn't set.
>
> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
> ---
>  mm/vmalloc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index d045634..1388c3d 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1443,7 +1443,8 @@ struct vm_struct *remove_vm_area(const void *addr)
>                 vmap_debug_free_range(va->va_start, va->va_end);
>                 kasan_free_shadow(vm);
>                 free_unmap_vmap_area(va);
> -               vm->size -= PAGE_SIZE;
> +               if (!(vm->flags & VM_NO_GUARD))
> +                       vm->size -= PAGE_SIZE;
>

I'd fix this in another way. I think that remove_vm_area() shouldn't
change vm's size, IMO it doesn't make sense.
The only caller who cares about vm's size after removing is __vunmap():
         area = remove_vm_area(addr);
         ....
         debug_check_no_locks_freed(addr, area->size);
         debug_check_no_obj_freed(addr, area->size);

We already have proper get_vm_area_size() helper which takes
VM_NO_GUARD into account.
So I think we should use that helper for debug_check_no_*() and just
remove 'vm->size -= PAGE_SIZE;' line
from remove_vm_area()



>                 return vm;
>         }
> --
> 2.4.3
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
