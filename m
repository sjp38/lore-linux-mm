Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4C60E6B0038
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 11:35:16 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 144so20600733pfv.5
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 08:35:16 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0113.outbound.protection.outlook.com. [104.47.1.113])
        by mx.google.com with ESMTPS id n3si571707plb.230.2016.11.22.08.35.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 Nov 2016 08:35:15 -0800 (PST)
Subject: Re: [PATCH 07/10] mm: warn about vfree from atomic context
References: <1479474236-4139-1-git-send-email-hch@lst.de>
 <1479474236-4139-8-git-send-email-hch@lst.de>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <996e56cb-137f-cd3e-eb69-e9ef03ad75c4@virtuozzo.com>
Date: Tue, 22 Nov 2016 19:35:34 +0300
MIME-Version: 1.0
In-Reply-To: <1479474236-4139-8-git-send-email-hch@lst.de>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, akpm@linux-foundation.org
Cc: joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

On 11/18/2016 04:03 PM, Christoph Hellwig wrote:
> We can't handle vfree itself from atomic context, but callers
> can explicitly use vfree_atomic instead, which defers the actual
> vfree to a workqueue.  Unfortunately in_atomic does not work
> on non-preemptible kernels, so we can't just do the right thing
> by default.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  mm/vmalloc.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 80f3fae..e2030b4 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1530,6 +1530,7 @@ void vfree_atomic(const void *addr)
>  void vfree(const void *addr)
>  {
>  	BUG_ON(in_nmi());
> +	WARN_ON_ONCE(in_atomic());

This one is wrong. We still can call vfree() from interrupt context.
So WARN_ON_ONCE(in_atomic() && !in_interrupt()) would be correct,
but also redundant. DEBUG_ATOMIC_SLEEP=y should catch illegal vfree() calls.
Let's just drop this patch, ok?



>  	kmemleak_free(addr);
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
