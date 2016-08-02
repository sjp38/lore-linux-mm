Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 649326B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 05:58:58 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id n69so364500358ion.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 02:58:58 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30133.outbound.protection.outlook.com. [40.107.3.133])
        by mx.google.com with ESMTPS id w9si844950oie.126.2016.08.02.02.58.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 02:58:57 -0700 (PDT)
Subject: Re: [PATCH] kasan: avoid overflowing quarantine size on low memory
 systems
References: <1470063563-96266-1-git-send-email-glider@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <57A06F23.9080804@virtuozzo.com>
Date: Tue, 2 Aug 2016 13:00:03 +0300
MIME-Version: 1.0
In-Reply-To: <1470063563-96266-1-git-send-email-glider@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, dvyukov@google.com, kcc@google.com, adech.fo@gmail.com, cl@linux.com, akpm@linux-foundation.org, rostedt@goodmis.org, js1304@gmail.com, iamjoonsoo.kim@lge.com, kuthonuzo.luruo@hpe.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 08/01/2016 05:59 PM, Alexander Potapenko wrote:
> If the total amount of memory assigned to quarantine is less than the
> amount of memory assigned to per-cpu quarantines, |new_quarantine_size|
> may overflow. Instead, set it to zero.
> 

Just curious, how did find this?
Overflow is possible if system has more than 32 cpus per GB of memory. AFIAK this quite unusual. 

> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Fixes: 55834c59098d ("mm: kasan: initial memory quarantine
> implementation")
> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---
>  mm/kasan/quarantine.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
> index 65793f1..416d3b0 100644
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
> @@ -214,7 +214,15 @@ void quarantine_reduce(void)
>  	 */
>  	new_quarantine_size = (READ_ONCE(totalram_pages) << PAGE_SHIFT) /
>  		QUARANTINE_FRACTION;
> -	new_quarantine_size -= QUARANTINE_PERCPU_SIZE * num_online_cpus();
> +	percpu_quarantines = QUARANTINE_PERCPU_SIZE * num_online_cpus();
> +	if (new_quarantine_size < percpu_quarantines) {
> +		WARN_ONCE(1,
> +			"Too little memory, disabling global KASAN quarantine.\n",
> +		);

Why WARN? I'd suggest pr_warn_once();

> +		new_quarantine_size = 0;
> +	} else {
> +		new_quarantine_size -= percpu_quarantines;
> +	}
>  	WRITE_ONCE(quarantine_size, new_quarantine_size);
>  
>  	last = global_quarantine.head;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
