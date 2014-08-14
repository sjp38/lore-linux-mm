Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 514AD6B0037
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 09:05:02 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id hi2so2257878wib.17
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 06:05:01 -0700 (PDT)
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
        by mx.google.com with ESMTPS id gm4si6692129wib.2.2014.08.14.06.04.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 Aug 2014 06:04:57 -0700 (PDT)
Received: by mail-we0-f181.google.com with SMTP id k48so1055026wev.12
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 06:04:55 -0700 (PDT)
Message-ID: <53ECB3F5.9020001@plexistor.com>
Date: Thu, 14 Aug 2014 16:04:53 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [RFC 5/9] SQUASHME: prd: Last fixes for partitions
References: <53EB5536.8020702@gmail.com> <53EB5709.4090401@plexistor.com>
In-Reply-To: <53EB5709.4090401@plexistor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

On 08/13/2014 03:16 PM, Boaz Harrosh wrote:
> From: Boaz Harrosh <boaz@plexistor.com>
> 
> This streamlines prd with the latest brd code.
> 
> In prd we do not allocate new devices dynamically on devnod
> access, because we need parameterization of each device. So
> the dynamic allocation in prd_init_one is removed.
> 
> Therefor prd_init_one only called from prd_prob is moved
> there, now that it is small.
> 
> And other small fixes regarding partitions
> 
> Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
> ---
>  drivers/block/prd.c | 47 ++++++++++++++++++++++++-----------------------
>  1 file changed, 24 insertions(+), 23 deletions(-)
> 
> diff --git a/drivers/block/prd.c b/drivers/block/prd.c
> index 62af81e..c4aeba7 100644
> --- a/drivers/block/prd.c
> +++ b/drivers/block/prd.c
> @@ -218,13 +218,13 @@ static long prd_direct_access(struct block_device *bdev, sector_t sector,
>  {
>  	struct prd_device *prd = bdev->bd_disk->private_data;
>  
> -	if (!prd)
> +	if (unlikely(!prd))
>  		return -ENODEV;
>  
>  	*kaddr = prd_lookup_pg_addr(prd, sector);
>  	*pfn = prd_lookup_pfn(prd, sector);
>  
> -	return size;
> +	return min_t(long, size, prd->size);

This is off course a BUG need to subtract offset, will send version 2

Boaz
<>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
