Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B3E096B0038
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 04:44:18 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x23so356785151pgx.6
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 01:44:18 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y189si14031865pgb.131.2016.12.05.01.44.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Dec 2016 01:44:18 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB59e59u119921
	for <linux-mm@kvack.org>; Mon, 5 Dec 2016 04:44:17 -0500
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2753tgn4wg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 05 Dec 2016 04:44:17 -0500
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Mon, 5 Dec 2016 04:44:16 -0500
Subject: Re: [RFC PATCH v2] mm: use ACCESS_ONCE in page_cpupid_xchg_last()
References: <584523E4.9030600@huawei.com>
 <26c66f28-d836-4d6e-fb40-3e2189a540ed@de.ibm.com>
 <0cc3c2bb-e292-2d7b-8d44-16c8e6c19899@de.ibm.com>
 <584532DF.7080805@huawei.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Mon, 5 Dec 2016 10:44:09 +0100
MIME-Version: 1.0
In-Reply-To: <584532DF.7080805@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <a38eab74-42a4-5133-2eca-712358834315@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>

On 12/05/2016 10:26 AM, Xishi Qiu wrote:
> A compiler could re-read "old_flags" from the memory location after reading
> and calculation "flags" and passes a newer value into the cmpxchg making 
> the comparison succeed while it should actually fail.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> Suggested-by: Christian Borntraeger <borntraeger@de.ibm.com>
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

please use READ_ONCE.

>  		last_cpupid = page_cpupid_last(page);
> 
>  		flags &= ~(LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
