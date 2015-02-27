Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 00CE46B0071
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 19:07:32 -0500 (EST)
Received: by pablf10 with SMTP id lf10so26472892pab.12
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 16:07:32 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id sp8si7346862pac.126.2015.02.27.16.07.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Feb 2015 16:07:31 -0800 (PST)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/2] kasan, module, vmalloc: rework shadow allocation for modules
In-Reply-To: <1425049816-11385-1-git-send-email-a.ryabinin@samsung.com>
References: <1425049816-11385-1-git-send-email-a.ryabinin@samsung.com>
Date: Sat, 28 Feb 2015 09:31:28 +1030
Message-ID: <87egpbklh3.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>

Andrey Ryabinin <a.ryabinin@samsung.com> writes:
> Current approach in handling shadow memory for modules is broken.
>
> Shadow memory could be freed only after memory shadow corresponds
> it is no longer used.
> vfree() called from interrupt context could use memory its
> freeing to store 'struct llist_node' in it:
>
> void vfree(const void *addr)
> {
> ...
> 	if (unlikely(in_interrupt())) {
> 		struct vfree_deferred *p = this_cpu_ptr(&vfree_deferred);
> 		if (llist_add((struct llist_node *)addr, &p->list))
> 				schedule_work(&p->wq);
>
> Latter this list node used in free_work() which actually frees memory.
> Currently module_memfree() called in interrupt context will free
> shadow before freeing module's memory which could provoke kernel
> crash.
> So shadow memory should be freed after module's memory.
> However, such deallocation order could race with kasan_module_alloc()
> in module_alloc().
>
> Free shadow right before releasing vm area. At this point vfree()'d
> memory is not used anymore and yet not available for other allocations.
> New VM_KASAN flag used to indicate that vm area has dynamically allocated
> shadow memory so kasan frees shadow only if it was previously allocated.
>
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Rusty Russell <rusty@rustcorp.com.au>

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Thanks!
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
