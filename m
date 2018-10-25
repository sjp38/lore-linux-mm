Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 655E16B02B5
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 14:44:44 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id y8-v6so6698158ioc.14
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 11:44:44 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0010.hostedemail.com. [216.40.44.10])
        by mx.google.com with ESMTPS id k7-v6si1495690itb.20.2018.10.25.11.44.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 11:44:43 -0700 (PDT)
Message-ID: <e0cd65fdd6afc17b2be9b3ac64d50b95b2c2f32e.camel@perches.com>
Subject: Re: [PATCH] mm/page_owner: use vmalloc instead of kmalloc
From: Joe Perches <joe@perches.com>
Date: Thu, 25 Oct 2018 11:44:38 -0700
In-Reply-To: <1540492481-4144-1-git-send-email-miles.chen@mediatek.com>
References: <1540492481-4144-1-git-send-email-miles.chen@mediatek.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: miles.chen@mediatek.com, Matthias Brugger <matthias.bgg@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org, linux-arm-kernel@lists.infradead.org

On Fri, 2018-10-26 at 02:34 +0800, miles.chen@mediatek.com wrote:
> From: Miles Chen <miles.chen@mediatek.com>
> 
> The kbuf used by page owner is allocated by kmalloc(),
> which means it can use only normal memory and there might
> be a "out of memory" issue when we're out of normal memory.
> 
> Use vmalloc() so we can also allocate kbuf from highmem
> on 32bit kernel.

If this is really necessary, using kvmalloc/kvfree would
be better as the vmalloc space is also limited.

> diff --git a/mm/page_owner.c b/mm/page_owner.c
[]
> @@ -1,7 +1,6 @@
>  // SPDX-License-Identifier: GPL-2.0
>  #include <linux/debugfs.h>
>  #include <linux/mm.h>
> -#include <linux/slab.h>
>  #include <linux/uaccess.h>
>  #include <linux/bootmem.h>
>  #include <linux/stacktrace.h>
> @@ -10,6 +9,7 @@
>  #include <linux/migrate.h>
>  #include <linux/stackdepot.h>
>  #include <linux/seq_file.h>
> +#include <linux/vmalloc.h>
>  
>  #include "internal.h"
>  
> @@ -351,7 +351,7 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
>  		.skip = 0
>  	};
>  
> -	kbuf = kmalloc(count, GFP_KERNEL);
> +	kbuf = vmalloc(count);
>  	if (!kbuf)
>  		return -ENOMEM;
>  
> @@ -397,11 +397,11 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
>  	if (copy_to_user(buf, kbuf, ret))
>  		ret = -EFAULT;
>  
> -	kfree(kbuf);
> +	vfree(kbuf);
>  	return ret;
>  
>  err:
> -	kfree(kbuf);
> +	vfree(kbuf);
>  	return -ENOMEM;
>  }
>  
