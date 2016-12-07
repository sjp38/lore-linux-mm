Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1D56B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 03:39:48 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i131so34462538wmf.3
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 00:39:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v2si23443515wjh.194.2016.12.07.00.39.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Dec 2016 00:39:47 -0800 (PST)
Subject: Re: [RFC PATCH v3] mm: use READ_ONCE in page_cpupid_xchg_last()
References: <584523E4.9030600@huawei.com> <58461A0A.3070504@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <70a14036-a8e7-473f-3dc1-2517ffbe27e9@suse.cz>
Date: Wed, 7 Dec 2016 09:39:32 +0100
MIME-Version: 1.0
In-Reply-To: <58461A0A.3070504@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>

On 12/06/2016 02:53 AM, Xishi Qiu wrote:
> A compiler could re-read "old_flags" from the memory location after reading
> and calculation "flags" and passes a newer value into the cmpxchg making 
> the comparison succeed while it should actually fail.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> Suggested-by: Christian Borntraeger <borntraeger@de.ibm.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/mmzone.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/mmzone.c b/mm/mmzone.c
> index 5652be8..e0b698e 100644
> --- a/mm/mmzone.c
> +++ b/mm/mmzone.c
> @@ -102,7 +102,7 @@ int page_cpupid_xchg_last(struct page *page, int cpupid)
>  	int last_cpupid;
>  
>  	do {
> -		old_flags = flags = page->flags;
> +		old_flags = flags = READ_ONCE(page->flags);
>  		last_cpupid = page_cpupid_last(page);
>  
>  		flags &= ~(LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
