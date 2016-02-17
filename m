Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id E41306B0253
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 19:18:46 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id g62so214814759wme.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 16:18:46 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x13si26789983wjw.168.2016.02.16.16.18.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 16:18:45 -0800 (PST)
Date: Tue, 16 Feb 2016 16:18:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] devm_memremap_release: fix memremap'd addr handling
Message-Id: <20160216161843.25aaac7046c7a79e1713c8a2@linux-foundation.org>
In-Reply-To: <1455640227-21459-1-git-send-email-toshi.kani@hpe.com>
References: <1455640227-21459-1-git-send-email-toshi.kani@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: dan.j.williams@intel.com, linux-nvdimm@ml01.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>

On Tue, 16 Feb 2016 09:30:27 -0700 Toshi Kani <toshi.kani@hpe.com> wrote:

> The pmem driver calls devm_memremap() to map a persistent memory
> range.  When the pmem driver is unloaded, this memremap'd range
> is not released.
> 
> Fix devm_memremap_release() to handle a given memremap'd address
> properly.
> 
> ...
>
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -114,7 +114,7 @@ EXPORT_SYMBOL(memunmap);
>  
>  static void devm_memremap_release(struct device *dev, void *res)
>  {
> -	memunmap(res);
> +	memunmap(*(void **)res);
>  }
>  

Huh.  So what happens?  memunmap() decides it isn't a vmalloc address
and we leak a vma?

I'll add a cc:stable to this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
