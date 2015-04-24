Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id D519A6B0038
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 20:42:46 -0400 (EDT)
Received: by qcyk17 with SMTP id k17so18557227qcy.1
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 17:42:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 202si9826899qht.82.2015.04.23.17.42.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Apr 2015 17:42:46 -0700 (PDT)
Message-ID: <5539916E.80809@redhat.com>
Date: Thu, 23 Apr 2015 19:42:22 -0500
From: Dean Nelson <dnelson@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm/hwpoison-inject: check PageLRU of hpage
References: <1429236509-8796-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1429236509-8796-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1429236509-8796-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 04/16/2015 09:08 PM, Naoya Horiguchi wrote:
> Hwpoison injector checks PageLRU of the raw target page to find out whether
> the page is an appropriate target, but current code now filters out thp tail
> pages, which prevents us from testing for such cases via this interface.
> So let's check hpage instead of p.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Dean Nelson <dnelson@redhat.com>


> ---
>   mm/hwpoison-inject.c | 6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git v4.0.orig/mm/hwpoison-inject.c v4.0/mm/hwpoison-inject.c
> index 2b3f933e3282..4ca5fe0042e1 100644
> --- v4.0.orig/mm/hwpoison-inject.c
> +++ v4.0/mm/hwpoison-inject.c
> @@ -34,12 +34,12 @@ static int hwpoison_inject(void *data, u64 val)
>   	if (!hwpoison_filter_enable)
>   		goto inject;
>   
> -	if (!PageLRU(p) && !PageHuge(p))
> -		shake_page(p, 0);
> +	if (!PageLRU(hpage) && !PageHuge(p))
> +		shake_page(hpage, 0);
>   	/*
>   	 * This implies unable to support non-LRU pages.
>   	 */
> -	if (!PageLRU(p) && !PageHuge(p))
> +	if (!PageLRU(hpage) && !PageHuge(p))
>   		goto put_out;
>   
>   	/*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
