Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 21DEC6B0033
	for <linux-mm@kvack.org>; Sat,  2 Dec 2017 19:56:05 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id s12so7430851otc.5
        for <linux-mm@kvack.org>; Sat, 02 Dec 2017 16:56:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t7si3228682oit.346.2017.12.02.16.56.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Dec 2017 16:56:04 -0800 (PST)
Date: Sun, 3 Dec 2017 08:55:56 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH] fix system_state checking in early_ioremap
Message-ID: <20171203005556.GA2378@dhcp-128-65.nay.redhat.com>
References: <20171202033430.GA2619@dhcp-128-65.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171202033430.GA2619@dhcp-128-65.nay.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, bp@suse.de, mingo@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-efi@vger.kernel.org

On 12/02/17 at 11:34am, Dave Young wrote:
> Since below commit earlyprintk=efi,keep does not work any more with a warning
> in mm/early_ioremap.c: WARN_ON(system_state >= SYSTEM_RUNNING):

Should be WARN_ON(system_state != SYSTEM_BOOTING) in original code, copy
paste wrongly, if need a resend please let me know :)

> commit 69a78ff226fe ("init: Introduce SYSTEM_SCHEDULING state")
> 
> Reason is the the original assumption is SYSTEM_BOOTING equal to
> system_state < SYSTEM_RUNNING. But with commit 69a78ff226fe it is not true
> any more. Change the WARN_ON to check system_state >= SYSTEM_RUNNING instead.
> 
> Signed-off-by: Dave Young <dyoung@redhat.com>
> ---
>  mm/early_ioremap.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-x86.orig/mm/early_ioremap.c
> +++ linux-x86/mm/early_ioremap.c
> @@ -111,7 +111,7 @@ __early_ioremap(resource_size_t phys_add
>  	enum fixed_addresses idx;
>  	int i, slot;
>  
> -	WARN_ON(system_state != SYSTEM_BOOTING);
> +	WARN_ON(system_state >= SYSTEM_RUNNING);
>  
>  	slot = -1;
>  	for (i = 0; i < FIX_BTMAPS_SLOTS; i++) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
