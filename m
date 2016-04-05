Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3FE6B0005
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 04:00:15 -0400 (EDT)
Received: by mail-pf0-f171.google.com with SMTP id c20so5933227pfc.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 01:00:15 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id 14si6569699pfp.31.2016.04.05.01.00.14
        for <linux-mm@kvack.org>;
        Tue, 05 Apr 2016 01:00:14 -0700 (PDT)
Message-ID: <1459843262.5564.4.camel@linux.intel.com>
Subject: Re: [PATCH v2 2/3] mm/vmap: Add a notifier for when we run out of
 vmap address space
From: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Date: Tue, 05 Apr 2016 11:01:02 +0300
In-Reply-To: <1459777603-23618-3-git-send-email-chris@chris-wilson.co.uk>
References: <1459777603-23618-1-git-send-email-chris@chris-wilson.co.uk>
	 <1459777603-23618-3-git-send-email-chris@chris-wilson.co.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>, intel-gfx@lists.freedesktop.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Roman Peniaev <r.peniaev@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tvrtko Ursulin <tvrtko.ursulin@intel.com>

On ma, 2016-04-04 at 14:46 +0100, Chris Wilson wrote:
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
> v2: Guard the blocking notifier call with gfpflags_allow_blocking()
> v3: Correct typo in forward declaration and move to head of file
> 
> Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Roman Peniaev <r.peniaev@gmail.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Acked-by: Andrew Morton <akpm@linux-foundation.org> # for inclusion via DRM
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>

Reviewed-by: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>

> Cc: Tvrtko Ursulin <tvrtko.ursulin@intel.com>
> ---
> A include/linux/vmalloc.h |A A 4 ++++
> A mm/vmalloc.cA A A A A A A A A A A A | 27 +++++++++++++++++++++++++++
> A 2 files changed, 31 insertions(+)
> 
> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index d1f1d338af20..8b51df3ab334 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -8,6 +8,7 @@
> A #include 
> A 
> A struct vm_area_struct;		/* vma defining user mapping in mm_types.h */
> +struct notifier_block;		/* in notifier.h */
> A 
> A /* bits in flags of vmalloc's vm_struct below */
> A #define VM_IOREMAP		0x00000001	/* ioremap() and friends */
> @@ -187,4 +188,7 @@ pcpu_free_vm_areas(struct vm_struct **vms, int nr_vms)
> A #define VMALLOC_TOTAL 0UL
> A #endif
> A 
> +int register_vmap_purge_notifier(struct notifier_block *nb);
> +int unregister_vmap_purge_notifier(struct notifier_block *nb);
> +
> A #endif /* _LINUX_VMALLOC_H */
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index ae7d20b447ff..293889d7f482 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -21,6 +21,7 @@
> A #include 
> A #include 
> A #include 
> +#include 
> A #include 
> A #include 
> A #include 
> @@ -344,6 +345,8 @@ static void __insert_vmap_area(struct vmap_area *va)
> A 
> A static void purge_vmap_area_lazy(void);
> A 
> +static BLOCKING_NOTIFIER_HEAD(vmap_notify_list);
> +
> A /*
> A  * Allocate a region of KVA of the specified size and alignment, within the
> A  * vstart and vend.
> @@ -363,6 +366,8 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
> A 	BUG_ON(offset_in_page(size));
> A 	BUG_ON(!is_power_of_2(align));
> A 
> +	might_sleep_if(gfpflags_allow_blocking(gfp_mask));
> +
> A 	va = kmalloc_node(sizeof(struct vmap_area),
> A 			gfp_mask & GFP_RECLAIM_MASK, node);
> A 	if (unlikely(!va))
> @@ -468,6 +473,16 @@ overflow:
> A 		purged = 1;
> A 		goto retry;
> A 	}
> +
> +	if (gfpflags_allow_blocking(gfp_mask)) {
> +		unsigned long freed = 0;
> +		blocking_notifier_call_chain(&vmap_notify_list, 0, &freed);
> +		if (freed > 0) {
> +			purged = 0;
> +			goto retry;
> +		}
> +	}
> +
> A 	if (printk_ratelimit())
> A 		pr_warn("vmap allocation for size %lu failed: use vmalloc= to increase size\n",
> A 			size);
> @@ -475,6 +490,18 @@ overflow:
> A 	return ERR_PTR(-EBUSY);
> A }
> A 
> +int register_vmap_purge_notifier(struct notifier_block *nb)
> +{
> +	return blocking_notifier_chain_register(&vmap_notify_list, nb);
> +}
> +EXPORT_SYMBOL_GPL(register_vmap_purge_notifier);
> +
> +int unregister_vmap_purge_notifier(struct notifier_block *nb)
> +{
> +	return blocking_notifier_chain_unregister(&vmap_notify_list, nb);
> +}
> +EXPORT_SYMBOL_GPL(unregister_vmap_purge_notifier);
> +
> A static void __free_vmap_area(struct vmap_area *va)
> A {
> A 	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
-- 
Joonas Lahtinen
Open Source Technology Center
Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
