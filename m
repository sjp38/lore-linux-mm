Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 64B796B0279
	for <linux-mm@kvack.org>; Thu, 25 May 2017 04:43:02 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id v195so80188089qka.1
        for <linux-mm@kvack.org>; Thu, 25 May 2017 01:43:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s129si2444254qkc.31.2017.05.25.01.43.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 01:43:01 -0700 (PDT)
Date: Thu, 25 May 2017 16:42:44 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH -mm 06/13] block: Increase BIO_MAX_PAGES to PMD size if
 THP_SWAP enabled
Message-ID: <20170525084238.GA15737@ming.t460p>
References: <20170525064635.2832-1-ying.huang@intel.com>
 <20170525064635.2832-7-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170525064635.2832-7-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Jens Axboe <axboe@kernel.dk>, Ming Lei <tom.leiming@gmail.com>, Shaohua Li <shli@fb.com>, linux-block@vger.kernel.org

On Thu, May 25, 2017 at 02:46:28PM +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> In this patch, BIO_MAX_PAGES is changed from 256 to HPAGE_PMD_NR if
> CONFIG_THP_SWAP is enabled and HPAGE_PMD_NR > 256.  This is to support
> THP (Transparent Huge Page) swap optimization.  Where the THP will be
> write to disk as a whole instead of HPAGE_PMD_NR normal pages to batch
> the various operations during swap.  And the page is likely to be
> written to disk to free memory when system memory goes really low, the
> memory pool need to be used to avoid deadlock.
> 
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Ming Lei <tom.leiming@gmail.com>
> Cc: Shaohua Li <shli@fb.com>
> Cc: linux-block@vger.kernel.org
> ---
>  include/linux/bio.h | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/include/linux/bio.h b/include/linux/bio.h
> index d1b04b0e99cf..314796486507 100644
> --- a/include/linux/bio.h
> +++ b/include/linux/bio.h
> @@ -38,7 +38,15 @@
>  #define BIO_BUG_ON
>  #endif
>  
> +#ifdef CONFIG_THP_SWAP
> +#if HPAGE_PMD_NR > 256
> +#define BIO_MAX_PAGES		HPAGE_PMD_NR
> +#else
>  #define BIO_MAX_PAGES		256
> +#endif
> +#else
> +#define BIO_MAX_PAGES		256
> +#endif
>  
>  #define bio_prio(bio)			(bio)->bi_ioprio
>  #define bio_set_prio(bio, prio)		((bio)->bi_ioprio = prio)

Last time we discussed we should use multipage bvec for this usage.

I will rebase the last post on v4.12-rc and kick if off again since
the raid cleanup is just done on v4.11.

	http://marc.info/?t=148453679000002&r=1&w=2

Thanks,
Ming

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
