Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 609826B0035
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 21:22:16 -0400 (EDT)
Received: by mail-we0-f175.google.com with SMTP id k48so9025831wev.20
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 18:22:15 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bv5si592650wib.12.2014.06.30.18.22.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jun 2014 18:22:14 -0700 (PDT)
Date: Mon, 30 Jun 2014 21:21:46 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] hwpoison: Fix race with changing page during offlining v2
Message-ID: <20140701012146.GA23311@nhori.redhat.com>
References: <1404174736-17480-1-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404174736-17480-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andi Kleen <ak@linux.intel.com>

On Mon, Jun 30, 2014 at 05:32:16PM -0700, Andi Kleen wrote:
> From: Andi Kleen <ak@linux.intel.com>
> 
> When a hwpoison page is locked it could change state
> due to parallel modifications.  Check after the lock
> if the page is still the same compound page.
> 
> [v2: Removed earlier non LRU check which should be already
> covered elsewhere]
> 
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Is it -stable matter?
Maybe 2.6.38+ can profit from this.

Thanks,
Naoya Horiguchi

> ---
>  mm/memory-failure.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index cd8989c..99e5077 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1168,6 +1168,16 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>  	lock_page(hpage);
>  
>  	/*
> +	 * The page could have changed compound pages during the locking.
> +	 * If this happens just bail out.
> +	 */
> +	if (compound_head(p) != hpage) {
> +		action_result(pfn, "different compound page after locking", IGNORED);
> +		res = -EBUSY;
> +		goto out;
> +	}
> +
> +	/*
>  	 * We use page flags to determine what action should be taken, but
>  	 * the flags can be modified by the error containment action.  One
>  	 * example is an mlocked page, where PG_mlocked is cleared by
> -- 
> 1.9.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
