Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 933A36B0038
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 15:38:59 -0400 (EDT)
Received: by wicfv8 with SMTP id fv8so90457216wic.0
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 12:38:59 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id z19si23162333wij.114.2015.10.21.12.38.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 12:38:58 -0700 (PDT)
Date: Wed, 21 Oct 2015 15:38:52 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: vmpressure: fix scan window after SWAP_CLUSTER_MAX
 increase
Message-ID: <20151021193852.GA13511@cmpxchg.org>
References: <1445278381-21033-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1445278381-21033-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Oct 19, 2015 at 02:13:01PM -0400, Johannes Weiner wrote:
> mm-increase-swap_cluster_max-to-batch-tlb-flushes.patch changed
> SWAP_CLUSTER_MAX from 32 pages to 256 pages, inadvertantly switching
> the scan window for vmpressure detection from 2MB to 16MB. Revert.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/vmpressure.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index c5afd57..74f206b 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -38,7 +38,7 @@
>   * TODO: Make the window size depend on machine size, as we do for vmstat
>   * thresholds. Currently we set it to 512 pages (2MB for 4KB pages).
>   */
> -static const unsigned long vmpressure_win = SWAP_CLUSTER_MAX * 16;
> +static const unsigned long vmpressure_win = SWAP_CLUSTER_MAX;

Argh, Mel's patch sets SWAP_CLUSTER_MAX to 256, so this should be
SWAP_CLUSTER_MAX * 2 to retain the 512 pages scan window.

Andrew could you please update this fix in-place? Otherwise I'll
resend a corrected version.

Thanks, and sorry about that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
