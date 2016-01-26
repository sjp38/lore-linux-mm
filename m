Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id E86066B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 13:19:13 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id 123so117545647wmz.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 10:19:13 -0800 (PST)
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com. [195.75.94.106])
        by mx.google.com with ESMTPS id u128si5893145wmd.39.2016.01.26.10.19.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 10:19:13 -0800 (PST)
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Tue, 26 Jan 2016 18:19:12 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 94E1417D8056
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 18:19:18 +0000 (GMT)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0QIJAXr10748348
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 18:19:10 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0QHJBbw012903
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 10:19:11 -0700
Date: Tue, 26 Jan 2016 19:19:03 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH/RFC 3/3] s390: query dynamic DEBUG_PAGEALLOC setting
Message-ID: <20160126181903.GB4671@osiris>
References: <1453799905-10941-1-git-send-email-borntraeger@de.ibm.com>
 <1453799905-10941-4-git-send-email-borntraeger@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453799905-10941-4-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org

On Tue, Jan 26, 2016 at 10:18:25AM +0100, Christian Borntraeger wrote:
> We can use debug_pagealloc_enabled() to check if we can map
> the identity mapping with 1MB/2GB pages as well as to print
> the current setting in dump_stack.
> 
> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
> ---
>  arch/s390/kernel/dumpstack.c |  4 +++-
>  arch/s390/mm/vmem.c          | 10 ++++------
>  2 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/arch/s390/kernel/dumpstack.c b/arch/s390/kernel/dumpstack.c
> index dc8e204..a1c0530 100644
> --- a/arch/s390/kernel/dumpstack.c
> +++ b/arch/s390/kernel/dumpstack.c
> @@ -11,6 +11,7 @@
>  #include <linux/export.h>
>  #include <linux/kdebug.h>
>  #include <linux/ptrace.h>
> +#include <linux/mm.h>
>  #include <linux/module.h>
>  #include <linux/sched.h>
>  #include <asm/processor.h>
> @@ -186,7 +187,8 @@ void die(struct pt_regs *regs, const char *str)
>  	printk("SMP ");
>  #endif
>  #ifdef CONFIG_DEBUG_PAGEALLOC
> -	printk("DEBUG_PAGEALLOC");
> +	printk("DEBUG_PAGEALLOC(%s)",
> +		debug_pagealloc_enabled() ? "enabled" : "disabled");
>  #endif

I'd prefer if you change this to

	if (debug_pagealloc_enabled())
		printk("DEBUG_PAGEALLOC");

That way we can get rid of yet another ifdef. Having
"DEBUG_PAGEALLOC(disabled)" doesn't seem to be very helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
