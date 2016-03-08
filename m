Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 998896B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 10:32:34 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id p65so154776516wmp.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 07:32:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kv8si4474175wjb.17.2016.03.08.07.32.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Mar 2016 07:32:33 -0800 (PST)
Subject: Re: [PATCH] mm: slub: Ensure that slab_unlock() is atomic
References: <1457447457-25878-1-git-send-email-vgupta@synopsys.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56DEF08D.607@suse.cz>
Date: Tue, 8 Mar 2016 16:32:29 +0100
MIME-Version: 1.0
In-Reply-To: <1457447457-25878-1-git-send-email-vgupta@synopsys.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>, linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Noam Camus <noamc@ezchip.com>, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org

On 03/08/2016 03:30 PM, Vineet Gupta wrote:
> We observed livelocks on ARC SMP setup when running hackbench with SLUB.
> This hardware configuration lacks atomic instructions (LLOCK/SCOND) thus
> kernel resorts to a central @smp_bitops_lock to protect any R-M-W ops
> suh as test_and_set_bit()

Sounds like this architecture should then redefine __clear_bit_unlock
and perhaps other non-atomic __X_bit() variants to be atomic, and not
defer this requirement to places that use the API?

> The spinlock itself is implemented using Atomic [EX]change instruction
> which is always available.
> 
> The race happened when both cores tried to slab_lock() the same page.
> 
>    c1		    c0
> -----------	-----------
> slab_lock
> 		slab_lock
> slab_unlock
> 		Not observing the unlock
> 
> This in turn happened because slab_unlock() doesn't serialize properly
> (doesn't use atomic clear) with a concurrent running
> slab_lock()->test_and_set_bit()
> 
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Noam Camus <noamc@ezchip.com>
> Cc: <stable@vger.kernel.org>
> Cc: <linux-mm@kvack.org>
> Cc: <linux-kernel@vger.kernel.org>
> Cc: <linux-snps-arc@lists.infradead.org>
> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
> ---
>  mm/slub.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index d8fbd4a6ed59..b7d345a508dc 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -345,7 +345,7 @@ static __always_inline void slab_lock(struct page *page)
>  static __always_inline void slab_unlock(struct page *page)
>  {
>  	VM_BUG_ON_PAGE(PageTail(page), page);
> -	__bit_spin_unlock(PG_locked, &page->flags);
> +	bit_spin_unlock(PG_locked, &page->flags);
>  }
>  
>  static inline void set_page_slub_counters(struct page *page, unsigned long counters_new)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
