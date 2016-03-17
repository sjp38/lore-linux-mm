Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id AED666B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 08:37:07 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id p65so24122350wmp.1
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 05:37:07 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id s67si2391344wmb.93.2016.03.17.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 05:37:06 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id x188so6466761wmg.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 05:37:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1458215982-13405-1-git-send-email-chris@chris-wilson.co.uk>
References: <1458215982-13405-1-git-send-email-chris@chris-wilson.co.uk>
Date: Thu, 17 Mar 2016 13:37:06 +0100
Message-ID: <CACZ9PQX+E2LscOGyVQ4xZNK3qdYYotq4HiyGc8o+YwoNi-w1Hg@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/vmap: Add a notifier for when we run out of vmap
 address space
From: Roman Peniaev <r.peniaev@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi, Chris.

Comment is below.

On Thu, Mar 17, 2016 at 12:59 PM, Chris Wilson <chris@chris-wilson.co.uk> wrote:
> vmaps are temporary kernel mappings that may be of long duration.
> Reusing a vmap on an object is preferrable for a driver as the cost of
> setting up the vmap can otherwise dominate the operation on the object.
> However, the vmap address space is rather limited on 32bit systems and
> so we add a notification for vmap pressure in order for the driver to
> release any cached vmappings.
>
> The interface is styled after the oom-notifier where the callees are
> passed a pointer to an unsigned long counter for them to indicate if they
> have freed any space.
>
> Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Roman Pen <r.peniaev@gmail.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  include/linux/vmalloc.h |  4 ++++
>  mm/vmalloc.c            | 22 ++++++++++++++++++++++
>  2 files changed, 26 insertions(+)
>
> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index d1f1d338af20..edd676b8e112 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -187,4 +187,8 @@ pcpu_free_vm_areas(struct vm_struct **vms, int nr_vms)
>  #define VMALLOC_TOTAL 0UL
>  #endif
>
> +struct notitifer_block;
> +int register_vmap_purge_notifier(struct notifier_block *nb);
> +int unregister_vmap_purge_notifier(struct notifier_block *nb);
> +
>  #endif /* _LINUX_VMALLOC_H */
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index fb42a5bffe47..fd2ca94c2732 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -21,6 +21,7 @@
>  #include <linux/debugobjects.h>
>  #include <linux/kallsyms.h>
>  #include <linux/list.h>
> +#include <linux/notifier.h>
>  #include <linux/rbtree.h>
>  #include <linux/radix-tree.h>
>  #include <linux/rcupdate.h>
> @@ -344,6 +345,8 @@ static void __insert_vmap_area(struct vmap_area *va)
>
>  static void purge_vmap_area_lazy(void);
>
> +static BLOCKING_NOTIFIER_HEAD(vmap_notify_list);
> +
>  /*
>   * Allocate a region of KVA of the specified size and alignment, within the
>   * vstart and vend.
> @@ -356,6 +359,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
>         struct vmap_area *va;
>         struct rb_node *n;
>         unsigned long addr;
> +       unsigned long freed;
>         int purged = 0;
>         struct vmap_area *first;
>
> @@ -468,6 +472,12 @@ overflow:
>                 purged = 1;
>                 goto retry;
>         }
> +       freed = 0;
> +       blocking_notifier_call_chain(&vmap_notify_list, 0, &freed);

It seems to me that alloc_vmap_area() was designed not to sleep,
at least on GFP_NOWAIT path (__GFP_DIRECT_RECLAIM is not set).

But blocking_notifier_call_chain() might sleep.

Roman.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
