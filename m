Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A475F6B03BA
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 13:18:55 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id c1so16241729ioc.20
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 10:18:55 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o65si3338263ioi.217.2017.03.30.10.18.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 10:18:54 -0700 (PDT)
Date: Thu, 30 Mar 2017 10:18:46 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 4/4] mm/vmalloc: remove vfree_atomic()
Message-ID: <20170330171845.GA19841@bombadil.infradead.org>
References: <20170330102719.13119-1-aryabinin@virtuozzo.com>
 <20170330102719.13119-4-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170330102719.13119-4-aryabinin@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: akpm@linux-foundation.org, penguin-kernel@I-love.SAKURA.ne.jp, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, hpa@zytor.com, chris@chris-wilson.co.uk, hch@lst.de, mingo@elte.hu, jszhang@marvell.com, joelaf@google.com, joaodias@google.com, tglx@linutronix.de

On Thu, Mar 30, 2017 at 01:27:19PM +0300, Andrey Ryabinin wrote:
> vfree() can be used in any atomic context and there is no
> vfree_atomic() callers left, so let's remove it.

We might still get warnings though.

> @@ -1588,9 +1556,11 @@ void vfree(const void *addr)
>  
>  	if (!addr)
>  		return;
> -	if (unlikely(in_interrupt()))
> -		__vfree_deferred(addr);
> -	else
> +	if (unlikely(in_interrupt())) {
> +		struct vfree_deferred *p = this_cpu_ptr(&vfree_deferred);
> +		if (llist_add((struct llist_node *)addr, &p->list))
> +			schedule_work(&p->wq);
> +	} else
>  		__vunmap(addr, 1);
>  }
>  EXPORT_SYMBOL(vfree);

If I disable preemption, then call vfree(), in_interrupt() will not be
true (I've only incremented preempt_count()), then __vunmap() calls
remove_vm_area() which calls might_sleep(), which will warn.

So I think this check needs to change from in_interrupt() to in_atomic().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
