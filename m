Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7FE526B0171
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 04:30:56 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id g10so736193pdj.15
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 01:30:56 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id lm5si308022pab.182.2014.06.12.01.30.54
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 01:30:55 -0700 (PDT)
Message-ID: <53996544.2050401@cn.fujitsu.com>
Date: Thu, 12 Jun 2014 16:31:00 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 08/10] mm, cma: clean-up cma allocation error path
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com> <1402543307-29800-9-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1402543307-29800-9-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On 06/12/2014 11:21 AM, Joonsoo Kim wrote:
> We can remove one call sites for clear_cma_bitmap() if we first
> call it before checking error number.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

> 
> diff --git a/mm/cma.c b/mm/cma.c
> index 1e1b017..01a0713 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -282,11 +282,12 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
>  		if (ret == 0) {
>  			page = pfn_to_page(pfn);
>  			break;
> -		} else if (ret != -EBUSY) {
> -			clear_cma_bitmap(cma, pfn, count);
> -			break;
>  		}
> +
>  		clear_cma_bitmap(cma, pfn, count);
> +		if (ret != -EBUSY)
> +			break;
> +
>  		pr_debug("%s(): memory range at %p is busy, retrying\n",
>  			 __func__, pfn_to_page(pfn));
>  		/* try again with a bit different memory target */
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
