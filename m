Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0D7C26B0038
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 04:44:17 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c85so34928540wmi.6
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 01:44:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v188si57843886wmb.168.2016.12.30.01.44.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Dec 2016 01:44:15 -0800 (PST)
Date: Fri, 30 Dec 2016 10:44:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: cma: print allocation failure reason and bitmap
 status
Message-ID: <20161230094411.GD13301@dhcp22.suse.cz>
References: <CGME20161229022722epcas5p4be0e1924f3c8d906cbfb461cab8f0374@epcas5p4.samsung.com>
 <1482978482-14007-1-git-send-email-jaewon31.kim@samsung.com>
 <20161229091449.GG29208@dhcp22.suse.cz>
 <xa1th95m7r6w.fsf@mina86.com>
 <58660BBE.1040807@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58660BBE.1040807@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>, gregkh@linuxfoundation.org, akpm@linux-foundation.org, labbott@redhat.com, m.szyprowski@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

On Fri 30-12-16 16:24:46, Jaewon Kim wrote:
[...]
> >From 7577cc94da3af27907aa6eec590d2ef51e4b9d80 Mon Sep 17 00:00:00 2001
> From: Jaewon Kim <jaewon31.kim@samsung.com>
> Date: Thu, 29 Dec 2016 11:00:16 +0900
> Subject: [PATCH] mm: cma: print allocation failure reason and bitmap status
> 
> There are many reasons of CMA allocation failure such as EBUSY, ENOMEM, EINTR.
> But we did not know error reason so far. This patch prints the error value.
> 
> Additionally if CONFIG_CMA_DEBUG is enabled, this patch shows bitmap status to
> know available pages. Actually CMA internally try all available regions because
> some regions can be failed because of EBUSY. Bitmap status is useful to know in
> detail on both ENONEM and EBUSY;
>  ENOMEM: not tried at all because of no available region
>          it could be too small total region or could be fragmentation issue
>  EBUSY:  tried some region but all failed
> 
> This is an ENOMEM example with this patch.
> [   13.250961]  [1:   Binder:715_1:  846] cma: cma_alloc: alloc failed, req-size: 256 pages, ret: -12
> Avabile pages also will be shown if CONFIG_CMA_DEBUG is enabled
> [   13.251052]  [1:   Binder:715_1:  846] cma: number of available pages: 4@572+7@585+7@601+8@632+38@730+166@1114+127@1921=>357 pages, total: 2048 pages

please mention how to interpret this information.

some more style suggestions below
> 
> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
> ---
>  mm/cma.c | 29 ++++++++++++++++++++++++++++-
>  1 file changed, 28 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/cma.c b/mm/cma.c
> index c960459..1bcd9db 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -369,7 +369,7 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align)
>      unsigned long start = 0;
>      unsigned long bitmap_maxno, bitmap_no, bitmap_count;
>      struct page *page = NULL;
> -    int ret;
> +    int ret = -ENOMEM;
>  
>      if (!cma || !cma->count)
>          return NULL;
> @@ -427,6 +427,33 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align)
>      trace_cma_alloc(pfn, page, count, align);
>  
>      pr_debug("%s(): returned %p\n", __func__, page);
> +
> +    if (ret != 0)

you can simply do
	if (!ret) {

		pr_info("%s: alloc failed, req-size: %zu pages, ret: %d\n",
			__func__, count, ret);
		debug_show_cma_areas();
	}

	return page;

static void debug_show_cma_areas(void)
{
#ifdef CONFIG_CMA_DEBUG
	unsigned int nr, nr_total = 0;
	unsigned long next_set_bit;

	mutex_lock(&cma->lock);
	pr_info("number of available pages: ");
	start = 0;
	for (;;) {
		bitmap_no = find_next_zero_bit(cma->bitmap, cma->count, start);
		if (bitmap_no >= cma->count)
		break;
		next_set_bit = find_next_bit(cma->bitmap, cma->count, bitmap_no);
		nr = next_set_bit - bitmap_no;
		pr_cont("%s%u@%lu", nr_total ? "+" : "", nr, bitmap_no);
		nr_total += nr;
		start = bitmap_no + nr;
	}
	pr_cont("=>%u pages, total: %lu pages\n", nr_total, cma->count);
	mutex_unlock(&cma->lock);
#endif
}

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
