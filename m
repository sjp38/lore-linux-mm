Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 142F66B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 03:11:20 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id r5so4932250qcx.11
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 00:11:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k32si1076023qge.43.2015.01.15.00.11.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 00:11:19 -0800 (PST)
Date: Thu, 15 Jan 2015 09:10:58 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 1/2] mm/slub: optimize alloc/free fastpath by
 removing preemption on/off
Message-ID: <20150115091058.07d0ae25@redhat.com>
In-Reply-To: <1421307633-24045-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1421307633-24045-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rostedt@goodmis.org, Thomas Gleixner <tglx@linutronix.de>, brouer@redhat.com

On Thu, 15 Jan 2015 16:40:32 +0900
Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

[...]
> 
> I saw roughly 5% win in a fast-path loop over kmem_cache_alloc/free
> in CONFIG_PREEMPT. (14.821 ns -> 14.049 ns)
> 
> Below is the result of Christoph's slab_test reported by
> Jesper Dangaard Brouer.
>
[...]

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

> Acked-by: Christoph Lameter <cl@linux.com>
> Tested-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/slub.c |   35 +++++++++++++++++++++++------------
>  1 file changed, 23 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index fe376fe..ceee1d7 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2398,13 +2398,24 @@ redo:
[...]
>  	 */
> -	preempt_disable();
> -	c = this_cpu_ptr(s->cpu_slab);
> +	do {
> +		tid = this_cpu_read(s->cpu_slab->tid);
> +		c = this_cpu_ptr(s->cpu_slab);
> +	} while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid != c->tid));
> +
> +	/*
> +	 * Irqless object alloc/free alogorithm used here depends on sequence

Spelling of algorithm contains a typo ^^ 

> +	 * of fetching cpu_slab's data. tid should be fetched before anything
> +	 * on c to guarantee that object and page associated with previous tid
> +	 * won't be used with current tid. If we fetch tid first, object and
> +	 * page could be one associated with next tid and our alloc/free
> +	 * request will be failed. In this case, we will retry. So, no problem.
> +	 */
> +	barrier();

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
