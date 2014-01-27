Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4F0356B0036
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 03:00:13 -0500 (EST)
Received: by mail-qa0-f47.google.com with SMTP id j5so6894771qaq.34
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 00:00:13 -0800 (PST)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id w8si7998047qag.70.2014.01.27.00.00.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Jan 2014 00:00:12 -0800 (PST)
Date: Sun, 26 Jan 2014 23:03:31 -0500
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] mm: bring back /sys/kernel/mm
Message-ID: <20140127040330.GA17584@windriver.com>
References: <alpine.LSU.2.11.1401261849120.1259@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1401261849120.1259@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

[[PATCH] mm: bring back /sys/kernel/mm] On 26/01/2014 (Sun 18:52) Hugh Dickins wrote:

> Commit da29bd36224b ("mm/mm_init.c: make creation of the mm_kobj happen
> earlier than device_initcall") changed to pure_initcall(mm_sysfs_init).
> 
> That's too early: mm_sysfs_init() depends on core_initcall(ksysfs_init)
> to have made the kernel_kobj directory "kernel" in which to create "mm".
> 
> Make it postcore_initcall(mm_sysfs_init).  We could use core_initcall(),
> and depend upon Makefile link order kernel/ mm/ fs/ ipc/ security/ ...
> as core_initcall(debugfs_init) and core_initcall(securityfs_init) do;
> but better not.

Agreed, N+1 is better than link order.  I guess it silently fails then,
with /sys/kernel/mm missing as the symptom?  I'd booted i386 and ppc
and didn't spot this, unfortunately...  wondering now if there was a
hint in dmesg that I simply failed to notice.

> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Thanks,
Paul.

> ---
> 
>  mm/mm_init.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- 3.13.0+/mm/mm_init.c	2014-01-23 21:51:26.004001378 -0800
> +++ linux/mm/mm_init.c	2014-01-26 18:06:40.488488209 -0800
> @@ -202,4 +202,4 @@ static int __init mm_sysfs_init(void)
>  
>  	return 0;
>  }
> -pure_initcall(mm_sysfs_init);
> +postcore_initcall(mm_sysfs_init);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
