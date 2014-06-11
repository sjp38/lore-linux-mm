Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id E5A3F6B0142
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 23:32:23 -0400 (EDT)
Received: by mail-qa0-f45.google.com with SMTP id hw13so10373244qab.18
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 20:32:23 -0700 (PDT)
Received: from n23.mail01.mtsvc.net (mailout32.mail01.mtsvc.net. [216.70.64.70])
        by mx.google.com with ESMTPS id 3si7780599qau.90.2014.06.10.20.32.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jun 2014 20:32:23 -0700 (PDT)
Message-ID: <5397CDC3.1050809@hurleysoftware.com>
Date: Tue, 10 Jun 2014 23:32:19 -0400
From: Peter Hurley <peter@hurleysoftware.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] vmalloc: use rcu list iterator to reduce vmap_area_lock
 contention
References: <1402453146-10057-1-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1402453146-10057-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Richard Yao <ryao@gentoo.org>, Eric Dumazet <eric.dumazet@gmail.com>

On 06/10/2014 10:19 PM, Joonsoo Kim wrote:
> Richard Yao reported a month ago that his system have a trouble
> with vmap_area_lock contention during performance analysis
> by /proc/meminfo. Andrew asked why his analysis checks /proc/meminfo
> stressfully, but he didn't answer it.
>
> https://lkml.org/lkml/2014/4/10/416
>
> Although I'm not sure that this is right usage or not, there is a solution
> reducing vmap_area_lock contention with no side-effect. That is just
> to use rcu list iterator in get_vmalloc_info().
>
> rcu can be used in this function because all RCU protocol is already
> respected by writers, since Nick Piggin commit db64fe02258f1507e13fe5
> ("mm: rewrite vmap layer") back in linux-2.6.28

While rcu list traversal over the vmap_area_list is safe, this may
arrive at different results than the spinlocked version. The rcu list
traversal version will not be a 'snapshot' of a single, valid instant
of the entire vmap_area_list, but rather a potential amalgam of
different list states.

This is because the vmap_area_list can continue to change during
list traversal.

Regards,
Peter Hurley

> Specifically :
>     insertions use list_add_rcu(),
>     deletions use list_del_rcu() and kfree_rcu().
>
> Note the rb tree is not used from rcu reader (it would not be safe),
> only the vmap_area_list has full RCU protection.
>
> Note that __purge_vmap_area_lazy() already uses this rcu protection.
>
>          rcu_read_lock();
>          list_for_each_entry_rcu(va, &vmap_area_list, list) {
>                  if (va->flags & VM_LAZY_FREE) {
>                          if (va->va_start < *start)
>                                  *start = va->va_start;
>                          if (va->va_end > *end)
>                                  *end = va->va_end;
>                          nr += (va->va_end - va->va_start) >> PAGE_SHIFT;
>                          list_add_tail(&va->purge_list, &valist);
>                          va->flags |= VM_LAZY_FREEING;
>                          va->flags &= ~VM_LAZY_FREE;
>                  }
>          }
>          rcu_read_unlock();
>
> v2: add more commit description from Eric
>
> [edumazet@google.com: add more commit description]
> Reported-by: Richard Yao <ryao@gentoo.org>
> Acked-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index f64632b..fdbb116 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2690,14 +2690,14 @@ void get_vmalloc_info(struct vmalloc_info *vmi)
>
>   	prev_end = VMALLOC_START;
>
> -	spin_lock(&vmap_area_lock);
> +	rcu_read_lock();
>
>   	if (list_empty(&vmap_area_list)) {
>   		vmi->largest_chunk = VMALLOC_TOTAL;
>   		goto out;
>   	}
>
> -	list_for_each_entry(va, &vmap_area_list, list) {
> +	list_for_each_entry_rcu(va, &vmap_area_list, list) {
>   		unsigned long addr = va->va_start;
>
>   		/*
> @@ -2724,7 +2724,7 @@ void get_vmalloc_info(struct vmalloc_info *vmi)
>   		vmi->largest_chunk = VMALLOC_END - prev_end;
>
>   out:
> -	spin_unlock(&vmap_area_lock);
> +	rcu_read_unlock();
>   }
>   #endif
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
