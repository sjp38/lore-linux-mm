Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id ACDED6B0038
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 03:31:27 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id he10so19963769wjc.6
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 00:31:27 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p123si11849323wmg.154.2016.12.05.00.31.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Dec 2016 00:31:26 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB58TStu112469
	for <linux-mm@kvack.org>; Mon, 5 Dec 2016 03:31:25 -0500
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2750kgf4bg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 05 Dec 2016 03:31:24 -0500
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Mon, 5 Dec 2016 01:31:24 -0700
Subject: Re: [RFC PATCH] mm: use ACCESS_ONCE in page_cpupid_xchg_last()
References: <584523E4.9030600@huawei.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Mon, 5 Dec 2016 09:31:18 +0100
MIME-Version: 1.0
In-Reply-To: <584523E4.9030600@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <26c66f28-d836-4d6e-fb40-3e2189a540ed@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>

On 12/05/2016 09:23 AM, Xishi Qiu wrote:
> By reading the code, I find the following code maybe optimized by
> compiler, maybe page->flags and old_flags use the same register,
> so use ACCESS_ONCE in page_cpupid_xchg_last() to fix the problem.

please use READ_ONCE instead of ACCESS_ONCE for future patches.

> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
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
> +		old_flags = flags = ACCESS_ONCE(page->flags);
>  		last_cpupid = page_cpupid_last(page);
> 
>  		flags &= ~(LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT);


I dont thing that this is actually a problem. The code below does  

   } while (unlikely(cmpxchg(&page->flags, old_flags, flags) != old_flags))

and the cmpxchg should be an atomic op that should already take care of everything
(page->flags is passed as a pointer).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
