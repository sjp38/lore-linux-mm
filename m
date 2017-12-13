Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 57E366B025F
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 09:47:03 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id 74so1303534otv.10
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 06:47:03 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 3si651614otc.364.2017.12.13.06.47.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 06:47:02 -0800 (PST)
Date: Wed, 13 Dec 2017 15:46:54 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH RT] mm/slub: close possible memory-leak in
 kmem_cache_alloc_bulk()
Message-ID: <20171213154654.2971ef2a@redhat.com>
In-Reply-To: <20171213140555.s4hzg3igtjfgaueh@linutronix.de>
References: <20171213140555.s4hzg3igtjfgaueh@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, brouer@redhat.com, Rao Shoaib <rao.shoaib@oracle.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Wed, 13 Dec 2017 15:05:55 +0100
Sebastian Andrzej Siewior <bigeasy@linutronix.de> wrote:

> Under certain circumstances we could leak elements which were moved to
> the local "to_free" list. The damage is limited since I can't find any
> users here.
> 
> Cc: stable-rt@vger.kernel.org
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
> Jesper: There are no users of kmem_cache_alloc_bulk() and kfree_bulk().
> Only kmem_cache_free_bulk() is used since it was introduced. Do you
> think that it would make sense to remove those?

I would like to keep them.

Rao Shoaib (Cc'ed) is/was working on a patchset for RCU-bulk-free that
used the kfree_bulk() API.

I plan to use kmem_cache_alloc_bulk() in the bpf-map "cpumap", for bulk
allocating SKBs during dequeue of XDP frames.  (My original bulk alloc
SKBs use-case during NAPI/softirq was never merged).


>  mm/slub.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index ffd2fa0f415e..9053e929ce9d 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3240,6 +3240,7 @@ int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
>  	return i;
>  error:
>  	local_irq_enable();
> +	free_delayed(&to_free);
>  	slab_post_alloc_hook(s, flags, i, p);
>  	__kmem_cache_free_bulk(s, i, p);
>  	return 0;

I've not seen free_delayed() before... and my cscope cannot find it...

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
