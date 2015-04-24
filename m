Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 757CD6B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 20:42:42 -0400 (EDT)
Received: by qku63 with SMTP id 63so21571967qku.3
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 17:42:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q12si9841412qkh.83.2015.04.23.17.42.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Apr 2015 17:42:41 -0700 (PDT)
Message-ID: <55399166.8050709@redhat.com>
Date: Thu, 23 Apr 2015 19:42:14 -0500
From: Dean Nelson <dnelson@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm/hwpoison-inject: fix refcounting in no-injection
 case
References: <1429236509-8796-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1429236509-8796-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 04/16/2015 09:08 PM, Naoya Horiguchi wrote:
> Hwpoison injection via debugfs:hwpoison/corrupt-pfn takes a refcount of
> the target page. But current code doesn't release it if the target page
> is not supposed to be injected, which results in memory leak.
> This patch simply adds the refcount releasing code.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Dean Nelson <dnelson@redhat.com>


> ---
>   mm/hwpoison-inject.c | 7 +++++--
>   1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git v4.0.orig/mm/hwpoison-inject.c v4.0/mm/hwpoison-inject.c
> index 329caf56df22..2b3f933e3282 100644
> --- v4.0.orig/mm/hwpoison-inject.c
> +++ v4.0/mm/hwpoison-inject.c
> @@ -40,7 +40,7 @@ static int hwpoison_inject(void *data, u64 val)
>   	 * This implies unable to support non-LRU pages.
>   	 */
>   	if (!PageLRU(p) && !PageHuge(p))
> -		return 0;
> +		goto put_out;
>   
>   	/*
>   	 * do a racy check with elevated page count, to make sure PG_hwpoison
> @@ -52,11 +52,14 @@ static int hwpoison_inject(void *data, u64 val)
>   	err = hwpoison_filter(hpage);
>   	unlock_page(hpage);
>   	if (err)
> -		return 0;
> +		goto put_out;
>   
>   inject:
>   	pr_info("Injecting memory failure at pfn %#lx\n", pfn);
>   	return memory_failure(pfn, 18, MF_COUNT_INCREASED);
> +put_out:
> +	put_page(hpage);
> +	return 0;
>   }
>   
>   static int hwpoison_unpoison(void *data, u64 val)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
