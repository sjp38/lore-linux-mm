Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 455636B0038
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 22:39:16 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o1so87144665qkd.3
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 19:39:16 -0700 (PDT)
Received: from mail-qk0-x23a.google.com (mail-qk0-x23a.google.com. [2607:f8b0:400d:c09::23a])
        by mx.google.com with ESMTPS id p126si1844360qkc.244.2016.08.30.19.39.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 19:39:15 -0700 (PDT)
Received: by mail-qk0-x23a.google.com with SMTP id t7so20732079qkh.0
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 19:39:15 -0700 (PDT)
Date: Tue, 30 Aug 2016 19:39:14 -0700 (PDT)
From: amanda4ray@gmail.com
Message-Id: <cd3db61c-a193-4a3a-a74e-7a440aa74744@googlegroups.com>
In-Reply-To: <1470063563-96266-1-git-send-email-glider@google.com>
References: <1470063563-96266-1-git-send-email-glider@google.com>
Subject: Re: [PATCH] kasan: avoid overflowing quarantine size on low memory
 systems
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_3204_1895713932.1472611154832"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kasan-dev <kasan-dev@googlegroups.com>
Cc: dvyukov@google.com, kcc@google.com, aryabinin@virtuozzo.com, adech.fo@gmail.com, cl@linux.com, akpm@linux-foundation.org, rostedt@goodmis.org, js1304@gmail.com, iamjoonsoo.kim@lge.com, kuthonuzo.luruo@hpe.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

------=_Part_3204_1895713932.1472611154832
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On Monday, August 1, 2016 at 10:59:29 AM UTC-4, Alexander Potapenko wrote:
> If the total amount of memory assigned to quarantine is less than the
> amount of memory assigned to per-cpu quarantines, |new_quarantine_size|
> may overflow. Instead, set it to zero.
> 
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
> +		new_quarantine_size = 0;
> +	} else {
> +		new_quarantine_size -= percpu_quarantines;
> +	}
>  	WRITE_ONCE(quarantine_size, new_quarantine_size);
>  
>  	last = global_quarantine.head;
> -- 
> 2.8.0.rc3.226.g39d4020



On Monday, August 1, 2016 at 10:59:29 AM UTC-4, Alexander Potapenko wrote:
> If the total amount of memory assigned to quarantine is less than the
> amount of memory assigned to per-cpu quarantines, |new_quarantine_size|
> may overflow. Instead, set it to zero.
> 
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
> +		new_quarantine_size = 0;
> +	} else {
> +		new_quarantine_size -= percpu_quarantines;
> +	}
>  	WRITE_ONCE(quarantine_size, new_quarantine_size);
>  
>  	last = global_quarantine.head;
> -- 
> 2.8.0.rc3.226.g39d4020
------=_Part_3204_1895713932.1472611154832--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
