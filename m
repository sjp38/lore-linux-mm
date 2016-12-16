Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E69CC6B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 00:02:03 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id e9so159202105pgc.5
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 21:02:03 -0800 (PST)
Received: from mgwym04.jp.fujitsu.com (mgwym04.jp.fujitsu.com. [211.128.242.43])
        by mx.google.com with ESMTPS id r11si5785347pfk.40.2016.12.15.21.02.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 21:02:03 -0800 (PST)
Received: from g01jpfmpwkw02.exch.g01.fujitsu.local (g01jpfmpwkw02.exch.g01.fujitsu.local [10.0.193.56])
	by yt-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 4507DAC01D1
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 14:01:47 +0900 (JST)
Message-ID: <585374F0.6040407@jp.fujitsu.com>
Date: Fri, 16 Dec 2016 14:00:32 +0900
From: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] block: avoid incorrect bdi_unregiter call
References: <584101D2.4090200@jp.fujitsu.com>
In-Reply-To: <584101D2.4090200@jp.fujitsu.com>
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-mm@kvack.org, linux-block@vger.kernel.org

Hi Jens,

Could you add this patch for 4.10?

- Masayoshi Mizuma

On Fri, 2 Dec 2016 14:08:34 +0900 Masayoshi Mizuma wrote:
> bdi_unregister() should be called after bdi_register() is called,
> so we should check whether WB_registered flag is set.
> 
> For example of the situation, error path in device driver may call
> blk_cleanup_queue() before the driver calls bdi_register().
> 
> Signed-off-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
> ---
>   mm/backing-dev.c | 3 +++
>   1 file changed, 3 insertions(+)
> 
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 8fde443..f8b07d4 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -853,6 +853,9 @@ static void bdi_remove_from_list(struct backing_dev_info *bdi)
>   
>   void bdi_unregister(struct backing_dev_info *bdi)
>   {
> +	if (!test_bit(WB_registered, &bdi->wb.state))
> +		return;
> +
>   	/* make sure nobody finds us on the bdi_list anymore */
>   	bdi_remove_from_list(bdi);
>   	wb_shutdown(&bdi->wb);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
