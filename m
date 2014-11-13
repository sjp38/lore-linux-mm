Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 401336B00DC
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 21:53:43 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id r5so2232559qcx.25
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 18:53:43 -0800 (PST)
Received: from relay.variantweb.net ([104.131.199.242])
        by mx.google.com with ESMTP id k10si44516339qae.72.2014.11.12.18.53.40
        for <linux-mm@kvack.org>;
        Wed, 12 Nov 2014 18:53:40 -0800 (PST)
Received: from mail (unknown [10.42.10.20])
	by relay.variantweb.net (Postfix) with ESMTP id 06E67101378
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 21:53:37 -0500 (EST)
Date: Wed, 12 Nov 2014 20:53:37 -0600
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH] mm/zswap: unregister zswap_cpu_notifier_block in cleanup
 procedure
Message-ID: <20141113025337.GA9068@medulla.variantweb.net>
References: <1415532143-4409-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1415532143-4409-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mahendran Ganesh <opensource.ganesh@gmail.com>
Cc: minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Nov 09, 2014 at 07:22:23PM +0800, Mahendran Ganesh wrote:
> In zswap_cpu_init(), the code does not unregister *zswap_cpu_notifier_block*
> during the cleanup procedure.

This is not needed.  If we are in the cleanup code, we never got to the
__register_cpu_notifier() call.

Thanks,
Seth

> 
> This patch fix this issue.
> 
> Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
> ---
>  mm/zswap.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/zswap.c b/mm/zswap.c
> index ea064c1..51a2c45 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -404,6 +404,7 @@ static int zswap_cpu_init(void)
>  cleanup:
>  	for_each_online_cpu(cpu)
>  		__zswap_cpu_notifier(CPU_UP_CANCELED, cpu);
> +	__unregister_cpu_notifier(&zswap_cpu_notifier_block);
>  	cpu_notifier_register_done();
>  	return -ENOMEM;
>  }
> -- 
> 1.7.9.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
