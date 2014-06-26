Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6A78D6B0031
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 02:10:31 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id x19so2632625ier.16
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 23:10:31 -0700 (PDT)
Received: from mail-ie0-x22c.google.com (mail-ie0-x22c.google.com [2607:f8b0:4001:c03::22c])
        by mx.google.com with ESMTPS id j1si682667igx.5.2014.06.25.23.10.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 23:10:30 -0700 (PDT)
Received: by mail-ie0-f172.google.com with SMTP id lx4so2619419iec.17
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 23:10:30 -0700 (PDT)
Date: Wed, 25 Jun 2014 23:10:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [mmotm:master 155/319] kernel/printk/printk.c:269:37: error:
 'CONFIG_LOG_CPU_MAX_BUF_SHIFT' undeclared
In-Reply-To: <20140626022455.GC27687@wotan.suse.de>
Message-ID: <alpine.DEB.2.02.1406252308160.3960@chino.kir.corp.google.com>
References: <53ab75fb.TL6r6DI5RYoz6W9P%fengguang.wu@intel.com> <20140626022455.GC27687@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@suse.com>
Cc: kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Petr Mladek <pmladek@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Thu, 26 Jun 2014, Luis R. Rodriguez wrote:

> diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> index 83f7a95..65ed0a6 100644
> --- a/kernel/printk/printk.c
> +++ b/kernel/printk/printk.c
> @@ -266,7 +266,11 @@ static u32 clear_idx;
>  #define LOG_ALIGN __alignof__(struct printk_log)
>  #endif
>  #define __LOG_BUF_LEN (1 << CONFIG_LOG_BUF_SHIFT)
> +#if defined(CONFIG_LOG_CPU_MAX_BUF_SHIFT)
>  #define __LOG_CPU_MAX_BUF_LEN (1 << CONFIG_LOG_CPU_MAX_BUF_SHIFT)
> +#else
> +#define __LOG_CPU_MAX_BUF_LEN 1
> +#endif
>  static char __log_buf[__LOG_BUF_LEN] __aligned(LOG_ALIGN);
>  static char *log_buf = __log_buf;
>  static u32 log_buf_len = __LOG_BUF_LEN;

No, I think this would be much cleaner to just define 
CONFIG_LOG_CPU_MAX_BUF_SHIFT unconditionally to 0 when !SMP || BASE_SMALL 
and otherwise allow it to be configured according to the allowed range.

The verbosity of this configuration option is just downright excessive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
