Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7A29F6B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 18:50:17 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o124so104896980pfg.1
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 15:50:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z88si50624867pff.218.2016.08.10.15.50.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Aug 2016 15:50:16 -0700 (PDT)
Date: Wed, 10 Aug 2016 15:50:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] kasan: avoid overflowing quarantine size on low
 memory systems
Message-Id: <20160810155015.bffc044a171466b2fdf5195e@linux-foundation.org>
In-Reply-To: <1470133620-28683-1-git-send-email-glider@google.com>
References: <1470133620-28683-1-git-send-email-glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: dvyukov@google.com, kcc@google.com, aryabinin@virtuozzo.com, adech.fo@gmail.com, cl@linux.com, rostedt@goodmis.org, js1304@gmail.com, iamjoonsoo.kim@lge.com, kuthonuzo.luruo@hpe.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue,  2 Aug 2016 12:27:00 +0200 Alexander Potapenko <glider@google.com> wrote:

> If the total amount of memory assigned to quarantine is less than the
> amount of memory assigned to per-cpu quarantines, |new_quarantine_size|
> may overflow. Instead, set it to zero.
> 
> ...
>
> --- a/mm/kasan/quarantine.c
> +++ b/mm/kasan/quarantine.c
> @@ -196,7 +196,7 @@ void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache)
>  
>  void quarantine_reduce(void)
>  {
> -	size_t new_quarantine_size;
> +	size_t new_quarantine_size, percpu_quarantines;
>  	unsigned long flags;
>  	struct qlist_head to_free = QLIST_INIT;
>  	size_t size_to_free = 0;
> @@ -214,7 +214,9 @@ void quarantine_reduce(void)
>  	 */
>  	new_quarantine_size = (READ_ONCE(totalram_pages) << PAGE_SHIFT) /
>  		QUARANTINE_FRACTION;
> -	new_quarantine_size -= QUARANTINE_PERCPU_SIZE * num_online_cpus();
> +	percpu_quarantines = QUARANTINE_PERCPU_SIZE * num_online_cpus();
> +	new_quarantine_size = (new_quarantine_size < percpu_quarantines) ?
> +		0 : new_quarantine_size - percpu_quarantines;
>  	WRITE_ONCE(quarantine_size, new_quarantine_size);
>  
>  	last = global_quarantine.head;

Confused.  Which kernel version is this supposed to apply to?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
