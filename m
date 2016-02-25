Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id EDF186B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 20:42:54 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id yy13so22596633pab.3
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 17:42:54 -0800 (PST)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id n88si8658304pfb.139.2016.02.24.17.42.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 17:42:54 -0800 (PST)
Received: by mail-pf0-x230.google.com with SMTP id x65so23150368pfb.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 17:42:54 -0800 (PST)
Date: Wed, 24 Feb 2016 17:42:52 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, memory hotplug: print more failure information for
 online_pages
In-Reply-To: <1456362446.22049.20.camel@gmail.com>
Message-ID: <alpine.DEB.2.10.1602241740390.12657@chino.kir.corp.google.com>
References: <1456300925-20415-1-git-send-email-slaoub@gmail.com> <alpine.DEB.2.10.1602241331570.5955@chino.kir.corp.google.com> <1456362446.22049.20.camel@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 25 Feb 2016, Chen Yucong wrote:

> > Please explain how the conversion from KERN_DEBUG to KERN_INFO level is 
> > better?
> 
> Like __offline_pages(), printk() in online_pages() is used for reporting
> an failed addition rather than debug information.
> Another reason is that pr_debug() is not an exact equivalent of 
> printk(KERN_DEBUG ...)
> 
> /* If you are writing a driver, please use dev_dbg instead */
> #if defined(CONFIG_DYNAMIC_DEBUG)
> /* dynamic_pr_debug() uses pr_fmt() internally so we don't need it here
> */
> #define pr_debug(fmt, ...) \
>         dynamic_pr_debug(fmt, ##__VA_ARGS__)
> #elif defined(DEBUG)
> #define pr_debug(fmt, ...) \
>         printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__)
> #else
> #define pr_debug(fmt, ...) \
>         no_printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__)
> #endif
> 

My question is why in either __offline_pages() (today's code) or 
__online_pages() (your patch) we would want to leave behind a message in 
the kernel log to indicate failure?  I don't think it's helpful to spam 
the kernel log with unnecessary information when onlining or offlining 
failed.  Userspace already knows the range that it attempted to online or 
offline, it already has the correct error value, why spam it?

A patch to move __offline_pages() to not print this with KERN_INFO would 
make more sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
