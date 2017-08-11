Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 25A2C6B02F3
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 11:56:55 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id v49so19504361qtc.2
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 08:56:55 -0700 (PDT)
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com. [209.85.220.170])
        by mx.google.com with ESMTPS id i194si1096659qki.188.2017.08.11.08.56.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 08:56:54 -0700 (PDT)
Received: by mail-qk0-f170.google.com with SMTP id u139so22578355qka.1
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 08:56:54 -0700 (PDT)
Subject: Re: [PATCH] mm: cma: fix stack corruption due to sprintf usage
References: <1502446217-21840-1-git-send-email-guptap@codeaurora.org>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <687e393b-b74f-5999-90a5-26dcb26c7df7@redhat.com>
Date: Fri, 11 Aug 2017 08:56:50 -0700
MIME-Version: 1.0
In-Reply-To: <1502446217-21840-1-git-send-email-guptap@codeaurora.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Gupta <guptap@codeaurora.org>, akpm@linux-foundation.org, l.stach@pengutronix.de, gregkh@linuxfoundation.org
Cc: linux-mm@kvack.org

On 08/11/2017 03:10 AM, Prakash Gupta wrote:
> name[] in cma_debugfs_add_one() can only accommodate 16 chars including
> NULL to store sprintf output.  It's common for cma device name to be larger
> than 15 chars. This can cause stack corrpution. If the gcc stack protector
> is turned on, this can cause a panic due to stack corruption.
> 
> Below is one example trace:
> 
> Kernel panic - not syncing: stack-protector: Kernel stack is corrupted in:
> ffffff8e69a75730
> Call trace:
>   [<ffffff8e68289504>] dump_backtrace+0x0/0x2c4
>   [<ffffff8e682897e8>] show_stack+0x20/0x28
>   [<ffffff8e685ea808>] dump_stack+0xb8/0xf4
>   [<ffffff8e683c454c>] panic+0x154/0x2b0
>   [<ffffff8e682a724c>] print_tainted+0x0/0xc0
>   [<ffffff8e69a75730>] cma_debugfs_init+0x274/0x290
>   [<ffffff8e682839ec>] do_one_initcall+0x5c/0x168
>   [<ffffff8e69a50e24>] kernel_init_freeable+0x1c8/0x280
> 
> Fix the short sprintf buffer in cma_debugfs_add_one() by using scnprintf()
> instead of sprintf().
> 

Acked-by: Laura Abbott <labbott@redhat.com>

> fixes: f318dd083c81 ("cma: Store a name in the cma structure")
> Signed-off-by: Prakash Gupta <guptap@codeaurora.org>
> ---
>  mm/cma_debug.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/cma_debug.c b/mm/cma_debug.c
> index 595b757..c03ccbc 100644
> --- a/mm/cma_debug.c
> +++ b/mm/cma_debug.c
> @@ -167,7 +167,7 @@ static void cma_debugfs_add_one(struct cma *cma, int idx)
>  	char name[16];
>  	int u32s;
>  
> -	sprintf(name, "cma-%s", cma->name);
> +	scnprintf(name, sizeof(name), "cma-%s", cma->name);
>  
>  	tmp = debugfs_create_dir(name, cma_debugfs_root);
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
