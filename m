Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CBA46B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 03:43:08 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id hb5so81068079wjc.2
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 00:43:08 -0800 (PST)
Received: from mail-wj0-f195.google.com (mail-wj0-f195.google.com. [209.85.210.195])
        by mx.google.com with ESMTPS id lg5si23466545wjc.131.2016.12.07.00.43.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 00:43:07 -0800 (PST)
Received: by mail-wj0-f195.google.com with SMTP id he10so34273868wjc.2
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 00:43:07 -0800 (PST)
Date: Wed, 7 Dec 2016 09:43:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v3] mm: use READ_ONCE in page_cpupid_xchg_last()
Message-ID: <20161207084305.GA20350@dhcp22.suse.cz>
References: <584523E4.9030600@huawei.com>
 <58461A0A.3070504@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58461A0A.3070504@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>

On Tue 06-12-16 09:53:14, Xishi Qiu wrote:
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
> +		old_flags = flags = READ_ONCE(page->flags);
>  		last_cpupid = page_cpupid_last(page);

what prevents compiler from doing?
		old_flags = READ_ONCE(page->flags);
		flags = READ_ONCE(page->flags);

Or this doesn't matter?

>  
>  		flags &= ~(LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT);
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
