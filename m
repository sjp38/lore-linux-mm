Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 677416B0073
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 22:13:58 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id eu11so15788657pac.7
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 19:13:58 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id zc3si1118729pbb.136.2015.02.12.19.13.56
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 19:13:57 -0800 (PST)
Date: Fri, 13 Feb 2015 12:16:14 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/4] mm: cma: add currently allocated CMA buffers list to
 debugfs
Message-ID: <20150213031613.GJ6592@js1304-P5Q-DELUXE>
References: <cover.1423777850.git.s.strogin@partner.samsung.com>
 <c4f408198ec7ea7656ae29220c1f96081bd2ade5.1423777850.git.s.strogin@partner.samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c4f408198ec7ea7656ae29220c1f96081bd2ade5.1423777850.git.s.strogin@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

On Fri, Feb 13, 2015 at 01:15:41AM +0300, Stefan Strogin wrote:
>  static int cma_debugfs_get(void *data, u64 *val)
>  {
>  	unsigned long *p = data;
> @@ -125,6 +221,52 @@ static int cma_alloc_write(void *data, u64 val)
>  
>  DEFINE_SIMPLE_ATTRIBUTE(cma_alloc_fops, NULL, cma_alloc_write, "%llu\n");
>  
> +static int cma_buffers_read(struct file *file, char __user *userbuf,
> +				size_t count, loff_t *ppos)
> +{
> +	struct cma *cma = file->private_data;
> +	struct cma_buffer *cmabuf;
> +	struct stack_trace trace;
> +	char *buf;
> +	int ret, n = 0;
> +
> +	if (*ppos < 0 || !count)
> +		return -EINVAL;
> +
> +	buf = kmalloc(count, GFP_KERNEL);
> +	if (!buf)
> +		return -ENOMEM;

Is count limited within proper size boundary for kmalloc()?
If it can exceed page size, using vmalloc() is better than this.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
